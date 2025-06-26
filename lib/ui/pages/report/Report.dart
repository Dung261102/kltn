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
      other is MonthYear &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          year == other.year;

  @override
  int get hashCode => month.hashCode ^ year.hashCode;

  @override
  String toString() => 'Month $month/$year';
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
    final random = DateTime
        .now()
        .millisecondsSinceEpoch;
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
          .where(
            (e) =>
        e.time.year == latest.year &&
            e.time.month == latest.month &&
            e.time.day == latest.day,
      )
          .toList();
    } else if (idx == 1) {
      // Month: lọc theo selectedMonthYear
      if (selectedMonthYear == null) return [];
      return history
          .where(
            (e) =>
        e.time.year == selectedMonthYear!.year &&
            e.time.month == selectedMonthYear!.month,
      )
          .toList();
    } else {
      // Year: lọc theo selectedYear
      if (selectedYear == null) return [];
      return history.where((e) => e.time.year == selectedYear).toList();
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
            // color: Colors.blueAccent,
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
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
              final monthYears =
              glucoseController.glucoseHistory
                  .map((e) => MonthYear(e.time.month, e.time.year))
                  .toSet()
                  .toList();
              monthYears.sort(
                    (a, b) =>
                b.year != a.year
                    ? b.year.compareTo(a.year)
                    : b.month.compareTo(a.month),
              );
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: DropdownButton<MonthYear>(
                  value: selectedMonthYear,
                  isExpanded: true,
                  items:
                  monthYears
                      .map(
                        (m) =>
                        DropdownMenuItem<MonthYear>(
                          value: m,
                          child: Text(m.toString()),
                        ),
                  )
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedMonthYear = val;
                    });
                  },
                ),
              );
            } else if (value == 2) {
              // Tab Year: chọn năm
              final years =
              glucoseController.glucoseHistory
                  .map((e) => e.time.year)
                  .toSet()
                  .toList()
                ..sort((a, b) => b.compareTo(a));
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
                  items:
                  years
                      .map(
                        (y) =>
                        DropdownMenuItem<int>(
                          value: y,
                          child: Text("Year $y"),
                        ),
                  )
                      .toList(),
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
              final monthYears =
              glucoseController.glucoseHistory
                  .map((e) => MonthYear(e.time.month, e.time.year))
                  .toSet()
                  .toList();
              if (monthYears.isNotEmpty) {
                monthYears.sort(
                      (a, b) =>
                  b.year != a.year
                      ? b.year.compareTo(a.year)
                      : b.month.compareTo(a.month),
                );
                selectedMonthYear = monthYears.first;
                setState(() {});
              }
            } else if (index == 2) {
              // Tab Year
              final years =
              glucoseController.glucoseHistory
                  .map((e) => e.time.year)
                  .toSet()
                  .toList()
                ..sort((a, b) => b.compareTo(a));
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
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              style: titleStyle.copyWith(
                color: isSelected ? Colors.black : Colors.grey,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTodaySection() {
    // Lấy dữ liệu glucose theo tab đang được chọn (Day/Month/Year)
    final filteredData = _filteredGlucoseRecords();

    String lastValue = "-";
    String lastTime = "--:--";
    String maxValue = "-";
    String maxTime = "--:--";
    String minValue = "-";
    String minTime = "--:--";

    if (filteredData.isNotEmpty) {
      // Sắp xếp theo thời gian tăng dần
      filteredData.sort((a, b) => a.time.compareTo(b.time));
      final last = filteredData.last;
      lastValue = last.value.toString();
      lastTime =
      "${last.time.hour.toString().padLeft(2, '0')}:${last.time.minute
          .toString().padLeft(2, '0')}";

      // Tìm max
      final maxEntry = filteredData.reduce((a, b) => a.value > b.value ? a : b);
      maxValue = maxEntry.value.toString();
      maxTime =
      "${maxEntry.time.hour.toString().padLeft(2, '0')}:${maxEntry.time.minute
          .toString().padLeft(2, '0')}";

      // Tìm min
      final minEntry = filteredData.reduce((a, b) => a.value < b.value ? a : b);
      minValue = minEntry.value.toString();
      minTime =
      "${minEntry.time.hour.toString().padLeft(2, '0')}:${minEntry.time.minute
          .toString().padLeft(2, '0')}";
    }

    // // Xác định tiêu đề dựa trên tab đang được chọn
    // String sectionTitle = "Today";
    // if (selectedIndex.value == 1) {
    //   sectionTitle = "Month Summary";
    // } else if (selectedIndex.value == 2) {
    //   sectionTitle = "Year Summary";
    // }

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
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
              const SizedBox(width: 10),

              Text("Today", style: headingStyle.copyWith(color: Colors.black)),

            ],
          ),
          const SizedBox(height: 15),
          _buildMetricCardWithBadge(
            icon: Icons.access_time,
            value: lastValue,
            unit: "mg/dL",
            time: lastTime,
            label: "Latest Reading",
            description: "Most recent glucose measurement",
            color: Colors.blue,
            badgeText: "LATEST",
          ),
          const SizedBox(height: 12),
          _buildMetricCardWithBadge(
            icon: Icons.trending_up,
            value: maxValue,
            unit: "mg/dL",
            time: maxTime,
            label: "Highest Level",
            description: "Peak glucose value recorded",
            color: Colors.red,
            badgeText: "MAX",
          ),
          const SizedBox(height: 12),
          _buildMetricCardWithBadge(
            icon: Icons.trending_down,
            value: minValue,
            unit: "mg/dL",
            time: minTime,
            label: "Lowest Level",
            description: "Lowest glucose value recorded",
            color: Colors.green,
            badgeText: "MIN",
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardWithBadge({
    required IconData icon,
    required String value,
    required String unit,
    required String time,
    required String label,
    required String description,
    required Color color,
    required String badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Icon với background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),

          // Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Thời gian
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.schedule, color: Colors.grey.shade400, size: 16),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


//   Widget _buildDoctorReports() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 10, 20, 30),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Text(
//             "Doctor Reports",
//             style: headingStyle.copyWith(color: Colors.black),
//           ),
//           const SizedBox(height: 10),
//           _buildReportList(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReportList() {
//     final List<String> reports = [
//       "Doctor report on 03/05",
//       "Doctor report on 02/05",
//       "Doctor report on 01/05",
//     ];
//
//     return Column(
//       children: reports.map((report) => _buildReportItem(report)).toList(),
//     );
//   }
//
//   Widget _buildReportItem(String title) {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.insert_drive_file, color: Colors.teal, size: 28),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(title, style: titleStyle.copyWith(color: Colors.black)),
//           ),
//         ],
//       ),
//     );
//   }
// }

  Widget _buildDoctorReports() {
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
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue.shade600,
                  size: 24),
              const SizedBox(width: 10),
              Text("Doctor Reports",
                  style: headingStyle.copyWith(color: Colors.black)),
            ],
          ),
          const SizedBox(height: 15),
          _buildReportList(),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    final List<Map<String, dynamic>> reports = [
      {
        "title": "Doctor report on 03/05",
        "description": "Latest medical consultation summary",
        "date": "May 3, 2025",
        "status": "Completed"
      },
      {
        "title": "Doctor report on 02/05",
        "description": "Follow-up appointment notes",
        "date": "May 2, 2025",
        "status": "Completed"
      },
      {
        "title": "Doctor report on 01/05",
        "description": "Initial consultation report",
        "date": "May 1, 2025",
        "status": "Completed"
      },
    ];

    return Column(
      children: reports.map((report) => _buildReportItem(report)).toList(),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> report) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
                Icons.medical_services, color: Colors.blue.shade600, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report["title"],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report["description"],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade500,
                        size: 14),
                    const SizedBox(width: 4),
                    Text(
                      report["date"],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        report["status"],
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
        ],
      ),
    );
  }
}