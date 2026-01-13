import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ✅ Helper class for showing snackbars properly throughout the app
class SnackbarHelper {
  /// Show success snackbar
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.check_circle, color: Colors.white, size: 28),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show error snackbar
  static void showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.error, color: Colors.white, size: 28),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show warning snackbar
  static void showWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.warning, color: Colors.white, size: 28),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show info snackbar
  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade600,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(Icons.info, color: Colors.white, size: 28),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Show custom snackbar with custom color
  static void showCustom(
    String title,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration? duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.grey.shade800,
      colorText: textColor ?? Colors.white,
      duration: duration ?? Duration(seconds: 3),
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      icon: icon != null
          ? Icon(icon, color: textColor ?? Colors.white, size: 28)
          : null,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
