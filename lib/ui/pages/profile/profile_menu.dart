import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileMenuWidget extends StatelessWidget {
  // Constructor nhận các tham số cần thiết cho widget
  const ProfileMenuWidget({
    super.key,
    required this.title,   // Tiêu đề của menu
    required this.icon,    // Icon sẽ hiển thị bên trái
    required this.onPress, // Hàm callback khi người dùng nhấn vào menu
    this.endIcon = true,   // Tham số boolean xác định có hiển thị icon mũi tên bên phải hay không
    this.textColor,        // Màu chữ có thể thay đổi
  });

  // Khai báo các biến final (bất biến) để giữ dữ liệu được truyền vào
  final String title;       // Tiêu đề của menu item
  final IconData icon;      // Icon hiển thị cho menu item
  final VoidCallback onPress; // Hàm callback được gọi khi nhấn vào menu item
  final bool endIcon;       // Xác định có hiển thị icon ở cuối hay không
  final Color? textColor;   // Màu chữ tùy chọn cho menu item

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem thiết bị có đang ở chế độ tối (dark mode) hay không
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    // Nếu là dark mode thì icon sẽ là màu trắng, ngược lại là màu xanh dương
    var iconColor = isDark ? Colors.white : Colors.blue;

    // Trả về một ListTile để tạo cấu trúc của menu item
    return ListTile(
      // Khi nhấn vào menu, hàm onPress sẽ được gọi
      onTap: onPress,
      // Phần leading hiển thị icon bên trái của menu item, bao bọc trong một Container
      leading: Container(
        width: 40,  // Chiều rộng của container là 40
        height: 40, // Chiều cao là 40
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), // Bo góc để tạo hình tròn
          color: Colors.white,                      // Nền của container là màu trắng
        ),
        // Hiển thị icon với màu sắc đã xác định dựa trên dark mode
        child: Icon(icon, color: iconColor),
      ),
      // Hiển thị tiêu đề của menu với màu chữ tùy chọn (nếu có)
      title: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.apply(color: textColor), // Áp dụng màu chữ nếu có
      ),
      // Phần trailing là icon ở cuối (bên phải) của menu item, chỉ hiển thị nếu endIcon = true
      trailing: endIcon
          ? Container(
        width: 40, // Container với kích thước tương tự như leading
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), // Tạo hình tròn
          color: Colors.white, // Nền trắng
        ),
        // Hiển thị icon mũi tên bên phải
        child: const Icon(
          LineAwesomeIcons.angle_right_solid, // Icon mũi tên
          size: 18, // Kích thước của icon
          color: Colors.grey, // Màu xám
        ),
      )
          : null, // Nếu endIcon = false thì không hiển thị icon ở cuối
    );
  }
}
