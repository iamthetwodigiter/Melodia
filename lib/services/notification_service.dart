import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotification =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await flutterLocalNotification.initialize(initializationSettings);
  }

  static Future<void> showInstanceNotification(String title, String body,
      {int? progress, int? maxProgress}) async {
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.thetwodigiter.melodia.notification',
        'Notification',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: false,
        progress: progress ?? 0,
        maxProgress: maxProgress ?? 0,
        showProgress: progress?.isFinite ?? false,
        
      ),
    );
    await flutterLocalNotification.show(
        0, title, body, platformChannelSpecifics);
  }
}
