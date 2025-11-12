import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/dealer_product_model/dealer_product_model.dart';
import '../services/apiServices/apiServices.dart';
import 'dealer_wishlist_controller.dart';

class DealerDescriptionController extends GetxController {
  final ApiService _apiService = ApiService();
  final String productId;
  final String? passedPhoneNumber;
  final String? passedDealerName;
  final String? passedSellerType;

  DealerDescriptionController({
    required this.productId,
    this.passedPhoneNumber,
    this.passedDealerName,
    this.passedSellerType,
  });

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
    print('[DealerDescriptionController] 🔧 Initializing with:');
    print('  - Product ID: $productId');
    print('  - Passed Phone: $passedPhoneNumber');
    print('  - Passed Dealer Name: $passedDealerName');
    print('  - Passed Seller Type: $passedSellerType');
    fetchProductDetails();
  }

  /// 🔧 Fetch product details
  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      print(
        '[DealerDescriptionController] 📡 Fetching product details for ID: $productId',
      );
      final response = await _apiService.fetchDealerProductById(productId);
      if (response != null && response.data != null) {
        productData.value = response.data;
        print(
          '[DealerDescriptionController] ✅ Product data loaded: ${response.data?.title}',
        );
        print(
          '[DealerDescriptionController] 📞 Product phone: "${response.data?.phone}"',
        );
        print(
          '[DealerDescriptionController] 🆔 Product dealerId: "${response.data?.dealerId}"',
        );
      } else {
        print('[DealerDescriptionController] ❌ No product data received');
      }
    } catch (e) {
      print('[DealerDescriptionController] 💥 Error fetching product: $e');
      Get.snackbar("Error", "Failed to load product details");
    } finally {
      isLoading.value = false;
    }
  }

  /// Enhanced Call dealer with comprehensive phone resolution
  Future<void> callDealer() async {
    print('[DealerDescriptionController] 🔥 callDealer() called');

    final product = productData.value;
    if (product == null) {
      _showNoPhoneError();
      return;
    }

    print('[DealerDescriptionController] 📋 Product data available');
    print('[DealerDescriptionController] 🔍 Phone sources check:');
    print('  - product.phone: "${product.phone}"');
    print('  - product.dealerPhone: "${product.dealerPhone}"');
    print('  - product.dealerId: "${product.dealerId}"');

    // 🔍 Try to get phone number from multiple sources with priority
    String? phoneNumber = _resolvePhoneNumber(product);

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      print(
        '[DealerDescriptionController] ✅ Using resolved phone: $phoneNumber',
      );
      await _directCall(phoneNumber);
      return;
    }

    // If no phone found, show user-friendly error
    print('[DealerDescriptionController] ❌ No phone number resolved');
    _showNoPhoneError();
  }

  /// Comprehensive phone number resolution for dealer products
  String? _resolvePhoneNumber(Data product) {
    // Priority 1: Phone number passed from dealer products list screen (most reliable)
    if (passedPhoneNumber != null && passedPhoneNumber!.trim().isNotEmpty) {
      print(
        '[DealerDescriptionController] ✅ Using passed phone: $passedPhoneNumber',
      );
      return passedPhoneNumber!.trim();
    }

    // Priority 2: Enhanced phone from model (includes dealerPhone, dealerId.phone, etc.)
    if (product.phone != null && product.phone!.trim().isNotEmpty) {
      print(
        '[DealerDescriptionController] ✅ Using model phone: ${product.phone}',
      );
      return product.phone!.trim();
    }

    // Priority 3: Direct dealerPhone field
    if (product.dealerPhone != null && product.dealerPhone!.trim().isNotEmpty) {
      print(
        '[DealerDescriptionController] ✅ Using dealerPhone: ${product.dealerPhone}',
      );
      return product.dealerPhone!.trim();
    }

    print('[DealerDescriptionController] ❌ No phone number found');
    return null;
  }

  /// Show user-friendly no phone error
  void _showNoPhoneError() {
    Get.snackbar(
      "📞 Call Not Available",
      "Contact information is not available for this product",
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.phone_disabled, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// Enhanced WhatsApp dealer with comprehensive phone resolution
  Future<void> whatsappDealer() async {
    print('[DealerDescriptionController] � whatsappDealer() called');

    final product = productData.value;
    if (product == null) {
      _showNoWhatsAppError();
      return;
    }

    // 🔍 Try to get phone number from multiple sources
    String? phoneNumber = _resolvePhoneNumber(product);

    if (phoneNumber == null || phoneNumber.isEmpty) {
      print('[DealerDescriptionController] ❌ No WhatsApp number resolved');
      _showNoWhatsAppError();
      return;
    }

    print(
      '[DealerDescriptionController] ✅ Using WhatsApp number: $phoneNumber',
    );

    // Create enhanced message for dealer products
    String message = _createDealerWhatsAppMessage(product);

    try {
      final success = await _launchWhatsApp(phoneNumber, message);
      if (!success) {
        _showWhatsAppLaunchError();
      }
    } catch (e) {
      print('[DealerDescriptionController] WhatsApp error: $e');
      _showWhatsAppLaunchError();
    }
  }

  /// Create enhanced WhatsApp message for dealer products
  String _createDealerWhatsAppMessage(Data product) {
    String message = "Hi! 👋 I'm interested in this vehicle:\n\n";
    message += "🚗 *${product.title ?? 'Vehicle'}*\n";

    if (product.price != null) {
      message += "💰 Price: *₹${product.price}*\n";
    }

    // Use passed dealer name first, then fallback to product data
    final dealerName = passedDealerName ?? product.dealerName;
    if (dealerName != null && dealerName.isNotEmpty) {
      message += "🏪 Dealer: *$dealerName*\n";
    }

    if (product.dealerBusinessName != null &&
        product.dealerBusinessName!.isNotEmpty) {
      message += "🏢 Business: *${product.dealerBusinessName}*\n";
    }

    message +=
        "\n🔗 View details: https://oldmarket.bhoomi.cloud/app/dealer/${product.id ?? ''}\n";
    message += "\n📱 Download Old Market app for complete details!";

    return message;
  }

  /// Launch WhatsApp with enhanced error handling
  Future<bool> _launchWhatsApp(String phoneNumber, String message) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return false;

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

    // Try WhatsApp app first
    final uriApp = Uri.parse('whatsapp://send?phone=$waNumber&text=$encoded');
    if (await canLaunchUrl(uriApp)) {
      await launchUrl(uriApp, mode: LaunchMode.externalApplication);

      Get.snackbar(
        "💬 Opening WhatsApp",
        "Starting conversation with dealer...",
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        icon: const Icon(Icons.message, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return true;
    }

    // Fallback to web WhatsApp
    final uriWeb = Uri.parse(
      'https://api.whatsapp.com/send?phone=$waNumber&text=$encoded',
    );
    if (await canLaunchUrl(uriWeb)) {
      await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
      return true;
    }

    return false;
  }

  /// Show user-friendly no WhatsApp error
  void _showNoWhatsAppError() {
    Get.snackbar(
      "💬 WhatsApp Not Available",
      "WhatsApp contact is not available for this dealer",
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.message_outlined, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// Show WhatsApp launch error
  void _showWhatsAppLaunchError() {
    Get.snackbar(
      "❌ WhatsApp Error",
      "Could not open WhatsApp. Please check if it's installed.",
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
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

  /// Direct call method for API phone numbers
  Future<void> _directCall(String phoneNumber) async {
    try {
      print(
        "📞 [DealerDescriptionController] Making direct call to: $phoneNumber",
      );

      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar(
          "📞 Call Error",
          "Invalid phone number format",
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
        Get.snackbar(
          "📞 Calling Dealer",
          "Dialing $phoneNumber...",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.phone, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "❌ Call Failed",
          "Cannot make phone calls on this device",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ [DealerDescriptionController] Direct call error: $e");
      Get.snackbar(
        "❌ Call Error",
        "Failed to make call: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
