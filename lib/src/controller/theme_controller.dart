// lib/controller/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  ThemeMode get theme => themeMode.value;
  Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }
}
