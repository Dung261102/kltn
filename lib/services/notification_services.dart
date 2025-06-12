import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task.dart';
import '../ui/pages/reminder/notified_page.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // Plugin thông báo

  initializeNotification() async {
    // tz.initializeTimeZones();
    _configureLocalTimezone();

    // Cấu hình cho iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    // Cấu hình cho Android
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("app_icon");

    // Gộp 2 cấu hình lại
    final InitializationSettings initializationSettings =
        InitializationSettings(
          iOS: initializationSettingsIOS,
          android: initializationSettingsAndroid,
        );

    // Khởi tạo plugin với hàm xử lý khi nhấn thông báo
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await selectNotification(response.payload);
      },
      // ✅ Dùng hàm top-level thay vì hàm trong class
      onDidReceiveBackgroundNotificationResponse:
          backgroundNotificationTapHandler,
    );
  }

  // hàm displayNotification dùng để hiển thị thông báo trong Flutter
  Future<void> displayNotification({
    required String title,
    required String body,
  }) async {
    print("doing test");

    // Cấu hình thông báo cho Android
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    // Cấu hình thông báo cho iOS (DarwinNotificationDetails cho phiên bản mới)
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    // Kết hợp cả hai cấu hình cho Android và iOS
    var platformChannelSpecifics = new NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Hiển thị thông báo
    await flutterLocalNotificationsPlugin.show(
      0, // ID của thông báo
      title, // Tiêu đề thông báo
      body, // Nội dung thông báo
      platformChannelSpecifics,
      payload: title,
    );
  }

  //hàm lên lịch thông báo với thời gian đã định -chưa được
  scheduledNotification(int hour, int minutes, Task task) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!.toInt(),
      task.title,
      task.note,
      _convertTime(hour, minutes),

      // tz.TZDateTime.now(tz.local).add(Duration(seconds: newTime)), // Thời gian gửi
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id', // ID kênh thông báo
          'your_channel_name', // Tên kênh
          channelDescription: 'your channel description', // Mô tả
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "${task.title}|" + "${task.note}|",
    );
  }

  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future<void> _configureLocalTimezone() async {
    tz.initializeTimeZones();
    String timeZone = await FlutterNativeTimezone.getLocalTimezone();

    // Sửa lỗi tên timezone không hợp lệ
    if (timeZone == 'Asia/Saigon') {
      timeZone = 'Asia/Ho_Chi_Minh';
    }

    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  // Hàm cấp quyền cho iOS
  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // ✅ Hàm cấp quyền cho Android (API 33+)
  Future<void> requestAndroidNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // Hàm xử lý khi người dùng nhấn vào thông báo (foreground)
  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }

    if (payload == "Theme Changed") {
      print("Nothing navigate to");
    } else {
      Get.to(() => NotifiedPage(label: payload));
    }
  }

  // Hàm xử lý khi đang foreground mà nhận được thông báo
  Future onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    Get.dialog(Text("Welcome to flutter"));
  }
}

// ✅ Hàm top-level xử lý thông báo khi app đang background/terminated
@pragma('vm:entry-point')
Future<void> backgroundNotificationTapHandler(
  NotificationResponse response,
) async {
  debugPrint("Background Notification payload: ${response.payload}");
  // Có thể thêm xử lý logic ở đây như lưu log, gọi API, v.v.
}
