import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/notification_services.dart';
import '../../services/theme_service.dart';
import '../../controllers/user_controller.dart';
import 'dart:io';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NotifyHelper notifyHelper;
  final String? title; // dòng 1
  final Widget? subtitle; // đổi từ String? sang Widget?
  final List<Widget>? actions;
  final bool showThemeToggle;

  CommonAppBar({
    required this.notifyHelper,
    this.title,
    this.subtitle,
    this.actions,
    this.showThemeToggle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      title: subtitle != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title ?? '', style: const TextStyle(fontSize: 16, color: Colors.blueAccent)),
                subtitle!, // dùng widget luôn
              ],
            )
          : (title != null ? Text(title!) : null),
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
      Obx(() {
        final userController = Get.find<UserController>();
        final bytes = userController.avatarBytes.value;
        final path = userController.avatarPath.value;
        ImageProvider provider;
        if (bytes != null) {
          provider = MemoryImage(bytes);
        } else if (path.startsWith('/') || path.startsWith('file://')) {
          provider = FileImage(File(path));
        } else {
          provider = AssetImage(path);
        }
        return CircleAvatar(
          backgroundImage: provider,
        );
      }),
      SizedBox(width: 20),
    ],


    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}