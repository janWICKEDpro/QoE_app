import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:qoe_app/supabase/db_methods.dart';
import 'package:qoe_app/utils/utility_functions.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:qoe_app/services/location_service.dart';
import 'package:qoe_app/models/device.dart';
import 'dart:io' show Platform;

class DeviceInfoProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Device? _currentDevice;

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  final SimCardInfo _simCardInfo = SimCardInfo();
  final LocationService _locationService = LocationService();
  final DbMethods _dbMethods = DbMethods();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Device? get currentDevice => _currentDevice;

  DeviceInfoProvider() {
    _locationService.addListener(_onLocationServiceChange);
    _locationService.initialize();
  }

  void _onLocationServiceChange() {
    _updateCurrentDeviceWithLocation();
    notifyListeners();
  }

  Future<void> fetchAndStoreDeviceInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? ipAddress = await fetchIpAddress();

      int? numberOfSims = await _fetchNumberOfSims();

      Map<String, String?> deviceOsInfo = await _fetchDeviceOsInfo();
      log("DEVICE INFO: $deviceOsInfo");
      String? deviceName = deviceOsInfo['deviceName'];
      String? osVersion = deviceOsInfo['osVersion'];
      String? identifier = deviceOsInfo['device_identifier'];
      await _locationService.ensureLocationAvailable();
      _updateCurrentDeviceWithLocation();
      log("WE ARE HERE: GOT ALL INFO");
      _currentDevice = Device(
        ipAddress: ipAddress,
        locationName: _currentDevice?.locationName,
        longitude: _currentDevice?.longitude,
        latitude: _currentDevice?.latitude,
        deviceName: '$deviceName ($osVersion)',
        numberOfSims: numberOfSims,
        identifier: identifier,
      );

      bool storedSuccessfully = await _dbMethods.storeDeviceInformation(
        _currentDevice!,
      );
      log("WE ARE HERE: ${storedSuccessfully}");
      if (!storedSuccessfully) {
        throw Exception('Failed to store device information in Supabase.');
      }

      log('Successfully fetched and stored device information.');
    } catch (e, stackTrace) {
      _errorMessage = 'Error fetching or storing device info: $e';
      log('Error in fetchAndStoreDeviceInfo: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches the number of SIM cards.
  Future<int?> _fetchNumberOfSims() async {
    try {
      if (Platform.isAndroid) {
        final simCards = await _simCardInfo.getSimInfo();
        return simCards?.length;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting number of SIMs: $e');
      return null;
    }
  }

  Future<Map<String, String?>> _fetchDeviceOsInfo() async {
    String? deviceName;
    String? osVersion;
    String? identifier;

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
        osVersion = "Android ${androidInfo.version.release}";
        identifier = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceName = iosInfo.name;
        osVersion = "iOS ${iosInfo.systemVersion}";
        identifier = iosInfo.identifierForVendor ?? "unkown";
      } else {
        deviceName = 'Unknown Device';
        osVersion = 'Unknown OS';
        identifier = "unkown identifier";
      }
    } catch (e) {
      debugPrint('Error fetching device OS info: $e');
      deviceName = 'Error Device';
      osVersion = 'Error OS';
      identifier = "unkown identifier";
    }

    return {
      'deviceName': deviceName,
      'osVersion': osVersion,
      'device_identifier': identifier,
    };
  }

  void _updateCurrentDeviceWithLocation() {
    String? locationName;
    double? latitude;
    double? longitude;

    if (_locationService.currentPosition != null) {
      latitude = _locationService.currentPosition!.latitude;
      longitude = _locationService.currentPosition!.longitude;
      if (_locationService.locationName.isNotEmpty &&
          _locationService.townCountry.isNotEmpty) {
        locationName =
            "${_locationService.locationName}, ${_locationService.townCountry}";
      } else if (_locationService.townCountry.isNotEmpty) {
        locationName = _locationService.townCountry;
      } else {
        locationName =
            "Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}";
      }
    } else if (_locationService.error != null) {
      locationName = "Location Error: ${_locationService.error}";
    } else {
      locationName = "Location unknown";
    }

    _currentDevice =
        _currentDevice?.copyWith(
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
        ) ??
        Device(
          locationName: locationName,
          latitude: latitude,
          longitude: longitude,
        );
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationServiceChange);
    _locationService.dispose();
    super.dispose();
  }
}
