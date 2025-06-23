import 'dart:async';
import 'dart:developer' as lg;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:dart_ping/dart_ping.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:network_type_detector/network_type_detector.dart';
import 'package:qoe_app/constants/env.dart';
import 'package:qoe_app/data/local/session_manager.dart';
import 'package:qoe_app/services/notification_service.dart';
import 'package:qoe_app/supabase/db_methods.dart';
import 'package:qoe_app/utils/plugin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qoe_app/utils/utility_functions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_signal_strength/flutter_signal_strength.dart';
import 'package:sim_card_info/sim_card_info.dart';

import 'package:qoe_app/services/location_service.dart';
import 'package:qoe_app/models/statistic.dart';

const notificationChannelId = 'my_foreground';
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
    final service = FlutterBackgroundService();
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      notificationChannelId,
      'QoE App Service',
      description: 'This channel is used for background network monitoring.',
      importance: Importance.low,
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
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  int init = 0;
  if (service is AndroidServiceInstance) {
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'QoE Service',
      'Service starting...', 
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'QoE App Service',
          icon: 'app_icon',
          ongoing: true,
          priority: Priority.low,
        ),
      ),
    );
  }
  await dotenv.load(fileName: ".env");
  SessionManager().init();
  await Supabase.initialize(
    url: EnvironmentVariables.supabaseUrl,
    anonKey: EnvironmentVariables.supabaseAnonKey,
  );
  lg.log("Background Service: Supabase initialized.");
  final SimCardInfo simCardInfo = SimCardInfo();
  final LocationService locationService = LocationService();

  final DbMethods dbMethods = DbMethods();
  await locationService.initialize();

  service.on('stop').listen((event) {
    service.stopSelf();
    lg.log("Background Service: Service stopped.");
  });

  dbMethods.listenToNewEvents().listen((e) {
    if (init != 0) {
      showNotification((e)['title'] as String, (e)['message'] as String);
    }
    init++;
    lg.log("Background Service: Listening to new events.");
  });
  List<double> successfulPingTimes = [];
  int packetsTransmitted = 0;
  int packetsReceived = 0;
  StreamSubscription<PingData>? pingSubscription;
  bool processing = false;
  Timer.periodic(const Duration(seconds: 100), (timer) {
    showNotificationCustomSound();
  });
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (SessionManager().deviceId() == 0) return;
    if (processing) {
      return;
    }
    processing = true;
    final connectivity = Connectivity();
    final connectivityResult = await _getNetworkType(connectivity);
    if (connectivityResult == ConnectivityResult.none) {
      lg.log(
        "Background Service: No internet connection. Skipping statistics collection.",
      );
      if (service is AndroidServiceInstance) {
        flutterLocalNotificationsPlugin.show(
          notificationId,
          'QoE Service',
          'No Internet Connection',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              notificationChannelId,
              'QoE App Service',
              icon: 'app_icon',
              ongoing: true,
            ),
          ),
        );
      }
      return;
    }

    lg.log(
      "Background Service: Internet connected. Collecting network statistics...",
    );
    successfulPingTimes.clear();
    packetsTransmitted = 0;
    packetsReceived = 0;

    final String targetHost = '8.8.8.8';
    final int pingCount = 10;

    if (service is AndroidServiceInstance) {
      flutterLocalNotificationsPlugin.show(
        notificationId,
        'QoE Service',
        'Collecting data... ${DateTime.now().second}s',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            notificationChannelId,
            'QoE App Service',
            icon: 'app_icon',
            ongoing: true,
          ),
        ),
      );
    }
    String? ip = await fetchIpAddress();
    pingSubscription = Ping(
      targetHost,
      count: pingCount,
      timeout: 30,
    ).stream.listen(
      (PingData event) {
        packetsTransmitted++;

        if (event.response != null && event.response!.time != null) {
          packetsReceived++;
          successfulPingTimes.add(
            event.response!.time!.inMilliseconds.toDouble(),
          );
          lg.log(
            "Ping response: ${event.response!.time!.inMilliseconds}ms from ${event.response!.ip}",
          );
        } else {
          lg.log("Ping failed: ${event.error ?? 'Unknown error'}");
        }
      },
      onError: (e) {
        lg.log('Background Service: Ping stream error: $e');
      },
      onDone: () async {
        lg.log(
          'Background Service: Ping sequence completed. Calculating metrics...',
        );
        pingSubscription?.cancel();

        double calculatedLatency = 0.0;
        double calculatedJitter = 0.0;
        double calculatedPacketLoss = 0.0;

        if (successfulPingTimes.isNotEmpty) {
          calculatedLatency =
              successfulPingTimes.reduce((a, b) => a + b) /
              successfulPingTimes.length;

          if (successfulPingTimes.length > 1) {
            double totalJitter = 0.0;
            for (int i = 0; i < successfulPingTimes.length - 1; i++) {
              totalJitter +=
                  (successfulPingTimes[i + 1] - successfulPingTimes[i]).abs();
            }
            calculatedJitter = totalJitter / (successfulPingTimes.length - 1);
          } else {
            calculatedJitter = 0.0; // Not enough pings to calculate jitter
          }
        } else {
          calculatedLatency = -1.0;
          calculatedJitter = -1.0;
        }

        if (packetsTransmitted > 0) {
          calculatedPacketLoss =
              ((packetsTransmitted - packetsReceived) / packetsTransmitted) *
              100.0;
        } else {
          calculatedPacketLoss = 100.0;
        }

        final Random random = Random();
        final double simulatedBandwidth =
            10 + random.nextDouble() * 90; // 10-100 Mbps

        // --- Collect other necessary metrics ---
        String? carrierName;
        String? signalStrength;
        String? locationName;
        double? latitude;
        double? longitude;
        String? networkType;
        final networkTypeDetectorPlugin = NetworkTypeDetector();
        NetworkStatus networkStatus =
            await networkTypeDetectorPlugin.currentNetworkStatus();
        networkType = networkStatus.name;
        try {
          if (Platform.isAndroid || Platform.isIOS) {
            final simInfo = await simCardInfo.getSimInfo();
            if (simInfo != null && simInfo.isNotEmpty) {
              carrierName = simInfo.first.carrierName;
            }
          }
        } catch (e) {
          lg.log('Background Service: Error getting carrier name: $e');
        }

        try {
          signalStrength = await _getSignalStrength();
        } catch (e) {
          lg.log('Background Service: Error getting signal strength: $e');
        }

        try {
          await locationService.ensureLocationAvailable();
          if (locationService.currentPosition != null) {
            latitude = locationService.currentPosition!.latitude;
            longitude = locationService.currentPosition!.longitude;
            if (locationService.locationName.isNotEmpty &&
                locationService.townCountry.isNotEmpty) {
              locationName =
                  "${locationService.locationName}, ${locationService.townCountry}";
            } else if (locationService.townCountry.isNotEmpty) {
              locationName = locationService.townCountry;
            } else {
              locationName =
                  "Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}";
            }
          } else if (locationService.error != null) {
            locationName = "Location Error: ${locationService.error}";
            lg.log(
              'Background Service: Location Service Error: ${locationService.error}',
            );
          } else {
            locationName = "Location Unknown";
          }
        } catch (e) {
          lg.log('Background Service: Error getting location: $e');
        }
        final Statistic statistic = Statistic(
          deviceId: SessionManager().deviceId(),
          carrierName: carrierName,
          jitter: calculatedJitter,
          latency: calculatedLatency,
          signalStrength: signalStrength,
          packetLoss: calculatedPacketLoss,
          bandwidth: simulatedBandwidth,
          locationName: locationName,
          longitude: longitude,
          latitude: latitude,
          ip: ip,
          networkType: networkType,
        );

        bool stored = await dbMethods.storeNetworkStatistics(statistic);
        processing = false;
        if (stored) {
          lg.log("Background Service: Stored network statistics successfully.");
          if (service is AndroidServiceInstance) {
            flutterLocalNotificationsPlugin.show(
              notificationId,
              'QoE Service',
              'Data collected: ${DateTime.now().toIso8601String().substring(11, 19)}',
              const NotificationDetails(
                android: AndroidNotificationDetails(
                  notificationChannelId,
                  'QoE App Service',
                  icon: 'app_icon',
                  ongoing: true,
                ),
              ),
            );
          }
        } else {
          lg.log("Background Service: Failed to store network statistics.");
        }
      },
    );
  });
}

Future<ConnectivityResult> _getNetworkType(Connectivity connectivity) async {
  try {
    final connectivityResult = await connectivity.checkConnectivity();
    return connectivityResult;
  } catch (e) {
    return ConnectivityResult.other;
  }
}

Future<String?> _getSignalStrength() async {
  if (Platform.isAndroid) {
    try {
      final signalStrengthPlugin = FlutterSignalStrength();
      int? strength = await signalStrengthPlugin.getCellularSignalStrength();
      return "$strength/5";
    } on PlatformException catch (e) {
      debugPrint("Failed to get signal strength on Android: ${e.message}");
      return "Error";
    }
  } else {
    return "N/A on iOS";
  }
}

Stream<PingData> pingData() {
  var ping = Ping('google.com', count: 10);
  return ping.stream;
}

// double _calculateJitter(List<double> pings) {
//   if (pings.length < 2) return 0;

//   double sumDiff = 0;
//   for (int i = 1; i < pings.length; i++) {
//     sumDiff += (pings[i] - pings[i - 1]).abs();
//   }

//   return sumDiff / (pings.length - 1);
// }
