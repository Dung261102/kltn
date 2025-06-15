// Các thư viện cần thiết
import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart'; // Giao diện tuỳ chỉnh
import '../../../services/notification_services.dart'; // Thông báo push
import '../../widgets/LineChart.dart'; // Widget biểu đồ (nếu dùng riêng)
import '../../widgets/common_appbar.dart'; // AppBar dùng chung
import 'package:fl_chart/fl_chart.dart'; // Thư viện vẽ biểu đồ
import 'dart:math'; // Để tạo dữ liệu giả ngẫu nhiên
import 'dart:async'; // Dùng trong async nếu cần

// Định nghĩa kiểu dữ liệu lịch sử
class GlucoseRecord {
  final DateTime time;
  final int value;

  GlucoseRecord({required this.time, required this.value});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? glucoseValue;
  bool isConnected = false;
  List<FlSpot> glucoseData = [];
  DateTime lastUpdateTime = DateTime.now();
  final Random _random = Random();
  List<GlucoseRecord> history = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    final now = DateTime.now();
    glucoseData = List.generate(5, (index) {
      final time = now.subtract(Duration(minutes: (4 - index) * 5));
      final value = 80 + _random.nextInt(60);
      history.add(GlucoseRecord(time: time, value: value));
      return FlSpot(index.toDouble(), value.toDouble());
    });
    glucoseValue = glucoseData.last.y.toInt();
    lastUpdateTime = now;
  }

  void _connectToDevice() async {
    setState(() {
      isConnected = true;
    });
  }

  void _disconnectFromDevice() async {
    setState(() {
      isConnected = false;
      glucoseValue = null;
    });
  }

  void updateGlucoseReading(int newValue) {
    setState(() {
      final now = DateTime.now();
      glucoseData.add(FlSpot(glucoseData.length.toDouble(), newValue.toDouble()));
      glucoseValue = newValue;
      lastUpdateTime = now;
      history.insert(0, GlucoseRecord(time: now, value: newValue));
      print('New glucose reading: $newValue mg/dL at ${_formatTime(now)}');
    });
  }

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
    final int displayValue = glucoseValue ?? 0;

    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
      ),
      body: ListView(
        children: [
          GlucoseLineChart( // Gọi widget đã tách riêng
            glucoseData: glucoseData,
            lastUpdateTime: lastUpdateTime,
          ),
          _buildGlucoseDisplay(displayValue),
          _buildBLEConnectionButton(),
          _buildHistoryList(),
        ],
      ),
    );
  }


  Widget _buildGlucoseDisplay(int displayValue) {
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
                  ? 'Last measurement: ${_formatTime(lastUpdateTime)}'
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

  Widget _buildBLEConnectionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ElevatedButton.icon(
        onPressed: isConnected ? _disconnectFromDevice : _connectToDevice,
        icon: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth),
        label: Text(isConnected ? 'Disconnect Device' : 'Connect BLE Device'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected ? Colors.green : Colors.blue,
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
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
