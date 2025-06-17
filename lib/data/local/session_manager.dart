
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
    await _prefs?.setString(StorageKeys.userToken, token);
  }

  String? getUserToken() {
    return _prefs?.getString(StorageKeys.userToken);
  }


  Future<void> setOnboarded(bool value) async {
    await _prefs?.setBool(StorageKeys.hasOnboarded, value);
  }

  bool hasOnboarded() {
    return _prefs?.getBool(StorageKeys.hasOnboarded) ?? false;
  }

  Future<void> setProfileCompleted(bool value) async {
    await _prefs?.setBool(StorageKeys.profileStatus, value);
  }

  bool isProfileCompleted() {
    return _prefs?.getBool(StorageKeys.profileStatus) ?? false;
  }


  Future<void> clearSession() async {
    await _prefs?.clear();
  }
}