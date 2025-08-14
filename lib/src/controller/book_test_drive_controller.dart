import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/apiServices/apiServices.dart';

class BookTestDriveController extends GetxController {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  var isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String get formattedDate {
    if (selectedDate == null) return '';
    return "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";
  }

  String get formattedTime {
    if (selectedTime == null || Get.context == null) return '';
    return selectedTime!.format(Get.context!);
  }

  void pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;
      update(); // Notify GetBuilder
    }
  }

  void pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      selectedTime = pickedTime;
      update(); // Notify GetBuilder
    }
  }

  void bookTestDrive(String carId) async {
    if (selectedDate == null || selectedTime == null) {
      Get.snackbar(
        "Missing Fields",
        "Please select both date and time",
        backgroundColor: Colors.orange.shade200,
        colorText: Colors.black,
      );
      return;
    }

    if (nameController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar(
        "Missing Fields",
        "Please enter your name and phone number",
        backgroundColor: Colors.orange.shade200,
        colorText: Colors.black,
      );
      return;
    }

    isLoading.value = true;

    final response = await ApiService.bookTestDrive(
      preferredDate: formattedDate,
      preferredTime: formattedTime,
      carId: carId,
      name: nameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
    );
    isLoading.value = false;

    if (response != null && response.status == true) {
      Get.back();
      Get.snackbar(
        "Success",
        response.message ?? "Test drive booked successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        "Error",
        response?.message ?? "Failed to book test drive",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
