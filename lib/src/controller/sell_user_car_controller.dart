import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/sell_car_model/sell_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';

class CarUploadController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  RxList<File> selectedImages = <File>[].obs;
  RxBool isUploading = false.obs;
  var selectedDealerType = "".obs;


  Future<void> uploadCarData() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedDealerType.value.isEmpty ||
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

    final carData = SellUserCarModel(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      price: int.parse(priceController.text.trim()),
      dealerType: selectedDealerType.value,
      type: 'image',
      userId: userId,
      location: Location(
        country: 'India',
        state: 'Maharashtra',
        city: 'Pune',
      ),
    );

    final ok = await ApiService.uploadCar(carData, selectedImages);
    isUploading.value = false;

    if (ok) {
      Get.snackbar("Success", "Car uploaded successfully", backgroundColor: AppColors.appGreen);
      clearForm();
    } else {
      Get.snackbar("Error", "Upload failed", backgroundColor: AppColors.appRed);
    }
  }


  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImages.clear();
  }
}