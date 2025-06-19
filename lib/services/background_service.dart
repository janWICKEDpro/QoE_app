import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:qoe_app/utils/plugin.dart';

const notificationChannelId = 'my_foreground';

// this will be used for notification id, So you can update your custom notification with this id.
const notificationId = 888;

class BackgroundService {
  void startBackgroundService() {
    final service = FlutterBackgroundService();
    service.startService();
  }

  void stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  Future<void> initializeService() async {
    log("Tried to initialize background service");
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId, // id
      'MY FOREGROUND SERVICE', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.low, // importance must be at low or higher level
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: true,
        autoStartOnBoot: true,
        notificationChannelId: notificationChannelId,
        foregroundServiceNotificationId: notificationId,
        foregroundServiceTypes: [AndroidForegroundType.dataSync],
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // final socket = io.io("your-server-url", <String, dynamic>{
  //   'transports': ['websocket'],
  //   'autoConnect': true,
  // });
  // socket.onConnect((_) {
  //   print('Connected. Socket ID: ${socket.id}');
  //   // Implement your socket logic here
  //   // For example, you can listen for events or send data
  // });

  // socket.onDisconnect((_) {
  //   print('Disconnected');
  // });
  //  socket.on("event-name", (data) {
  //   //do something here like pushing a notification
  // });
  // service.on("stop").listen((event) {
  //   service.stopSelf();
  //   print("background process is now stopped");
  // });

  // service.on("start").listen((event) {});

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    // socket.emit("event-name", "your-message");
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'QoE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'MY FOREGROUND SERVICE',
              icon: 'app_icon',
              ongoing: true,
            ),
          ),
        );
      }
      // print("service is successfully running ${DateTime.now().second}");
      // log("message sent at ${DateTime.now().second}");
    }
  });
}
