// import 'package:flutter/material.dart';
// import 'package:glucose_real_time/ui/theme/theme.dart';  // Import theme

// class LineChart extends StatelessWidget {
//   const LineChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         //Line chart
//         Container(
//           // Căn chỉnh chiều cao và padding của Container
//           height: 300, // Đặt chiều cao của Container là 500
//           padding: EdgeInsets.all(15), // Padding của Container là 15 pixel
//           margin: EdgeInsets.only(
//             left: 20,
//             right: 20,
//             top: 10,
//             bottom: 10,
//           ), // Lề 4 phía

//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(35), // 4 góc bo tròn 35 pixel
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey,
//                 blurRadius: 7,
//                 offset: Offset(2, 5),
//               ),
//             ],
//           ),

//           // Thành phần 1 - thanh ngang trên cùng có 3 thành phần nhỏ
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start, // ở trên cùng
//             mainAxisAlignment: MainAxisAlignment.spaceBetween, // cách đều
//             children: [
//               Text(
//                 "Health Report",
//                 style: headingStyle.copyWith(
//                   color: Colors.black,
//                 ),
//               ),
//               Spacer(), // đẩy 2 thành phần còn lại qua bên phải
//               // Thành phần 2
//               Container(
//                 padding: EdgeInsets.only(left: 10, right: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15), // Bo tròn viền
//                   border: Border.all(
//                     color: Colors.grey, // Màu của viền
//                     width: 2, // Độ dày của viền là 2
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(radius: 5, backgroundColor: Colors.red),
//                     SizedBox(width: 5),
//                     Text("Heart", style: titleStyle),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 10), // khoảng cách giữa 2 container
//               // Thành phần 3
//               Container(
//                 padding: EdgeInsets.only(left: 10, right: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(15), // Bo tròn viền
//                   border: Border.all(
//                     color: Colors.grey, // Màu của viền
//                     width: 2, // Độ dày của viền là 2
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     CircleAvatar(radius: 5, backgroundColor: Colors.blue),
//                     SizedBox(width: 5),
//                     Text("Glucose"),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // 3 - Chữ More Detail
//         // TextButton để hiển thị dòng chữ "More detail >"
//         TextButton(
//           onPressed: () {
//             Navigator.pushNamed(
//               context,
//               "Details",
//             ); // Điều hướng đến màn hình Details bằng tên route
//           },

//           child: Text(
//             'More detail >',
//             style: TextStyle(
//               color: Colors.blue, // Màu xanh cho chữ
//               decoration: TextDecoration.underline, // Gạch chân dưới chữ
//               fontSize: 18, // Kích thước chữ
//             ),
//           ),
//         ),
//       ],
//     ); // của line chart
//   }
// }

import 'package:fl_chart/fl_chart.dart'; // Thư viện để vẽ biểu đồ dạng đường (line chart)
import 'package:flutter/material.dart';
import 'package:glucose_real_time/ui/theme/theme.dart'; // Thư viện giao diện của bạn, chứa headingStyle

// Widget biểu đồ đường thể hiện dữ liệu glucose
class GlucoseLineChart extends StatelessWidget {
  final List<FlSpot> glucoseData; // Danh sách các điểm dữ liệu glucose (x: thời gian, y: chỉ số)
  final DateTime lastUpdateTime; // Thời gian cập nhật cuối cùng để tính lại mốc thời gian trên trục X

  const GlucoseLineChart({
    Key? key,
    required this.glucoseData,
    required this.lastUpdateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300, // Chiều cao của biểu đồ
      padding: const EdgeInsets.all(15), // Padding bên trong biểu đồ
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Khoảng cách với bên ngoài
      decoration: BoxDecoration(
        color: Colors.white, // Màu nền trắng
        borderRadius: BorderRadius.circular(35), // Bo tròn góc
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3), // Đổ bóng màu xám nhạt
            blurRadius: 7,
            offset: const Offset(2, 5), // Độ lệch của bóng đổ
          ),
        ],
      ),

      // Dùng Column để chứa cả tiêu đề và biểu đồ
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề "Health Report"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Health Report",
                style: headingStyle, // Kiểu chữ từ theme tùy chỉnh
              ),
            ],
          ),

          const SizedBox(height: 15), // Khoảng cách giữa tiêu đề và biểu đồ

          // Biểu đồ glucose
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true), // Hiển thị lưới
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(),
                    bottom: BorderSide(),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 50,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= glucoseData.length) return const Text('');
                        final time = lastUpdateTime.subtract(
                          Duration(minutes: (glucoseData.length - 1 - value.toInt()) * 30),
                        );
                        return Text(
                          '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                minY: 60,
                maxY: 200,
                lineBarsData: [
                  LineChartBarData(
                    spots: glucoseData,
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: true),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '${spot.y.toInt()} mg/dL',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 70,
                      color: Colors.orange,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                    HorizontalLine(
                      y: 180,
                      color: Colors.red,
                      strokeWidth: 2,
                      dashArray: [5, 5],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
