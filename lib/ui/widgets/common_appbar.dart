// App Bar cơ bản (có thể chỉnh sửa)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import 2 service bạn đang dùng (đường dẫn tương đối)
import '../../services/notification_services.dart';
import '../../services/theme_service.dart';


class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NotifyHelper notifyHelper;
  final String? title; // thêm tiêu đề nếu cần
  final List<Widget>? actions; // thêm action riêng cho từng màn hình (có thể null)
  final bool showThemeToggle; // có hiển thị icon đổi theme không

  CommonAppBar({
    required this.notifyHelper,
    this.title,
    this.actions,
    this.showThemeToggle = true, // mặc định bật nút đổi theme
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      title: title != null ? Text(title!) : null,
      leading: showThemeToggle
          ? GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
          notifyHelper.displayNotification(
            title: "Theme Changed",
            body: Get.isDarkMode ? "Activated Light Theme" : "Activated Dark Theme",
          );
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      )
          : null,
      actions: actions ??
          [
            CircleAvatar(backgroundImage: AssetImage("assets/images/profile/avatar.jpg")),
            SizedBox(width: 20),
          ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
