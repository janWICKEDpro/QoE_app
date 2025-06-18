import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qoe_app/routes/route_names.dart';
import 'package:qoe_app/services/notification_service.dart';
import 'package:qoe_app/utils/plugin.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  void _onTapBottomNav(int index) {
    widget.navigationShell.goBranch(index, initialLocation: true);
  }


  bool _notificationsEnabled = false;
  @override
  initState() {
    super.initState();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureSelectNotificationSubject();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted =
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.areNotificationsEnabled() ??
          false;

      setState(() {
        _notificationsEnabled = granted;
      });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      setState(() {
        _notificationsEnabled = grantedNotificationPermission ?? false;
      });
    }
  }

  Future<void> _requestPermissionsWithCriticalAlert() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    }
  }

  Future<void> _requestNotificationPolicyAccess() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationPolicyAccess();
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((
      NotificationResponse? response,
    ) async {
      context.goNamed(RoutePath.speedTest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTapBottomNav,
      ),
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, required this.currentIndex, this.onTap});
  final int currentIndex;
  final void Function(int)? onTap;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      enableFeedback: false,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedHome01,
            color: currentIndex == 0 ? Colors.blue : Colors.grey,
            size: 30.0,
          ),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedChart01,
            color: currentIndex == 1 ? Colors.blue : Colors.grey,
            size: 30.0,
          ),

          label: "Speed Test",
        ),
        BottomNavigationBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: currentIndex == 2 ? Colors.blue : Colors.grey,
            size: 30.0,
          ),
          label: "Settings",
        ),
      ],
    );
  }
}
