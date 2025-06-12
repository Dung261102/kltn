import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';  // Import theme

import '../../../services/notification_services.dart';
import '../../widgets/LineChart.dart';
import '../../widgets/common_appbar.dart';



class ReportPage extends StatelessWidget {
  final ValueNotifier<int> selectedIndex = ValueNotifier<int>(
    0,
  );

  ReportPage({super.key}); // ValueNotifier để quản lý trạng thái

  @override
  Widget build(BuildContext context) {
    final NotifyHelper notifyHelper = NotifyHelper();

    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
      ),
      body: ListView(
        children: [
          _buildDateSelector(),
          _buildLineChart(),
          _buildGlucoseMetrics(),
          _buildTodaySection(),
          _buildDoctorReports(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0.1),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
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

  Widget _buildLineChart() {
    return LineChart();
  }

  Widget _buildGlucoseMetrics() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricCard(
          icon: Icons.bloodtype,
          label: "Average",
          value: "100 mg/dL",
          margin: EdgeInsets.only(left: 20, bottom: 10),
        ),
        SizedBox(width: 20),
        _buildMetricCard(
          icon: Icons.bloodtype,
          label: "Maximum",
          value: "100 mg/dL",
          margin: EdgeInsets.only(right: 20, bottom: 10),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required EdgeInsets margin,
  }) {
    return Flexible(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(30),
        ),
        margin: margin,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.red,
                  size: 30.0,
                ),
                SizedBox(width: 5),
                Text(
                  label,
                  style: titleStyle.copyWith(
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              value,
              style: headingStyle.copyWith(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Today",
            style: headingStyle.copyWith(
              color: Colors.black,
            ),
          ),
          SizedBox(height: 10),
          _buildTodayMetricRow(
            icon: Icons.bloodtype,
            value: "60",
            unit: "mg/dL",
            time: "14:06",
          ),
          _buildTodayMetricRow(
            icon: Icons.favorite,
            value: "60",
            unit: "bpm",
            time: "14:06",
          ),
          _buildTodayMetricRow(
            icon: Icons.directions_car,
            value: "60",
            unit: "score",
            time: "14:06",
          ),
        ],
      ),
    );
  }

  Widget _buildTodayMetricRow({
    required IconData icon,
    required String value,
    required String unit,
    required String time,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.red,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                value,
                style: headingStyle.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Text(
            unit,
            style: titleStyle.copyWith(
              color: Colors.black,
            ),
          ),
          Text(
            time,
            style: subTitleStyle.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorReports() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: 100,
      ),
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 7,
            offset: Offset(2, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Doctor Reports",
              style: headingStyle.copyWith(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _buildReportList(),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReportItem("Doctor report on 03/05"),
        _buildReportItem("Doctor report on 02/05"),
        _buildReportItem("Doctor report on 01/05"),
      ],
    );
  }

  Widget _buildReportItem(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file,
            color: Colors.teal,
            size: 30,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: titleStyle.copyWith(
                color: Colors.black,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(String label, int index) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (context, value, _) {
        bool isSelected = value == index;
        return GestureDetector(
          onTap: () {
            selectedIndex.value = index;
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0.1),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : null,
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
}
