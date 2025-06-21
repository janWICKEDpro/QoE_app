import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qoe_app/utils/plugin.dart';

final StreamController<NotificationResponse> selectNotificationStream =
    StreamController<NotificationResponse>.broadcast();

const MethodChannel platform = MethodChannel(
  'dexterx.dev/flutter_local_notifications_example',
);

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.data,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
  final Map<String, dynamic>? data;
}

String? selectedNotificationPayload;

const String urlLaunchActionId = 'id_1';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryText = 'textCategory';

const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.input?.isNotEmpty ?? false) {}
}

Future<void> showNotification(String title, String message) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    '$title',
    '$message',
    notificationDetails,
    payload: 'item x',
  );
}

Future<void> showNotificationCustomSound({
  String? title,
  String? message,
}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        'your other channel id',
        'your other channel name',
        channelDescription: 'your other channel description',
        sound: RawResourceAndroidNotificationSound('slow_spring_board'),
        priority: Priority.high,
        importance: Importance.max,
      );
  const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(sound: 'slow_spring_board.aiff');

  final NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: darwinNotificationDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    id++,
    title ?? 'Rate your experience',
    message ?? 'Rate your your experience with the app',
    notificationDetails,
  );
}
