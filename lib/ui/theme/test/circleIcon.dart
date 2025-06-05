import 'package:flutter/material.dart';

// Widget tái sử dụng cho IconButton không có badge
class ReusableIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed; // Hàm xử lý khi nhấn vào IconButton

  const ReusableIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.grey, // Màu nền của CircleAvatar
      radius: 24, // Kích thước của hình tròn (điều chỉnh tùy theo kích thước icon)
      child: IconButton(
        iconSize: 32, // Kích thước icon
        color: Colors.white, // Màu của icon
        icon: Icon(icon), // Icon truyền vào
        onPressed: onPressed, // Xử lý sự kiện khi nhấn
      ),
    );
  }
}
