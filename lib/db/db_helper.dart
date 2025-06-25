import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/task.dart';
import '../models/glucose_data.dart';

class DBHelper {
  static Database? _db;
  static final int _version = 2; // Tăng version để thêm bảng glucose_data
  static final String _tableName = "tasks";
  static final String _glucoseTableName = "glucose_data";

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    }
    try {
      String _path = '${await getDatabasesPath()}glucose_app.db';
      // await deleteDatabase(_path); // Xóa cơ sở dữ liệu
      // String _path = await getDatabasesPath() + 'tasks.db';
      _db = await openDatabase(
        _path,
        version: _version,
        onCreate: (db, version) async {
          print("creating a new database");
          
          // Tạo bảng tasks
          await db.execute(
            "CREATE TABLE $_tableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title STRING, note TEXT, date STRING, "
            "startTime TEXT, endTime TEXT, "
            "remind INTEGER, repeat STRING, "
            "color INTEGER, "
            "isCompleted INTEGER)",
          );
          
          // Tạo bảng glucose_data
          await db.execute(
            "CREATE TABLE $_glucoseTableName("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "userId INTEGER, "
            "glucoseValue INTEGER, "
            "deviceId STRING, "
            "timestamp STRING, "
            "isSynced INTEGER DEFAULT 0)",
          );
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            // Thêm bảng glucose_data nếu upgrade từ version 1
            await db.execute(
              "CREATE TABLE $_glucoseTableName("
              "id INTEGER PRIMARY KEY AUTOINCREMENT, "
              "userId INTEGER, "
              "glucoseValue INTEGER, "
              "deviceId STRING, "
              "timestamp STRING, "
              "isSynced INTEGER DEFAULT 0)",
            );
          }
        },
      );
    } catch (e) {
      print(e);
    }
  }

  // ========== TASK METHODS ==========
  static Future<int> insert(Task? task) async {
    print("insert function called");

    if (_db == null) {
      throw Exception("Database not initialized");
    }
    return await _db!.insert(_tableName, task!.toJson());
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print("query function called");
    return await _db!.query(_tableName);
  }

  static delete (Task task) async{
   return await _db!.delete(_tableName, where: 'id=?', whereArgs: [task.id]);
  }

  static update(int id) async{
    return await _db!.rawUpdate('''
    UPDATE tasks
    SET isCompleted = ?
    WHERE id =?
    
    ''', [1, id]);
  }

  // ========== GLUCOSE DATA METHODS ==========
  
  // Thêm dữ liệu glucose mới
  static Future<int> insertGlucoseData(GlucoseData glucoseData) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    return await _db!.insert(_glucoseTableName, glucoseData.toJson());
  }

  // Lấy tất cả dữ liệu glucose của user
  static Future<List<GlucoseData>> getGlucoseDataByUserId(int userId) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      _glucoseTableName,
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return GlucoseData.fromJson(maps[i]);
    });
  }

  // Lấy dữ liệu glucose chưa đồng bộ
  static Future<List<GlucoseData>> getUnsyncedGlucoseData() async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    final List<Map<String, dynamic>> maps = await _db!.query(
      _glucoseTableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return GlucoseData.fromJson(maps[i]);
    });
  }

  // Đánh dấu dữ liệu đã đồng bộ
  static Future<int> markGlucoseDataAsSynced(int id) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    return await _db!.update(
      _glucoseTableName,
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Xóa dữ liệu glucose cũ (tùy chọn)
  static Future<int> deleteOldGlucoseData(DateTime beforeDate) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    return await _db!.delete(
      _glucoseTableName,
      where: 'timestamp < ?',
      whereArgs: [beforeDate.toIso8601String()],
    );
  }

  // Xóa tất cả dữ liệu glucose của user
  static Future<int> deleteGlucoseDataByUserId(int userId) async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    return await _db!.delete(
      _glucoseTableName,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // ========== UTILITY METHODS ==========
  
  // Xóa toàn bộ dữ liệu (chỉ dùng cho testing)
  static Future<void> clearAllData() async {
    if (_db == null) {
      throw Exception("Database not initialized");
    }
    
    await _db!.delete(_tableName);
    await _db!.delete(_glucoseTableName);
  }
}
