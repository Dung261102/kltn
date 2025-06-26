// Các thư viện cần thiết
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Thư viện UI chính của Flutter
import 'package:glucose_real_time/ui/theme/theme.dart'; // Tuỳ chỉnh giao diện app
import '../../../services/notification_services.dart'; // Dịch vụ gửi thông báo
import '../../widgets/LineChart.dart'; // Biểu đồ tuyến hiển thị glucose
import '../../widgets/common_appbar.dart'; // AppBar dùng chung cho các màn hình
import 'package:fl_chart/fl_chart.dart'; // Thư viện vẽ biểu đồ tuỳ chỉnh
import 'dart:math'; // Hỗ trợ tạo dữ liệu ngẫu nhiên
import 'dart:async'; // Cho các thao tác bất đồng bộ nếu cần
import 'package:get/get.dart';
import 'package:glucose_real_time/controllers/ble_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:glucose_real_time/controllers/user_controller.dart';
import 'dart:convert';
import 'package:glucose_real_time/rest/socket_service.dart'; // Import SocketService
import 'package:glucose_real_time/controllers/glucose_controller.dart';

// Định nghĩa kiểu dữ liệu đơn giản để lưu lịch sử đo đường huyết
typedef GlucoseRecord = ({DateTime time, int value});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BleController bleController = Get.put(BleController());
  final UserController userController = Get.put(UserController());
  final GlucoseController glucoseController = Get.put(GlucoseController());
  RxBool isMeasuring = false.obs;

  // Thêm SocketService và danh sách dữ liệu glucose
  final SocketService socketService = SocketService();
  int currentGlucose = 0; // Giá trị glucose hiện tại

  @override
  void initState() {
    super.initState();
    getGlucose();
    _loadUserName();
    _loadAvatar();
    _initSocket(); // Khởi tạo và kết nối socket
    testAddSampleGlucoseData(); // Thêm dữ liệu mẫu để test UI ReportPage
  }

  // Hàm khởi tạo socket
  void _initSocket() {
    socketService.connect(
      onConnect: () {
        print("Socket connected!");
      },
      onError: (error) {
        print("Socket error: $error");
      },
    );

    // Lắng nghe sự kiện 'Glucose_SensorData' từ server
    socketService.on('Glucose_SensorData', (data) {
      print('[SOCKET RECEIVED] → Glucose_SensorData: $data');
      if (data != null && data['value'] is int) {
        if (!mounted) return;
        setState(() {
          currentGlucose = data['value'];
          final record = (time: DateTime.now(), value: currentGlucose);
          glucoseController.addRecord(record);
          // Giới hạn lịch sử chỉ 20 điểm gần nhất để biểu đồ không quá dày
          if (glucoseController.glucoseHistory.length > 20) {
            glucoseController.glucoseHistory.removeAt(0);
          }
        });
      }
    });

    // Lắng nghe sự kiện 'Glucose_History' từ server (toàn bộ lịch sử)
    socketService.on('Glucose_History', (data) {
      print('[SOCKET RECEIVED] → Glucose_History: $data');
      if (data is List) {
        if (!mounted) return;
        setState(() {
          final List<GlucoseRecord> list = [];
          for (var item in data) {
            if (item is Map && item['value'] is int && item['created'] != null) {
              list.add((
              time: DateTime.parse(item['created'].toString()),
              value: item['value']
              ));
            }
          }
          glucoseController.setHistory(list);
          if (glucoseController.glucoseHistory.isNotEmpty) {
            currentGlucose = glucoseController.glucoseHistory.last.value;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    socketService.disconnect(); // Ngắt kết nối khi thoát trang
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('username') ?? "User";
    if (!mounted) return;
    userController.setUsername(name);
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAvatar = prefs.getString('avatar');
    final base64Str = prefs.getString('avatar_base64');
    if (base64Str != null && base64Str.isNotEmpty) {
      if (!mounted) return;
      userController.setAvatarBytes(base64Decode(base64Str));
    } else if (savedAvatar != null && savedAvatar.isNotEmpty) {
      if (!mounted) return;
      userController.setAvatarPath(savedAvatar);
    } else {
      if (!mounted) return;
      userController.setAvatarPath("assets/images/profile/avatar.jpg");
    }
  }

  Future<void> getGlucose() async {
    // Lấy dữ liệu từ local (BLE Controller)
    final history = await bleController.getGlucoseHistory();
    for (var record in history) {
      print('🩸 Glucose: ${record.value} mg/dL at ${record.time}');
    }
  }

  // Đánh giá trạng thái đường huyết theo ngưỡng thông thường
  String getGlucoseStatus(int value) {
    if (value < 70) return "🟡 Low";
    if (value > 180) return "🔴 High";
    return "🟢 Normal";
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final NotifyHelper notifyHelper = NotifyHelper();
    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
        title: 'Hi, WelcomeBack',
        subtitle: Obx(() => Text(
          userController.username.value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        )),
      ),
      body: Obx(() {
        final device = bleController.connectedDevice.value;
        final isConnected = device != null;
        // Ưu tiên dữ liệu từ GlucoseController
        final glucoseHistory = glucoseController.glucoseHistory;
        if (glucoseHistory.isNotEmpty) {
          return ListView(
            children: [
              GlucoseLineChartSection(
                data: glucoseHistory,
                title: null,
                showMetrics: false,
              ),
              _buildGlucoseDisplay(glucoseHistory.last.value, isConnected, device?.name ?? '', glucoseHistory.last.time),
              _buildHistoryList(glucoseHistory),
            ],
          );
        }
        // Nếu chưa có dữ liệu WebSocket, kiểm tra BLE
        if (!isConnected) {
          return Center(
            child: Text(
              'No real-time data yet. Please connect to a BLE device to get glucose data.',
              style: subTitleStyle,
              textAlign: TextAlign.center,
            ),
          );
        }
        // Nếu đã kết nối BLE, hiển thị dữ liệu từ BLE
        return ListView(
          children: [
            Obx(() => GlucoseLineChartSection(
              data: bleController.glucoseHistory,
              title: null,
              showMetrics: false,
            )),
            Obx(() => _buildGlucoseDisplay(
              bleController.glucoseHistory.isNotEmpty ? bleController.glucoseHistory.last.value : 0, 
              isConnected, 
              device?.name ?? '', 
              bleController.glucoseHistory.isNotEmpty ? bleController.glucoseHistory.last.time : DateTime.now()
            )),
            // Chỉ Obx cho nút đo glucose
            Obx(() => ElevatedButton.icon(
              onPressed: isMeasuring.value ? null : () async {
                isMeasuring.value = true;
                await bleController.doMeasureGlucose();
                isMeasuring.value = false;
              },
              icon: isMeasuring.value
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(Icons.bloodtype),
              label: Text(isMeasuring.value ? 'Measuring...' : 'Measure Glucose'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
              ),
            )),
            Obx(() => _buildHistoryList(bleController.glucoseHistory)),
          ],
        );
      }),
    );
  }

  Widget _buildGlucoseDisplay(int displayValue, bool isConnected, String deviceName, DateTime measuredTime) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.02),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Glucose',
                    style: headingStyle.copyWith(
                      fontFamily: 'Montserrat',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isConnected)
                    const Icon(Icons.bluetooth_connected, color: Colors.blue, size: 22),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Cột trái: Giá trị glucose
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          //giá trị glucose
                          Text(
                            '$displayValue',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            //đơn vị đo
                            child: Text('mg/dL', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          //thời gian đo
                          Text('Measured at ${_formatTime(measuredTime)}', style: const TextStyle(fontSize: 13, color: Colors.black87, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(width: 32),
                  // Cột phải: Thông tin phụ
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //trạng thái đường huyết
                        Text(
                          getGlucoseStatus(displayValue),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 25),
                        //thông báo kết nối
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            isConnected ? 'Connected: $deviceName' : 'Not connected to device',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isConnected ? Colors.black87 : Colors.red[600],
                            ),
                            maxLines: 1,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sửa lại để nhận history từ controller
  Widget _buildHistoryList(List<({DateTime time, int value})> history) {
    if (history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.history, color: Colors.teal, size: 48),
            const SizedBox(height: 12),
            Text(
              'No glucose history yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(Colors.white, Colors.blueAccent, 0.02)!, // Trắng pha xanh, trắng đậm hơn ở trên
            Colors.blueAccent
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.teal, size: 24),
              const SizedBox(width: 8),
              Text(
                'Measurement History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal[700]),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Recent",
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...history.map((record) => Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: Colors.orange),

                const SizedBox(width: 10),
                Text(
                  '${record.value} mg/dL',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                ),
                const SizedBox(width: 14),
                Text(
                  _formatTime(record.time),
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  //hiển thị lịch sử đo

  Widget _buildRealtimeGlucoseCard() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            Text(
              "Current Glucose Level",
              style: subTitleStyle.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "$currentGlucose",
                  style: headingStyle.copyWith(fontSize: 48, color: Colors.blueAccent),
                ),
                const SizedBox(width: 8),
                Text("mg/dL", style: titleStyle),
              ],
            ),
            const SizedBox(height: 16),
            GlucoseLineChartSection(
              data: glucoseController.glucoseHistory,
              title: null,
              showMetrics: false,
            ),
          ],
        ),
      ),
    );
  }

  // Phương thức hiển thị các thông báo gần đây
  Widget _buildRecentNotifications() {
    return SizedBox.shrink();
  }

  // Dữ liệu glucose giả lập (sẽ được thay bằng dữ liệu từ socket)
  List<GlucoseRecord> _generateRandomData() {
    final Random random = Random();
    return List.generate(20, (index) {
      return (
      time: DateTime.now().subtract(Duration(minutes: (20 - index) * 5)),
      value: 80 + random.nextInt(60),
      );
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: Text(
        'Welcome back!',
        style: headingStyle,
      ),
    );
  }

  Widget _buildHealthTips() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Tip: Stay hydrated and check your glucose regularly!',
          style: subTitleStyle,
        ),
      ),
    );
  }

  // Thêm dữ liệu mẫu nhiều ngày/tháng/năm khác nhau vào glucoseController
  void testAddSampleGlucoseData() {
    final now = DateTime.now();
    final List<GlucoseRecord> samples = [
      // Dữ liệu hôm nay (hiện tại) - sẽ hiển thị ở HomePage và tab Day
      (time: now.subtract(const Duration(hours: 1)), value: 110),
      (time: now.subtract(const Duration(hours: 2)), value: 120),
      (time: now.subtract(const Duration(hours: 3)), value: 115),
      // Dữ liệu tháng này, ngày trước đó
      (time: now.subtract(const Duration(days: 2)), value: 130),
      (time: now.subtract(const Duration(days: 3)), value: 125),
      // Dữ liệu tháng trước
      (time: DateTime(now.year, now.month - 1, 10, 8, 0), value: 140),
      (time: DateTime(now.year, now.month - 1, 12, 9, 0), value: 135),
      // Dữ liệu năm trước
      (time: DateTime(now.year - 1, 5, 15, 7, 0), value: 150),
      (time: DateTime(now.year - 1, 6, 20, 10, 0), value: 145),
      (time: DateTime(now.year - 1, 7, 25, 11, 0), value: 138),
    ];
    glucoseController.setHistory(samples);
  }
}

// Widget chuyển đổi dữ liệu glucoseHistory sang FlSpot và hiển thị bằng GlucoseLineChart



