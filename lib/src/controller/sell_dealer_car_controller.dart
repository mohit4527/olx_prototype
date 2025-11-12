import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/sell_dealer_car_model/sell_dealer_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';

class DealerCarUploadController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final selectedCategory = RxString('all');

  RxList<File> selectedImages = <File>[].obs;
  RxBool isUploading = false.obs;

  Future<void> uploadCarData() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar("Error", "Please fill all fields & select images");
      return;
    }
    final dealerId = await AuthService.getDealerId();
    final userId = await AuthService.getLoggedInUserId();

    if (dealerId == null || userId == null) {
      Get.snackbar("Error", "Dealer or user not logged in");
      return;
    }

    isUploading.value = true;

    try {
      final dealerCarData = DealerCarModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        sellerType: 'dealer',
        userId: userId,
        dealerId: dealerId,
        category: selectedCategory.value,
        tags: ["Certified", "Low KM"],
      );

      await ApiService.uploadDealerCar(dealerCarData, selectedImages);

      // Clear form first
      clearForm();

      // Show success message with enhanced styling
      Get.snackbar(
        "🎉 Dealer Success!",
        "Dealer product has been uploaded successfully!\nRedirecting to home...",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );

      // Navigate directly to home screen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        // First try to navigate to home route
        Get.offAllNamed("/home_screen");
      } catch (e) {
        try {
          // Fallback: Pop all screens until we reach home
          Get.until((route) => route.isFirst);
        } catch (e2) {
          // Final fallback: Simple back navigation
          Get.back();
        }
      }
    } finally {
      isUploading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImages.clear();
    selectedCategory.value = 'all';
    Get.focusScope?.unfocus();
  }
}
