import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/apiServices/apiServices.dart';
import '../view/verify_otp/verify_otp_screen.dart';

class LoginController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  final phoneController = TextEditingController();
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Repeating back and forth animation using sin curve
    shakeAnimation = Tween<double>(begin: 0, end: 80).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );

    shakeController.repeat(reverse: true);

    // Stop after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      shakeController.stop();
      shakeController.reset();
    });
  }

  @override
  void onClose() {
    shakeController.dispose();
    super.onClose();
  }

  void loginWithPhone() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      Get.snackbar("Error", "Please enter a valid phone number");
      return;
    }

    isLoading.value = true;

    try {
      final response = await ApiService.login(phone, "+91");

      if (response['message'] == "OTP sent (static)") {
        Get.snackbar("Success", "OTP sent successfully");
        Get.to(() => VerifyOtpScreen(), arguments: {'phone': phone});

      } else {
        Get.snackbar("Failed", "Unable to send OTP");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
