
// class Utils{
//   //you add your port no that u define in node js
//   static String baseUrl="http://10.0.2.2:3000"; // here we define the base url
// }

// import 'dart:io';
//
// class Utils {
//   static String get baseUrl {
//     if (Platform.isAndroid) {
//       // Nếu chạy trên máy ảo Android → dùng 10.0.2.2
//       return "http://10.0.2.2:3000";
//     } else {
//       // Nếu là máy thật (Android/iOS) → dùng IP thật của máy bạn
//       return "http://192.168.1.152:3000"; // 👈 thay đúng IP
//     }
//   }
// }

import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Utils {
  static String _baseUrl = "http://localhost:3000"; // fallback

  static Future<void> initBaseUrl() async {
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      final isEmulator = !deviceInfo.isPhysicalDevice;

      _baseUrl = isEmulator
          ? "http://10.0.2.2:3000"
          : "http://192.168.1.152:3000"; // 👈 thay đúng IP máy bạn
    } else if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      final isEmulator = !deviceInfo.isPhysicalDevice;

      _baseUrl = isEmulator
          ? "http://localhost:3000"
          : "http://192.168.1.152:3000"; // 👈 thay đúng IP
    } else {
      // nếu là web hoặc desktop
      _baseUrl = "http://localhost:3000";
    }
  }

  static String get baseUrl => _baseUrl;
}
