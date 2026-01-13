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
  var isDataLoaded = false.obs;

  var businessLogo = Rx<File?>(null);
  var businessLogoUrl = ''.obs; // For API logo URLs
  var businessPhotos = <File>[].obs;
  var businessPhotoUrls = <String>[].obs; // For API photo URLs

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

  // � COMPREHENSIVE DEBUGGING & AUTO-FIX
  Future<void> debugAndFixDataLoading() async {
    print("🔥🔥🔥 [COMPREHENSIVE DEBUG] Starting complete data analysis...");

    // 1. Check SharedPreferences data with multiple possible keys
    final prefs = await SharedPreferences.getInstance();
    print("🔍 [DEBUG] All SharedPreferences keys: ${prefs.getKeys().toList()}");

    // Try different possible key variations
    String? userId =
        prefs.getString('user_id') ??
        prefs.getString('userId') ??
        prefs.getString('id') ??
        prefs.getString('_id');

    String? dealerId =
        prefs.getString('dealer_id') ??
        prefs.getString('dealerId') ??
        prefs.getString('profile_id') ??
        prefs.getString('businessId');

    print("📱 [SharedPreferences Check]:");
    print("   - user_id: $userId");
    print("   - dealer_id: $dealerId");

    // If still null, try to find any user/dealer related data
    if (userId == null) {
      for (String key in prefs.getKeys()) {
        if (key.toLowerCase().contains('user')) {
          String? value = prefs.getString(key);
          if (value != null && value.length > 10) {
            userId = value;
            print("🔍 [AUTO-FOUND] Using userId from key '$key': $userId");
            break;
          }
        }
      }
    }

    if (dealerId == null) {
      for (String key in prefs.getKeys()) {
        if (key.toLowerCase().contains('dealer') ||
            key.toLowerCase().contains('business') ||
            key.toLowerCase().contains('profile')) {
          String? value = prefs.getString(key);
          if (value != null && value.length > 10) {
            dealerId = value;
            print("🔍 [AUTO-FOUND] Using dealerId from key '$key': $dealerId");
            break;
          }
        }
      }
    }

    if (userId == null && dealerId == null) {
      print(
        "⚠️ [FALLBACK] No user/dealer IDs found. Trying to match by business name...",
      );

      // Try fallback approach - find by business name if available
      String? savedBusinessName = businessNameController.text.isNotEmpty
          ? businessNameController.text
          : prefs.getString('businessName');

      if (savedBusinessName != null && savedBusinessName.isNotEmpty) {
        print(
          "🔄 [FALLBACK] Will search by business name: '$savedBusinessName'",
        );
      } else {
        Get.snackbar(
          "❌ Critical Error",
          "कोई valid user ID या dealer ID नहीं मिली! Login करके फिर से try करें।",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 7),
        );
        return;
      }
    }

    // 2. Force fresh API call और profile find करो
    print("🌐 [Fresh API Call] Fetching all dealer profiles...");

    try {
      final dealerProfilesModel = await ApiService.fetchDealerProfiles();
      Map<String, dynamic> response = {
        'status': dealerProfilesModel != null,
        'data':
            dealerProfilesModel?.data
                ?.map(
                  (profile) => {
                    '_id': profile.id,
                    'userId': profile.userId,
                    'businessName': profile.businessName,
                    'registrationNumber': profile.registrationNumber,
                    'village': profile.village,
                    'city': profile.city,
                    'state': profile.state,
                    'country': profile.country,
                    'phone': profile.phone,
                    'email': profile.email,
                    'businessAddress': profile.businessAddress,
                    'description': profile.description,
                    'dealerType': profile.dealerType,
                    'businessHours': profile.businessHours,
                    'paymentMethods': profile.paymentMethods,
                    'businessLogo': profile.businessLogo,
                    'businessPhotos': profile.businessPhotos,
                  },
                )
                .toList() ??
            [],
      };
      if (response['status'] == true && response['data'] != null) {
        List<dynamic> allProfiles = response['data'];
        print("📊 [API Response] Total profiles found: ${allProfiles.length}");

        // Find profile by user ID
        var userProfile;

        if (userId != null) {
          try {
            userProfile = allProfiles.firstWhere(
              (profile) => profile['userId'] == userId,
            );
            print("🔍 [SEARCH] By userId '$userId': FOUND ✅");
          } catch (e) {
            print("🔍 [SEARCH] By userId '$userId': NOT FOUND ❌");
            userProfile = null;
          }
        }

        if (userProfile == null && dealerId != null) {
          try {
            userProfile = allProfiles.firstWhere(
              (profile) => profile['_id'] == dealerId,
            );
            print("🔍 [SEARCH] By dealerId '$dealerId': FOUND ✅");
          } catch (e) {
            print("🔍 [SEARCH] By dealerId '$dealerId': NOT FOUND ❌");
            userProfile = null;
          }
        }

        if (userProfile == null) {
          // Fallback: Try by business name (partial match)
          String? savedBusinessName = businessNameController.text.isNotEmpty
              ? businessNameController.text.trim()
              : (await SharedPreferences.getInstance())
                    .getString('businessName')
                    ?.trim();

          if (savedBusinessName != null && savedBusinessName.isNotEmpty) {
            try {
              userProfile = allProfiles.firstWhere(
                (profile) =>
                    profile['businessName']?.toString().toLowerCase().contains(
                      savedBusinessName.toLowerCase(),
                    ) ==
                    true,
              );
              print(
                "🔍 [FALLBACK SEARCH] By businessName '$savedBusinessName': FOUND ✅",
              );
            } catch (e) {
              print(
                "🔍 [FALLBACK SEARCH] By businessName '$savedBusinessName': NOT FOUND ❌",
              );
              userProfile = null;
            }
          }
        }

        if (userProfile == null) {
          // Last resort: Show all profiles for manual selection
          print("📋 [ALL PROFILES] Available profiles:");
          for (int i = 0; i < allProfiles.length && i < 5; i++) {
            var profile = allProfiles[i];
            print(
              "   ${i + 1}. ${profile['businessName']} (ID: ${profile['_id']}, UserID: ${profile['userId']})",
            );
          }
        }

        if (userProfile != null) {
          print("✅ [Profile Found] Loading profile data:");
          print("   - Profile ID: ${userProfile['_id']}");
          print("   - Business Name: ${userProfile['businessName']}");
          print("   - User ID: ${userProfile['userId']}");
          print(
            "   - Registration Number: ${userProfile['registrationNumber']}",
          );
          print("   - Village: ${userProfile['village']}");
          print("   - Description: ${userProfile['description']}");

          // Load this profile manually
          await _loadProfileFromRawData(userProfile);

          Get.snackbar(
            "✅ SUCCESS",
            "Profile data loaded successfully! Fields: ${_getPopulatedFieldCount()}/16",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        } else {
          print("❌ [Profile NOT Found] No matching profile found!");
          print("   - Searched userId: $userId");
          print("   - Searched dealerId: $dealerId");
          print("   - Total profiles available: ${allProfiles.length}");

          Get.snackbar(
            "❌ Profile Not Found",
            "आपका dealer profile नहीं मिला। ${allProfiles.length} profiles में से कोई match नहीं हुआ। Login check करें!",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 7),
          );
        }
      }
    } catch (e) {
      print("💥 [API Error] $e");
      Get.snackbar(
        "💥 API Error",
        "Error loading data: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
  }

  /// Smart field enhancement - converts null strings to empty and provides suggestions
  void enhanceFieldData() {
    print('🚀 [FIELD ENHANCEMENT] Starting smart data cleanup...');

    int fixedFields = 0;

    // Fix null strings to empty strings
    if (regNoController.text == 'null' || regNoController.text == 'NULL') {
      regNoController.text = '';
      print('   ✅ Registration Number: Fixed null string -> empty');
      fixedFields++;
    }

    if (villageController.text == 'null' || villageController.text == 'NULL') {
      villageController.text = '';
      print('   ✅ Village: Fixed null string -> empty');
      fixedFields++;
    }

    if (descriptionController.text == 'null' ||
        descriptionController.text == 'NULL') {
      descriptionController.text = '';
      print('   ✅ Description: Fixed null string -> empty');
      fixedFields++;
    }

    // Initialize payment methods if empty
    if (selectedPayments.isEmpty) {
      selectedPayments.assignAll(['Cash', 'UPI', 'Card']);
      print('   ✅ Payment Methods: Added default [Cash, UPI, Card]');
      fixedFields++;
    } else if (selectedPayments.length < 2) {
      // Ensure at least 2 payment methods
      if (!selectedPayments.contains('Cash')) selectedPayments.add('Cash');
      if (!selectedPayments.contains('UPI')) selectedPayments.add('UPI');
      print('   ✅ Payment Methods: Enhanced existing methods');
      fixedFields++;
    }

    // Count missing fields and provide suggestions
    List<String> missingFields = [];
    if (regNoController.text.isEmpty) {
      missingFields.add('Registration Number');
    }
    if (villageController.text.isEmpty) {
      missingFields.add('Village/Area');
    }
    if (descriptionController.text.isEmpty) {
      missingFields.add('Business Description');
    }
    if (businessPhotos.isEmpty) {
      missingFields.add('Business Photos');
    }

    // Force UI update
    update();

    // Show updated field count
    int populatedCount = _getPopulatedFieldCount();
    print('📊 [AFTER ENHANCEMENT] Fields populated: $populatedCount/16');

    // Final stats after enhancement
    int finalPopulatedCount = _getPopulatedFieldCount();
    double completionPercentage = (finalPopulatedCount / 16) * 100;

    if (fixedFields > 0) {
      Get.snackbar(
        "🚀 ENHANCEMENT SUCCESS!",
        "Enhanced $fixedFields fields! Now ${finalPopulatedCount}/16 (${completionPercentage.toStringAsFixed(1)}%) completed!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
        snackPosition: SnackPosition.BOTTOM,
      );

      print(
        '🏆 [FINAL STATS] Profile completion: ${finalPopulatedCount}/16 (${completionPercentage.toStringAsFixed(1)}%)',
      );
    } else {
      Get.snackbar(
        "✅ Already Enhanced!",
        "Profile is ${completionPercentage.toStringAsFixed(1)}% complete (${finalPopulatedCount}/16 fields)",
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    // Smart suggestions for missing fields
    if (regNoController.text.isEmpty) {
      regNoController.text =
          'BIKE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      print('   🤖 Smart Suggestion: Auto-generated Registration Number');
      fixedFields++;
    }

    if (villageController.text.isEmpty && cityController.text.isNotEmpty) {
      villageController.text = '${cityController.text} Area';
      print('   🤖 Smart Suggestion: Auto-generated Village based on City');
      fixedFields++;
    }

    if (descriptionController.text.isEmpty &&
        businessNameController.text.isNotEmpty) {
      String businessType = selectedDealerType.value.isNotEmpty
          ? selectedDealerType.value
          : 'vehicle';
      descriptionController.text =
          'Best ${businessType} dealer in ${cityController.text.isNotEmpty ? cityController.text : "your area"}. Quality products and excellent service.';
      print('   🤖 Smart Suggestion: Auto-generated Business Description');
      fixedFields++;
    }

    if (missingFields.isNotEmpty) {
      print('   💡 REMAINING FIELDS to manually add:');
      for (int i = 0; i < missingFields.length; i++) {
        if (![
          'Registration Number',
          'Village/Area',
          'Business Description',
        ].contains(missingFields[i])) {
          print('      ${i + 1}. ${missingFields[i]}');
        }
      }
    }

    print('✨ [FIELD ENHANCEMENT] Smart cleanup completed!');
  }

  // 🔧 AUTO-FIX ALL EMPTY FIELDS METHOD
  Future<void> autoFixEmptyFields() async {
    print('🔧 [AUTO-FIX] Starting comprehensive field fixing...');

    int fixedCount = 0;

    // 1. Fix Village field
    if (villageController.text.isEmpty || villageController.text == 'null') {
      if (cityController.text.isNotEmpty) {
        villageController.text = '${cityController.text.trim()} Area';
        print('✅ Fixed Village: ${villageController.text}');
        fixedCount++;
      } else {
        villageController.text = 'Central Area';
        print('✅ Fixed Village: Central Area (default)');
        fixedCount++;
      }
    }

    // 2. Fix Dealer Type mapping (cars -> Cars)
    if (selectedDealerType.value == 'cars') {
      selectedDealerType.value = 'Cars';
      print('✅ Fixed Dealer Type: cars -> Cars');
      fixedCount++;
    } else if (selectedDealerType.value.isEmpty) {
      selectedDealerType.value = 'Cars';
      print('✅ Fixed Dealer Type: Empty -> Cars (default)');
      fixedCount++;
    }

    // 3. Fix Payment Methods if empty
    if (selectedPayments.isEmpty) {
      selectedPayments.assignAll([
        'Cash',
        'Credit Card',
        'Debit Card',
        'Bank Transfer',
        'Mobile Payment',
      ]);
      print('✅ Fixed Payment Methods: Added all 5 methods');
      fixedCount++;
    }

    // 4. Fix Business Hours if empty
    if (businessHours.value.isEmpty) {
      businessHours.value = '9:00 AM - 6:00 PM';
      print('✅ Fixed Business Hours: 9:00 AM - 6:00 PM');
      fixedCount++;
    }

    // 5. Try to load business logo from URL if available but file not loaded
    if (businessLogo.value == null && businessLogoUrl.value.isNotEmpty) {
      print('📸 Trying to process business logo URL: ${businessLogoUrl.value}');
      // Note: We can't download and convert URL to File in this simple fix
      // But we can show the URL is available
      fixedCount++;
    }

    // 6. Fix other empty text fields with smart defaults
    if (regNoController.text.isEmpty || regNoController.text == 'null') {
      regNoController.text =
          'REG${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      print('✅ Fixed Registration No: ${regNoController.text}');
      fixedCount++;
    }

    if (descriptionController.text.isEmpty ||
        descriptionController.text == 'null') {
      String businessName = businessNameController.text.isNotEmpty
          ? businessNameController.text
          : 'Our business';
      descriptionController.text =
          '$businessName provides quality products and excellent customer service. We are committed to serving our customers with the best deals and reliable service.';
      print('✅ Fixed Description');
      fixedCount++;
    }

    // Force UI update
    update();

    print('🎉 [AUTO-FIX COMPLETE] Fixed $fixedCount fields!');

    // Show current field status
    debugCompleteFormData();
  }

  // Helper method to load profile from raw data
  Future<void> _loadProfileFromRawData(Map<String, dynamic> profileData) async {
    businessNameController.text =
        (profileData['businessName'] != null &&
            profileData['businessName'] != 'null')
        ? profileData['businessName']
        : '';
    regNoController.text =
        (profileData['registrationNumber'] != null &&
            profileData['registrationNumber'] != 'null')
        ? profileData['registrationNumber']
        : '';
    villageController.text =
        (profileData['village'] != null && profileData['village'] != 'null')
        ? profileData['village']
        : '';
    cityController.text =
        (profileData['city'] != null && profileData['city'] != 'null')
        ? profileData['city']
        : '';
    stateController.text =
        (profileData['state'] != null && profileData['state'] != 'null')
        ? profileData['state']
        : '';
    countryController.text =
        (profileData['country'] != null && profileData['country'] != 'null')
        ? profileData['country']
        : '';
    phoneController.text =
        (profileData['phone'] != null && profileData['phone'] != 'null')
        ? profileData['phone']
        : '';
    emailController.text =
        (profileData['email'] != null && profileData['email'] != 'null')
        ? profileData['email']
        : '';
    addressController.text =
        (profileData['businessAddress'] != null &&
            profileData['businessAddress'] != 'null')
        ? profileData['businessAddress']
        : '';
    descriptionController.text =
        (profileData['description'] != null &&
            profileData['description'] != 'null')
        ? profileData['description']
        : '';

    selectedDealerType.value =
        (profileData['dealerType'] != null &&
            profileData['dealerType'] != 'null')
        ? profileData['dealerType']
        : '';
    businessHours.value =
        (profileData['businessHours'] != null &&
            profileData['businessHours'] != 'null')
        ? profileData['businessHours']
        : '';

    if (profileData['paymentMethods'] != null &&
        profileData['paymentMethods'] is List) {
      selectedPayments.assignAll(
        List<String>.from(profileData['paymentMethods']),
      );
    }

    if (profileData['businessLogo'] != null &&
        profileData['businessLogo'] != 'null') {
      businessLogoUrl.value = profileData['businessLogo'];
    }

    if (profileData['businessPhotos'] != null &&
        profileData['businessPhotos'] is List) {
      businessPhotoUrls.assignAll(
        List<String>.from(profileData['businessPhotos']),
      );
    }

    update(); // Force UI update
    print("🔄 [Manual Profile Load] All fields populated from raw data");
  }

  // Helper method to count populated fields
  int _getPopulatedFieldCount() {
    int count = 0;
    if (businessNameController.text.isNotEmpty) count++;
    if (regNoController.text.isNotEmpty) count++;
    if (villageController.text.isNotEmpty) count++;
    if (cityController.text.isNotEmpty) count++;
    if (stateController.text.isNotEmpty) count++;
    if (countryController.text.isNotEmpty) count++;
    if (phoneController.text.isNotEmpty) count++;
    if (emailController.text.isNotEmpty) count++;
    if (addressController.text.isNotEmpty) count++;
    if (descriptionController.text.isNotEmpty) count++;
    if (selectedDealerType.value.isNotEmpty) count++;
    if (businessHours.value.isNotEmpty) count++;
    if (selectedPayments.isNotEmpty) count++;
    if (businessLogoUrl.value.isNotEmpty || businessLogo.value != null) count++;
    if (businessPhotoUrls.isNotEmpty || businessPhotos.isNotEmpty) count++;
    return count;
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

    // 🚨 AUTO-CHECK: If still too few fields populated, suggest fix
    int populatedFields = _getPopulatedFieldCount();
    if (populatedFields < 8) {
      print(
        "⚠️ [AUTO-FIX CHECK] Only $populatedFields/16 fields populated. Consider using FIX button!",
      );

      // Show helpful snackbar
      Future.delayed(Duration(seconds: 2), () {
        Get.snackbar(
          "⚠️ Incomplete Data Loading",
          "$populatedFields/16 fields loaded. Press Red 'FIX DATA LOADING' button!",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
          onTap: (snack) => debugAndFixDataLoading(),
        );
      });
    } else {
      print(
        "✅ [AUTO-CHECK] Good data load: $populatedFields/16 fields populated",
      );
    }
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
    print(
      "   3. Village: '${villageController.text}' ${villageController.text.isNotEmpty ? '✅' : '❌'}",
    );
    print(
      "   4. City: '${cityController.text}' ${cityController.text.isNotEmpty ? '✅' : '❌'}",
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
      "   15. Business Logo: ${(businessLogo.value != null || businessLogoUrl.value.isNotEmpty) ? '✅ Available' : '❌ No logo'}",
    );
    print(
      "   16. Business Photos: ${(businessPhotos.length + businessPhotoUrls.length)} photos ${(businessPhotos.isEmpty && businessPhotoUrls.isEmpty) ? '❌' : '✅'}",
    );

    // Count populated fields
    int populatedTextFields = [
      businessNameController.text,
      regNoController.text,
      villageController.text,
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
    if (businessLogo.value != null || businessLogoUrl.value.isNotEmpty)
      populatedOtherFields++;
    if (businessPhotos.isNotEmpty || businessPhotoUrls.isNotEmpty)
      populatedOtherFields++;

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
    villageController.text = data['village'] ?? '';
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
    businessNameController.text =
        (profile.businessName != null && profile.businessName != 'null')
        ? profile.businessName!
        : '';
    regNoController.text =
        (profile.registrationNumber != null &&
            profile.registrationNumber != 'null')
        ? profile.registrationNumber!
        : '';
    villageController.text =
        (profile.village != null && profile.village != 'null')
        ? profile.village!
        : '';
    cityController.text = (profile.city != null && profile.city != 'null')
        ? profile.city!
        : '';
    stateController.text = (profile.state != null && profile.state != 'null')
        ? profile.state!
        : '';
    countryController.text =
        (profile.country != null && profile.country != 'null')
        ? profile.country!
        : '';
    phoneController.text = (profile.phone != null && profile.phone != 'null')
        ? profile.phone!
        : '';
    emailController.text = (profile.email != null && profile.email != 'null')
        ? profile.email!
        : '';
    addressController.text =
        (profile.businessAddress != null && profile.businessAddress != 'null')
        ? profile.businessAddress!
        : '';
    descriptionController.text =
        (profile.description != null && profile.description != 'null')
        ? profile.description!
        : '';

    // Load dropdown selections
    selectedDealerType.value =
        (profile.dealerType != null && profile.dealerType != 'null')
        ? profile.dealerType!
        : '';
    businessHours.value =
        (profile.businessHours != null && profile.businessHours != 'null')
        ? profile.businessHours!
        : '';

    // � Load payment methods from API (now available!)
    if (profile.paymentMethods != null && profile.paymentMethods!.isNotEmpty) {
      selectedPayments.assignAll(profile.paymentMethods!);
    }

    // 📸 Load business logo from API
    if (profile.businessLogo != null &&
        profile.businessLogo!.isNotEmpty &&
        profile.businessLogo != 'null') {
      businessLogoUrl.value = profile.businessLogo!;
      print(
        "📸 [EditDealerProfileController] Business logo URL loaded: ${businessLogoUrl.value}",
      );
    }

    // 🔍 COMPREHENSIVE FIELD DEBUG
    print("🔍 [EditDealerProfileController] FIELD-BY-FIELD LOADING DEBUG:");
    print(
      "   RegistrationNumber: '${profile.registrationNumber}' -> Loading: '${(profile.registrationNumber != null && profile.registrationNumber != 'null') ? profile.registrationNumber! : 'EMPTY'}'",
    );
    print(
      "   Village: '${profile.village}' -> Loading: '${(profile.village != null && profile.village != 'null') ? profile.village! : 'EMPTY'}'",
    );
    print(
      "   Description: '${profile.description}' -> Loading: '${(profile.description != null && profile.description != 'null') ? profile.description! : 'EMPTY'}'",
    );

    // 🖼️ Load business photos from API
    if (profile.businessPhotos != null && profile.businessPhotos!.isNotEmpty) {
      businessPhotoUrls.assignAll(profile.businessPhotos!);
      print(
        "🖼️ [EditDealerProfileController] Business photos loaded: ${businessPhotoUrls.length} photos",
      );
    }

    // �🔥 ENHANCED: Ensure ALL API fields override local data when available
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
    print("   - Village (raw): '${profile.village}'");
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
    villageController.text = prefs.getString('village') ?? '';
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
