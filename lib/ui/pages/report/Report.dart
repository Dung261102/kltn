import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import '../../../services/notification_services.dart';
import '../../widgets/LineChart.dart';
import '../../widgets/common_appbar.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/controllers/ble_controller.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final BleController bleController = Get.put(BleController());
  final NotifyHelper notifyHelper = NotifyHelper();
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  List<int> _todayGlucoseValues() {
    final now = DateTime.now();
    return bleController.glucoseHistory
        .where((e) => e.time.year == now.year && e.time.month == now.month && e.time.day == now.day)
        .map((e) => e.value)
        .toList();
  }

  int? _todayMaxGlucose() {
    final values = _todayGlucoseValues();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  double? _todayAvgGlucose() {
    final values = _todayGlucoseValues();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(notifyHelper: notifyHelper),
      body: Obx(() {
        final history = bleController.glucoseHistory;
        final glucoseData = List<FlSpot>.generate(
          history.length,
              (i) => FlSpot(i.toDouble(), history[i].value.toDouble()),
        );
        final lastUpdateTime = history.isNotEmpty ? history.first.time : DateTime.now();
        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: [
            _buildDateSelector(),
            GlucoseLineChart(
              glucoseData: glucoseData,
              lastUpdateTime: lastUpdateTime,
            ),
            _buildGlucoseMetrics(),
            _buildTodaySection(),
            _buildDoctorReports(),
          ],
        );
      }),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSelectionButton('Day', 0),
          _buildSelectionButton('Month', 1),
          _buildSelectionButton('Year', 2),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String label, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, value, _) {
        final isSelected = value == index;
        return GestureDetector(
          onTap: () => selectedIndex.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              style: titleStyle.copyWith(
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlucoseMetrics() {
    final avg = _todayAvgGlucose();
    final max = _todayMaxGlucose();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetricCard(
            icon: Icons.bloodtype,
            label: "Average",
            value: avg != null ? "${avg.toStringAsFixed(1)} mg/dL" : "-",
          ),
          _buildMetricCard(
            icon: Icons.bloodtype,
            label: "Maximum",
            value: max != null ? "$max mg/dL" : "-",
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red),
              const SizedBox(width: 10),
              Text(label, style: titleStyle.copyWith(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: headingStyle.copyWith(color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text("Today", style: headingStyle.copyWith(color: Colors.black)),
          const SizedBox(height: 10),
          _buildTodayMetricRow(Icons.bloodtype, "108", "mg/dL", "14:06"),
          _buildTodayMetricRow(Icons.favorite, "72", "bpm", "14:06"),
          _buildTodayMetricRow(Icons.directions_car, "85", "score", "14:06"),
        ],
      ),
    );
  }

  Widget _buildTodayMetricRow(
      IconData icon, String value, String unit, String time) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red, size: 30),
              const SizedBox(width: 10),
              Text(value, style: headingStyle.copyWith(color: Colors.black)),
            ],
          ),
          Text(unit, style: titleStyle.copyWith(color: Colors.black)),
          Text(time, style: subTitleStyle.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDoctorReports() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Doctor Reports",
            style: headingStyle.copyWith(color: Colors.black),
          ),
          const SizedBox(height: 10),
          _buildReportList(),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final List<String> reports = [
      "Doctor report on 03/05",
      "Doctor report on 02/05",
      "Doctor report on 01/05",
    ];

    return Column(
      children: reports.map((report) => _buildReportItem(report)).toList(),
    );
  }

  Widget _buildReportItem(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file, color: Colors.teal, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: titleStyle.copyWith(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
