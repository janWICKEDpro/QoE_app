import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signal_strength/flutter_signal_strength.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:sim_card_info/sim_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:qoe_app/services/location_service.dart';

class NetworkInfoProvider with ChangeNotifier {
  int _signalStrength = 0;
  String _currentCarrier = "Unknown";

  int _numberOfSimCards = 0;
  List<SimInfo> _simCardDetails = [];
  String _currentSimForInternet = "N/A";

  String _currentLocation = "Fetching location...";
  String _osVersion = "Unknown OS";
  String _phoneModel = "Unknown Device";

  bool _isLoading = false;
  String? _errorMessage;

  final LocationService _locationService = LocationService();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  int get signalStrength => _signalStrength;
  String get currentCarrier => _currentCarrier;
  int get numberOfSimCards => _numberOfSimCards;
  List<SimInfo> get simCardDetails => _simCardDetails;
  String get currentSimForInternet => _currentSimForInternet;
  String get currentLocation => _currentLocation;
  String get osVersion => _osVersion;
  String get phoneModel => _phoneModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NetworkInfoProvider() {
    _locationService.addListener(_onLocationServiceChange);
    fetchNetworkInfo();
  }

  void _onLocationServiceChange() {
    if (_locationService.currentPosition != null) {
      if (_locationService.locationName.isNotEmpty &&
          _locationService.townCountry.isNotEmpty) {
        _currentLocation =
            "${_locationService.locationName}, ${_locationService.townCountry}";
      } else if (_locationService.townCountry.isNotEmpty) {
        _currentLocation = _locationService.townCountry;
      } else {
        _currentLocation =
            "Lat: ${_locationService.currentPosition!.latitude.toStringAsFixed(4)}, Long: ${_locationService.currentPosition!.longitude.toStringAsFixed(4)}";
      }
    } else if (_locationService.error != null) {
      _currentLocation = "Error: ${_locationService.error}";
    } else {
      _currentLocation = "Location unknown";
    }
    notifyListeners();
  }

  Future<void> fetchNetworkInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _fetchSignalStrength();
      await _fetchSimInfo();
      await _fetchDeviceInfo();
      await _fetchLocation();
    } catch (e) {
      _errorMessage = "Failed to fetch network info: $e";
      debugPrint("Error fetching network info: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchSignalStrength() async {
    if (Platform.isAndroid) {
      try {
        final signalStrengthPlugin = FlutterSignalStrength();
        int? strength = await signalStrengthPlugin.getCellularSignalStrength();
        _signalStrength = strength ;
        log("Signal Strength: $_signalStrength");
      } on PlatformException catch (e) {
        debugPrint("Failed to get signal strength on Android: ${e.message}");
        _signalStrength = 0;
      }
    } else {
      _signalStrength = 0;
    }
  }

  Future<void> _fetchSimInfo() async {
    await Permission.phone.request();
    //await MobileNumber.requestPhonePermission;
    try {
      final simInfoPlugin = SimCardInfo();
      List<SimInfo>? simCards = await simInfoPlugin.getSimInfo();
      log("SIM CARD OH: ${simCards?.length ?? 0}");
      _simCardDetails = simCards ?? [];
      _numberOfSimCards = _simCardDetails.length;

      if (_numberOfSimCards == 1) {
        _currentSimForInternet = _simCardDetails.first.carrierName;
      } else if (_numberOfSimCards > 1) {
        _currentSimForInternet =
            "Multiple SIMs (Cannot determine active data SIM)";
      } else {
        log("Failed to get SIM info:");
        _currentSimForInternet = "No SIMs found";
      }
    } on PlatformException catch (e) {
      log("Failed to get SIM info: ${e.message}");
      _simCardDetails = [];
      _numberOfSimCards = 0;
      _currentSimForInternet = "Error fetching SIM info";
    }
  }

  Future<void> _fetchDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfoPlugin.androidInfo;
        _osVersion =
            "Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})";
        _phoneModel = "${androidInfo.name} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfoPlugin.iosInfo;
        _osVersion = "iOS ${iosInfo.systemVersion}";
        _phoneModel = iosInfo.modelName;
      } else {
        _osVersion = "Non-Android/iOS Device";
        _phoneModel = "Unknown Device";
      }
    } on PlatformException catch (e) {
      debugPrint("Failed to get device info: ${e.message}");
      _osVersion = "Error fetching OS";
      _phoneModel = "Error fetching model";
    }
  }

  Future<void> _fetchLocation() async {
    await _locationService.initialize();
    _onLocationServiceChange(); // Update immediately after initialize
  }

  @override
  void dispose() {
    _locationService.removeListener(_onLocationServiceChange);
    _locationService.dispose();
    super.dispose();
  }
}
