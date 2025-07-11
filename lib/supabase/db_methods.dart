import 'dart:developer';

import 'package:qoe_app/data/local/session_manager.dart';
import 'package:qoe_app/models/review.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/material.dart';
import 'package:qoe_app/models/device.dart';
import 'package:qoe_app/models/statistic.dart';

class DbMethods {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<bool> storeDeviceInformation(Device device) async {
    if (SessionManager().hasRegisteredDevice()) return true;
    try {
      final String? sessionToken =
          _supabaseClient.auth.currentSession?.accessToken;

      if (sessionToken == null) {
        debugPrint(
          'Error: Supabase session token is null. User might not be authenticated.',
        );
        return false;
      }

      // If identifier is not "unknown", check if it exists in Supabase
      if (device.identifier != "unknown") {
        final List<Map<String, dynamic>> existingDevices = await _supabaseClient
            .from('Device')
            .select()
            .eq('device_identifier', device.identifier!);

        if (existingDevices.isNotEmpty) {
          // Device already exists, update SessionManager and return
          final existingDevice = existingDevices.first;
          SessionManager().setHasRegisteredDevice(true);
          SessionManager().setDeviceId(existingDevice['id']);
          return true;
        }
      }

      // Insert device (either identifier is "unknown" or not found in Supabase)
      final Map<String, dynamic> dataToInsert = {
        ...device.toJson(),
        'token': sessionToken,
      };

      final List<Map<String, dynamic>> response =
          await _supabaseClient.from('Device').insert(dataToInsert).select();

      if (response.isNotEmpty) {
        log("RESPONSE: ${response}");
        log("RESPONSE: ${response.first}");
        log("RESPONSE: ${response.first['id']}");
        SessionManager().setHasRegisteredDevice(true);
        SessionManager().setDeviceId(response.first['id']);
        return true;
      } else {
        debugPrint('Failed to store device information: Response was empty.');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error storing device information: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> storeNetworkStatistics(Statistic statistic) async {
    try {
      // Ensure deviceId is present as it's a foreign key and nullable in the model
      if (statistic.deviceId == null) {
        debugPrint(
          'Error: deviceId is null for network statistics. Cannot store.',
        );
        return false;
      }

      // Prepare the data to be inserted.
      // Omit 'id' and 'created_at' as they are auto-generated by Supabase.
      final Map<String, dynamic> dataToInsert = statistic.toJson();

      // Perform the insert operation
      final List<Map<String, dynamic>> response =
          await _supabaseClient
              .from('NetworkStatistics')
              .insert(dataToInsert)
              .select(); // Use .select() to return the inserted row(s)

      if (response.isNotEmpty) {
        debugPrint('Network statistics stored successfully: ${response.first}');
        return true;
      } else {
        debugPrint('Failed to store network statistics: Response was empty.');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error storing network statistics: $e\n$stackTrace');
      return false;
    }
  }

  Future<bool> storeReviews(Review review) async {
    try {
      final Map<String, dynamic> dataToInsert = {
        ...review.toJson(),
        'device_id': SessionManager().deviceId(),
      };

      final List<Map<String, dynamic>> response =
          await _supabaseClient.from('Reviews').insert(dataToInsert).select();

      if (response.isNotEmpty) {
        debugPrint('Reviews Stored Successfully: ${response.first}');
        return true;
      } else {
        debugPrint('Failed to store Reviews: Response was empty.');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error storing Reviews: $e\n$stackTrace');
      return false;
    }
  }

  Stream<Map<String, dynamic>> listenToNewEvents() {
    log("Started listening");
    return _supabaseClient
        .from('Event')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((events) => events.isNotEmpty ? events.first : null)
        .where((event) => event != null)
        .cast<Map<String, dynamic>>();
  }
}
