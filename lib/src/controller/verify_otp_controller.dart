import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import '../model/verify_otp/verify_otp_model.dart';

class VerifyOtpController extends GetxController {
  final TextEditingController otpController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments['phone'] != null) {
      phone = Get.arguments['phone'];
    }
  }


  String phone = "";
  void setPhone(String phoneNumber) => phone = phoneNumber;

  Future<void> verifyOtp() async {
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse("http://oldmarket.bhoomi.cloud/api/auth/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": phone,
          "otp": otpController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final verifyOtpResponse = VerifyOtpResponse.fromJson(data);

        // save token & userId
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", verifyOtpResponse.token);
        await prefs.setString("userId", verifyOtpResponse.user.id);

        // update GetX TokenController
        TokenController tc;
        if (Get.isRegistered<TokenController>()) {
          tc = Get.find<TokenController>();
        } else {
          tc = Get.put(TokenController(), permanent: true);
        }
        tc.saveToken(verifyOtpResponse.token);

        isLoading.value = false;
        Get.snackbar("Success", verifyOtpResponse.message,
            snackPosition: SnackPosition.TOP);
        Get.offAllNamed(AppRoutes.home);
      } else {
        isLoading.value = false;
        Get.snackbar("Error", "OTP verification failed",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e",
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
