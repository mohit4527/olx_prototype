// lib/src/controller/dealer_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_routes.dart';
import 'edit_dealer_profile_controller.dart';

class DealerProfileController extends GetxController {
  /// ---------------- TEXT CONTROLLERS ----------------
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

  /// ---------------- OBSERVABLE STATES ----------------
  var startTime = Rx<TimeOfDay?>(null);
  var endTime = Rx<TimeOfDay?>(null);
  var isLoading = false.obs;
  var isProfileCreated = false.obs;

  var dealerTypes = ["Cars", "Motorcycles", "Trucks", "Parts", "Other"];
  var selectedDealerType = "".obs;

  var paymentMethods = [
    "Cash",
    "Credit Card",
    "Debit Card",
    "Bank Transfer",
    "Mobile Payment"
  ];
  var selectedPayments = <String>[].obs;

  final ImagePicker _picker = ImagePicker();
  var businessLogo = Rx<File?>(null);
  var businessPhotos = <File>[].obs;

  /// ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();
    // Jab app shuru ho, to check karo ki profile already bani hai ya nahi.
    checkIfProfileExists();
    loadSavedData();
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

  /// ---------------- PICKERS ----------------
  Future<void> selectStartTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: startTime.value ?? TimeOfDay.now(),
    );
    if (pickedTime != null) startTime.value = pickedTime;
  }

  Future<void> selectEndTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: endTime.value ?? TimeOfDay.now(),
    );
    if (pickedTime != null) endTime.value = pickedTime;
  }

  void selectDealerType(String type) => selectedDealerType.value = type;

  void togglePayment(String method) {
    selectedPayments.contains(method)
        ? selectedPayments.remove(method)
        : selectedPayments.add(method);
  }

  Future<void> pickBusinessLogo(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      businessLogo.value = File(pickedFile.path);
    } else {
      Get.snackbar("Error", "No image selected.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickBusinessPhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      businessPhotos.add(File(pickedFile.path));
    } else {
      Get.snackbar("Error", "No image selected.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void removeBusinessPhoto(int index) async {
    if (index >= 0 && index < businessPhotos.length) {
      businessPhotos.removeAt(index);
      await _savePhotosToPrefs();
    }
  }

  /// ---------------- VALIDATION ----------------
  bool validateForm() {
    if (businessNameController.text.isEmpty ||
        regNoController.text.isEmpty ||
        gstNoController.text.isEmpty ||
        villageController.text.isEmpty ||
        cityController.text.isEmpty ||
        stateController.text.isEmpty ||
        countryController.text.isEmpty ||
        phoneController.text.isEmpty ||
        emailController.text.isEmpty ||
        addressController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        startTime.value == null ||
        endTime.value == null ||
        selectedDealerType.value.isEmpty ||
        selectedPayments.isEmpty ||
        businessLogo.value == null) {
      Get.snackbar("Error", "Please fill all required fields",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      Get.snackbar("Error", "Phone number must be exactly 10 digits",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar("Error", "Invalid Email Address",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    return true;
  }

  /// ---------------- FORM SUBMISSION ----------------
  Future<void> submitForm(BuildContext context) async {
    if (!validateForm()) return;

    isLoading.value = true;
    try {
      final formattedStart = startTime.value!.format(context);
      final formattedEnd = endTime.value!.format(context);
      String businessHours = "$formattedStart - $formattedEnd";

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId") ?? "";

      if (userId.isEmpty) {
        Get.snackbar("Error", "User not logged in. Please login again.",
            backgroundColor: Colors.red, colorText: Colors.white);
        isLoading.value = false;
        return;
      }

      String dealerType = selectedDealerType.value.toLowerCase();
      List<String> normalizedPayments =
      selectedPayments.map((p) => p.toLowerCase()).toList();

      final result = await ApiService.registerDealer(
        userId: userId,
        businessName: businessNameController.text,
        registrationNumber: regNoController.text,
        gstNumber: gstNoController.text,
        village: villageController.text,
        city: cityController.text,
        state: stateController.text,
        country: countryController.text,
        phone: phoneController.text,
        email: emailController.text,
        businessAddress: addressController.text,
        dealerType: dealerType,
        description: descriptionController.text,
        businessHours: businessHours,
        paymentMethods: normalizedPayments,
        businessLogo: businessLogo.value!,
        businessPhotos: businessPhotos,
      );

      if (result != null && result["status"] == true) {
        isProfileCreated.value = true;

        if (result["data"] != null && result["data"]["_id"] != null) {
          await saveDealerId(result["data"]["_id"]);
        }

        await prefs.setBool('isProfileCreated', true);
        await saveProfileDataToSharedPreferences(businessHours);

        Get.snackbar("Success", "Dealer Profile Created Successfully!",
            backgroundColor: Colors.green, colorText: Colors.white);

        final Map<String, dynamic> dealerData = {
          'businessName': businessNameController.text,
          'regNo': regNoController.text,
          'gstNo': gstNoController.text,
          'village': villageController.text,
          'city': cityController.text,
          'state': stateController.text,
          'country': countryController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'address': addressController.text,
          'description': descriptionController.text,
          'selectedDealerType': selectedDealerType.value,
          'selectedPayments': selectedPayments.toList(),
          'businessHours': businessHours,
          'businessLogoPath': businessLogo.value?.path,
          'businessPhotoPaths': businessPhotos.map((f) => f.path).toList(),
        };

        Get.offAllNamed(AppRoutes.edit_dealer_profile, arguments: dealerData);
      } else {
        Get.snackbar("Error",
            "Failed to create dealer profile: ${result?["error"] ?? "Unknown error"}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }




  /// ---------------- SHARED PREFERENCES ----------------
  Future<void> saveProfileDataToSharedPreferences(String businessHours) async {
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
    await prefs.setString('businessHours', businessHours);

    if (businessLogo.value != null) {
      await prefs.setString('businessLogoPath', businessLogo.value!.path);
    }
    await _savePhotosToPrefs();
  }

  Future<void> _savePhotosToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final photoPaths = businessPhotos.map((f) => f.path).toList();
    await prefs.setStringList('businessPhotoPaths', photoPaths);
  }

  Future<void> loadSavedData() async {
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

    final savedLogoPath = prefs.getString('businessLogoPath');
    if (savedLogoPath != null && File(savedLogoPath).existsSync()) {
      businessLogo.value = File(savedLogoPath);
    }

    final savedPhotoPaths = prefs.getStringList('businessPhotoPaths');
    if (savedPhotoPaths != null) {
      businessPhotos.assignAll(savedPhotoPaths
          .where((path) => File(path).existsSync())
          .map((path) => File(path))
          .toList());
    }
  }

  /// ---------------- NAYA FUNCTION ----------------
  Future<void> checkIfProfileExists() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isCreated = prefs.getBool('isProfileCreated');
    if (isCreated != null && isCreated) {
      isProfileCreated.value = true;
    }
  }

  /// ---------------- SAVE DEALER ID ----------------
  Future<void> saveDealerId(String dealerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dealerId', dealerId);
    print("DealerId stored in SharedPreferences: $dealerId");
  }

  /// ---------------- INPUT FORMATTERS ----------------
  List<TextInputFormatter> phoneInputFormatters() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];
}