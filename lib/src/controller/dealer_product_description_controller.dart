import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
// removed unused imports
import 'package:url_launcher/url_launcher.dart';

import '../model/dealer_product_model/dealer_product_model.dart';
import '../services/apiServices/apiServices.dart';
import 'dealer_wishlist_controller.dart';

class DealerDescriptionController extends GetxController {
  final ApiService _apiService = ApiService();
  final String productId;

  DealerDescriptionController({required this.productId});

  // Reactive variables
  var productData = Rx<Data?>(null);
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var isBooking = false.obs;
  var currentIndex = 0.obs;

  final TextEditingController offerController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final dealerWishlistController = Get.put(DealerWishlistController());

  @override
  void onInit() {
    super.onInit();
    print('Received Product ID: $productId');
    fetchProductDetails();
  }

  /// 🔧 Fetch product details
  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      final response = await _apiService.fetchDealerProductById(productId);
      if (response != null && response.data != null) {
        productData.value = response.data;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load product details");
    } finally {
      isLoading.value = false;
    }
  }

  ///  Call dealer
  /// Call dealer dynamically
  Future<void> callDealer() async {
    String phoneNumber = productData.value?.phone ?? ""; // 🔹 dynamic phone
    if (phoneNumber.isEmpty) {
      // Try dealer stats endpoint for contact fallback
      try {
        final dealerId = productData.value?.dealerId ?? '';
        if (dealerId.isNotEmpty) {
          final stats = await ApiService.getDealerStats(dealerId);
          final contact =
              stats?['phone'] ?? stats?['contact'] ?? stats?['data']?['phone'];
          if (contact != null) phoneNumber = contact.toString();
        }
      } catch (e) {
        print('[DealerDescriptionController] dealer stats fetch error: $e');
      }

      if (phoneNumber.isEmpty) {
        Get.snackbar(
          "Error",
          "Dealer phone not available.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }
    }

    try {
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar(
          "Error",
          "Dealer phone not available.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }

      String dialNumber = cleaned;
      if (cleaned.length == 10) {
        dialNumber = '+91$cleaned';
      } else if (cleaned.startsWith('0')) {
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) dialNumber = '+91$stripped';
      } else if (!cleaned.startsWith('+') && cleaned.length > 10) {
        dialNumber = '+$cleaned';
      }

      final uri = Uri(scheme: 'tel', path: dialNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          "Error",
          "Could not launch call functionality.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }

  /// WhatsApp dealer dynamically
  Future<void> whatsappDealer() async {
    String phoneNumber = productData.value?.phone ?? ""; // 🔹 dynamic phone
    if (phoneNumber.isEmpty) {
      try {
        final dealerId = productData.value?.dealerId ?? '';
        if (dealerId.isNotEmpty) {
          final stats = await ApiService.getDealerStats(dealerId);
          final contact =
              stats?['whatsapp'] ??
              stats?['contact'] ??
              stats?['data']?['whatsapp'];
          if (contact != null) phoneNumber = contact.toString();
        }
      } catch (e) {
        print('[DealerDescriptionController] dealer stats fetch error: $e');
      }

      if (phoneNumber.isEmpty) {
        Get.snackbar(
          "Error",
          "Dealer WhatsApp not available.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }
    }

    final message =
        'Hi, I am interested in this vehicle: ${productData.value?.title ?? ''} - http://oldmarket.bhoomi.cloud/dealer/${productData.value?.id ?? ''}';

    try {
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar(
          "Error",
          "Dealer WhatsApp not available.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
        return;
      }

      String waNumber = cleaned;
      if (cleaned.length == 10) {
        waNumber = '91$cleaned';
      } else if (cleaned.startsWith('0')) {
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) waNumber = '91$stripped';
      } else if (cleaned.startsWith('+')) {
        waNumber = cleaned.replaceFirst('+', '');
      }

      final encoded = Uri.encodeComponent(message);
      final uriApp = Uri.parse('whatsapp://send?phone=$waNumber&text=$encoded');
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }

      final uriWeb = Uri.parse(
        'https://api.whatsapp.com/send?phone=$waNumber&text=$encoded',
      );
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        return;
      }

      Get.snackbar(
        "Error",
        "Could not launch WhatsApp.",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong: $e",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }

  /// Carousel index
  void updateImageIndex(int index) {
    currentIndex.value = index;
  }

  /// Pick date
  void pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) selectedDate = picked;
    update();
  }

  /// Pick time
  void pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) selectedTime = picked;
    update();
  }

  /// Formatted date
  String get formattedDate => selectedDate != null
      ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
      : "";

  ///  Formatted time
  String get formattedTime => selectedTime != null
      ? "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}"
      : "";

  /// Book test drive
  Future<void> bookTestDrive(String carId) async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final date = formattedDate;
    final time = formattedTime;

    print("🧠 Booking Test Drive Debug Info:");
    print("Product ID: $carId");
    print("Name: $name");
    print("Phone: $phone");
    print("Date: $date");
    print("Time: $time");

    if (name.isEmpty || phone.isEmpty || date.isEmpty || time.isEmpty) {
      print("⚠️ Validation Failed: Missing fields");
      Get.snackbar(
        "Error",
        "Please fill all fields",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
      return;
    }

    isBooking.value = true;

    try {
      final response = await ApiService.bookTestDrive(
        preferredDate: date,
        preferredTime: time,
        carId: carId,
        name: name,
        phoneNumber: phone,
      );

      print("📡 API Response:");
      print("Status: ${response?.status}");
      print("Message: ${response?.message}");
      print("Data: ${response?.data}");

      // ✅ Always close bottom sheet and clear fields
      Get.back();
      nameController.clear();
      phoneController.clear();
      selectedDate = null;
      selectedTime = null;

      if (response != null && response.status == true) {
        Get.snackbar(
          "Success",
          "Test drive booked successfully",
          backgroundColor: AppColors.appGreen,
          colorText: AppColors.appWhite,
        );
      } else {
        Get.snackbar(
          "Error",
          "Book Test Drive Failed",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
      }
    } catch (e, stack) {
      print("🔥 Exception during booking: $e");
      print("📍 Stack Trace:\n$stack");

      Get.back();
      nameController.clear();
      phoneController.clear();
      selectedDate = null;
      selectedTime = null;

      Get.snackbar(
        "Error",
        "Something went wrong while booking",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isBooking.value = false;
    }
  }

  /// Show offer dialog
  void showMakeOfferDialog({
    required String productId,
    required String buyerId,
    required String sellerId,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.green.shade600,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Enter Your Offer Price",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: offerController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Offer Price",
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: isSubmitting.value
                            ? null
                            : () async {
                                if (offerController.text.isEmpty) {
                                  Get.snackbar(
                                    "Error",
                                    "Please enter an offer price",
                                  );
                                  return;
                                }

                                final price = int.tryParse(
                                  offerController.text,
                                );
                                if (price == null || price <= 0) {
                                  Get.snackbar("Error", "Invalid offer price");
                                  return;
                                }

                                isSubmitting.value = true;
                                final response = await _apiService
                                    .dealerMakeOffer(
                                      productId: productId,
                                      buyerId: buyerId,
                                      sellerId: sellerId,
                                      offerPrice: price,
                                    );
                                isSubmitting.value = false;

                                if (response != null &&
                                    response["status"] == true) {
                                  Get.back();
                                  Get.snackbar(
                                    "Success",
                                    "Offer submitted successfully",
                                    backgroundColor: Colors.green,
                                    colorText: AppColors.appWhite,
                                  );
                                  offerController.clear();
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Could not submit offer",
                                    backgroundColor: AppColors.appRed,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.green,
                                ),
                              )
                            : const Text("Post Offer"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
