
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';


// Widget tái sử dụng cho IconButton có badge, sử dụng CircleAvatar
class IconButtonWithBadge extends StatelessWidget {
  final IconData icon;
  final String badgeContent;
  final VoidCallback onPressed;

  const IconButtonWithBadge({super.key, 
    required this.icon,
    required this.badgeContent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeStyle: badges.BadgeStyle(
        badgeColor: Colors.red, // Màu nền của Badge
        padding: EdgeInsets.all(7), // Padding bên trong Badge
      ),
      badgeContent: Text(
        badgeContent, // Nội dung hiển thị trong Badge
        style: TextStyle(color: Colors.white), // Màu chữ bên trong Badge
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey, // Màu nền của CircleAvatar
        radius: 24, // Kích thước hình tròn
        child: IconButton(
          iconSize: 32, // Kích thước icon
          color: Colors.white, // Màu của icon
          icon: Icon(icon), // Icon truyền vào
          onPressed: onPressed, // Xử lý sự kiện khi nhấn
        ),
      ),
    );
  }
}
