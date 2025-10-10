// lib/src/controller/dealer_wishlist_controller.dart

import 'package:get/get.dart';
import '../services/auth_service/auth_service.dart';
import '../services/dealer_wishlist_service/dealer_wishlist_service.dart';

class DealerWishlistController extends GetxController {
  final DealerWishlistService _wishlistService = DealerWishlistService();

  var wishlist = <dynamic>[].obs;
  var isLoading = false.obs;
  String? dealerId;

  @override
  void onInit() {
    super.onInit();
    initDealer();
  }

  Future<void> initDealer() async {
    dealerId = await AuthService.getLoggedInUserId();

    if (dealerId != null) {
      await fetchWishlist();
    } else {
      print("Dealer ID (userId) not found in SharedPreferences");
    }
  }

  /// Fetch dealer wishlist
  Future<void> fetchWishlist() async {
    if (dealerId == null) return;
    try {
      isLoading.value = true;
      final items = await _wishlistService.getDealerWishlist(dealerId!);
      wishlist.assignAll(items);
    } catch (e) {
      print("Error fetching wishlist: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle wishlist (add/remove)
  Future<void> toggleWishlist(String itemId) async {
    if (dealerId == null) return;

    final alreadyInWishlist = wishlist.any((item) => item["_id"].toString() == itemId);

    if (alreadyInWishlist) {
      final success = await _wishlistService.removeFromDealerWishlist(dealerId!, itemId);
      if (success) {
        wishlist.removeWhere((item) => item["_id"].toString() == itemId);
      }
    } else {
      final success = await _wishlistService.addToDealerWishlist(dealerId!, itemId);
      if (success) {
        await fetchWishlist();
      }
    }
  }

  /// Check if item is in wishlist
  bool isInWishlist(String itemId) {
    return wishlist.any((item) {
      if (item is Map<String, dynamic> && item.containsKey('_id')) {
        return item["_id"].toString() == itemId;
      }
      return false;
    });
  }
}