import 'package:qoe_app/constants/storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  SharedPreferences? _prefs;

  SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setUserToken(String token) async {
    await _prefs?.setString(StorageKeys.token, token);
  }

  String? getUserToken() {
    return _prefs?.getString(StorageKeys.token);
  }

  Future<void> setOnboarded(bool value) async {
    await _prefs?.setBool(StorageKeys.hasOnboarded, value);
  }

  bool hasOnboarded() {
    return _prefs?.getBool(StorageKeys.hasOnboarded) ?? false;
  }

  Future<void> setHasRegisteredDevice(bool value) async {
    await _prefs?.setBool(StorageKeys.hasRegistered, value);
  }

  bool hasRegisteredDevice() {
    return _prefs?.getBool(StorageKeys.hasRegistered) ?? false;
  }

  Future<void> setDeviceId(int value) async {
    await _prefs?.setInt(StorageKeys.deviceId, value);
  }

  int deviceId() {
    return _prefs?.getInt(StorageKeys.deviceId) ?? 0;
  }

  Future<void> clearSession() async {
    await _prefs?.clear();
  }
}
