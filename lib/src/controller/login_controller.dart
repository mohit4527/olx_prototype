import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../utils/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isEmailValid = true.obs;
  var isPasswordValid = true.obs;
  var isLoading = false.obs;
  RxBool isPasswordHidden = true.obs;
  RxBool rememberMe = false.obs;

  void validateEmail(String email) {
    if (email.isEmpty || !email.contains("@")) {
      isEmailValid.value = false;
    } else {
      isEmailValid.value = true;
    }
  }


  void validatePassword(String password) {
    if (password.isEmpty || password.length < 6) {
      isPasswordValid.value = false;
    } else {
      isPasswordValid.value = true;
    }
  }

  Future<bool> login() async {
    validateEmail(emailController.text);
    validatePassword(passwordController.text);

    if (isEmailValid.value && isPasswordValid.value) {
      isLoading.value = true;
      await Future.delayed(Duration(seconds: 2));
      isLoading.value = false;
      Get.offAllNamed(AppRoutes.home);
      fieldClear();
      Get.snackbar("success", "login Successfully");
      return true;
    } else {
      Get.snackbar("Error", "Please Enter valid data");
      return false;
    }
  }

  @override
  void fieldClear() {
    emailController.clear();
    passwordController.clear();
  }
}
// Dart Collection , Json , all stateful States
