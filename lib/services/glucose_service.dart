import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/db_helper.dart';
import '../models/glucose_data.dart';
import '../rest/rest_api.dart';

class GlucoseService {
  static final GlucoseService _instance = GlucoseService._internal();
  factory GlucoseService() => _instance;
  GlucoseService._internal();

  Timer? _syncTimer;
  bool _isSyncing = false;

  // Khởi tạo service
  Future<void> initialize() async {
    // Bắt đầu đồng bộ định kỳ
    _startPeriodicSync();
  }

  // Lưu dữ liệu glucose mới
  Future<void> saveGlucoseData(int glucoseValue, String deviceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userid');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      GlucoseData glucoseData = GlucoseData(
        userId: userId,
        glucoseValue: glucoseValue,
        deviceId: deviceId,
        timestamp: DateTime.now(),
        isSynced: false,
      );

      // Lưu vào database local
      await DBHelper.insertGlucoseData(glucoseData);
      
      print('✅ Glucose data saved locally: $glucoseValue mg/dL');
      
      // Thử đồng bộ ngay lập tức
      await _syncToServer();
      
    } catch (e) {
      print('❌ Error saving glucose data: $e');
    }
  }

  // Lấy dữ liệu glucose của user
  Future<List<GlucoseData>> getUserGlucoseData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userid');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      return await DBHelper.getGlucoseDataByUserId(userId);
    } catch (e) {
      print('❌ Error getting glucose data: $e');
      return [];
    }
  }

  // Load dữ liệu glucose khi đăng nhập lại
  Future<void> loadUserDataOnLogin() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userid');
      
      if (userId == null) {
        print('⚠️ No user ID found, skipping data load');
        return;
      }

      // Load dữ liệu glucose từ database
      List<GlucoseData> glucoseData = await DBHelper.getGlucoseDataByUserId(userId);
      print('📊 Loaded ${glucoseData.length} glucose records for user $userId');
      
      // Bắt đầu đồng bộ nếu có dữ liệu chưa sync
      if (glucoseData.any((data) => !data.isSynced)) {
        print('🔄 Found unsynced data, starting sync...');
        await _syncToServer();
      }
      
    } catch (e) {
      print('❌ Error loading user data on login: $e');
    }
  }

  // Đồng bộ dữ liệu lên server
  Future<void> _syncToServer() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    
    try {
      // Lấy dữ liệu chưa đồng bộ
      List<GlucoseData> unsyncedData = await DBHelper.getUnsyncedGlucoseData();
      
      if (unsyncedData.isEmpty) {
        print('📱 No unsynced data to sync');
        return;
      }

      print('🔄 Syncing ${unsyncedData.length} glucose records...');

      for (GlucoseData data in unsyncedData) {
        try {
          // Gửi dữ liệu lên server
          await sendGlucoseDataToBackend(
            deviceId: data.deviceId,
            glucoseValue: data.glucoseValue,
          );
          
          // Đánh dấu đã đồng bộ
          await DBHelper.markGlucoseDataAsSynced(data.id!);
          
          print('✅ Synced glucose data: ${data.glucoseValue} mg/dL');
          
        } catch (e) {
          print('❌ Failed to sync glucose data ${data.id}: $e');
        }
      }
      
    } catch (e) {
      print('❌ Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Bắt đầu đồng bộ định kỳ
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      _syncToServer();
    });
  }

  // Dừng đồng bộ định kỳ
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // Đồng bộ thủ công
  Future<void> manualSync() async {
    await _syncToServer();
  }

  // Xóa dữ liệu glucose cũ (tùy chọn)
  Future<void> cleanupOldData({int daysToKeep = 30}) async {
    try {
      DateTime cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      int deletedCount = await DBHelper.deleteOldGlucoseData(cutoffDate);
      print('🗑️ Cleaned up $deletedCount old glucose records');
    } catch (e) {
      print('❌ Error cleaning up old data: $e');
    }
  }

  // Xóa tất cả dữ liệu glucose của user hiện tại
  Future<void> clearUserGlucoseData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userid');
      
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Xóa dữ liệu glucose của user
      await DBHelper.deleteGlucoseDataByUserId(userId);
      print('🗑️ Cleared all glucose data for user $userId');
    } catch (e) {
      print('❌ Error clearing user glucose data: $e');
    }
  }

  // Dispose service
  void dispose() {
    stopPeriodicSync();
  }
} 