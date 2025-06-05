import 'package:flutter/material.dart';

// Widget tái sử dụng cho IconButton không có badge, sử dụng CircleAvatar
class ReusableIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ReusableIconButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.transparent, // Nền của avatar trong suốt
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey, // Màu nền của IconButton
          borderRadius: BorderRadius.circular(15), // Bo góc cho viền hình vuông
          border: Border.all(
            color: Colors.blue, // Màu viền
            width: 2.0, // Độ dày của viền
          ),
        ),
        child: IconButton(
          iconSize: 32, // Kích thước của icon
          color: Colors.white, // Màu của icon
          icon: Icon(icon),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
