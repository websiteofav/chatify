import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ReceiveNotification {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidInitializationSettings _androidInitializationSettings =
      AndroidInitializationSettings("app_icon");

  ReceiveNotification() {
    const InitializationSettings initializationSettings =
        InitializationSettings(android: _androidInitializationSettings);

    initAll(initializationSettings);
  }

  initAll(InitializationSettings initializationSettings) async {
    final response = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) async {
        debugPrint("Foregroun notifciation $details");
      },
    );

    debugPrint("Local Notification response: $response");
  }

  Future<void> showForegroundNotification(
      {required String title, required String body}) async {
    try {
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails("CHANNEL ID", "chatify",
              channelDescription: "A Messaging app",
              importance: Importance.max);

      const NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails);

      await _flutterLocalNotificationsPlugin
          .show(0, title, body, notificationDetails, payload: title);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
