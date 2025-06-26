import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

//màn hình Remider
import 'package:get_storage/get_storage.dart'; // thư viện lưu trữ biến cục bộ
import 'package:glucose_real_time/db/db_helper.dart';
import 'package:glucose_real_time/services/notification_services.dart';
import 'package:glucose_real_time/services/glucose_service.dart';

import 'package:glucose_real_time/services/theme_service.dart';
import 'package:glucose_real_time/ui/pages/login/login_page.dart';
import 'package:glucose_real_time/ui/theme/test/utils.dart';

import 'package:glucose_real_time/ui/theme/theme.dart';
import 'package:glucose_real_time/ui/widgets/custom_bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Khởi tạo GlucoseService
  await GlucoseService().initialize();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Glucose Real Time",
      debugShowCheckedModeBanner: false,

      theme: Themes.light,
      darkTheme: Themes.dark,
      // themeMode: ThemeMode.light,
      themeMode: ThemeService().theme,

      // Định nghĩa routes (đường dẫn), nơi mỗi route là một màn hình
      routes: {
        "/": (context) => CheckLoginPage(), // Trang kiểm tra login đầu tiên
        "/main": (context) => MainPage(), // Trang chính của app
        "/login": (context) => LoginPage(),

        //cập nhật UI
        // "/": (context) =>  MainPage(),
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
        // ✅ Nếu đã đăng nhập → chuyển sang MainPage
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo app_icon thay cho hình trái tim
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 28),
            // Tên app
            Text(
              "Glucose Real Time",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 8,
                    color: Colors.black26,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Your health, your data, real time!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 40),
            // Hiển thị vòng quay chờ trong khi kiểm tra login
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
