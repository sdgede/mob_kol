import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sevanam_mobkol/services/config/config.dart' as config;

enum NotificationMode { internal, general }

class NotificationUtils {
  static NotificationUtils instance = NotificationUtils();

  Future<void> showNotification(BuildContext context, String title, String body) async {
    debugPrint("NOTIFICATION [TITLE] : $title");
    debugPrint("NOTIFICATION [BODY] : $body");

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      Platform.isAndroid ? "ANDROID" : "IOS",
      config.companyName,
      channelDescription: 'This channel is used for mobnas notification.',
      importance: Importance.max,
      playSound: true,
      priority: Priority.max,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );
    await FlutterLocalNotificationsPlugin().show(0, title, body, notificationDetails);
  }
}
