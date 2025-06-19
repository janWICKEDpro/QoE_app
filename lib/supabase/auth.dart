import 'dart:developer';

import 'package:qoe_app/data/local/session_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Auth {
  final _instance = Supabase.instance;

  void anonymousLogin() async {
    if (SessionManager().getUserToken() == null) {
      try {
        final response = await _instance.client.auth.signInAnonymously();
        log(
          'Anonymous login response: ${response.session?.accessToken ?? 'Failed'}',
        );
        if (response.session?.accessToken != null) {
          SessionManager().setUserToken(response.session!.accessToken);
        }
      } catch (e) {
        log("Error ${e.toString()}");
      }
    }
  }

  User getUser() {
    final session = _instance.client.auth.currentSession;
    if (session != null) {
      return session.user;
    } else {
      throw Exception('No user is currently logged in');
    }
  }

  String? getToken() {
    return _instance.client.auth.currentSession?.accessToken;
  }
}
