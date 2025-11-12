import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/sell_user_car_model/sell_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';

class CarUploadController extends GetxController {
  final formKey = GlobalKey<FormState>(); // 🔥 Form validation key
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController =
      TextEditingController(); // 📞 Phone number controller added
  final selectedCategory = RxString('all');

  RxList<File> selectedImages = <File>[].obs;
  RxBool isUploading = false.obs;

  Future<void> uploadCarData() async {
    // 🔥 Validate form first
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        "❌ Validation Error",
        "Please fix all errors before uploading",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error, color: Colors.red),
        duration: Duration(seconds: 3),
      );
      return;
    }

    // 🔥 Check images
    if (selectedImages.isEmpty) {
      Get.snackbar(
        "❌ Images Required",
        "Please select at least one image for your product",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        icon: Icon(Icons.image, color: Colors.orange),
        duration: Duration(seconds: 3),
      );
      return;
    }

    // 🔥 Additional phone validation
    final phoneNumber = phoneController.text.trim();
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phoneNumber)) {
      Get.snackbar(
        "❌ Invalid Phone Number",
        "Please enter a valid 10-digit Indian mobile number",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.phone, color: Colors.red),
        duration: Duration(seconds: 3),
      );
      return;
    }

    final userId = await AuthService.getLoggedInUserId();
    if (userId == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    isUploading.value = true;

    try {
      // ✅ Location string ko parse karne ka simple tarika
      // format: "City, State, Country"
      final locParts = locationController.text.split(',');
      String city = locParts.isNotEmpty ? locParts[0].trim() : "";
      String state = locParts.length > 1 ? locParts[1].trim() : "";
      String country = locParts.length > 2 ? locParts[2].trim() : "";

      final carData = SellUserCarModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        dealerType: "user",
        type: 'image',
        userId: userId,
        category: selectedCategory.value,
        phoneNumber: phoneController.text.trim(), // 📞 Phone number added
        location: Location(
          country: country.isNotEmpty ? country : "India",
          state: state.isNotEmpty ? state : "Unknown",
          city: city.isNotEmpty ? city : "Unknown",
        ),
      );

      // 🔥 DEBUG: Phone number upload
      print(
        '[SellUserCarController] Uploading car with phone: "${carData.phoneNumber}"',
      );
      print('[SellUserCarController] Car title: "${carData.title}"');

      await ApiService.uploadCar(carData, selectedImages);

      // Clear form first
      clearForm();

      // Show success message with enhanced styling
      Get.snackbar(
        "🎉 Success!",
        "Your product has been uploaded successfully!\nRedirecting to home...",
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
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload car: $e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUploading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    locationController.clear();
    phoneController.clear(); // 📞 Phone controller clear
    selectedImages.clear();
    selectedCategory.value = 'all';
    Get.focusScope?.unfocus();
  }
}
