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
  final List<DateTime> chartTimes; // Thời gian thực tế của từng điểm
  final DateTime lastUpdateTime; // Thời gian cập nhật cuối cùng để tính lại mốc thời gian trên trục X

  const GlucoseLineChart({
    Key? key,
    required this.glucoseData,
    required this.chartTimes,
    required this.lastUpdateTime,
  }) : super(key: key);

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300, // Chiều cao của biểu đồ
          padding: const EdgeInsets.all(5), // Padding bên trong biểu đồ
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Khoảng cách với bên ngoài
          decoration: BoxDecoration(
            color: Colors.white,
        //    gradient: LinearGradient(
        //   colors: [
        //     Color.lerp(Colors.white, Colors.blueAccent, 0.02)!, // Trắng pha xanh, trắng đậm hơn ở trên
        //     Colors.blueAccent
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),

        // gradient: LinearGradient(
        //   colors: [
        //     Colors.white,           // trắng
        //     Color(0xFFE3F6FF),      // trắng xanh nhạt hơn nữa
        //     Colors.white,           // trắng
        //      Color(0xFFE3F6FF),     // hồng nhạt
        //     Colors.white,  
        //     Colors.white,  
        //     Colors.white,      
        
        //     Colors.white,           // trắng
        //     Color(0xFFE3F6FF),     // hồng nhạt
        //     Colors.white],         // trắng
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
          
        // ),

            
            borderRadius: BorderRadius.circular(35), // Bo tròn góc
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3), // Đổ bóng màu xám nhạt
                blurRadius: 7,
                offset: const Offset(2, 5), // Độ lệch của bóng đổ
              ),
            ],
            // Không cần border
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.show_chart, color: Colors.teal, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        "Health Report",
                        style: headingStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.teal.withOpacity(0.15),
                              blurRadius: 4,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false), // Bỏ viền
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 40,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value % 40 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  shadows: [Shadow(color: Colors.grey.withOpacity(0.15), blurRadius: 2)],
                                ),
                                textAlign: TextAlign.right,
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 40,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value % 40 == 0) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                  shadows: [Shadow(color: Colors.grey.withOpacity(0.15), blurRadius: 2)],
                                ),
                                textAlign: TextAlign.left,
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            final n = glucoseData.length;
                            final idxs = <int>{0, n - 1, n ~/ 3, (2 * n) ~/ 3};
                            if (idxs.contains(idx)) {
                              if (idx < chartTimes.length) {
                                final time = chartTimes[idx];
                                String label = _formatTime(time);
                                if (idx == 0) label = '  $label';
                                if (idx == n - 1) label = '$label  ';
                                return Text(label, style: const TextStyle(fontSize: 10));
                              }
                            }
                            return const Text('');
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
                        barWidth: 4,
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.blueAccent, Colors.purpleAccent],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.withOpacity(0.3),
                              Colors.blueAccent.withOpacity(0.15),
                              Colors.purpleAccent.withOpacity(0.05),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) {
                            final isLast = index == glucoseData.length - 1;
                            final value = spot.y;
                            // Dot vượt ngưỡng
                            if (value < 70) {
                              return FlDotCirclePainter(
                                radius: isLast ? 8 : 6,
                                color: Colors.orange,
                                strokeWidth: isLast ? 4 : 3,
                                strokeColor: Colors.white,
                              );
                            } else if (value > 180) {
                              return FlDotCirclePainter(
                                radius: isLast ? 8 : 6,
                                color: Colors.red,
                                strokeWidth: isLast ? 4 : 3,
                                strokeColor: Colors.white,
                              );
                            } else if (isLast) {
                              return FlDotCirclePainter(
                                radius: 8,
                                color: Colors.blueAccent,
                                strokeWidth: 4,
                                strokeColor: Colors.white,
                              );
                            } else {
                              return FlDotCirclePainter(
                                radius: 5,
                                color: Colors.white,
                                strokeWidth: 3,
                                strokeColor: Colors.teal,
                              );
                            }
                          },
                        ),
                        showingIndicators: List.generate(glucoseData.length, (i) => i),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpots) => Colors.white,
                        tooltipBorderRadius: BorderRadius.circular(12),                        tooltipBorder: BorderSide(color: Colors.teal.withOpacity(0.2), width: 1.5),
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final idx = spot.x.toInt();
                            String timeStr = '';
                            if (idx >= 0 && idx < chartTimes.length) {
                              timeStr = _formatTime(chartTimes[idx]);
                            }
                            return LineTooltipItem(
                              '${spot.y.toInt()} mg/dL\n$timeStr',
                              const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                shadows: [Shadow(color: Colors.black12, blurRadius: 2)],
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
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.centerRight,
                            labelResolver: (_) => ' 70 mg/dL ',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        HorizontalLine(
                          y: 180,
                          color: Colors.red,
                          strokeWidth: 2,
                          dashArray: [5, 5],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.centerRight,
                            labelResolver: (_) => ' 180 mg/dL ',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class GlucoseLineChartSection extends StatelessWidget {
  final List<({DateTime time, int value})> data;
  final String? title;
  final bool showMetrics;

  const GlucoseLineChartSection({
    Key? key,
    required this.data,
    this.title,
    this.showMetrics = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No data yet', style: TextStyle(color: Colors.grey)));
    }
    // Lọc data theo ngày cuối cùng trong danh sách
    final DateTime lastDay = data.last.time;
    final todayData = data.where((e) =>
      e.time.year == lastDay.year &&
      e.time.month == lastDay.month &&
      e.time.day == lastDay.day
    ).toList();
    // Lấy 10 điểm cuối cùng
    final List<({DateTime time, int value})> last10 = data.length > 10 ? data.sublist(data.length - 10) : data;
    final List<FlSpot> chartData = List.generate(
      last10.length,
      (i) => FlSpot(i.toDouble(), last10[i].value.toDouble()),
    );
    final List<DateTime> chartTimes = last10.map((e) => e.time).toList();
    final DateTime lastUpdateTime = last10.last.time;
    final avg = todayData.isNotEmpty ? todayData.map((e) => e.value).reduce((a, b) => a + b) / todayData.length : 0;
    final max = todayData.isNotEmpty ? todayData.map((e) => e.value).reduce((a, b) => a > b ? a : b) : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 10, bottom: 5),
            child: Text(title!, style: headingStyle.copyWith(color: Colors.black)),
          ),
        GlucoseLineChart(
          glucoseData: chartData,
          chartTimes: chartTimes,
          lastUpdateTime: lastUpdateTime,
        ),
        if (showMetrics)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildMetricCard("Average", todayData.isNotEmpty ? "${avg.toStringAsFixed(1)} mg/dL" : "-"),
                const SizedBox(width: 16),
                _buildMetricCard("Maximum", todayData.isNotEmpty ? "$max mg/dL" : "-"),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: subTitleStyle.copyWith(color: Colors.teal[800])),
          const SizedBox(height: 4),
          Text(value, style: headingStyle.copyWith(color: Colors.teal[900], fontSize: 18)),
        ],
      ),
    );
  }
}
