import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

//màn hình Remider
import 'package:get_storage/get_storage.dart'; // thư viện lưu trữ biến cục bộ
import 'package:glucose_real_time/db/db_helper.dart';
import 'package:glucose_real_time/services/notification_services.dart';

import 'package:glucose_real_time/services/theme_service.dart';

import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/ui/widgets/custom_bottom_navigation_bar.dart';
//theme_service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DBHelper.dropTable(); // Xoá bảng 'tasks'
  await DBHelper.initDb();
  await GetStorage.init();


  // Khởi tạo NotifyHelper
  final notifyHelper = NotifyHelper();
  await notifyHelper.initializeNotification();
  notifyHelper.requestIOSPermissions();
  notifyHelper.requestAndroidNotificationPermission();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,

      theme: Themes.light,
      darkTheme: Themes.dark,
      // themeMode: ThemeMode.light,
      themeMode: ThemeService().theme,

      // Định nghĩa routes (đường dẫn), nơi mỗi route là một màn hình
      routes: {
        "/":
            (context) =>
                MainPage(), // Khi route là "/", nó sẽ điều hướng đến màn hình MainPage
      },

      // home: ReminderPage(), // màn hình đầu tiên
    );
  }
}
