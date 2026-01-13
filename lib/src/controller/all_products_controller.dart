import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/all_product_model/all_product_model.dart';
import '../services/apiServices/apiServices.dart';
import '../controller/subscription_controller.dart';
import '../controller/token_controller.dart';
import '../widgets/subscription_popup_simple.dart';

class ProductController extends GetxController {
  RxList<AllProductModel> productList = <AllProductModel>[].obs;
  RxList<AllProductModel> _originalProductList =
      <AllProductModel>[].obs; // Store original list
  RxBool isLoading = false.obs;

  // User's uploaded products count
  RxList<AllProductModel> myProducts = <AllProductModel>[].obs;

  // Get subscription controller
  SubscriptionController get subscriptionController {
    if (Get.isRegistered<SubscriptionController>()) {
      return Get.find<SubscriptionController>();
    } else {
      return Get.put(SubscriptionController());
    }
  }

  // Get token controller
  TokenController get tokenController {
    if (Get.isRegistered<TokenController>()) {
      return Get.find<TokenController>();
    } else {
      return Get.put(TokenController());
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
    fetchMyProducts(); // Fetch user's products for count
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getAllProducts();

      if (response.isNotEmpty) {
        _originalProductList.value = response; // Store original
        shuffleProducts(); // Apply randomization
      } else {
        Get.snackbar('Error', 'No products found');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void refreshProductList() {
    print(
      '[ProductController] 🔄 Refreshing products with new randomization...',
    );
    fetchProducts(); // This will fetch fresh data and auto-shuffle
  }

  /// 🔥 Shuffle products for varied home screen experience
  /// Boosted products are prioritized at the top
  void shuffleProducts() {
    if (_originalProductList.isEmpty) return;

    print(
      '[ProductController] 🎲 Shuffling ${_originalProductList.length} products...',
    );

    // Separate boosted and non-boosted products
    List<AllProductModel> boostedProducts = _originalProductList
        .where((product) => product.isBoosted == true)
        .toList();
    List<AllProductModel> regularProducts = _originalProductList
        .where((product) => product.isBoosted != true)
        .toList();

    // Shuffle both lists separately for variety
    boostedProducts.shuffle(Random());
    regularProducts.shuffle(Random());

    // Combine: boosted products first, then regular
    List<AllProductModel> shuffledList = [
      ...boostedProducts,
      ...regularProducts,
    ];

    // Update the displayed list
    productList.value = shuffledList;

    print(
      '[ProductController] ✅ Products shuffled! Boosted: ${boostedProducts.length}, Regular: ${regularProducts.length}',
    );
    if (shuffledList.isNotEmpty) {
      print(
        '   First product: ${shuffledList.first.title} (Boosted: ${shuffledList.first.isBoosted})',
      );
    }
  }

  /// 🔄 Get different random subset each time
  /// Prioritizes boosted products at the top
  List<AllProductModel> getRandomProducts({int limit = 8}) {
    if (_originalProductList.isEmpty) return [];

    // Separate boosted and non-boosted
    List<AllProductModel> boostedProducts = _originalProductList
        .where((product) => product.isBoosted == true)
        .toList();
    List<AllProductModel> regularProducts = _originalProductList
        .where((product) => product.isBoosted != true)
        .toList();

    // Shuffle both
    boostedProducts.shuffle(Random());
    regularProducts.shuffle(Random());

    // Combine and take limit
    List<AllProductModel> combined = [...boostedProducts, ...regularProducts];
    return combined.take(limit).toList();
  }

  /// Filter products by location (Country, State, City)
  void filterProductsByLocation({
    String? country,
    String? state,
    String? city,
  }) {
    // Trim whitespace from filter inputs
    final filterCountry = country?.trim().toLowerCase() ?? '';
    final filterState = state?.trim().toLowerCase() ?? '';
    final filterCity = city?.trim().toLowerCase() ?? '';

    print('🔍 [ProductController] Filtering products by location:');
    print(
      '   Country: "$filterCountry", State: "$filterState", City: "$filterCity"',
    );

    if (_originalProductList.isEmpty) {
      print('⚠️ [ProductController] Original product list is empty');
      return;
    }

    // DEBUG: Print first few products' location data
    for (
      int i = 0;
      i < (_originalProductList.length > 3 ? 3 : _originalProductList.length);
      i++
    ) {
      final p = _originalProductList[i];
      print('   📦 Product $i: "${p.country}", "${p.state}", "${p.city}"');
    }

    List<AllProductModel> filteredList = _originalProductList.where((product) {
      // Trim and lowercase product location data
      final productCountry = (product.country ?? '').trim().toLowerCase();
      final productState = (product.state ?? '').trim().toLowerCase();
      final productCity = (product.city ?? '').trim().toLowerCase();

      // Use contains for flexible matching (handles "Ghaziabad Uttar Pradesh" etc)
      bool matchesCountry =
          filterCountry.isEmpty ||
          productCountry.contains(filterCountry) ||
          filterCountry.contains(productCountry);

      bool matchesState =
          filterState.isEmpty ||
          productState.contains(filterState) ||
          filterState.contains(productState);

      bool matchesCity =
          filterCity.isEmpty ||
          productCity.contains(filterCity) ||
          filterCity.contains(productCity);

      final matches = matchesCountry && matchesState && matchesCity;

      return matches;
    }).toList();

    print(
      '✅ [ProductController] Filtered ${filteredList.length} products from ${_originalProductList.length}',
    );

    // Separate boosted and regular products in filtered results
    List<AllProductModel> boostedProducts = filteredList
        .where((product) => product.isBoosted == true)
        .toList();
    List<AllProductModel> regularProducts = filteredList
        .where((product) => product.isBoosted != true)
        .toList();

    // 🔥 IMPORTANT: Completely reassign to trigger reactive update
    final newList = [...boostedProducts, ...regularProducts];
    productList.value = newList;

    print(
      '📊 [ProductController] productList.value assigned with ${productList.length} items',
    );
    if (newList.isNotEmpty) {
      print('📊 First 3 filtered products:');
      for (int i = 0; i < (newList.length > 3 ? 3 : newList.length); i++) {
        print('   ${i + 1}. ${newList[i].title} - ${newList[i].city}');
      }
    }
  }

  /// Clear location filter and show all products
  void clearLocationFilter() {
    print('[ProductController] 🔄 Clearing location filter...');
    shuffleProducts(); // This will reset to all products
    Get.snackbar(
      'Filter Cleared',
      'Showing all products',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void sortProducts(String sortType) {
    List<AllProductModel> sortedList = List.from(productList);

    switch (sortType) {
      case 'name_asc':
        sortedList.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        Get.snackbar(
          'Sorted',
          'Products sorted by Name (A-Z)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'name_desc':
        sortedList.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        Get.snackbar(
          'Sorted',
          'Products sorted by Name (Z-A)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'price_asc':
        sortedList.sort((a, b) => a.price.compareTo(b.price));
        Get.snackbar(
          'Sorted',
          'Products sorted by Price (Low to High)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'price_desc':
        sortedList.sort((a, b) => b.price.compareTo(a.price));
        Get.snackbar(
          'Sorted',
          'Products sorted by Price (High to Low)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'date_desc':
        sortedList.sort((a, b) {
          DateTime? dateA = a.createdAt != null
              ? DateTime.tryParse(a.createdAt!)
              : null;
          DateTime? dateB = b.createdAt != null
              ? DateTime.tryParse(b.createdAt!)
              : null;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Newest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'date_asc':
        sortedList.sort((a, b) {
          DateTime? dateA = a.createdAt != null
              ? DateTime.tryParse(a.createdAt!)
              : null;
          DateTime? dateB = b.createdAt != null
              ? DateTime.tryParse(b.createdAt!)
              : null;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Oldest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }

    productList.assignAll(sortedList);
  }

  /// Check if user can upload more products (subscription limit check)
  bool canUploadProduct() {
    final currentCount = myProducts.length;
    print(
      '🔍 canUploadProduct: count=$currentCount, subscribed=${subscriptionController.isSubscribed.value}',
    );
    return subscriptionController.canUploadProduct(currentCount);
  }

  /// Show subscription popup when limit reached
  void showSubscriptionPopup() {
    if (!subscriptionController.isSubscribed.value) {
      Get.dialog(
        SubscriptionPopup(isDismissible: false),
        barrierDismissible: false,
      );
    }
  }

  /// Fetch user's uploaded products for counting
  Future<void> fetchMyProducts() async {
    try {
      print('🔍 [fetchMyProducts] Starting...');

      final userId = tokenController.userUid.value;
      print('🔍 [fetchMyProducts] userId: $userId');

      if (userId.isEmpty) {
        print('⚠️ [fetchMyProducts] No userId found, setting products to 0');
        myProducts.clear();
        return;
      }

      final response = await ApiService.getMyProducts();
      myProducts.assignAll(response);

      print(
        '📊 [fetchMyProducts] User has uploaded ${myProducts.length} products',
      );

      // Debug: Print product titles for verification
      for (int i = 0; i < myProducts.length && i < 5; i++) {
        print('📦 Product ${i + 1}: ${myProducts[i].title}');
      }
    } catch (e) {
      print('❌ [fetchMyProducts] Error: $e');
      myProducts.clear(); // Clear on error to be safe
    }
  }

  /// Check subscription before allowing product upload
  Future<bool> checkSubscriptionLimit() async {
    print('🔍 Starting subscription limit check...');

    // Check if user is already subscribed
    if (subscriptionController.isSubscribed.value) {
      print('✅ User is subscribed - unlimited uploads allowed');
      return true;
    }

    // Fetch user's current products count first
    await fetchMyProducts();

    final currentCount = myProducts.length;
    print('📊 Current product count: $currentCount');

    // Check if user has reached the limit
    if (currentCount >= 2) {
      print('🚫 Upload limit reached! Showing subscription popup...');

      // Show subscription popup IMMEDIATELY
      showSubscriptionPopup();

      return false;
    }

    print('✅ Upload allowed - user has $currentCount/2 products');
    return true;
  }
}
