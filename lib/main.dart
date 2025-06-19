import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:qoe_app/constants/env.dart';
import 'package:qoe_app/data/local/session_manager.dart';
import 'package:qoe_app/providers/device_info_provider.dart';
import 'package:qoe_app/providers/network_info_provider.dart';
import 'package:qoe_app/routes/routes.dart';
import 'package:qoe_app/services/background_service.dart';
import 'package:qoe_app/services/location_service.dart';
import 'package:qoe_app/services/notification_service.dart';
import 'package:qoe_app/supabase/auth.dart';
import 'package:qoe_app/utils/plugin.dart';
import 'package:qoe_app/utils/utility_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    dotenv.load(fileName: ".env"),
    SessionManager().init(),
    LocationService().initialize(),
  ]);
  await Supabase.initialize(
    url: EnvironmentVariables.supabaseUrl,
    anonKey: EnvironmentVariables.supabaseAnonKey,
  );
  await configureLocalTimeZone();
  await initializeNotificationService();
  final backgroundService = BackgroundService();
  final auth = Auth();
  auth.anonymousLogin();
  await requestPermissions();
  await backgroundService.initializeService();

  final router = RouterClass.instance;

  runApp(FeedbackApp(routes: router));
}

class FeedbackApp extends StatelessWidget {
  final RouterClass routes;

  const FeedbackApp({super.key, required this.routes});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DeviceInfoProvider()..fetchAndStoreDeviceInfo(),
          lazy: false,
        ),
        ChangeNotifierProvider(create: (_) => NetworkInfoProvider()),
      ],
      child: MaterialApp.router(
        title: 'Feedback',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: routes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future initializeNotificationService() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          darwinNotificationCategoryText,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.text(
              'text_1',
              'Action 1',
              buttonTitle: 'Send',
              placeholder: 'Placeholder',
            ),
          ],
        ),
        DarwinNotificationCategory(
          darwinNotificationCategoryPlain,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('id_1', 'Action 1'),
            DarwinNotificationAction.plain(
              'id_2',
              'Action 2 (destructive)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain(
              navigationActionId,
              'Action 3 (foreground)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              'id_4',
              'Action 4 (auth required)',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.authenticationRequired,
              },
            ),
          ],
          options: <DarwinNotificationCategoryOption>{
            DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
          },
        ),
      ];

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        notificationCategories: darwinNotificationCategories,
      );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: selectNotificationStream.add,
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload =
        notificationAppLaunchDetails!.notificationResponse?.payload;
    log("Payload");
  }
}
