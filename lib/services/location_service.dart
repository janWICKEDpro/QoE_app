import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:qoe_app/utils/utility_functions.dart';

class LocationService with ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;
  LocationPermission? _permissionStatus;
  bool _isLoading = false;
  String? _error;
  bool _serviceEnabled = false;
  String _locationName = "";
  String _townCountry = "";

  Position? get currentPosition => _currentPosition;
  LocationPermission? get permissionStatus => _permissionStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get serviceEnabled => _serviceEnabled;
  String get locationName => _locationName;
  String get townCountry => _townCountry;

  StreamSubscription<Position>? _positionSubscription;
  bool _disposed = false;
  bool get disposed => _disposed;

  Future<void> initialize() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!_serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      await _checkAndRequestPermissions();

      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings:
            LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      );
      startListening();
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('LocationService error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkAndRequestPermissions() async {
    _permissionStatus = await Geolocator.checkPermission();

    if (_permissionStatus == LocationPermission.denied) {
      _permissionStatus = await Geolocator.requestPermission();
      if (_permissionStatus == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (_permissionStatus == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  Future<bool> promptEnableLocation() async {
    try {
      _serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (_serviceEnabled) return true;

      // Show dialog explaining why location is needed
      // In a real app, you would show a custom dialog here
      // and then call openLocationSettings() if user agrees

      return await openLocationSettings();
    } catch (e) {
      debugPrint('Error prompting to enable location: $e');
      return false;
    }
  }

  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('Error opening location settings: $e');
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      await _checkAndRequestPermissions();
      if (_permissionStatus == LocationPermission.whileInUse ||
          _permissionStatus == LocationPermission.always) {
        await initialize();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  Future<bool> ensureLocationAvailable() async {
    if (_currentPosition != null) return true;

    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!_serviceEnabled) {
      return await promptEnableLocation();
    }

    if (_permissionStatus == LocationPermission.denied ||
        _permissionStatus == LocationPermission.deniedForever) {
      return await requestLocationPermission();
    }

    if (_currentPosition == null) {
      await initialize();
      return _currentPosition != null;
    }

    return true;
  }

  static const double _locationNameUpdateThreshold = 200.0;
  Position? _lastLocationNamePosition;

  void startListening() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      if (_disposed) return;
      bool shouldUpdateLocationName = false;

      if (_lastLocationNamePosition == null) {
        shouldUpdateLocationName = true;
      } else {
        final distance = Geolocator.distanceBetween(
          _lastLocationNamePosition!.latitude,
          _lastLocationNamePosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance > _locationNameUpdateThreshold) {
          shouldUpdateLocationName = true;
        }
      }

      if (shouldUpdateLocationName) {
        _lastLocationNamePosition = position;
        getNameOfLocation(position.latitude, position.longitude);
      }

      _currentPosition = position;
      notifyListeners();
    });
  }

  void getNameOfLocation(double lat, double long) async {
    try {
      final result = await getLocationName(lat, long);
      _locationName = result.mainLocation ?? "";
      _townCountry = result.townCountry ?? "";
    } catch (e) {
      _locationName = "";
    } finally {
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
     super.dispose();
    _disposed = true;
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}