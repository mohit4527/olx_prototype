// lib/src/controller/dealer_profile_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service/auth_service.dart';

import '../utils/app_routes.dart';

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
    "Mobile Payment",
  ];
  var selectedPayments = <String>[].obs;

  final ImagePicker _picker = ImagePicker();
  var businessLogo = Rx<File?>(null);
  var businessPhotos = <File>[].obs;

  /// ---------------- LIFECYCLE ----------------
  @override
  void onInit() {
    super.onInit();
    print('🚀 [DealerController] onInit() called');
    // 🔥 FIXED: Initialize profile state on controller creation
    _initializeProfileState();
  }

  @override
  void onReady() {
    super.onReady();
    print('🚀 [DealerController] onReady() called');
    // Force refresh state when controller is fully ready
    isProfileCreated.refresh();
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
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      businessLogo.value = File(pickedFile.path);
    } else {
      Get.snackbar(
        "Error",
        "No image selected.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickBusinessPhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      businessPhotos.add(File(pickedFile.path));
    } else {
      Get.snackbar(
        "Error",
        "No image selected.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
      Get.snackbar(
        "Error",
        "Please fill all required fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (!RegExp(r'^\d{10}$').hasMatch(phoneController.text)) {
      Get.snackbar(
        "Error",
        "Phone number must be exactly 10 digits",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
    if (!GetUtils.isEmail(emailController.text)) {
      Get.snackbar(
        "Error",
        "Invalid Email Address",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
        Get.snackbar(
          "Error",
          "User not logged in. Please login again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      // 🔥 FIX: Map dealer types to API-expected values
      String dealerType = _mapDealerTypeToAPI(selectedDealerType.value);
      List<String> normalizedPayments = selectedPayments
          .map((p) => p.toLowerCase())
          .toList();

      print('🔍 [DealerController] Dealer type mapping:');
      print('   - Selected: ${selectedDealerType.value}');
      print('   - API value: $dealerType');

      final result = await ApiService.registerDealer(
        userId: userId,
        businessName: businessNameController.text,
        registrationNumber: regNoController.text,
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
        print('🎉 [DealerController] Dealer profile created successfully!');
        isProfileCreated.value = true;
        print(
          '✅ [DealerController] Set isProfileCreated to: ${isProfileCreated.value}',
        );

        if (result["data"] != null && result["data"]["_id"] != null) {
          await saveDealerId(result["data"]["_id"]);
        }

        // 🔥 FIX: Use user-specific key for profile creation flag
        final currentUserId = await AuthService.getLoggedInUserId();
        final userProfileKey = 'isProfileCreated_$currentUserId';
        await prefs.setBool(userProfileKey, true);
        await saveProfileDataToSharedPreferences(businessHours);
        print('💾 [DealerController] Saved profile data to SharedPreferences');

        // 🔥 Force UI update by triggering reactive change
        isProfileCreated.refresh();
        print(
          '🔄 [DealerController] Triggered isProfileCreated refresh for UI update',
        );

        Get.snackbar(
          "Success",
          "Dealer Profile Created Successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        final Map<String, dynamic> dealerData = {
          'businessName': businessNameController.text,
          'regNo': regNoController.text,
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

        print(
          '🚀 [DealerController] Navigating to edit_dealer_profile with data',
        );
        // 🔥 FIX: Use Get.toNamed instead of Get.offAllNamed to keep navigation stack
        Get.toNamed(AppRoutes.edit_dealer_profile, arguments: dealerData);
      } else {
        Get.snackbar(
          "Error",
          "Failed to create dealer profile: ${result?["error"] ?? "Unknown error"}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ---------------- SHARED PREFERENCES ----------------
  Future<void> saveProfileDataToSharedPreferences(String businessHours) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 FIX: Use user-specific keys for all profile data
    final currentUserId = await AuthService.getLoggedInUserId();
    await prefs.setString(
      'businessName_$currentUserId',
      businessNameController.text,
    );
    await prefs.setString('regNo_$currentUserId', regNoController.text);
    await prefs.setString('village_$currentUserId', villageController.text);
    await prefs.setString('city_$currentUserId', cityController.text);
    await prefs.setString('state_$currentUserId', stateController.text);
    await prefs.setString('country_$currentUserId', countryController.text);
    await prefs.setString('phone_$currentUserId', phoneController.text);
    await prefs.setString('email_$currentUserId', emailController.text);
    await prefs.setString('address_$currentUserId', addressController.text);
    await prefs.setString(
      'description_$currentUserId',
      descriptionController.text,
    );

    await prefs.setString(
      'selectedDealerType_$currentUserId',
      selectedDealerType.value,
    );
    await prefs.setStringList(
      'selectedPayments_$currentUserId',
      selectedPayments.toList(),
    );
    await prefs.setString('businessHours_$currentUserId', businessHours);

    if (businessLogo.value != null) {
      await prefs.setString(
        'businessLogoPath_$currentUserId',
        businessLogo.value!.path,
      );
    }
    await _savePhotosToPrefs();
  }

  Future<void> _savePhotosToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = await AuthService.getLoggedInUserId();
    final photoPaths = businessPhotos.map((f) => f.path).toList();
    await prefs.setStringList('businessPhotoPaths_$currentUserId', photoPaths);
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 FIX: Use user-specific keys for loading data
    final currentUserId = await AuthService.getLoggedInUserId();
    businessNameController.text =
        prefs.getString('businessName_$currentUserId') ?? '';
    regNoController.text = prefs.getString('regNo_$currentUserId') ?? '';
    villageController.text = prefs.getString('village_$currentUserId') ?? '';
    cityController.text = prefs.getString('city_$currentUserId') ?? '';
    stateController.text = prefs.getString('state_$currentUserId') ?? '';
    countryController.text = prefs.getString('country_$currentUserId') ?? '';
    phoneController.text = prefs.getString('phone_$currentUserId') ?? '';
    emailController.text = prefs.getString('email_$currentUserId') ?? '';
    addressController.text = prefs.getString('address_$currentUserId') ?? '';
    descriptionController.text =
        prefs.getString('description_$currentUserId') ?? '';

    selectedDealerType.value =
        prefs.getString('selectedDealerType_$currentUserId') ?? '';
    final savedPayments = prefs.getStringList(
      'selectedPayments_$currentUserId',
    );
    if (savedPayments != null) selectedPayments.assignAll(savedPayments);

    final savedLogoPath = prefs.getString('businessLogoPath_$currentUserId');
    if (savedLogoPath != null && File(savedLogoPath).existsSync()) {
      businessLogo.value = File(savedLogoPath);
    }

    final savedPhotoPaths = prefs.getStringList(
      'businessPhotoPaths_$currentUserId',
    );
    if (savedPhotoPaths != null) {
      businessPhotos.assignAll(
        savedPhotoPaths
            .where((path) => File(path).existsSync())
            .map((path) => File(path))
            .toList(),
      );
    }
  }

  /// ---------------- 🔥 COMPREHENSIVE: Initialize profile state properly ----------------
  Future<void> _initializeProfileState() async {
    try {
      print('🚀 [DealerController] _initializeProfileState() started');

      // 🔥 FIX: Get current user ID from AuthService (more reliable)
      final prefs = await SharedPreferences.getInstance();
      final String? userId = await AuthService.getLoggedInUserId();

      print('🔍 [DealerController] USER ID CHECK:');
      print('   - AuthService userId: $userId');
      print('   - Prefs userId: ${prefs.getString('userId')}');

      // 🔥 FIX: Use USER-SPECIFIC keys for all dealer data
      final String userDealerKey = 'dealerId_$userId';
      final String userProfileKey = 'isProfileCreated_$userId';

      final String? savedDealerId = prefs.getString(userDealerKey);
      final bool? cachedProfileState = prefs.getBool(userProfileKey);

      print('🔍 [DealerController] CRITICAL DATA CHECK:');
      print('   - userId: $userId');
      print('   - userDealerKey: $userDealerKey');
      print('   - userProfileKey: $userProfileKey');
      print('   - savedDealerId: $savedDealerId');
      print('   - cachedProfileState: $cachedProfileState');

      if (userId == null || userId.isEmpty) {
        print('❌ [DealerController] No userId found, clearing all dealer data');
        isProfileCreated.value = false;
        await clearDealerDataFromPrefs();
        print(
          '🔄 [DealerController] Set isProfileCreated to: ${isProfileCreated.value}',
        );
        return;
      }

      print('🌐 [DealerController] Checking dealer profile status...');

      // 🔥 STEP 1: Load from SharedPreferences first for instant feedback
      bool hasProfileLocal = prefs.getBool(userProfileKey) ?? false;

      if (hasProfileLocal &&
          savedDealerId != null &&
          savedDealerId.isNotEmpty) {
        isProfileCreated.value = true;
        print(
          '⚡ [DealerController] Loaded from cache - isProfileCreated: true, dealerId: $savedDealerId',
        );
      } else {
        print(
          '⚠️ [DealerController] Cache check failed - hasProfileLocal: $hasProfileLocal, savedDealerId: $savedDealerId',
        );
      }

      // 🔥 STEP 2: Use dealerId-based verification (more reliable than userId)
      bool hasProfileAPI = false;
      try {
        if (savedDealerId != null && savedDealerId.isNotEmpty) {
          // Verify dealerId exists in API
          final dealerProfiles = await ApiService.fetchDealerProfiles();
          if (dealerProfiles?.data != null) {
            hasProfileAPI = dealerProfiles!.data!.any(
              (profile) => profile.id == savedDealerId,
            );
            print(
              '✅ [DealerController] DealerId verification result: $hasProfileAPI',
            );
          }
        } else {
          // 🔥 NEW: Check if user has any dealer profile by matching userId from API
          print(
            '🔍 [DealerController] No local dealerId found, checking API by userId...',
          );
          await _syncDealerProfileByUserId(userId, prefs);

          // Re-check after sync
          final syncedDealerId = prefs.getString(userDealerKey);
          hasProfileAPI = syncedDealerId != null && syncedDealerId.isNotEmpty;
          print(
            '✅ [DealerController] After userId sync - hasProfile: $hasProfileAPI, dealerId: $syncedDealerId',
          );
        }

        // Update state and preferences with API result
        isProfileCreated.value = hasProfileAPI;
        await prefs.setBool(userProfileKey, hasProfileAPI);
        print(
          '💾 [DealerController] Updated isProfileCreated to: $hasProfileAPI',
        );
      } catch (e) {
        print('⚠️ [DealerController] API verification failed: $e');
        // Keep the local cached value if API fails but only if we have dealerId
        if (hasProfileLocal &&
            savedDealerId != null &&
            savedDealerId.isNotEmpty) {
          isProfileCreated.value = hasProfileLocal;
          print(
            '🔄 [DealerController] API failed, keeping cached value: $hasProfileLocal',
          );
        } else {
          isProfileCreated.value = false;
          print(
            '🔄 [DealerController] API failed and no reliable local data, setting false',
          );
        }
      }

      // 🔥 STEP 3: Load or clear data based on final profile status
      if (isProfileCreated.value) {
        // Load saved data only if profile exists
        await loadSavedData();
        print('✅ [DealerController] Loaded dealer data from preferences');
      } else {
        // Clear all local data if no profile found
        await clearDealerDataFromPrefs();
        print('🧹 [DealerController] Cleared local dealer data - no profile');
      }
    } catch (e) {
      print('💥 [DealerController] Error initializing profile state: $e');
      isProfileCreated.value = false;
      await clearDealerDataFromPrefs();
      print(
        '🔄 [DealerController] Error fallback - Set isProfileCreated to: ${isProfileCreated.value}',
      );
    }

    print(
      '🏁 [DealerController] _initializeProfileState() completed - Final isProfileCreated: ${isProfileCreated.value}',
    );
  }

  /// ---------------- 🔥 CLIENT-SIDE FIX: DealerId-based profile check ----------------
  Future<void> checkIfProfileExists() async {
    try {
      print('🔍 [DealerController] checkIfProfileExists() called');

      final prefs = await SharedPreferences.getInstance();

      // 🔥 FIX: Get current user ID and use user-specific keys
      final String? userId = await AuthService.getLoggedInUserId();
      final String? dealerId = prefs.getString('dealerId_$userId');
      final bool? cachedState = prefs.getBool('isProfileCreated_$userId');

      print('📱 [DealerController] Retrieved data:');
      print('   - userId: $userId');
      print('   - dealerId: $dealerId');
      print('   - cachedState: $cachedState');

      if (userId == null || userId.isEmpty) {
        print('❌ [DealerController] No userId found, profile not created');
        isProfileCreated.value = false;
        await prefs.setBool('isProfileCreated_$userId', false);
        return;
      }

      // � CLIENT-SIDE FIX: Use dealerId as primary indicator since API userId issue
      bool hasProfile = false;

      if (dealerId != null && dealerId.isNotEmpty) {
        // If we have a dealerId, verify it exists in API
        print(
          '� [DealerController] Found dealerId: $dealerId, verifying with API...',
        );

        try {
          final dealerProfiles = await ApiService.fetchDealerProfiles();
          if (dealerProfiles?.data != null) {
            // Check if our dealerId exists in the API response
            final profileExists = dealerProfiles!.data!.any(
              (profile) => profile.id == dealerId,
            );

            if (profileExists) {
              hasProfile = true;
              print(
                '✅ [DealerController] Verified dealerId exists in API: $dealerId',
              );
            } else {
              hasProfile = false;
              print(
                '❌ [DealerController] DealerId not found in API, clearing local data',
              );
            }
          }
        } catch (apiError) {
          print('⚠️ [DealerController] API verification failed: $apiError');
          // Fallback to cached state if API fails
          hasProfile = cachedState ?? false;
          print(
            '🔄 [DealerController] Using cached state as fallback: $hasProfile',
          );
        }
      } else {
        // No dealerId, try original userId-based check as backup
        print(
          '🌐 [DealerController] No dealerId found, trying userId-based check...',
        );
        try {
          hasProfile = await ApiService.checkUserHasDealerProfile(userId);
          print('✅ [DealerController] UserId-based check result: $hasProfile');
        } catch (apiError) {
          print('⚠️ [DealerController] UserId check also failed: $apiError');
          hasProfile = cachedState ?? false;
        }
      }

      // Update state and save to preferences with user-specific key
      isProfileCreated.value = hasProfile;
      await prefs.setBool('isProfileCreated_$userId', hasProfile);

      print(
        '🎯 [DealerController] FINAL RESULT - isProfileCreated: ${isProfileCreated.value}',
      );

      if (!hasProfile) {
        await clearDealerDataFromPrefs();
        print('🧹 [DealerController] Cleared dealer data (no profile)');
      } else {
        await loadExistingProfileData();
        print('📦 [DealerController] Loaded existing profile data');
      }

      isProfileCreated.refresh();
    } catch (e) {
      print('💥 [DealerController] Critical error: $e');
      isProfileCreated.value = false;
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = await AuthService.getLoggedInUserId();
      await prefs.setBool('isProfileCreated_$currentUserId', false);
    }

    print(
      '🏁 [DealerController] checkIfProfileExists() completed - Final: ${isProfileCreated.value}',
    );
  }

  /// 🔥 NEW: Load existing profile data for quick access
  Future<void> loadExistingProfileData() async {
    try {
      print('📦 [DealerController] Loading existing profile data...');
      final prefs = await SharedPreferences.getInstance();

      // Load basic info if available
      final businessName = prefs.getString('businessName');
      final dealerId = prefs.getString('dealerId');

      if (businessName != null && businessName.isNotEmpty) {
        businessNameController.text = businessName;
        print('✅ [DealerController] Loaded business name: $businessName');
      }

      if (dealerId != null && dealerId.isNotEmpty) {
        print('✅ [DealerController] Confirmed dealerId exists: $dealerId');
      }

      // Load other saved data
      cityController.text = prefs.getString('city') ?? '';
      phoneController.text = prefs.getString('phone') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      selectedDealerType.value = prefs.getString('selectedDealerType') ?? '';
    } catch (e) {
      print('⚠️ [DealerController] Error loading existing profile data: $e');
    }
  }

  /// 🔥 NEW: Clear dealer-related data from SharedPreferences
  Future<void> clearDealerDataFromPrefs() async {
    print('🧹 [DealerController] clearDealerDataFromPrefs() called');
    final prefs = await SharedPreferences.getInstance();

    // 🔥 FIX: Clear user-specific keys
    final currentUserId = await AuthService.getLoggedInUserId();
    final userDealerKey = 'dealerId_$currentUserId';
    final userProfileKey = 'isProfileCreated_$currentUserId';

    await prefs.remove(userProfileKey);
    await prefs.remove(userDealerKey);
    // Clear user-specific profile data
    await prefs.remove('businessName_$currentUserId');
    await prefs.remove('regNo_$currentUserId');
    await prefs.remove('village_$currentUserId');
    await prefs.remove('city_$currentUserId');
    await prefs.remove('state_$currentUserId');
    await prefs.remove('country_$currentUserId');
    await prefs.remove('phone_$currentUserId');
    await prefs.remove('email_$currentUserId');
    await prefs.remove('address_$currentUserId');
    await prefs.remove('description_$currentUserId');
    await prefs.remove('selectedDealerType_$currentUserId');
    await prefs.remove('selectedPayments_$currentUserId');
    await prefs.remove('businessHours_$currentUserId');
    await prefs.remove('businessLogoPath_$currentUserId');
    await prefs.remove('businessPhotoPaths_$currentUserId');

    // Also clear controller data
    _resetControllerData();

    print(
      '✅ [DealerController] Cleared all local dealer data from SharedPreferences',
    );
  }

  /// 🔥 NEW: Reset all controller data to default state
  void _resetControllerData() {
    businessNameController.clear();
    regNoController.clear();
    gstNoController.clear();
    villageController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    descriptionController.clear();

    startTime.value = null;
    endTime.value = null;
    selectedDealerType.value = "";
    selectedPayments.clear();
    businessLogo.value = null;
    businessPhotos.clear();

    print('🔄 [DealerController] Reset all controller data');
  }

  /// ---------------- SAVE DEALER ID ----------------
  Future<void> saveDealerId(String dealerId) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 FIX: Use user-specific keys
    final currentUserId = await AuthService.getLoggedInUserId();
    final userDealerKey = 'dealerId_$currentUserId';
    final userProfileKey = 'isProfileCreated_$currentUserId';

    await prefs.setString(userDealerKey, dealerId);
    print(
      "✅ DealerId stored in SharedPreferences with user-specific key: $dealerId",
    );

    // Also immediately update profile created state
    isProfileCreated.value = true;
    await prefs.setBool(userProfileKey, true);
    print(
      "✅ [DealerController] Immediately set isProfileCreated to true after saving dealerId",
    );
  }

  /// ---------------- 🔥 ENHANCED: FORCE SYNC WITH PROFILE RECOVERY ----------------
  Future<void> forceSyncProfileState() async {
    try {
      print('🔄 [DealerController] forceSyncProfileState() called');

      // Step 1: Check current state with user-specific keys
      final prefs = await SharedPreferences.getInstance();
      final userId = await AuthService.getLoggedInUserId();
      final dealerId = prefs.getString('dealerId_$userId');

      print('🔍 [DealerController] Current state check:');
      print('   - userId: $userId');
      print('   - dealerId: $dealerId');
      print('   - isProfileCreated (before): ${isProfileCreated.value}');

      // Step 2: Try to recover lost profile if userId exists but no dealerId
      if (userId != null &&
          userId.isNotEmpty &&
          (dealerId == null || dealerId.isEmpty)) {
        print('🔍 [DealerController] Attempting profile recovery...');
        await _attemptProfileRecovery(userId, prefs);
      }

      // Step 3: Run comprehensive profile check
      await checkIfProfileExists();

      // Step 4: Force UI refresh
      isProfileCreated.refresh();

      print(
        '✅ [DealerController] Profile state synced - Final isProfileCreated: ${isProfileCreated.value}',
      );

      // Step 5: Load data if profile exists
      final finalDealerId = prefs.getString('dealerId_$userId');
      if (isProfileCreated.value && finalDealerId != null) {
        await loadExistingProfileData();
        print('📦 [DealerController] Loaded existing profile data for UI');
      }
    } catch (e) {
      print('💥 [DealerController] Error in forceSyncProfileState: $e');
      isProfileCreated.refresh(); // Refresh anyway to trigger UI update
    }
  }

  /// 🔥 NEW: Attempt to recover profile by matching user details
  Future<void> _attemptProfileRecovery(
    String userId,
    SharedPreferences prefs,
  ) async {
    try {
      print(
        '🔍 [DealerController] Attempting to recover profile for userId: $userId',
      );

      final dealerProfiles = await ApiService.fetchDealerProfiles();
      if (dealerProfiles?.data != null && dealerProfiles!.data!.isNotEmpty) {
        // Try to find profile by matching other user details (phone, email, etc.)
        final currentPhone = prefs.getString('active_user_phone');
        final currentEmail = prefs.getString('email');

        print(
          '🔍 [DealerController] Searching profiles with phone: $currentPhone, email: $currentEmail',
        );

        for (final profile in dealerProfiles.data!) {
          // Match by phone number or email
          bool isMatch = false;

          if (currentPhone != null && profile.phone == currentPhone) {
            isMatch = true;
            print(
              '📞 [DealerController] Found matching profile by phone: ${profile.phone}',
            );
          } else if (currentEmail != null && profile.email == currentEmail) {
            isMatch = true;
            print(
              '📧 [DealerController] Found matching profile by email: ${profile.email}',
            );
          }

          if (isMatch && profile.id != null) {
            // Save recovered dealerId with user-specific keys
            final currentUserId = await AuthService.getLoggedInUserId();
            final userDealerKey = 'dealerId_$currentUserId';
            final userProfileKey = 'isProfileCreated_$currentUserId';

            await prefs.setString(userDealerKey, profile.id!);
            await prefs.setBool(userProfileKey, true);

            print(
              '✅ [DealerController] Profile recovered! DealerId: ${profile.id}',
            );
            print(
              '💾 [DealerController] Saved recovered profile to preferences',
            );
            return;
          }
        }

        print('❌ [DealerController] No matching profile found for recovery');
      }
    } catch (e) {
      print('💥 [DealerController] Profile recovery failed: $e');
    }
  }

  /// 🔥 NEW: Sync dealer profile by matching userId in API response
  Future<void> _syncDealerProfileByUserId(
    String userId,
    SharedPreferences prefs,
  ) async {
    try {
      print('🔍 [DealerController] Syncing dealer profile for userId: $userId');

      final dealerProfiles = await ApiService.fetchDealerProfiles();
      if (dealerProfiles?.data != null && dealerProfiles!.data!.isNotEmpty) {
        // Find dealer profile with matching userId
        for (final profile in dealerProfiles.data!) {
          if (profile.userId == userId && profile.id != null) {
            print('🎯 [DealerController] Found matching dealer profile!');
            print('   - UserId: ${profile.userId}');
            print('   - DealerId: ${profile.id}');
            print('   - Business Name: ${profile.businessName}');

            // Save dealer data with user-specific keys
            final userDealerKey = 'dealerId_$userId';
            final userProfileKey = 'isProfileCreated_$userId';

            await prefs.setString(userDealerKey, profile.id!);
            await prefs.setBool(userProfileKey, true);

            // Also update the reactive variable
            isProfileCreated.value = true;

            print('✅ [DealerController] Dealer profile synced successfully!');
            print('   - Saved dealerId: ${profile.id}');
            print('   - Set isProfileCreated: true');
            return;
          }
        }

        print(
          '❌ [DealerController] No dealer profile found for userId: $userId',
        );
      } else {
        print(
          '⚠️ [DealerController] No dealer profiles data received from API',
        );
      }
    } catch (e) {
      print('💥 [DealerController] Error syncing dealer profile: $e');
    }
  }

  /// 🚀 PUBLIC: Force refresh dealer profile state (call after login/app start)
  Future<void> forceRefreshProfileState() async {
    try {
      print('🔄 [DealerController] forceRefreshProfileState() called');

      // Clear any stale state first
      isProfileCreated.value = false;

      // Re-initialize profile state
      await _initializeProfileState();

      // Force UI refresh
      isProfileCreated.refresh();

      print(
        '✅ [DealerController] Profile state force refreshed - Final: ${isProfileCreated.value}',
      );
    } catch (e) {
      print('💥 [DealerController] Error in forceRefreshProfileState: $e');
    }
  }

  /// 🔥 FIX: Map UI dealer types to API-expected values
  String _mapDealerTypeToAPI(String uiType) {
    // Convert UI display names to API enum values (based on common API patterns)
    switch (uiType.toLowerCase()) {
      case 'cars':
        return 'cars'; // Confirmed working from curl example
      case 'motorcycles':
        return 'motorcycle'; // API expects singular form
      case 'trucks':
        return 'truck'; // Try singular
      case 'parts':
        return 'parts'; // Usually plural
      case 'other':
        return 'other';
      default:
        print(
          '⚠️ [DealerController] Unknown dealer type: $uiType, defaulting to "car"',
        );
        return 'car'; // Safe default
    }
  }

  /// ---------------- INPUT FORMATTERS ----------------
  List<TextInputFormatter> phoneInputFormatters() => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];
}
