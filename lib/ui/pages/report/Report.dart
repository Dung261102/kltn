import 'package:flutter/material.dart';

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

    // Lấy instance NotifyHelper singleton
    final NotifyHelper notifyHelper = NotifyHelper();

    return Scaffold(
      appBar: CommonAppBar(
        notifyHelper: notifyHelper,
        // thêm code để chỉnh sửa app bar tại đây
      ),
      body: ListView(
        children: [
          // 1 - Container bao trùm thanh ngang hiển thị ngày tháng năm
          Container(
            margin: EdgeInsets.all(20), // Khoảng cách bên ngoài
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 0.1,
            ), // Khoảng cách bên trong
            decoration: BoxDecoration(
              color: Colors.grey[200], // Màu nền của Container bao trùm
              borderRadius: BorderRadius.circular(30), // Bo tròn góc
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceAround, // Phân bố đều các phần tử trong Row
              children: [
                _buildSelectionButton('Day', 0),
                _buildSelectionButton('Month', 1),
                _buildSelectionButton('Year', 2),
              ],
            ),
          ),

          // 2 - LineChart
          LineChart(),

          // 3 - chỉ số glucose trung bình và max
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Căn đều 2 cột
            children: [
              // Cột 1 - chỉ số avg
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Màu nền của container
                    borderRadius: BorderRadius.circular(30), // Bo tròn góc
                  ),
                  margin: EdgeInsets.only(left: 20, bottom: 10), // Lề
                  padding: EdgeInsets.all(20), // Thêm padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bloodtype, // Icon biểu tượng giọt máu
                            color: Colors.red, // Màu sắc cho icon
                            size: 30.0, // Kích thước của icon
                          ),
                          SizedBox(width: 5), // Khoảng cách giữa icon và text
                          Text(
                            "Avegare",
                            style: TextStyle(color: Colors.black, fontSize: 21),
                          ),
                        ],
                      ),
                      SizedBox(height: 10), // Khoảng cách giữa các dòng
                      Text(
                        "100 mg/dL",
                        style: TextStyle(color: Colors.black, fontSize: 25),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 20), // Khoảng cách giữa 2 container
              // Cột 2 - chỉ số max
              Flexible(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey, // Màu nền của container
                    borderRadius: BorderRadius.circular(30), // Bo tròn góc
                  ),
                  margin: EdgeInsets.only(right: 20, bottom: 10), // Lề
                  padding: EdgeInsets.all(20), // Thêm padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bloodtype, // Icon biểu tượng giọt máu
                            color: Colors.red, // Màu sắc cho icon
                            size: 30.0, // Kích thước của icon
                          ),
                          SizedBox(width: 5), // Khoảng cách giữa icon và text
                          Text(
                            "Maximum",
                            style: TextStyle(color: Colors.black, fontSize: 21),
                          ),
                        ],
                      ),
                      SizedBox(height: 10), // Khoảng cách giữa các dòng
                      Text(
                        "100 mg/dL",
                        style: TextStyle(color: Colors.black, fontSize: 25),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          //4- Today
          //container bọc bên ngoài
          Container(
            // Căn chỉnh chiều cao và padding của Container
            height: 300, // Đặt chiều cao của Container là 500
            padding: EdgeInsets.all(15), // Padding của Container là 15 pixel
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 20,
            ), // Lề 4 phía

            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(35), // 4 góc bo tròn 35 pixel
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 7,
                  offset: Offset(2, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min, // Đảm bảo không chiếm nhiều không gian hơn cần thiết
              children: [
                // Tiêu đề "Today"
                Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10), // Khoảng cách giữa tiêu đề và các hàng

                // Hàng đầu tiên
                Container(
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
                        offset: Offset(0, 4), // Đổ bóng
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Cách đều 3 phần
                    children: [
                      // Phần icon và chỉ số
                      Row(
                        children: [
                          Icon(
                            Icons.bloodtype, // Icon biểu tượng giọt máu
                            color: Colors.red,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "60",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Phần đơn vị đo
                      Text(
                        "mg/dL",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                      // Phần thời gian
                      Text(
                        "14:06",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hàng thứ hai
                Container(
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
                        offset: Offset(0, 4), // Đổ bóng
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Cách đều 3 phần
                    children: [
                      // Phần icon và chỉ số
                      Row(
                        children: [
                          Icon(
                            Icons.favorite, // Icon nhịp tim
                            color: Colors.red,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "60",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Phần đơn vị đo
                      Text(
                        "bpm",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                      // Phần thời gian
                      Text(
                        "14:06",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Hàng thứ ba
                Container(
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
                        offset: Offset(0, 4), // Đổ bóng
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Cách đều 3 phần
                    children: [
                      // Phần icon và chỉ số
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car, // Icon ô tô
                            color: Colors.blue,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "60",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                      // Phần đơn vị đo
                      Text(
                        "score",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),

                      // Phần thời gian
                      Text(
                        "14:06",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),


          ),

          //5 - Doctor Report
          //container bọc bên ngoài
          Container(
            // Căn chỉnh chiều cao và padding của Container
            height: 300, // Đặt chiều cao của Container là 500
            padding: EdgeInsets.all(15), // Padding của Container là 15 pixel
            margin: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 10,
              bottom: 100,
            ), // Lề 4 phía

            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(35), // 4 góc bo tròn 35 pixel
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 7,
                  offset: Offset(2, 5),
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Căn chữ Doctor Reports ở giữa
              children: [
                // Tiêu đề "Doctor Reports" ở giữa
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Doctor Reports",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center, // Đảm bảo tiêu đề nằm giữa
                  ),
                ),

                // Phần danh sách báo cáo
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Đảm bảo nội dung các dòng báo cáo căn trái
                  children: [
                    // Báo cáo 1
                    Container(
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
                            offset: Offset(0, 3), // Đổ bóng
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.insert_drive_file, // Icon file
                            color: Colors.teal,
                            size: 30,
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              "Doctor report on 03/05",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right, // Căn phải text
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Báo cáo 2
                    Container(
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
                            offset: Offset(0, 3), // Đổ bóng
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file, // Icon file
                            color: Colors.teal,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Doctor report on 02/05",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right, // Căn phải text
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Báo cáo 3
                    Container(
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
                            offset: Offset(0, 3), // Đổ bóng
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.insert_drive_file, // Icon file
                            color: Colors.teal,
                            size: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Doctor report on 01/05",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.right, // Căn phải text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),


          ),
        ],
      ),
    );
  }

  // Hàm xây dựng các button trong Row
  Widget _buildSelectionButton(String label, int index) {
    return ValueListenableBuilder<int>(
      valueListenable:
          selectedIndex, // Lắng nghe thay đổi của chỉ mục được chọn
      builder: (context, value, _) {
        bool isSelected = value == index; // Kiểm tra button nào đang được chọn
        return GestureDetector(
          onTap: () {
            selectedIndex.value =
                index; // Cập nhật trạng thái khi nhấn vào button
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0.1),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? Colors.black
                      : null, // khi không được chọn thì không có màu
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Colors.grey, // Màu chữ thay đổi khi được chọn
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        );
      },
    );
  }
}
