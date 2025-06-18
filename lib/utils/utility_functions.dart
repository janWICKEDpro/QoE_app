import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:http/http.dart' as http;
import 'package:qoe_app/constants/env.dart';
import 'package:qoe_app/models/location_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

Future<LocationModel> getLocationName(double lat, double lon) async {
  final url = Uri.parse(
    'https://us1.locationiq.com/v1/reverse?key=${EnvironmentVariables.locationIQKey}&lat=$lat&lon=$lon&format=json',
  );
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      final displayName = data['display_name'] as String?;
      final town =
          data['address']['town'] as String? ??
          data['address']['city'] as String? ??
          data['address']['state'] as String?;
      final country = data['address']['country'] as String?;

      return LocationModel(
        address: displayName,
        mainLocation: displayName,
        townCountry: "$town $country",
        latitude: lat,
        longitude: lon,
      );
    } else {
      throw Exception('Failed to fetch location name: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching location name: $e');
  }
}


Future<void> configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}