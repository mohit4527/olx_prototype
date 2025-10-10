// lib/src/controller/edit_dealer_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    print("EditDealerProfileController initialized");
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      print("Loading data from arguments");
      _loadFromArguments(Get.arguments as Map<String, dynamic>);
    } else {
      print("Loading data from SharedPreferences");
      loadProfileDataFromSharedPreferences();
    }
  }

  void _loadFromArguments(Map<String, dynamic> data) {
    print("Data received from arguments: $data");
    businessNameController.text = data['businessName'] ?? '';
    regNoController.text = data['regNo'] ?? '';
    gstNoController.text = data['gstNo'] ?? '';
    villageController.text = data['village'] ?? '';
    cityController.text = data['city'] ?? '';
    stateController.text = data['state'] ?? '';
    countryController.text = data['country'] ?? '';
    phoneController.text = data['phone'] ?? '';
    emailController.text = data['email'] ?? '';
    addressController.text = data['address'] ?? '';
    descriptionController.text = data['description'] ?? '';
    selectedDealerType.value = data['selectedDealerType'] ?? '';
    if (data['selectedPayments'] is List<dynamic>) {
      selectedPayments.assignAll(List<String>.from(data['selectedPayments']));
    }
    businessHours.value = data['businessHours'] ?? '';

    final logoPath = data['businessLogoPath'];
    if (logoPath != null && File(logoPath).existsSync()) {
      businessLogo.value = File(logoPath);
      print("Business logo loaded from path: $logoPath");
    }

    if (data['businessPhotoPaths'] != null) {
      businessPhotos.assignAll(
        (data['businessPhotoPaths'] as List<dynamic>)
            .map((p) => File(p))
            .where((f) => f.existsSync())
            .toList(),
      );
      print("Business photos loaded from paths: ${businessPhotos.map((f) => f.path).toList()}");
    }
  }

  Future<void> loadProfileDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print("Loading profile from SharedPreferences");
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

    final logoPath = prefs.getString('businessLogoPath');
    if (logoPath != null && File(logoPath).existsSync()) {
      businessLogo.value = File(logoPath);
      print("Business logo loaded from SharedPreferences: $logoPath");
    }

    final savedPhotos = prefs.getStringList('businessPhotoPaths');
    if (savedPhotos != null) {
      businessPhotos.assignAll(savedPhotos.map((p) => File(p)).where((f) => f.existsSync()).toList());
      print("Business photos loaded from SharedPreferences: ${businessPhotos.map((f) => f.path).toList()}");
    }
  }

  Future<void> pickBusinessLogo(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        businessLogo.value = File(pickedFile.path);
        print("Picked business logo: ${pickedFile.path}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('businessLogoPath', pickedFile.path);
        print("Business logo path saved in SharedPreferences");
      } else {
        Get.snackbar("Error", "No image selected.", backgroundColor: Colors.red, colorText: Colors.white);
        print("No image selected for business logo");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e", backgroundColor: Colors.red, colorText: Colors.white);
      print("Error picking business logo: $e");
    }
  }

  Future<void> pickBusinessPhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
      if (pickedFile != null) {
        businessPhotos.add(File(pickedFile.path));
        print("Picked business photo: ${pickedFile.path}");
        final prefs = await SharedPreferences.getInstance();
        final photoPaths = businessPhotos.map((file) => file.path).toList();
        await prefs.setStringList('businessPhotoPaths', photoPaths);
        print("Business photos paths saved in SharedPreferences: $photoPaths");
      } else {
        Get.snackbar("Error", "No image selected.", backgroundColor: Colors.red, colorText: Colors.white);
        print("No image selected for business photo");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e", backgroundColor: Colors.red, colorText: Colors.white);
      print("Error picking business photo: $e");
    }
  }

  void removeBusinessPhoto(int index) async {
    if (index >= 0 && index < businessPhotos.length) {
      print("Removing business photo at index: $index");
      businessPhotos.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      final photoPaths = businessPhotos.map((file) => file.path).toList();
      await prefs.setStringList('businessPhotoPaths', photoPaths);
      print("Updated business photos paths in SharedPreferences: $photoPaths");
    }
  }

  String formatRawTime(String rawTime) {
    // rawTime example: "15:30" (HH:mm) ya "3:30 PM" already formatted
    if (rawTime.isEmpty) return "";

    try {
      // Agar rawTime HH:mm format me hai
      final parts = rawTime.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? "PM" : "AM";
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final minStr = minute.toString().padLeft(2, '0');
        return "$hour:$minStr $period";
      }
      return rawTime; // agar already formatted
    } catch (e) {
      print("Error formatting time: $e");
      return rawTime;
    }
  }


  Future<void> pickBusinessHours(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final hour = pickedTime.hourOfPeriod == 0 ? 12 : pickedTime.hourOfPeriod;
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      final period = pickedTime.period == DayPeriod.am ? "AM" : "PM";

      businessHours.value = "$hour:$minute $period";
      print("Picked business hours: ${businessHours.value}");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('businessHoursRaw', "${pickedTime.hour}${pickedTime.minute.toString().padLeft(2, '0')}");
      print("Business hours saved in SharedPreferences");
    }
  }

  void submitDealerProfile() async {
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
    await prefs.setStringList('selectedPayments', selectedPayments);
    await prefs.setString('businessHours', businessHours.value);

    print("Dealer profile saved to SharedPreferences");
    print("Business logo path: ${businessLogo.value?.path}");
    print("Business photos paths: ${businessPhotos.map((f) => f.path).toList()}");

    Get.snackbar("Success", "Dealer profile updated successfully",
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}
