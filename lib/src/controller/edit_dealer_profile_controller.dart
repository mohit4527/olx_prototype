// lib/src/controller/edit_dealer_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this

class EditDealerProfileController extends GetxController {
  final businessNameController = TextEditingController();
  final regNoController = TextEditingController();
  final gstNoController = TextEditingController();
  final villageController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  var selectedDealerType = "".obs;
  var selectedPayments = <String>[].obs;
  var businessHours = "".obs;

  var businessLogo = Rx<File?>(null);
  var businessPhotos = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Load saved data when the controller is initialized
    loadProfileDataFromSharedPreferences();
  }

  Future<void> loadProfileDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    businessNameController.text = prefs.getString('businessName') ?? '';
    regNoController.text = prefs.getString('regNo') ?? '';
    gstNoController.text = prefs.getString('gstNo') ?? '';
    villageController.text = prefs.getString('village') ?? '';
    cityController.text = prefs.getString('city') ?? '';
    stateController.text = prefs.getString('state') ?? '';
    countryController.text = prefs.getString('country') ?? '';
    phoneController.text = prefs.getString('phone') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    addressController.text = prefs.getString('address') ?? '';
    descriptionController.text = prefs.getString('description') ?? '';

    selectedDealerType.value = prefs.getString('selectedDealerType') ?? '';
    final savedPayments = prefs.getStringList('selectedPayments');
    if (savedPayments != null) selectedPayments.assignAll(savedPayments);
    businessHours.value = prefs.getString('businessHours') ?? '';

    final savedLogoPath = prefs.getString('businessLogoPath');
    if (savedLogoPath != null && File(savedLogoPath).existsSync()) {
      businessLogo.value = File(savedLogoPath);
    }

    final savedPhotoPaths = prefs.getStringList('businessPhotoPaths');
    if (savedPhotoPaths != null) {
      businessPhotos.assignAll(savedPhotoPaths.where((path) => File(path).existsSync()).map((path) => File(path)).toList());
    }
  }

  void loadProfileData({
    required String businessName,
    required String regNo,
    required String gstNo,
    required String village,
    required String city,
    required String state,
    required String country,
    required String phone,
    required String email,
    required String address,
    required String description,
    required String dealerType,
    required String businessHours,
    required List<String> paymentMethods,
    File? businessLogoFile,
    List<File>? businessPhotosFiles,
  }) {
    businessNameController.text = businessName;
    regNoController.text = regNo;
    gstNoController.text = gstNo;
    villageController.text = village;
    cityController.text = city;
    stateController.text = state;
    countryController.text = country;
    phoneController.text = phone;
    emailController.text = email;
    addressController.text = address;
    descriptionController.text = description;

    selectedDealerType.value = dealerType;
    selectedPayments.value = paymentMethods;
    this.businessHours.value = businessHours;

    businessLogo.value = businessLogoFile;
    if (businessPhotosFiles != null) {
      businessPhotos.assignAll(businessPhotosFiles);
    }
  }

  Future<void> pickBusinessLogo(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        businessLogo.value = File(pickedFile.path);
        // Save to prefs immediately
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('businessLogoPath', pickedFile.path);
      } else {
        Get.snackbar("Error", "No image selected.", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickBusinessHours(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      // Format hour & minute properly
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? "AM" : "PM";

      businessHours.value = "$hour:$minute $period";

      // Save raw format (like 437, 837)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'businessHoursRaw',
          "${pickedTime.hour}${pickedTime.minute.toString().padLeft(2, '0')}"
      );
    }
  }

  /// Function to format raw string (437 -> 4:37 AM/PM)
  String formatRawTime(String raw) {
    if (raw.isEmpty) return "Not set";

    try {
      // Ensure length (e.g., 437 -> 0437)
      raw = raw.padLeft(4, '0');
      final hour = int.parse(raw.substring(0, 2));
      final minute = int.parse(raw.substring(2));

      final time = TimeOfDay(hour: hour, minute: minute);
      final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final m = time.minute.toString().padLeft(2, '0');
      final p = time.period == DayPeriod.am ? "AM" : "PM";

      return "$h:$m $p";
    } catch (e) {
      return raw; // fallback
    }
  }



  Future<void> pickBusinessPhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        businessPhotos.add(File(pickedFile.path));
        // Save to prefs immediately
        final prefs = await SharedPreferences.getInstance();
        final photoPaths = businessPhotos.map((file) => file.path).toList();
        await prefs.setStringList('businessPhotoPaths', photoPaths);
      } else {
        Get.snackbar("Error", "No image selected.", backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeBusinessPhoto(int index) async {
    if (index >= 0 && index < businessPhotos.length) {
      businessPhotos.removeAt(index);
      // Update prefs
      final prefs = await SharedPreferences.getInstance();
      final photoPaths = businessPhotos.map((file) => file.path).toList();
      await prefs.setStringList('businessPhotoPaths', photoPaths);
    }
  }

  void submitDealerProfile() async {
    // Save all data to SharedPreferences before showing success message
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('businessName', businessNameController.text);
    await prefs.setString('regNo', regNoController.text);
    await prefs.setString('gstNo', gstNoController.text);
    await prefs.setString('village', villageController.text);
    await prefs.setString('city', cityController.text);
    await prefs.setString('state', stateController.text);
    await prefs.setString('country', countryController.text);
    await prefs.setString('phone', phoneController.text);
    await prefs.setString('email', emailController.text);
    await prefs.setString('address', addressController.text);
    await prefs.setString('description', descriptionController.text);

    await prefs.setString('selectedDealerType', selectedDealerType.value);
    await prefs.setStringList('selectedPayments', selectedPayments.toList());
    await prefs.setString('businessHours', businessHours.value);

    Get.snackbar("Success", "Dealer profile updated successfully!",
        backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  void onClose() {
    businessNameController.dispose();
    regNoController.dispose();
    gstNoController.dispose();
    villageController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}