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
    if (selectedTime == null) return '';
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return "$hour:$minute"; // backend expects HH:mm
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
      update();
    }
  }

  void pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedTime = pickedTime;
      update();
    }
  }

  bool isValidPhone(String phone) {
    final regex = RegExp(r'^\d{10}$');
    return regex.hasMatch(phone);
  }

  void bookTestDrive(String carId) async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (selectedDate == null || selectedTime == null) {
      Get.snackbar("Missing Fields", "Please select both date and time",
          backgroundColor: Colors.orange.shade200,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (name.isEmpty) {
      Get.snackbar("Missing Name", "Please enter your name",
          backgroundColor: Colors.orange.shade200,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!isValidPhone(phone)) {
      Get.snackbar("Invalid Phone", "Phone number must be exactly 10 digits",
          backgroundColor: Colors.orange.shade200,
          colorText: Colors.black,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (carId.isEmpty) {
      Get.snackbar("Missing Product", "Product ID is missing or invalid",
          backgroundColor: Colors.red.shade300,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;

    try {
      print("🔍 Booking Test Drive Debug Info:");
      print("Product ID: $carId");
      print("Name: $name");
      print("Phone: $phone");
      print("Date: $formattedDate");
      print("Time: $formattedTime");

      final response = await ApiService.userBookTestDrive(
        carId: carId,
        name: name,
        phoneNumber: phone,
        preferredDate: formattedDate,
        preferredTime: formattedTime,
      );

      // ✅ Always close bottom sheet and clear fields
      Get.back();
      nameController.clear();
      phoneController.clear();
      selectedDate = null;
      selectedTime = null;
      update();

      if (response != null) {
        Get.snackbar("Success", "Test drive booked successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      } else {
        Get.snackbar("Error", "Failed to book test drive",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      print("🔥 Exception during booking: $e");

      // ✅ Still close bottom sheet and clear fields
      Get.back();
      nameController.clear();
      phoneController.clear();
      selectedDate = null;
      selectedTime = null;
      update();

      Get.snackbar("Error", "Something went wrong while booking",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }
}
