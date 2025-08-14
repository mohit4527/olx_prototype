
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';



class VerifyOtpController extends GetxController {
  TextEditingController otpController = TextEditingController();

  var isLoading = false.obs;
  String phone = "";

  void setPhone(String phoneNumber) {
    phone = phoneNumber;
  }

  Future<void> verifyOtp() async {
    isLoading.value = true;

    await Future.delayed(const Duration(seconds: 2));
    if (otpController.text == "1234") {
      String token = "abc123xyzToken";
      String userId = "785548296";


   SharedPreferences prefs = await SharedPreferences.getInstance();
   await prefs.setString("auth_token", token);
   await prefs.setString("userId", userId);

   isLoading.value = false;
   Get.snackbar("Success", "OTP Verified Successfully", snackPosition: SnackPosition.TOP);
   Get.offAllNamed(AppRoutes.home);

  } else {
   isLoading.value = false;
    Get.snackbar("Error", "Invalid OTP", snackPosition: SnackPosition.TOP);
   }
   }
}