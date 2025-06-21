import 'dart:developer';
import 'dart:typed_data';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:qoe_app/providers/network_info_provider.dart';
import 'package:qoe_app/routes/route_names.dart';
import 'package:qoe_app/services/notification_service.dart';
import 'package:qoe_app/utils/plugin.dart';
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Request permissions before using network/location features
    Future.microtask(() async {
      final networkInfoProvider = Provider.of<NetworkInfoProvider>(
        context,
        listen: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 10,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset("assets/images/feedback1.png", height: 32),
            ),
            const Text('Feedback'),
          ],
        ),
        actions: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedSettings01,
              color: Colors.black,
              size: 30.0,
            ),
            onPressed: () {
              context.goNamed(RoutePath.settings);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final ping = Ping('google.com', count: 5);

              // Begin ping process and listen for output
              ping.stream.listen((event) {
                log("Ping: ${event.response?.time} ms");
              });
            },
            child: Text("PING"),
          ),
          ElevatedButton(
            onPressed: () async {
         //     await _showNotification();
            },
            child: Text("_showNotification"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _showNotificationWithActions();
            },
            child: Text("_showNotificationWithActions"),
          ),
          ElevatedButton(
            onPressed: () async {
           //   await _showNotificationCustomSound();
            },
            child: Text("_showNotificationCustomSound"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _showInsistentNotification();
            },
            child: Text("_showNotificationCustomSound"),
          ),
        ],
      ),
    );
  }

  

  Future<void> _showInsistentNotification() async {
    // This value is from: https://developer.android.com/reference/android/app/Notification.html#FLAG_INSISTENT
    const int insistentFlag = 4;
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          additionalFlags: Int32List.fromList(<int>[insistentFlag]),
        );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'insistent title',
      'insistent body',
      notificationDetails,
      payload: 'item x',
    );
  }



  Future<void> _zonedScheduleNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'scheduled title',
      'scheduled body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _showNotificationWithActions() async {
    const AndroidNotificationDetails
    androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          urlLaunchActionId,
          'Action 1',
          icon: DrawableResourceAndroidBitmap('app_icon'),
          contextual: true,
        ),
        AndroidNotificationAction(
          'id_2',
          'Action 2',
          titleColor: Color.fromARGB(255, 255, 0, 0),
          icon: DrawableResourceAndroidBitmap('app_icon'),
        ),
        AndroidNotificationAction(
          navigationActionId,
          'Action 3',
          icon: DrawableResourceAndroidBitmap('app_icon'),
          showsUserInterface: true,
          // By default, Android plugin will dismiss the notification when the
          // user tapped on a action (this mimics the behavior on iOS).
          cancelNotification: false,
        ),
      ],
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
        );

    const DarwinNotificationDetails macOSNotificationDetails =
        DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: macOSNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      'plain title',
      'plain body',
      notificationDetails,
      payload: 'item z',
    );
  }

  Future<void> _showNotificationWithTextAction() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              'text_id_1',
              'Enter Text',
              icon: DrawableResourceAndroidBitmap('food'),
              inputs: <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(label: 'Enter a message'),
              ],
            ),
          ],
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryText,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id++,
      'Text Input Notification',
      'Expand to see input action',
      notificationDetails,
      payload: 'item x',
    );
  }

  Future<void> _zonedScheduleAlarmClockNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      123,
      'scheduled alarm clock title',
      'scheduled alarm clock body',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_clock_channel',
          'Alarm Clock Channel',
          channelDescription: 'Alarm Clock Notification',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  Future<void> _showNotificationWithNoSound() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'silent channel id',
          'silent channel name',
          channelDescription: 'silent channel description',
          playSound: false,
          styleInformation: DefaultStyleInformation(true, true),
        );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    final WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails(audio: WindowsNotificationAudio.silent());
    final NotificationDetails notificationDetails = NotificationDetails(
      windows: windowsDetails,
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      '<b>silent</b> title',
      '<b>silent</b> body',
      notificationDetails,
    );
  }

  Future<void> _showNotificationSilently() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          silent: true,
        );
    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(presentSound: false);
    final WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails(audio: WindowsNotificationAudio.silent());
    final NotificationDetails notificationDetails = NotificationDetails(
      windows: windowsDetails,
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
      macOS: darwinNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      id++,
      '<b>silent</b> title',
      '<b>silent</b> body',
      notificationDetails,
    );
  }
}
