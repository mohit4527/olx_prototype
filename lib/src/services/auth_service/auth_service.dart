import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // helpful:
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
}
