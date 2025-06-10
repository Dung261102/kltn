import 'package:flutter/material.dart';
import '../theme/theme.dart';

class MyButton extends StatelessWidget {
  final String label;                        // Nhãn nút
  final Function()? onTap;                  // Hàm khi nhấn nút
  final Color? color;                       // Màu nền có thể tùy chỉnh
  final double width;                       // Chiều rộng nút
  final double height;                      // Chiều cao nút

  const MyButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,                              // Có thể null => sẽ dùng màu mặc định
    this.width = 100,                        // Giá trị mặc định
    this.height = 60,                        // Giá trị mặc định
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,                        // Gán chiều rộng
        height: height,                      // Gán chiều cao
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color ?? primaryClr,        // Nếu không truyền thì dùng màu mặc định
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

//cách tái sử dụng
// MyButton(
// label: "+ Add Task",
// onTap: () {
// print("Tapped Add Task");
// },
// color: Colors.green,        // Tùy chỉnh màu sắc
// width: 140,                 // Tùy chỉnh chiều rộng
// height: 50,                 // Tùy chỉnh chiều cao
// ),

