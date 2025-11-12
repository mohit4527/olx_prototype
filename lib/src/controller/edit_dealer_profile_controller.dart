// lib/src/controller/edit_dealer_profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiServices/apiServices.dart'; // 🔥 Added API service import
import '../model/dealer_profiles_model/dealer_profiles_model.dart'; // 🔥 Added model import

class EditDealerProfileController extends GetxController {
  EditDealerProfileController() {
    print('🏗️🏗️🏗️ [EditDealerProfileController] Constructor called!');

    // Force immediate initialization check with delay
    Future.delayed(Duration(milliseconds: 500), () {
      print(
        '🎬 [EditDealerProfileController] Delayed initialization triggered!',
      );
      _loadData();
    });
  }

  final businessNameController = TextEditingController();
  final regNoController = TextEditingController();
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
  var isDataLoaded = false.obs;

  var businessLogo = Rx<File?>(null);
  var businessPhotos = <File>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    print("🎯🎯🎯 [EditDealerProfileController] onInit() called!");
    isDataLoaded.value = false;

    // 🔥 DEBUG: Check if arguments are available immediately
    final arguments = Get.arguments;
    print("📦 [EditDealerProfileController] Arguments in onInit: $arguments");

    // Force data loading from onInit
    print('🔄 [EditDealerProfileController] Triggering _loadData from onInit');
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    print(
      "🚀🚀🚀 [EditDealerProfileController] onReady called - Starting data load",
    );

