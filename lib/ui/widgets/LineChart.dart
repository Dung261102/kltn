import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  const LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Line chart
        Container(
          // Căn chỉnh chiều cao và padding của Container
          height: 300, // Đặt chiều cao của Container là 500
          padding: EdgeInsets.all(15), // Padding của Container là 15 pixel
          margin: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 10,
            bottom: 10,
          ), // Lề 4 phía

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(35), // 4 góc bo tròn 35 pixel
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 7,
                offset: Offset(2, 5),
              ),
            ],
          ),

          // Thành phần 1 - thanh ngang trên cùng có 3 thành phần nhỏ
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // ở trên cùng
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // cách đều
            children: [
              Text(
                "Health Report",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Spacer(), // đẩy 2 thành phần còn lại qua bên phải
              // Thành phần 2
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Bo tròn viền
                  border: Border.all(
                    color: Colors.grey, // Màu của viền
                    width: 2, // Độ dày của viền là 2
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: Colors.red),
                    SizedBox(width: 5),
                    Text("Heart"),
                  ],
                ),
              ),
              SizedBox(width: 10), // khoảng cách giữa 2 container
              // Thành phần 3
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), // Bo tròn viền
                  border: Border.all(
                    color: Colors.grey, // Màu của viền
                    width: 2, // Độ dày của viền là 2
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 5, backgroundColor: Colors.blue),
                    SizedBox(width: 5),
                    Text("Glucose"),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 3 - Chữ More Detail
        // TextButton để hiển thị dòng chữ "More detail >"
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "Details",
            ); // Điều hướng đến màn hình Details bằng tên route
          },

          child: Text(
            'More detail >',
            style: TextStyle(
              color: Colors.blue, // Màu xanh cho chữ
              decoration: TextDecoration.underline, // Gạch chân dưới chữ
              fontSize: 18, // Kích thước chữ
            ),
          ),
        ),
      ],
    ); // của line chart
  }
}
