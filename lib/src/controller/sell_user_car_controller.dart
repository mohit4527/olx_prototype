import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/sell_user_car_model/sell_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';

class CarUploadController extends GetxController {
  final titleController = TextEditingController();
  final locationController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final selectedCategory = RxString('all');

  RxList<File> selectedImages = <File>[].obs;
  RxBool isUploading = false.obs;

  Future<void> uploadCarData() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar("Error", "Please fill all fields & select images");
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
        location: Location(
          country: country.isNotEmpty ? country : "India",
          state: state.isNotEmpty ? state : "Unknown",
          city: city.isNotEmpty ? city : "Unknown",
        ),
      );


      await ApiService.uploadCar(carData, selectedImages);

      Get.snackbar("Success", "Car uploaded successfully!",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);

      clearForm();
    } catch (e) {
      Get.snackbar("Error", "Failed to upload car: $e",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    locationController.clear();
    selectedImages.clear();
    selectedCategory.value = 'all';
    Get.focusScope?.unfocus();
  }
}
