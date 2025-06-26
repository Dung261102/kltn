import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import '../../../services/notification_services.dart';
import '../../widgets/LineChart.dart';
import '../../widgets/common_appbar.dart';
import 'package:get/get.dart';
import 'package:glucose_real_time/controllers/ble_controller.dart';
import 'package:glucose_real_time/controllers/glucose_controller.dart';


class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class MonthYear {
  final int month;
  final int year;
  MonthYear(this.month, this.year);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthYear && runtimeType == other.runtimeType && month == other.month && year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;

  @override
  String toString() => 'Tháng $month/$year';
}

class _ReportPageState extends State<ReportPage> {
  final BleController bleController = Get.put(BleController());
  final NotifyHelper notifyHelper = NotifyHelper();
  final GlucoseController glucoseController = Get.put(GlucoseController());
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  MonthYear? selectedMonthYear;
  int? selectedYear;

  @override
  void initState() {
    super.initState();
    _addSampleDataForReport();
    _initDefaultMonthYear();
  }

  void _initDefaultMonthYear() {
    final history = glucoseController.glucoseHistory;
    if (history.isNotEmpty) {
      final latest = history.last.time;
      selectedMonthYear = MonthYear(latest.month, latest.year);
      selectedYear = latest.year;
    }
  }

  // Thêm dữ liệu mẫu chỉ trong tháng 6 và năm 2025
  void _addSampleDataForReport() {
    final List<({DateTime time, int value})> samples = [];
    final random = DateTime.now().millisecondsSinceEpoch;
    final usedDays = <int>{};
    for (int i = 0; i < 10; i++) {
      int day;
      do {
        day = 1 + (random + i * 13) % 28; // random ngày từ 1-28, tránh trùng
      } while (usedDays.contains(day));
      usedDays.add(day);
      final value = 110 + ((random + i * 17) % 50); // random value 110-159
      samples.add((time: DateTime(2025, 6, day, 8 + i, 0), value: value));
    }
    if (glucoseController.glucoseHistory.length < 3) {
      glucoseController.setHistory(samples);
    }
  }

  List<({DateTime time, int value})> _filteredGlucoseRecords() {
    final history = glucoseController.glucoseHistory;
    if (history.isEmpty) return [];
    final idx = selectedIndex.value;
    final latest = history.last.time;
    if (idx == 0) {
      // Day: lọc theo ngày mới nhất trong dữ liệu
      return history
          .where((e) => e.time.year == latest.year && e.time.month == latest.month && e.time.day == latest.day)
          .toList();
    } else if (idx == 1) {
      // Month: lọc theo selectedMonthYear
      if (selectedMonthYear == null) return [];
      return history
          .where((e) => e.time.year == selectedMonthYear!.year && e.time.month == selectedMonthYear!.month)
          .toList();
    } else {
      // Year: lọc theo selectedYear
      if (selectedYear == null) return [];
      return history
          .where((e) => e.time.year == selectedYear)
          .toList();
    }
  }

  int? _selectedMaxGlucose() {
    final values = _filteredGlucoseRecords().map((e) => e.value).toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }

  double? _selectedAvgGlucose() {
    final values = _filteredGlucoseRecords().map((e) => e.value).toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(notifyHelper: notifyHelper),
      body: Builder(
        builder: (context) {
          return ListView(
            padding: const EdgeInsets.only(top: 10),
            children: [
              _buildDateSelector(),
              ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, value, _) {
                  return Obx(() {
                    final filteredData = _filteredGlucoseRecords();
                    return Column(
                      children: [
                        GlucoseLineChartSection(
                          data: filteredData,
                          title: null,
                          showMetrics: false,
                        ),
                        _buildGlucoseMetrics(filteredData),
                      ],
                    );
                  });
                },
              ),
              _buildTodaySection(),
              _buildDoctorReports(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateSelector() {
    return Column(
      children: [
        Container(
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
        ),
        ValueListenableBuilder<int>(
          valueListenable: selectedIndex,
          builder: (context, value, _) {
            if (value == 1) {
              // Tab Month: chọn tháng/năm
              final monthYears = glucoseController.glucoseHistory
                  .map((e) => MonthYear(e.time.month, e.time.year))
                  .toSet()
                  .toList();
              monthYears.sort((a, b) => b.year != a.year ? b.year.compareTo(a.year) : b.month.compareTo(a.month));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: DropdownButton<MonthYear>(
                  value: selectedMonthYear,
                  isExpanded: true,
                  items: monthYears.map((m) => DropdownMenuItem<MonthYear>(
                    value: m,
                    child: Text(m.toString()),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedMonthYear = val;
                    });
                  },
                ),
              );
            } else if (value == 2) {
              // Tab Year: chọn năm
              final years = glucoseController.glucoseHistory.map((e) => e.time.year).toSet().toList()..sort((a, b) => b.compareTo(a));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  items: years.map((y) => DropdownMenuItem<int>(value: y, child: Text("Năm $y"))).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedYear = val;
                    });
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildSelectionButton(String label, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, value, _) {
        final isSelected = value == index;
        return GestureDetector(
          onTap: () {
            selectedIndex.value = index;
            // Khi chuyển tab, cập nhật selectedMonthYear/selectedYear phù hợp
            if (index == 1) {
              // Tab Month
              final monthYears = glucoseController.glucoseHistory
                  .map((e) => MonthYear(e.time.month, e.time.year))
                  .toSet()
                  .toList();
              if (monthYears.isNotEmpty) {
                monthYears.sort((a, b) => b.year != a.year ? b.year.compareTo(a.year) : b.month.compareTo(a.month));
                selectedMonthYear = monthYears.first;
                setState(() {});
              }
            } else if (index == 2) {
              // Tab Year
              final years = glucoseController.glucoseHistory.map((e) => e.time.year).toSet().toList()..sort((a, b) => b.compareTo(a));
              if (years.isNotEmpty) {
                selectedYear = years.first;
                setState(() {});
              }
            }
          },
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

  Widget _buildGlucoseMetrics(List<({DateTime time, int value})> data) {
    if (data.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricCard(
              icon: Icons.bloodtype,
              label: "Average",
              value: "-",
              color: Colors.blueAccent,
            ),
            _buildMetricCard(
              icon: Icons.trending_up,
              label: "Maximum",
              value: "-",
              color: Colors.redAccent,
            ),
          ],
        ),
      );
    }
    final avg = data.map((e) => e.value).reduce((a, b) => a + b) / data.length;
    final max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMetricCard(
            icon: Icons.bloodtype,
            label: "Average",
            value: "${avg.toStringAsFixed(1)} mg/dL",
            color: Colors.blueAccent,
          ),
          _buildMetricCard(
            icon: Icons.trending_up,
            label: "Maximum",
            value: "$max mg/dL",
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    // Tách số và đơn vị nếu có
    String number = value;
    String unit = '';
    if (value.contains('mg/dL')) {
      final parts = value.split(' ');
      if (parts.length >= 2) {
        number = parts[0];
        unit = parts.sublist(1).join(' ');
      }
    }
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(number, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
              ]
            ],
          ),
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
