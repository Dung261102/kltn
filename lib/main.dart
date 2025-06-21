import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

//màn hình Remider
import 'package:get_storage/get_storage.dart'; // thư viện lưu trữ biến cục bộ
import 'package:glucose_real_time/db/db_helper.dart';
import 'package:glucose_real_time/services/notification_services.dart';

import 'package:glucose_real_time/services/theme_service.dart';
import 'package:glucose_real_time/ui/pages/login/login_page.dart';
import 'package:glucose_real_time/ui/theme/test/utils.dart';

import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
//theme_service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Utils.initBaseUrl(); // 👈 quan trọng!


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
        // "/":
        //     (context) =>
        //         MainPage(), // Khi route là "/", nó sẽ điều hướng đến màn hình MainPage

        // "/": (context) => CheckLoginPage(), // Trang kiểm tra login đầu tiên
        // "/main": (context) => MainPage(), // Trang chính của app
        // "/login": (context) => LoginPage(),
        // "/": (context) => LoginPage(),
        // "/home": (context) => HomePage(),
         "/": (context) => MainPage(),
      },

      // home: ReminderPage(), // màn hình đầu tiên
    );
  }
}

// 🆕 Màn hình kiểm tra trạng thái đăng nhập từ SharedPreferences
class CheckLoginPage extends StatefulWidget {
  @override
  _CheckLoginPageState createState() => _CheckLoginPageState();
}

class _CheckLoginPageState extends State<CheckLoginPage> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 🕒 Delay tạo hiệu ứng Splash (có thể điều chỉnh thời gian hoặc bỏ luôn)
    Timer(Duration(seconds: 2), () {
      final userId = prefs.getInt('userid');
      final userMail = prefs.getString('usermail');

      if (userId == null || userMail == null) {
        // ❌ Nếu chưa đăng nhập → chuyển sang LoginPage
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        // ✅ Nếu đã đăng nhập → chuyển sang HomePage hoặc MainPage
        Navigator.pushReplacementNamed(context, '/home'); // Hoặc '/main'
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Hiển thị vòng quay chờ trong khi kiểm tra login
        child: CircularProgressIndicator(),
      ),
    );
  }
}
