import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/sell_user_car_model/sell_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';
import '../controller/subscription_controller.dart';
import '../controller/all_products_controller.dart';
import '../controller/token_controller.dart';
import '../controller/location_controller.dart';
import '../controller/dealer_controller.dart';

class CarUploadController extends GetxController {
  final formKey = GlobalKey<FormState>(); // 🔥 Form validation key
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final phoneController =
      TextEditingController(); // 📞 Phone number controller added
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final selectedCategory = RxString('all');

  RxList<File> selectedImages = <File>[].obs;
  RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> uploadCarData() async {
    print('🚀 [uploadCarData] STARTING UPLOAD PROCESS...');
    print('⚡ [uploadCarData] INSTANT subscription check - POPUP FIRST!');

    // Get controllers immediately
    final productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());

    final subscriptionController = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());

    final dealerController = Get.isRegistered<DealerProfileController>()
        ? Get.find<DealerProfileController>()
        : Get.put(DealerProfileController());

    // Reload subscription status to get latest from storage
    await subscriptionController.reloadSubscriptionStatus();

    final isSubscribed = subscriptionController.isSubscribed.value;
    final isDealerProfile = dealerController.isProfileCreated.value;
    print('💎 [uploadCarData] Is subscribed: $isSubscribed');
    print('🏪 [uploadCarData] Is dealer profile: $isDealerProfile');

    // ✅ If user is subscribed OR has dealer profile, skip product count check
    if (isSubscribed || isDealerProfile) {
      print(
        '✅ [uploadCarData] User is SUBSCRIBED or DEALER - unlimited uploads allowed!',
      );
    } else {
      // 🔥 Only check product count for NON-SUBSCRIBED users
      final cachedCount = productController.myProducts.length;
      print(
        '📊 [uploadCarData] NON-SUBSCRIBED user - checking product count: $cachedCount',
      );

      // If cached count is >= 2, fetch fresh data to confirm
      if (cachedCount >= 2) {
        print(
          '⚠️ [uploadCarData] Cached limit reached, fetching fresh count...',
        );
        try {
          await productController.fetchMyProducts();
          final freshCount = productController.myProducts.length;
          print('📊 [uploadCarData] Fresh product count: $freshCount');

          // If fresh count also shows >= 2, block upload
          if (freshCount >= 2) {
            print('🚫 [uploadCarData] FRESH BLOCK: Limit reached!');
            _showSubscriptionPopup(freshCount);
            return; // Stop here
          }
        } catch (e) {
          print('⚠️ [uploadCarData] Error fetching fresh count: $e');
          // If error, block upload for safety
          _showSubscriptionPopup(cachedCount);
          return;
        }
      } else {
        // Even if cached count is less than 2, fetch fresh data to be absolutely sure
        print(
          '🔄 [uploadCarData] Fetching fresh product count for verification...',
        );
        try {
          await productController.fetchMyProducts();
          final freshCount = productController.myProducts.length;
          print('📊 [uploadCarData] Fresh product count: $freshCount');

          // Check fresh count
          if (freshCount >= 2) {
            print('🚫 [uploadCarData] FRESH BLOCK: Limit reached!');
            _showSubscriptionPopup(freshCount);
            return; // Stop here
          }
        } catch (e) {
          print('⚠️ [uploadCarData] Error fetching fresh count: $e');
          // Continue with upload if error in fetching
        }
      }
    }

    print('✅ [uploadCarData] Product count check passed - proceeding...');

    // =================================
    // NOW PROCEED WITH FORM VALIDATION (only if product count check passed)
    // =================================

    isUploading.value = true;
    print(
      '📤 [uploadCarData] Upload state set to TRUE - proceeding with validations',
    );

    if (!formKey.currentState!.validate()) {
      isUploading.value = false;
      Get.snackbar(
        "Validation Error",
        "Please fill all required fields correctly",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Check location fields
    if (countryController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty) {
      isUploading.value = false;
      Get.snackbar(
        "Location Required",
        "Please enter country, state, and city",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (selectedImages.isEmpty) {
      isUploading.value = false;
      Get.snackbar(
        "Image Required",
        "Please select at least one image",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: Duration(seconds: 3),
      );
      return;
    }

    // Phone number validation
    final phoneNumber = phoneController.text.trim();
    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(phoneNumber)) {
      isUploading.value = false;
      Get.snackbar(
        "Invalid Phone Number",
        "Please enter a valid 10-digit Indian phone number",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: Duration(seconds: 3),
      );
      return;
    }

    final userId = await AuthService.getLoggedInUserId();
    if (userId == null) {
      isUploading.value = false;
      Get.snackbar("Error", "User not found");
      return;
    }

    print(
      '📤 [uploadCarData] All validations passed - proceeding with actual upload',
    );

    try {
      // Rest of your upload logic here...
      print('[SellUserCarController] Uploading car with phone: "$phoneNumber"');
      print('[SellUserCarController] Car title: "${titleController.text}"');
      print('Sending userId: $userId');

      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('Upload attempt $attempt of 3');

          // Create the car model object
          final carModel = SellUserCarModel(
            title: titleController.text,
            description: descriptionController.text,
            price: int.tryParse(priceController.text) ?? 0,
            category: selectedCategory.value,
            type: 'user', // Default type for user uploads
            userId: userId,
            country: countryController.text.trim(),
            state: stateController.text.trim(),
            city: cityController.text.trim(),
            phoneNumber: phoneNumber,
          );

          await ApiService.uploadCar(carModel, selectedImages);

          // Success! (uploadCar returns void on success)
          print('✅ Upload successful on attempt $attempt');
          Get.snackbar(
            "Success! 🎉",
            "Car uploaded successfully!",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            duration: Duration(seconds: 3),
          );
          _clearForm();
          Get.offAllNamed("/home_screen");
          return;
        } catch (uploadError) {
          print('❌ Upload attempt $attempt failed: $uploadError');

          // Check if this is a subscription limit error
          if (uploadError.toString().contains('Subscription limit reached')) {
            print(
              '🚫 [uploadCarData] Subscription limit reached - stopping upload',
            );
            return; // Exit upload process, popup already shown
          }

          if (attempt < 3) {
            await Future.delayed(Duration(seconds: 2));
          } else {
            rethrow;
          }
        }
      }

      // All attempts failed
      throw Exception('All upload attempts failed');
    } catch (e) {
      print('❌ Final upload error: $e');

      // Don't show error snackbar for subscription limit errors (popup already shown)
      if (!e.toString().contains('Subscription limit reached')) {
        Get.snackbar(
          "Upload Failed ❌",
          "Failed to upload car: $e",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: Duration(seconds: 5),
        );
      }
    } finally {
      isUploading.value = false;
    }
  }

  // 🚀 INSTANT SUBSCRIPTION POPUP METHOD
  void _showSubscriptionPopup(int currentCount) {
    print('💎 [_showSubscriptionPopup] Showing popup for count: $currentCount');

    final subscriptionController = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: Get.width * 0.9,
            constraints: BoxConstraints(maxHeight: Get.height * 0.75),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple.shade50,
                  Colors.white,
                  Colors.orange.shade50,
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.orange.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.diamond, color: Colors.white, size: 30),
                        SizedBox(width: 8),
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Warning icon
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Icon(Icons.lock, color: Colors.red, size: 40),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '🚫 Upload Limit Reached!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Progress info
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Your Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '$currentCount / 2 Products',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              Text(
                                'Free limit reached! 🎯',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        // Benefits
                        Text(
                          '✨ Premium Benefits',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            children: [
                              _buildBenefitRow(
                                '🚀',
                                'Unlimited Product Uploads',
                              ),
                              _buildBenefitRow('⭐', 'Featured Listings'),
                              _buildBenefitRow('📊', 'Advanced Analytics'),
                              _buildBenefitRow('🎯', 'Priority Support'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
                    child: Column(
                      children: [
                        // Premium button
                        Container(
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              print('💎 User clicked upgrade to premium');
                              Navigator.of(Get.context!).pop();
                              Future.delayed(Duration(milliseconds: 200), () {
                                subscriptionController.startRazorpayPayment();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.diamond,
                                  color: Colors.white,
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Upgrade to Premium',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        // Cancel button
                        TextButton(
                          onPressed: () {
                            Navigator.of(Get.context!).pop();
                            print('❌ User cancelled upgrade - upload blocked');
                          },
                          child: Text(
                            'Maybe Later',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    phoneController.clear();
    countryController.clear();
    stateController.clear();
    cityController.clear();
    selectedImages.clear();
    selectedCategory.value = 'all';
  }

  // Helper method for benefit rows in popup
  Widget _buildBenefitRow(String icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2), // Reduced from 4 to 2
      child: Row(
        children: [
          Text(icon, style: TextStyle(fontSize: 14)), // Reduced from 16 to 14
          SizedBox(width: 8), // Reduced from 12 to 8
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12, // Reduced from 14 to 12
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    phoneController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    super.onClose();
  }
}