    // 🔥 Load data directly (no PostFrameCallback to avoid conflicts)
    _loadData();
  }

  Future<void> _loadData() async {
    print("🚀🚀🚀 [EditDealerProfileController] _loadData() STARTED!");
    try {
      // 🔥 FIRST: Check if data passed from arguments (dealer profile creation)
      var arguments = Get.arguments;
      print("🔍 [EditDealerProfileController] Arguments received: $arguments");
      print(
        "🔍 [EditDealerProfileController] Arguments type: ${arguments.runtimeType}",
      );

      // 🔥 If no arguments initially, wait a bit and retry (sometimes arguments come later)
      if (arguments == null) {
        print(
          "⏳ [EditDealerProfileController] No arguments found, waiting 500ms and retrying...",
        );
        await Future.delayed(const Duration(milliseconds: 500));
        arguments = Get.arguments;
        print(
          "🔄 [EditDealerProfileController] Arguments after retry: $arguments",
        );
      }

      if (arguments != null && arguments is Map<String, dynamic>) {
        print(
          "✅ [EditDealerProfileController] Valid arguments found - Loading data from arguments",
        );
        _loadFromArguments(arguments);
        isDataLoaded.value = true;
        return;
      } else {
        print(
          "❌ [EditDealerProfileController] No valid arguments found - Will load from API/SharedPreferences",
        );
      }

      // 🔥 ENHANCED: Load data from multiple sources
      final prefs = await SharedPreferences.getInstance();
      final String? userId = prefs.getString('userId');
      final String? dealerId = prefs.getString('dealerId');

      print('🔍 [EditDealerProfileController] Loading existing profile data:');
      print('   - userId: $userId');
      print('   - dealerId: $dealerId');

      if (userId == null || userId.isEmpty) {
        print('❌ [EditDealerProfileController] No userId found');
        isDataLoaded.value = true;
        return;
      }

      // 🔥 Try multiple approaches to load data
      bool dataLoaded = false;

      // 🔥 METHOD 1: Try dealerId-based loading (most reliable)
      if (dealerId != null && dealerId.isNotEmpty) {
        try {
          print(
            '� [EditDealerProfileController] Attempting dealerId-based loading...',
          );
          dataLoaded = await _loadDataByDealerId(dealerId);
          if (dataLoaded) {
            print(
              '✅ [EditDealerProfileController] Successfully loaded data by dealerId',
            );
          }
        } catch (dealerIdError) {
          print(
            '⚠️ [EditDealerProfileController] DealerId-based loading failed: $dealerIdError',
          );
        }
      }

      // 🔥 METHOD 2: Try original userId-based API if dealerId failed
      if (!dataLoaded) {
        try {
          print(
            '🌐 [EditDealerProfileController] Attempting userId-based API loading...',
          );
          final dealerProfile = await ApiService.getCurrentUserDealerProfile(
            userId,
          );
          if (dealerProfile != null) {
            await loadProfileDataFromAPI(dealerProfile);
            print(
              '✅ [EditDealerProfileController] Successfully loaded data from userId API',
            );
            dataLoaded = true;
          }
        } catch (apiError) {
          print('⚠️ [EditDealerProfileController] UserId API error: $apiError');
        }
      }

      // If API failed, try SharedPreferences
      if (!dataLoaded) {
        print(
          '🔄 [EditDealerProfileController] API failed, trying SharedPreferences...',
        );
        await loadProfileDataFromSharedPreferences();

        // Check if we actually have some data
        if (businessNameController.text.isNotEmpty ||
            phoneController.text.isNotEmpty) {
          print(
            '✅ [EditDealerProfileController] Loaded data from SharedPreferences',
          );
          dataLoaded = true;
        }
      }

      if (!dataLoaded) {
        print(
          '❌ [EditDealerProfileController] No dealer profile data found anywhere',
        );
      }
    } catch (e, stackTrace) {
      print(
        '💥💥💥 [EditDealerProfileController] CRITICAL ERROR in _loadData: $e',
      );
      print('📋 [EditDealerProfileController] Stack trace: $stackTrace');

      try {
        // Fallback to SharedPreferences if API fails
        print(
          '🆘 [EditDealerProfileController] Attempting SharedPreferences fallback...',
        );
        await loadProfileDataFromSharedPreferences();
        print(
          '✅ [EditDealerProfileController] SharedPreferences fallback completed',
        );
      } catch (fallbackError) {
        print(
          '💥 [EditDealerProfileController] Even SharedPreferences fallback failed: $fallbackError',
        );
      }
    }

    isDataLoaded.value = true;
    print("🏁🏁🏁 [EditDealerProfileController] _loadData() COMPLETED!");
  }

  Future<void> debugSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print("🔍 DEBUG: All SharedPreferences keys: ${prefs.getKeys().toList()}");
    print(
      "🔍 DEBUG: businessName = '${prefs.getString('businessName') ?? 'NOT FOUND'}'",
    );
    print("🔍 DEBUG: regNo = '${prefs.getString('regNo') ?? 'NOT FOUND'}'");
    print("🔍 DEBUG: city = '${prefs.getString('city') ?? 'NOT FOUND'}'");
    print("🔍 DEBUG: phone = '${prefs.getString('phone') ?? 'NOT FOUND'}'");
  }

  /// 🔥 NEW: Comprehensive debug method to show ALL loaded form data
  void debugCompleteFormData() {
    print("🎯🎯🎯 [COMPLETE FORM DATA DEBUG] 🎯🎯🎯");
    print("📝 TEXT FIELDS:");
    print(
      "   1. Business Name: '${businessNameController.text}' ${businessNameController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   2. Registration No: '${regNoController.text}' ${regNoController.text.isNotEmpty ? '✅' : '❌'}",
    );
    // Village field removed - not in current controller declarations
    print(
      "   3. City: '${cityController.text}' ${cityController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   5. State: '${stateController.text}' ${stateController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   6. Country: '${countryController.text}' ${countryController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   7. Phone: '${phoneController.text}' ${phoneController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   8. Email: '${emailController.text}' ${emailController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   9. Address: '${addressController.text}' ${addressController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   10. Description: '${descriptionController.text}' ${descriptionController.text.isNotEmpty ? '✅' : '❌'}",
    );

    print("🎯 DROPDOWN/SELECTION FIELDS:");
    print(
      "   11. Dealer Type: '${selectedDealerType.value}' ${selectedDealerType.value.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   12. Business Hours: '${businessHours.value}' ${businessHours.value.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   13. Payment Methods: ${selectedPayments.toList()} ${selectedPayments.isNotEmpty ? '✅' : '❌'}",
    );

    print("📸 MEDIA FIELDS:");
    print(
      "   15. Business Logo: ${businessLogo.value != null ? '✅ File exists' : '❌ No logo'}",
    );
    print(
      "   16. Business Photos: ${businessPhotos.length} photos ${businessPhotos.isNotEmpty ? '✅' : '❌'}",
    );

    // Count populated fields
    int populatedTextFields = [
      businessNameController.text,
      regNoController.text,
      cityController.text,
      stateController.text,
      countryController.text,
      phoneController.text,
      emailController.text,
      addressController.text,
      descriptionController.text,
    ].where((text) => text.isNotEmpty).length;

    int populatedOtherFields = [
      selectedDealerType.value,
      businessHours.value,
    ].where((value) => value.isNotEmpty).length;

    if (selectedPayments.isNotEmpty) populatedOtherFields++;
    if (businessLogo.value != null) populatedOtherFields++;
    if (businessPhotos.isNotEmpty) populatedOtherFields++;

    int totalPopulated = populatedTextFields + populatedOtherFields;
    print(
      "📊 SUMMARY: $totalPopulated/16 fields populated (${(totalPopulated / 16 * 100).toStringAsFixed(1)}%)",
    );
    print("🏁🏁🏁 [COMPLETE FORM DATA DEBUG END] 🏁🏁🏁");
  }

  // 🔥 Public method to load data from arguments (called from screen)
  void loadDataFromArguments(Map<String, dynamic> data) {
    print(
      "🚀 [EditDealerProfileController] PUBLIC loadDataFromArguments() called",
    );
    _loadFromArguments(data);
    isDataLoaded.value = true;
  }

  /// 🔥 NEW: Load data by dealerId from API
  Future<bool> _loadDataByDealerId(String dealerId) async {
    try {
      print(
        '🆔 [EditDealerProfileController] Loading data by dealerId: $dealerId',
      );

      // Fetch all dealer profiles and find the one matching our dealerId
      final dealerProfilesModel = await ApiService.fetchDealerProfiles();

      if (dealerProfilesModel?.data != null &&
          dealerProfilesModel!.data!.isNotEmpty) {
        // Find our profile by dealerId
        final ourProfile = dealerProfilesModel.data!.firstWhere(
          (profile) => profile.id == dealerId,
          orElse: () => throw Exception('Profile not found'),
        );

        // Load data from found profile
        await loadProfileDataFromAPI(ourProfile);
        print(
          '✅ [EditDealerProfileController] Data loaded successfully from dealerId',
        );
        return true;
      }

      print(
        '❌ [EditDealerProfileController] No profiles found in API response',
      );
      return false;
    } catch (e) {
      print('💥 [EditDealerProfileController] Error loading by dealerId: $e');
      return false;
    }
  }

  void _loadFromArguments(Map<String, dynamic> data) {
    print("🔥 [EditDealerProfileController] _loadFromArguments() called");
    print(
      "📦 [EditDealerProfileController] Data received from arguments: $data",
    );

    businessNameController.text = data['businessName'] ?? '';
    regNoController.text = data['regNo'] ?? '';
    // Village field removed - not in current controller declarations
    cityController.text = data['city'] ?? '';
    stateController.text = data['state'] ?? '';
    countryController.text = data['country'] ?? '';
    phoneController.text = data['phone'] ?? '';
    emailController.text = data['email'] ?? '';
    addressController.text = data['address'] ?? '';
    descriptionController.text = data['description'] ?? '';

    // Debug print loaded data from arguments
    print("✅ [EditDealerProfileController] Text fields loaded from arguments:");
    print("   Business Name: '${businessNameController.text}'");
    print("   Reg No: '${regNoController.text}'");
    // Village debug removed - field not used
    print("   City: '${cityController.text}'");
    print("   State: '${stateController.text}'");
    print("   Phone: '${phoneController.text}'");
    print("   Email: '${emailController.text}'");
    print("   Address: '${addressController.text}'");
    print("   Description: '${descriptionController.text}'");

    selectedDealerType.value = data['selectedDealerType'] ?? '';
    if (data['selectedPayments'] is List<dynamic>) {
      selectedPayments.assignAll(List<String>.from(data['selectedPayments']));
    }
    businessHours.value = data['businessHours'] ?? '';

    print(
      "✅ [EditDealerProfileController] Other fields loaded from arguments:",
    );
    print("   Dealer Type: '${selectedDealerType.value}'");
    print("   Payment Methods: ${selectedPayments.toList()}");
    print("   Business Hours: '${businessHours.value}'");

    final logoPath = data['businessLogoPath'];
    if (logoPath != null &&
        logoPath.isNotEmpty &&
        File(logoPath).existsSync()) {
      businessLogo.value = File(logoPath);
      print(
        "📸 [EditDealerProfileController] Business logo loaded from path: $logoPath",
      );
    } else {
      print(
        "⚠️ [EditDealerProfileController] No valid business logo path found or file doesn't exist: $logoPath",
      );
    }

    if (data['businessPhotoPaths'] != null &&
        data['businessPhotoPaths'] is List) {
      final validPhotos = (data['businessPhotoPaths'] as List<dynamic>)
          .where((p) => p != null && p.isNotEmpty && File(p).existsSync())
          .map((p) => File(p))
          .toList();

      businessPhotos.assignAll(validPhotos);
      print(
        "📸 [EditDealerProfileController] Business photos loaded: ${businessPhotos.map((f) => f.path).toList()}",
      );
    } else {
      print(
        "⚠️ [EditDealerProfileController] No valid business photos paths found",
      );
    }

    print(
      "🏁 [EditDealerProfileController] _loadFromArguments() completed successfully",
    );
  }

  /// 🔥 ENHANCED: Load profile data from API response with complete mapping
  Future<void> loadProfileDataFromAPI(DealerProfile profile) async {
    print("🌐 [EditDealerProfileController] Loading profile from API data");
    print("📦 [EditDealerProfileController] Profile ID: ${profile.id}");

    // 🚀 Load ALL text fields from API (now available in model!)
    businessNameController.text = profile.businessName ?? '';
    regNoController.text = profile.registrationNumber ?? '';
    // GST Number field removed
    // Village field removed - not in current controller declarations
    cityController.text = profile.city ?? '';
    stateController.text = profile.state ?? '';
    countryController.text = profile.country ?? '';
    phoneController.text = profile.phone ?? '';
    emailController.text = profile.email ?? '';
    addressController.text = profile.businessAddress ?? '';
    descriptionController.text = profile.description ?? '';

    // Load dropdown selections
    selectedDealerType.value = profile.dealerType ?? '';
    businessHours.value = profile.businessHours ?? '';

    // � Load payment methods from API (now available!)
    if (profile.paymentMethods != null && profile.paymentMethods!.isNotEmpty) {
      selectedPayments.assignAll(profile.paymentMethods!);
    }

    // 🔥 ENHANCED: Ensure ALL API fields override local data when available
    // Priority: API data takes precedence over SharedPreferences
    if (profile.registrationNumber != null &&
        profile.registrationNumber!.isNotEmpty) {
      regNoController.text = profile.registrationNumber!;
    }
    // GST Number field removed
    // Village field removed - not in current controller declarations
    if (profile.description != null && profile.description!.isNotEmpty) {
      descriptionController.text = profile.description!;
    }
    if (profile.businessAddress != null &&
        profile.businessAddress!.isNotEmpty) {
      addressController.text = profile.businessAddress!;
    }

    // 🚀 FORCE: Core fields always use API data when available
    if (profile.businessName != null && profile.businessName!.isNotEmpty) {
      businessNameController.text = profile.businessName!;
    }
    if (profile.city != null && profile.city!.isNotEmpty) {
      cityController.text = profile.city!;
    }
    if (profile.state != null && profile.state!.isNotEmpty) {
      stateController.text = profile.state!;
    }
    if (profile.country != null && profile.country!.isNotEmpty) {
      countryController.text = profile.country!;
    }
    if (profile.phone != null && profile.phone!.isNotEmpty) {
      phoneController.text = profile.phone!;
    }
    if (profile.email != null && profile.email!.isNotEmpty) {
      emailController.text = profile.email!;
    }

    // 🔥 Fallback to SharedPreferences only for empty fields
    final prefs = await SharedPreferences.getInstance();
    if (regNoController.text.isEmpty) {
      regNoController.text = prefs.getString('regNo') ?? '';
    }
    // Village field removed - not in current controller declarations
    if (descriptionController.text.isEmpty) {
      descriptionController.text = prefs.getString('description') ?? '';
    }

    // Load payment methods from SharedPreferences only if API didn't provide them
    if (selectedPayments.isEmpty) {
      final savedPayments = prefs.getStringList('selectedPayments');
      if (savedPayments != null && savedPayments.isNotEmpty) {
        selectedPayments.assignAll(savedPayments);
      }
    }

    // Debug print loaded data with COMPLETE API structure
    print("✅ [EditDealerProfileController] COMPLETE API data loaded:");
    print("   Business Name: '${businessNameController.text}'");
    print("   Registration No: '${regNoController.text}'");
    // GST Number debug removed
    // Village debug removed - field not used
    print("   City: '${cityController.text}'");
    print("   State: '${stateController.text}'");
    print("   Country: '${countryController.text}'");
    print("   Phone: '${phoneController.text}'");
    print("   Email: '${emailController.text}'");
    print("   Address: '${addressController.text}'");
    print("   Description: '${descriptionController.text}'");
    print("   Dealer Type: '${selectedDealerType.value}'");
    print("   Business Hours: '${businessHours.value}'");
    print("   Payment Methods: ${selectedPayments.toList()}");

    // 🔥 Show raw API data to ensure we're not missing anything
    print("🔍 [EditDealerProfileController] RAW API PROFILE DATA:");
    print("   - ID: ${profile.id}");
    print("   - UserId: ${profile.userId}");
    print("   - BusinessName (raw): '${profile.businessName}'");
    print("   - RegistrationNumber (raw): '${profile.registrationNumber}'");
    // GST Number debug removed
    // Village debug removed - field not used
    print("   - Description (raw): '${profile.description}'");
    print("   - Status: ${profile.status}");
    print("   - CreatedAt: ${profile.createdAt}");
    print("   - BusinessLogo: ${profile.businessLogo}");
    print("   - BusinessPhotos: ${profile.businessPhotos}");
    print(
      "📊 [EditDealerProfileController] FIELD MAPPING COMPLETE - All available API fields populated!",
    );

    print(
      "🎉 [EditDealerProfileController] Complete API profile data loaded successfully!",
    );

    // 🔥 FORCE UI UPDATE - Trigger reactive updates
    print("🔄 [EditDealerProfileController] Forcing UI updates...");
    selectedDealerType.refresh();
    businessHours.refresh();
    selectedPayments.refresh();
    isDataLoaded.value = true;
    update(); // Force GetX controller update

    print("✅ [EditDealerProfileController] UI updates completed!");

    // 🔥 Show comprehensive form data summary
    debugCompleteFormData();

    print(
      "🎯 [EditDealerProfileController] isDataLoaded.value: ${isDataLoaded.value}",
    );
  }

  Future<void> loadProfileDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    print("Loading profile from SharedPreferences");
    businessNameController.text = prefs.getString('businessName') ?? '';
    regNoController.text = prefs.getString('regNo') ?? '';
    // GST Number field removed
    // Village field removed - not in current controller declarations
    cityController.text = prefs.getString('city') ?? '';
    stateController.text = prefs.getString('state') ?? '';
    countryController.text = prefs.getString('country') ?? '';
    phoneController.text = prefs.getString('phone') ?? '';
    emailController.text = prefs.getString('email') ?? '';
    addressController.text = prefs.getString('address') ?? '';
    descriptionController.text = prefs.getString('description') ?? '';

    // Debug print loaded data
    print("🔍 Loaded dealer data from SharedPreferences:");
    print("   Business Name: '${businessNameController.text}'");
    print("   Reg No: '${regNoController.text}'");
    // Village debug removed - field not used
    print("   City: '${cityController.text}'");
    print("   State: '${stateController.text}'");

    selectedDealerType.value = prefs.getString('selectedDealerType') ?? '';
    final savedPayments = prefs.getStringList('selectedPayments');
    if (savedPayments != null) selectedPayments.assignAll(savedPayments);

    businessHours.value = prefs.getString('businessHours') ?? '';

    // Debug print additional data
    print("   Phone: '${phoneController.text}'");
    print("   Email: '${emailController.text}'");
    print("   Description: '${descriptionController.text}'");
    print("   Dealer Type: '${selectedDealerType.value}'");
    print("   Payment Methods: ${selectedPayments.toList()}");
    print("   Business Hours: '${businessHours.value}'");

    final logoPath = prefs.getString('businessLogoPath');
    if (logoPath != null && File(logoPath).existsSync()) {
      businessLogo.value = File(logoPath);
      print("Business logo loaded from SharedPreferences: $logoPath");
    }

    final savedPhotos = prefs.getStringList('businessPhotoPaths');
    if (savedPhotos != null) {
      businessPhotos.assignAll(
        savedPhotos.map((p) => File(p)).where((f) => f.existsSync()).toList(),
      );
      print(
        "Business photos loaded from SharedPreferences: ${businessPhotos.map((f) => f.path).toList()}",
      );
    }
  }

  Future<void> pickBusinessLogo(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        businessLogo.value = File(pickedFile.path);
        print("Picked business logo: ${pickedFile.path}");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('businessLogoPath', pickedFile.path);
        print("Business logo path saved in SharedPreferences");
      } else {
        Get.snackbar(
          "Error",
          "No image selected.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("No image selected for business logo");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("Error picking business logo: $e");
    }
  }

  Future<void> pickBusinessPhoto(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        businessPhotos.add(File(pickedFile.path));
        print("Picked business photo: ${pickedFile.path}");
        final prefs = await SharedPreferences.getInstance();
        final photoPaths = businessPhotos.map((file) => file.path).toList();
        await prefs.setStringList('businessPhotoPaths', photoPaths);
        print("Business photos paths saved in SharedPreferences: $photoPaths");
      } else {
        Get.snackbar(
          "Error",
          "No image selected.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print("No image selected for business photo");
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
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
    // rawTime example: "15:30" (HH:mm), "3:30 PM" already formatted, or "9:00 AM - 5:00 PM" (range)
    if (rawTime.isEmpty) return "";

    try {
      // If it's already a formatted range like "9:00 AM - 5:00 PM", return as is
      if (rawTime.contains(' - ')) {
        return rawTime;
      }

      // If it contains AM/PM, it's already formatted
      if (rawTime.contains('AM') || rawTime.contains('PM')) {
        return rawTime;
      }

      // If it's HH:mm format, convert to 12-hour format
      final parts = rawTime.split(':');
      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        final period = hour >= 12 ? "PM" : "AM";
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final minStr = minute.toString().padLeft(2, '0');
        return "$hour:$minStr $period";
      }
      return rawTime; // Return as is if format is unknown
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
      await prefs.setString(
        'businessHoursRaw',
        "${pickedTime.hour}${pickedTime.minute.toString().padLeft(2, '0')}",
      );
      print("Business hours saved in SharedPreferences");
    }
  }

  void submitDealerProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('businessName', businessNameController.text);
    await prefs.setString('regNo', regNoController.text);
    // GST Number field removed
    // Village field removed - not in current controller declarations  
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
    print(
      "Business photos paths: ${businessPhotos.map((f) => f.path).toList()}",
    );

    Get.snackbar(
      "Success",
      "Dealer profile updated successfully",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }
}
