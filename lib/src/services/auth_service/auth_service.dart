// lib/src/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getDealerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('dealerId');
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
