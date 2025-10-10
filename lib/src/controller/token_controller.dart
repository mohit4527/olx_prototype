import 'package:get/get.dart';
import 'ads_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// TokenController to manage API token
class TokenController extends GetxController {
  var apiToken = ''.obs;
  // Additional flag to cover non-API logins (e.g., Firebase/Google)
  var loggedInFlag = false.obs;
  // Expose saved user display name and photo url for UI
  var displayName = ''.obs;
  var photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTokenFromStorage();
  }

  /// Load token from SharedPreferences
  Future<void> loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final logged = prefs.getBool('isLoggedIn') ?? false;
      final savedName = prefs.getString('user_display_name') ?? '';
      final savedPhoto = prefs.getString('user_photo_url') ?? '';
      apiToken.value = token;
      loggedInFlag.value = logged;
      displayName.value = savedName;
      photoUrl.value = savedPhoto;
      Logger.d(
        'TokenController',
        'Loaded token from storage: ${token.isNotEmpty ? 'Token exists' : 'No token'}',
      );
    } catch (e) {
      Logger.d('TokenController', 'Error loading token: $e');
    }
  }

  /// Save API token
  Future<void> saveApiToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setBool('isLoggedIn', true);
      apiToken.value = token;
      loggedInFlag.value = true;
      Logger.d('TokenController', 'Token saved successfully');
      // If AdsController is active, refresh its data so "My Ads" reflects the logged-in user
      try {
        if (Get.isRegistered<AdsController>()) {
          final ads = Get.find<AdsController>();
          ads.fetchMyVideos();
          ads.fetchMyProducts();
          Logger.d(
            'TokenController',
            'Triggered AdsController refresh after token save',
          );
        }
      } catch (e) {
        Logger.d(
          'TokenController',
          'Could not trigger AdsController refresh: $e',
        );
      }
    } catch (e) {
      Logger.d('TokenController', 'Error saving token: $e');
    }
  }

  /// Clear token and user info
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      apiToken.value = '';

      // Also clear user info
      await clearUserInfo();
      // Clear logged in flag
      await prefs.setBool('isLoggedIn', false);
      loggedInFlag.value = false;

      Logger.d('TokenController', 'Token and user info cleared');
    } catch (e) {
      Logger.d('TokenController', 'Error clearing token: $e');
    }
  }

  /// Save user information
  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save individual user info fields
      if (userInfo['uid'] != null) {
        await prefs.setString('user_uid', userInfo['uid']);
      }
      if (userInfo['email'] != null) {
        await prefs.setString('user_email', userInfo['email']);
      }
      if (userInfo['displayName'] != null) {
        await prefs.setString('user_display_name', userInfo['displayName']);
        displayName.value = userInfo['displayName'].toString();
      }
      if (userInfo['photoURL'] != null) {
        await prefs.setString('user_photo_url', userInfo['photoURL']);
        photoUrl.value = userInfo['photoURL'].toString();
      }
      if (userInfo['loginMethod'] != null) {
        await prefs.setString('login_method', userInfo['loginMethod']);
      }

      Logger.d('TokenController', 'User info saved successfully');
    } catch (e) {
      Logger.d('TokenController', 'Error saving user info: $e');
    }
  }

  /// Get user information
  Future<Map<String, String?>> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'uid': prefs.getString('user_uid'),
        'email': prefs.getString('user_email'),
        'displayName': prefs.getString('user_display_name'),
        'photoURL': prefs.getString('user_photo_url'),
        'loginMethod': prefs.getString('login_method'),
      };
    } catch (e) {
      Logger.d('TokenController', 'Error getting user info: $e');
      return {};
    }
  }

  /// Clear user information
  Future<void> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_uid');
      await prefs.remove('user_email');
      await prefs.remove('user_display_name');
      await prefs.remove('user_photo_url');
      await prefs.remove('login_method');
      displayName.value = '';
      photoUrl.value = '';
      Logger.d('TokenController', 'User info cleared');
    } catch (e) {
      Logger.d('TokenController', 'Error clearing user info: $e');
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => apiToken.value.isNotEmpty || loggedInFlag.value;

  /// Mark logged in via non-API flow (e.g., Firebase/Google)
  Future<void> markLoggedInViaExternal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      loggedInFlag.value = true;
      Logger.d('TokenController', 'Marked user as logged in (external)');
    } catch (e) {
      Logger.d('TokenController', 'Error marking logged in: $e');
    }
  }
}
