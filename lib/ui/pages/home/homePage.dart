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

// Định nghĩa kiểu dữ liệu đơn giản để lưu lịch sử đo đường huyết
typedef GlucoseRecord = ({DateTime time, int value});

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // final glucoseCollection = FirebaseFirestore.instance.collection('Glucose');
  final BleController bleController = Get.put(BleController());
  RxBool isMeasuring = false.obs;

  @override
  void initState() {
    super.initState();
    getGlucose();
  }

  Future<void> getGlucose() async {
    final glucoseCollection = FirebaseFirestore.instance.collection('Glucose');
    final glucoseSnapshot = await glucoseCollection.get();

    for (var doc in glucoseSnapshot.docs) {
      final data = doc.data(); // data: Map<String, dynamic>

      final Timestamp timestamp = data['Time']; // kiểu Timestamp
      final DateTime time = timestamp.toDate(); // chuyển sang DateTime

      final int glucose = data['GlucoseData']; // hoặc data['glucoseLevel'] tùy tên field

      print('🩸 Glucose: $glucose mg/dL at $time');
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
      ),
      body: Obx(() {
        final history = bleController.glucoseHistory;
        final glucoseData = List<FlSpot>.generate(
          history.length,
              (i) => FlSpot(i.toDouble(), history[i].value.toDouble()),
        );
        final displayValue = history.isNotEmpty ? history.first.value : 0;
        final lastUpdateTime = history.isNotEmpty ? history.first.time : DateTime.now();
        final device = bleController.connectedDevice.value;
        final isConnected = device != null;
        return ListView(
          children: [
            GlucoseLineChart(
              glucoseData: glucoseData,
              lastUpdateTime: lastUpdateTime,
            ),
            _buildGlucoseDisplay(displayValue, isConnected, device?.name ?? ''),
            if (isConnected)
              Obx(() => ElevatedButton.icon(
                onPressed: isMeasuring.value ? null : () async {
                  isMeasuring.value = true;
                  await bleController.doMeasureGlucose();
                  isMeasuring.value = false;
                },
                icon: isMeasuring.value
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.bloodtype),
                label: Text(isMeasuring.value ? 'Đang đo...' : 'Đo Glucose'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 50),
                ),
              )),
            _buildHistoryList(history),
          ],
        );
      }),
    );
  }

  Widget _buildGlucoseDisplay(int displayValue, bool isConnected, String deviceName) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  color: isConnected ? Colors.blue : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 8),
                Text(
                  'Glucose',
                  style: headingStyle,
                ),
                const SizedBox(width: 8),
                if (isConnected)
                  const Icon(
                    Icons.bluetooth_connected,
                    color: Colors.blue,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '$displayValue mg/dL',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: isConnected ? Colors.teal : Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              getGlucoseStatus(displayValue),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              isConnected
                  ? 'Connected: $deviceName'
                  : 'Not connected to device',
              style: TextStyle(
                fontSize: 12,
                color: isConnected ? Colors.grey[600] : Colors.red[300],
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
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: Text(
          'No glucose history yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Measurement History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final record = history[index];
                return ListTile(
                  leading: const Icon(Icons.history, color: Colors.teal),
                  title: Text('${record.value} mg/dL'),
                  subtitle: Text(_formatTime(record.time)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


