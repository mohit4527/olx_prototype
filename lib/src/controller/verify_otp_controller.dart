import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';

class VerifyOtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final isLoading = false.obs;

  String verificationId = "";
  // Make phone reactive so UI updates when it's set from Get.arguments
  final phone = ''.obs;
  String countryCode = "";
  bool useFirebase =
      false; // Flag to determine which verification method to use

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      // For Firebase verification (legacy)
      if (Get.arguments['verificationId'] != null) {
        verificationId = Get.arguments['verificationId'];
        useFirebase = true;
      }

      // For API verification (new)
      if (Get.arguments['phone'] != null) {
        phone.value = Get.arguments['phone'].toString();
      }
      if (Get.arguments['countryCode'] != null) {
        countryCode = Get.arguments['countryCode'].toString();
      }
    }
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.length != 4 && otp.length != 6) {
      // Support both 4 and 6 digit OTPs
      Get.snackbar("Error", "Enter a valid OTP");
      return;
    }

    // DEV OVERRIDE: If developer enters 0000, treat as successful verification
    // This is temporary to help QA/devs verify navigation flow quickly.
    // Remove or disable before production.
    if (otp == '0000') {
      try {
        isLoading.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('phone', phone.value);
      } catch (_) {}
      isLoading.value = false;
      Get.snackbar(
        'DEV',
        'Bypassing OTP (0000) — navigating to Home',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAllNamed(AppRoutes.home);
      return;
    }

    try {
      isLoading.value = true;

      if (useFirebase) {
        // Use Firebase verification (legacy)
        await _verifyFirebaseOtp(otp);
      } else {
        // Use API verification (new)
        await _verifyApiOtp(otp);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "OTP verification failed: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// NEW: API-based OTP verification
  Future<void> _verifyApiOtp(String otp) async {
    try {
      // Normalize phone for API: include countryCode if provided and phone
      final rawPhone = phone.value;

      // Build API phone as plain 10-digit number (strip +, country code or any non-digits)
      String digitsOnly(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');
      final rawDigits = digitsOnly(rawPhone);
      String phoneForApi;
      if (rawDigits.length <= 10) {
        phoneForApi = rawDigits;
      } else {
        // If server expects the local 10-digit number, keep the last 10 digits
        phoneForApi = rawDigits.substring(rawDigits.length - 10);
      }

      // Persist the exact request payload so it's easy to share with backend
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'last_verify_request',
          jsonEncode({'phone': phoneForApi, 'otp': otp}),
        );
      } catch (_) {}

      final result = await ApiService.verifyOtp(phoneForApi, otp);

      // Persist the parsed result for quick debugging / copy-paste
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_verify_response', jsonEncode(result));
      } catch (_) {}

      // Extra debug logging so we can see exact API response in console
      try {
        print('🔍 verifyOtp -> request: {phone: $phoneForApi, otp: $otp}');
        print('🔍 verifyOtp -> response: $result');
      } catch (_) {}

      // Temporary debug snackbar showing what we sent (helps during testing).
      // Remove or restrict this in production to avoid exposing OTPs in UI.
      try {
        Get.snackbar(
          'Debug',
          'Sent payload: phone=$phoneForApi otp=$otp',
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {}

      if (result['success'] == true) {
        isLoading.value = false;

        Get.snackbar(
          "Success",
          result['message'] ?? "Login successful",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          snackPosition: SnackPosition.TOP,
          duration: Duration(seconds: 2),
        );

        // Navigate to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        isLoading.value = false;

        // Extract useful error text from result: some APIs return `message`,
        // others return `error` as a string or object. Try common fields.
        String errMsg = "Invalid OTP";
        try {
          if (result['message'] != null &&
              result['message'].toString().isNotEmpty) {
            errMsg = result['message'].toString();
          } else if (result['error'] != null) {
            final e = result['error'];
            if (e is String && e.isNotEmpty) {
              errMsg = e;
            } else if (e is Map &&
                (e['error'] != null || e['message'] != null)) {
              errMsg = (e['message'] ?? e['error']).toString();
            } else {
              errMsg = e.toString();
            }
          }
        } catch (_) {}

        // Show a visible dialog with raw response for debugging (dev)
        try {
          Get.defaultDialog(
            title: 'Verification Failed',
            middleText: errMsg + '\n\nFull response: ' + result.toString(),
            textConfirm: 'OK',
            onConfirm: () => Get.back(),
          );
        } catch (_) {
          Get.snackbar(
            "Verification Failed",
            errMsg,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Network error occurred: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  /// Firebase OTP verification (legacy - keeping for backward compatibility)
  Future<void> _verifyFirebaseOtp(String otp) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(
      credential,
    );

    // Save user UID in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("uid", userCred.user?.uid ?? "");
    await prefs.setString("phone", phone.value);

    String? token = await userCred.user?.getIdToken();
    if (token != null) {
      try {
        final TokenController tokenController = Get.find<TokenController>();
        tokenController.apiToken.value = token;
      } catch (e) {
        print("Could not update TokenController: $e");
      }
    }

    isLoading.value = false;
    Get.snackbar(
      "Success",
      "OTP Verified Successfully",
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 2),
    );
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
