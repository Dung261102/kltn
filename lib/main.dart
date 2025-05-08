import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

//màn hình Remider
import 'package:get_storage/get_storage.dart'; // thư viện lưu trữ biến cục bộ
import 'package:glucose_real_time/db/db_helper.dart';
import 'package:glucose_real_time/ui/remider_page.dart'; // màn hình remider
import 'package:glucose_real_time/ui/theme.dart'; //các theme chính
import 'package:glucose_real_time/services/theme_service.dart';
//theme_service

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await DBHelper.dropTable(); // Xoá bảng 'tasks'
  await DBHelper.initDb();
  await GetStorage.init();
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
      // routes: {
      //   "/":
      //       (context) =>
      //       MainPage(), // Khi route là "/", nó sẽ điều hướng đến màn hình MainPage
      //   "Details":
      //       (context) => Details(), // Thêm đường dẫn cho màn hình Details
      // },
      home: RemiderPage(), // màn hình đầu tiên
    );
  }
}
