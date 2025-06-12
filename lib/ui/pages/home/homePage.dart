import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart';
import '../../../services/notification_services.dart';
import '../../widgets/LineChart.dart';
import '../../widgets/common_appbar.dart';

// page 1 - HomePage gồm 4 thành phần chính (appbar, line chart, 3 chỉ số, today)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotifyHelper notifyHelper = NotifyHelper();

    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
      ),
      body: ListView(
        children: [
          _buildLineChart(),
          _buildGlucoseCard(),
          _buildHealthMetrics(),
          _buildTodaySection(),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart();
  }

  Widget _buildGlucoseCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: EdgeInsets.only(
        left: 25,
        right: 25,
        top: 5,
        bottom: 20,
      ),
      padding: EdgeInsets.all(25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.bloodtype,
                color: Colors.white,
                size: 40.0,
              ),
              SizedBox(width: 10),
              Text(
                "Glucose",
                style: headingStyle.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            "100 mg/dL",
            style: headingStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMetricCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required EdgeInsets margin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
      ),
      margin: margin,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 30.0,
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: titleStyle.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: titleStyle.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    // Implementation of _buildHealthMetrics method
    // This method is mentioned in the original file but not implemented in the new file
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildTodaySection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
            color: Colors.blue,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TODAY',
                  style: headingStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.only(left: 25, right: 25, bottom: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Today is a great day to learn something new!",
                  style: titleStyle.copyWith(
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
