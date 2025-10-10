import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var verificationId = "".obs;
  var isLoading = false.obs;

  /// Step 1: Phone Number Verify
  Future<void> verifyPhone(String phone) async {
    isLoading.value = true;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          isLoading.value = false;
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar("Error", e.message ?? "Verification failed");
          isLoading.value = false;
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          isLoading.value = false;
          Get.toNamed(AppRoutes.verify_otp, arguments: {"phone": phone});
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
          isLoading.value = false;
        },
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
      isLoading.value = false;
    }
  }

  /// Step 2: Verify OTP
  Future<void> verifyOtp(String otp, String phone) async {
    isLoading.value = true;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Check if new user
      final isNew = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (isNew) {
        // Redirect to Signup screen
        Get.offAllNamed(AppRoutes.signup_screen, arguments: {"phone": phone});
      } else {
        // Save locally
        await saveUserLocally(userCredential.user!);
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Step 3: Save user info locally
  Future<void> saveUserLocally(
    User user, {
    String? name,
    String? email,
    String? image,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("uid", user.uid);
    await prefs.setString("phone", user.phoneNumber ?? "");
    if (name != null) await prefs.setString("name", name);
    if (email != null) await prefs.setString("email", email);
    if (image != null) await prefs.setString("image", image);
  }

  /// Step 4: Logout
  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Step 5: Check login
  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey("uid");
  }
}
