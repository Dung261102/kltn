
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Utils {
  static String _baseUrl = "http://192.168.0.75:3000"; // fallback, dùng IP LAN thực tế

  static Future<void> initBaseUrl() async {
    try {
      if (Platform.isAndroid) {
        final deviceInfo = await DeviceInfoPlugin().androidInfo;
        final isEmulator = !deviceInfo.isPhysicalDevice;

        _baseUrl = isEmulator
            ? "http://10.0.2.2:3000"
            : "http://192.168.0.75:3000"; // IP LAN thực tế
      } else if (Platform.isIOS) {
        final deviceInfo = await DeviceInfoPlugin().iosInfo;
        final isEmulator = !deviceInfo.isPhysicalDevice;

        _baseUrl = isEmulator
            ? "http://192.168.0.75:3000" // iOS emulator cũng dùng IP LAN
            : "http://192.168.0.75:3000";
      } else {
        // For web or desktop
        _baseUrl = "http://192.168.0.75:3000";
      }
      print('Base URL initialized: $_baseUrl');
    } catch (e) {
      print('Error initializing base URL: $e');
      // Keep the fallback URL
    }
  }

  static String get baseUrl => _baseUrl;
}
