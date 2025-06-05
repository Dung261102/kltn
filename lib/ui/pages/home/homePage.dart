import 'package:flutter/material.dart';
import '../../widgets/LineChart.dart';
import 'homeAppBar.dart'; //widget HomeAppBar trong folder Widgets

// page 1 - HomePage gồm 4 thành phần chính (appbar, line chart, 3 chỉ số, today)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử avatarUrl là null khi người dùng chưa có ảnh đại diện
    String? avatarUrl; // avatarUrl có thể là null nếu không có ảnh người dùng
    int?
    notificationCount; // Biến này có thể là null nếu không có số lượng thông báo

    return Scaffold(
      // backgroundColor: Color(0xffE2EAFF), // test - set màu nền là màu xám
      // backgroundColor: Colors.white,

      body: ListView(
        // ListView là widget giúp hiển thị danh sách các widget con theo chiều dọc có thể cuộn
        children: [
          // 1 - HomeAppBar
          // Truyền cả tên, URL ảnh đại diện và số thông báo vào HomeAppBar
          HomeAppBar(
            name: 'Dung', // Tên người dùng
            avatarUrl: avatarUrl, // URL ảnh đại diện có thể là null
            notificationCount:
                notificationCount ??
                3, // Số thông báo thực tế, nếu không có thì mặc định là 3
          ),


          // 2 -  Line chart - widget LineChart
          LineChart (),


// Thành phần 3 - 3 chỉ số (2 hàng)

          // Hàng 1 - chỉ so glucose

          // Container bao bên ngoài để căn chỉnh
          Container(
            decoration: BoxDecoration(
              color: Colors.blue, // Màu nền của container
              borderRadius: BorderRadius.circular(
                30,
              ), // Bo tròn góc với bán kính 30
            ),
            margin: EdgeInsets.only(
              left: 25,
              right: 25,
              top: 5,
              bottom: 20,
            ), // Lề 4 phía
            padding: EdgeInsets.all(25),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row ( //bao gồm 2 hàng - hàng 1: chỉ số glucose,
                  // hàng 2 chỉ số heart và sleep
                  children: [
                    // chỉ số 1 - glucose (gồm 3 thành phần, 2 bên trái, 1 bên phải)

                    // 2 thành phần bên trái
                    // Thành phần con 1
                    Icon(
                      Icons.bloodtype, // Icon biểu tượng giọt máu
                      color: Colors.white, // Màu sắc cho icon
                      size: 40.0, // Kích thước của icon
                    ),

                    SizedBox(width: 10),

                    // Thành phần con 2
                    Text(
                      "Glucose",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30
                      ),
                    ),
                  ],
                ),

                // Thành phần bên phải

                Text (
                  "100 mg/dL",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30
                  ),
                ),
              ],
            ),
          ),


          // Hàng 2 - chỉ số Heart và sleep

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Căn đều 2 cột
            children: [

              // Cột 1 - chỉ số heart
              Container(
                decoration: BoxDecoration(
                  color: Colors.red, // Màu nền của container
                  borderRadius: BorderRadius.circular(30), // Bo tròn góc với bán kính 20
                ),
                margin: EdgeInsets.only(left: 45, bottom: 10), // Lề 4 phía
                padding: EdgeInsets.all(20), // Thêm padding bao quanh nội dung bên trong
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite, // Biểu tượng hình trái tim (nhịp tim)
                      color: Colors.white, // Màu sắc cho icon
                      size: 30.0, // Kích thước của icon
                    ),
                    SizedBox(height: 10), // Khoảng cách giữa các dòng
                    Text(
                      "100 bmp",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(height: 5), // Khoảng cách giữa các dòng
                    Text(
                      "Heart rate",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Cột 2 - chỉ số sleep
              Container(
                decoration: BoxDecoration(
                  color: Colors.purple, // Màu nền của container
                  borderRadius: BorderRadius.circular(30), // Bo tròn góc với bán kính 20
                ),
                margin: EdgeInsets.only(right: 45, bottom: 10), // Lề 4 phía, // Lề 4 phía
                padding: EdgeInsets.all(20), // Thêm padding bao quanh nội dung bên trong
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bedtime, // Biểu tượng giấc ngủ
                      color: Colors.white, // Màu sắc cho icon
                      size: 30.0, // Kích thước của icon
                    ),
                    SizedBox(height: 5), // Khoảng cách giữa các dòng
                    Text(
                      "8 hrs",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                    SizedBox(height: 5), // Khoảng cách giữa các dòng
                    Text(
                      "Sleep rate",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
              ),
            ],
          ),



          // 4 - Dữ liệu Today
          // Thành phần 4 - Today (single child scrollview)
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 30.0),
                  color: Colors.blue, // Màu nền của thanh ngang
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down, // Mũi tên xuống
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),


                // Nội dung test
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
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )


          ////////////// 3 hàng liên tiếp children ], listview, ); scaffold
        ], //chidren [ hàng 17// Kết thúc
      ),
    );
  }
}
