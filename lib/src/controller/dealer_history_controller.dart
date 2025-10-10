import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/dealer_product_model/dealer_product_model.dart';
import '../model/user_desler_products/user_dealer_product_model.dart';
import '../model/user_offermodel/user_offermodel.dart';
import '../services/apiServices/apiServices.dart';
import '../constants/app_colors.dart';

class DealerHistoryController extends GetxController {
  var isLoadingProducts = false.obs;
  var isLoadingOffers = false.obs;

  var dealerProducts = <DealerProduct>[].obs;
  var offers = <UserOffer>[].obs;

  // Fetch all dealer products
  Future<void> fetchProducts() async {
    try {
      isLoadingProducts.value = true;
      // Try to scope to the logged-in dealer if we have a dealerId stored
      try {
        final prefs = await SharedPreferences.getInstance();
        final dealerId = prefs.getString('dealerId') ?? '';
        if (dealerId.isNotEmpty) {
          final data = await ApiService.getDealerCars(dealerId);
          if (data != null && data['data'] is List) {
            final list = (data['data'] as List)
                .map((e) => DealerProduct.fromJson(e as Map<String, dynamic>))
                .toList();
            dealerProducts.assignAll(list);
            return;
          }
        }
      } catch (e) {
        print(
          '[DealerHistoryController] Could not read dealerId from prefs: $e',
        );
      }

      // Fallback to the general dealer products endpoint
      final result = await ApiService.fetchDealerProducts();
      dealerProducts.assignAll(result);
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // Fetch offers for selected product
  Future<void> getDealerOffers(String productId) async {
    try {
      isLoadingOffers.value = true;
      final result = await ApiService.fetchDealerOffers(productId);
      offers.assignAll(result);
    } finally {
      isLoadingOffers.value = false;
    }
  }

  // Accept offer
  // Accept offer
  Future<void> acceptOffer(String productId, String offerId) async {
    try {
      isLoadingOffers.value = true;
      final acceptedOffer = await ApiService.dealerAcceptOffer(
        productId,
        offerId,
      );

      if (acceptedOffer != null) {
        int index = offers.indexWhere((o) => o.id == offerId);
        if (index != -1) {
          offers[index] = acceptedOffer;
          offers.refresh();
        }
        Get.snackbar(
          "Success",
          "Offer accepted successfully",
          backgroundColor: AppColors.appGreen,
          colorText: AppColors.appWhite,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to accept offer. Try again.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to accept offer. ${e.toString()}",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isLoadingOffers.value = false;
    }
  }

  // Reject offer
  Future<void> rejectOffer(String productId, String offerId) async {
    try {
      isLoadingOffers.value = true;
      final rejectedOffer = await ApiService.dealerRejectOffer(
        productId,
        offerId,
      );

      if (rejectedOffer != null) {
        int index = offers.indexWhere((o) => o.id == offerId);
        if (index != -1) {
          offers[index] = rejectedOffer;
          offers.refresh();
        }
        Get.snackbar(
          "Rejected",
          "Offer rejected successfully",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to reject offer. Try again.",
          backgroundColor: AppColors.appRed,
          colorText: AppColors.appWhite,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to reject offer. ${e.toString()}",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isLoadingOffers.value = false;
    }
  }
}
