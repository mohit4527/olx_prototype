import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/sell_dealer_car_model/sell_dealer_car_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';
import '../controller/subscription_controller.dart';
import '../controller/all_products_controller.dart';
import '../controller/location_controller.dart';

class DealerCarUploadController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final tagsController = TextEditingController();
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
    print(
      '🚀 [DealerUpload] Starting upload with instant subscription check...',
    );

    // Get controllers
    final productController = Get.isRegistered<ProductController>()
        ? Get.find<ProductController>()
        : Get.put(ProductController());
    final subscriptionController = Get.isRegistered<SubscriptionController>()
        ? Get.find<SubscriptionController>()
        : Get.put(SubscriptionController());

    // Reload subscription status to get latest from storage
    await subscriptionController.reloadSubscriptionStatus();

    // Check subscription status
    final isSubscribed = subscriptionController.isSubscribed.value;
    print('💎 [DealerUpload] Is subscribed: $isSubscribed');

    // ✅ If user is subscribed, skip product count check entirely
    if (isSubscribed) {
      print('✅ [DealerUpload] User is SUBSCRIBED - unlimited uploads allowed!');
    } else {
      // 🔥 Only check product count for NON-SUBSCRIBED dealers
      final cachedCount = productController.myProducts.length;
      print(
        '📊 [DealerUpload] NON-SUBSCRIBED dealer - checking product count: $cachedCount',
      );

      // Show popup immediately if limit reached
      if (cachedCount >= 2) {
        print('🚫 [DealerUpload] INSTANT BLOCK: Limit reached!');
        productController.showSubscriptionPopup();
        return;
      }

      // Check fresh count if needed
      try {
        await productController.fetchMyProducts();
        if (productController.myProducts.length >= 2) {
          print('🚫 [DealerUpload] FRESH BLOCK: Limit reached!');
          productController.showSubscriptionPopup();
          return;
        }
      } catch (e) {
        print('⚠️ [DealerUpload] Error checking limit: $e');
        if (cachedCount >= 2) {
          productController.showSubscriptionPopup();
          return;
        }
      }
    }

    // Proceed with validation only if subscription allows
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        tagsController.text.trim().isEmpty ||
        countryController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill all fields (including country, state, city) & select images",
      );
      return;
    }

    final dealerId = await AuthService.getDealerId();
    final userId = await AuthService.getLoggedInUserId();

    if (dealerId == null || userId == null) {
      Get.snackbar("Error", "Dealer or user not logged in");
      return;
    }

    print('✅ [DealerUpload] All checks passed - proceeding with upload');

    isUploading.value = true;

    try {
      // Parse tags from comma-separated string
      List<String> tagsList = tagsController.text
          .trim()
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final dealerCarData = DealerCarModel(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: int.parse(priceController.text.trim()),
        sellerType: 'dealer',
        userId: userId,
        dealerId: dealerId,
        category: selectedCategory.value,
        tags: tagsList.isNotEmpty ? tagsList : ["Certified"],
        country: countryController.text.trim(),
        state: stateController.text.trim(),
        city: cityController.text.trim(),
      );

      await ApiService.uploadDealerCar(dealerCarData, selectedImages);

      // Clear form first
      clearForm();

      // Show success message with enhanced styling
      Get.snackbar(
        "🎉 Dealer Success!",
        "Dealer product has been uploaded successfully!\nRedirecting to home...",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white, size: 28),
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );

      // Navigate directly to home screen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        // First try to navigate to home route
        Get.offAllNamed("/home_screen");
      } catch (e) {
        try {
          // Fallback: Pop all screens until we reach home
          Get.until((route) => route.isFirst);
        } catch (e2) {
          // Final fallback: Simple back navigation
          Get.back();
        }
      }
    } catch (e) {
      print('❌ Dealer upload error: $e');

      // Don't show error snackbar for subscription limit errors (popup already shown)
      if (!e.toString().contains('subscription limit reached')) {
        Get.snackbar(
          "Upload Failed ❌",
          "Failed to upload dealer product: $e",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: Duration(seconds: 5),
        );
      }
    } finally {
      isUploading.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    tagsController.clear();
    countryController.clear();
    stateController.clear();
    cityController.clear();
    selectedImages.clear();
    selectedCategory.value = 'all';
    Get.focusScope?.unfocus();
  }
}
