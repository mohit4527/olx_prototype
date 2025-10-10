import 'package:get/get.dart';
import '../model/wishlist_model/wishlist_model.dart';
import '../services/auth_service/auth_service.dart';
import '../services/wishlist_service/wishlist_service.dart';

class UserWishlistController extends GetxController {
  final WishlistService _service = WishlistService();

  var wishlist = <WishlistItem>[].obs;
  var isLoading = false.obs;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    initUser();
  }

  /// Initialize user and fetch wishlist if logged in
  Future<void> initUser() async {
    try {
      userId = await AuthService.getLoggedInUserId();
      if (userId != null && userId!.isNotEmpty) {
        await fetchWishlist();
      }
    } catch (e) {
      print("Error initializing user: $e");
    }
  }

  /// Fetch user wishlist
  Future<void> fetchWishlist() async {
    if (userId == null) return;
    try {
      isLoading(true);
      final items = await _service.getWishlist(userId!);
      wishlist.assignAll(items);
    } catch (e) {
      wishlist.clear();
      print("Error fetching wishlist: $e");
    } finally {
      isLoading(false);
    }
  }

  /// Check if item exists in wishlist
  bool isInWishlist(String itemId) {
    return wishlist.any((item) => item.id == itemId);
  }

  /// Add or remove from wishlist
  Future<void> toggleWishlist(String itemId) async {
    if (userId == null) return;

    try {
      if (isInWishlist(itemId)) {
        final success = await _service.removeFromWishlist(userId!, itemId);
        if (success) {
          wishlist.removeWhere((item) => item.id == itemId);
        }
      } else {
        final success = await _service.addToWishlist(userId!, itemId);
        if (success) {
          await fetchWishlist();
        }
      }
    } catch (e) {
      print("Error toggling wishlist: $e");
    }
  }
}
