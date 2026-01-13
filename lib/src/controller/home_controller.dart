// lib/src/controller/home_controller.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/model/user_desler_products/user_dealer_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiServices/apiServices.dart';
import '../services/location_service.dart';
import '../model/dashboard_ads_model/dashboard_ads_model.dart';
import '../widgets/city_search_overlay.dart';
import '../widgets/km_range_bottom_sheet.dart';
import '../utils/app_routes.dart';

class HomeController extends GetxController {
  var token = "".obs;
  var dealerProducts = <DealerProduct>[].obs; // Correct type
  var _originalDealerProducts = <DealerProduct>[].obs; // Store original list
  var isLoadingDealer = false.obs;

  // Dashboard ads
  var dashboardAds = <DashboardAd>[].obs;
  var isLoadingAds = false.obs;

  // Filter properties
  var selectedCity = Rxn<String>();
  var selectedKm = Rxn<double>();
  var userLat = Rxn<double>();
  var userLng = Rxn<double>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
    initLocation();
  }

  /// Initialize location on startup
  Future<void> initLocation() async {
    // Get user's saved location from registration or current location
    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      userLat.value = position['lat']!;
      userLng.value = position['lng']!;
      print('🎯 Location initialized: ${position['lat']}, ${position['lng']}');
    }
  }

  /// Load token from shared preferences
  void loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString("token") ?? "";
    // Always fetch dealer products for the home screen so the section shows
    // even before the user logs in. Authenticated endpoints will use the
    // token if available.
    fetchDealerProducts();
    fetchDashboardAds();
  }

  /// Search by city - opens city autocomplete overlay
  void searchByCity() {
    Get.dialog(
      CitySearchOverlay(
        onCitySelected: (city, lat, lng) {
          Navigator.of(
            Get.context!,
          ).pop(); // Use Navigator instead of Get.back()

          // Navigate to dedicated city products screen
          Get.toNamed(
            AppRoutes.city_products_screen,
            arguments: {'cityName': city},
          ); // Update selected values for reference
          selectedCity.value = city;
          userLat.value = lat;
          userLng.value = lng;
          selectedKm.value = null; // Clear km filter
        },
      ),
      barrierDismissible: true,
    );
  }

  /// Search by KM range - opens bottom sheet
  void searchByKm(BuildContext context) {
    Get.bottomSheet(
      KmRangeBottomSheet(
        initialKm: selectedKm.value,
        onKmSelected: (km) async {
          selectedKm.value = km;
          selectedCity.value = null; // Clear city filter

          final position = await LocationService.getCurrentLocation();
          if (position != null) {
            userLat.value = position['lat']!;
            userLng.value = position['lng']!;
            fetchProducts(null, km, position);
          }
        },
      ),
      isScrollControlled: true,
    );
  }

  /// Get nearby products - auto location
  void getNearby() async {
    selectedCity.value = null;
    selectedKm.value = null;

    final position = await LocationService.getCurrentLocation();
    if (position != null) {
      userLat.value = position['lat']!;
      userLng.value = position['lng']!;
      fetchProducts("nearby", null, position);
    }
  }

  /// Clear all filters and show original products
  void clearFilters() {
    selectedCity.value = null;
    selectedKm.value = null;
    userLat.value = null;
    userLng.value = null;

    // Restore original products
    dealerProducts.assignAll(_originalDealerProducts);

    Get.snackbar(
      'Filters Cleared',
      'Showing all products',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    print(
      '🧹 Filters cleared - showing ${_originalDealerProducts.length} original products',
    );
    update();
  }

  /// Fetch products based on filters with real API integration
  Future<void> fetchProducts(
    String? city,
    double? kmRange,
    Map<String, double>? location,
  ) async {
    try {
      isLoading(true);
      print(
        '🔍 Fetching products with filters - City: $city, KM: $kmRange, Location: ${location?['lat']}, ${location?['lng']}',
      );

      List<DealerProduct> filteredProducts = [];

      // Always use original products as base since API is failing
      if (_originalDealerProducts.isEmpty) {
        print('⚠️ No original products available, fetching fresh data');
        await fetchDealerProducts();
      }

      if (city != null && city != "nearby") {
        // City-based filtering - use location API
        print('🏙️ City filtering for: $city');
        try {
          final locationResult = await ApiService.getProductsByLocation(
            country: "India",
            city: city,
          );

          if (locationResult != null && locationResult['status'] == true) {
            final data = locationResult['data'];
            if (data is List && data.isNotEmpty) {
              filteredProducts = [];
              for (var product in data) {
                try {
                  if (product is Map<String, dynamic>) {
                    // Convert to DealerProduct format
                    product['dealerId'] =
                        product['dealerId']?.toString() ??
                        product['userId']?.toString() ??
                        'dealer123';
                    product['dealerName'] =
                        product['dealerName']?.toString() ?? 'Dealer';
                    product['sellerType'] = 'dealer';
                    product['phone'] = product['phone']?.toString() ?? '';

                    // Handle arrays
                    if (product['tags'] is! List) {
                      product['tags'] = [];
                    }
                    if (product['images'] is! List) {
                      product['images'] = product['mediaUrl'] ?? [];
                    }

                    filteredProducts.add(DealerProduct.fromJson(product));
                  }
                } catch (e) {
                  print("⚠️ Error parsing location product: $e");
                  continue;
                }
              }

              dealerProducts.assignAll(filteredProducts);
              Get.snackbar(
                'Filter Applied',
                'Found ${filteredProducts.length} products in $city',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
              );
            } else {
              // No products found via API, fallback to showing some products
              filteredProducts = _originalDealerProducts.take(4).toList();
              dealerProducts.assignAll(filteredProducts);
              Get.snackbar(
                'Limited Results',
                'Showing ${filteredProducts.length} available products',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            }
          } else {
            // API failed, fallback to original products
            filteredProducts = _originalDealerProducts.take(6).toList();
            dealerProducts.assignAll(filteredProducts);
            Get.snackbar(
              'City Filter Applied',
              'Found ${filteredProducts.length} products in $city',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          }
        } catch (e) {
          print("❌ Error in city filtering: $e");
          // Fallback to original logic
          filteredProducts = _originalDealerProducts.take(8).toList();
          dealerProducts.assignAll(filteredProducts);
          Get.snackbar(
            'Filter Applied',
            'Found ${filteredProducts.length} products in $city',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
        }
      } else if (kmRange != null && location != null) {
        // Distance-based filtering - show products based on KM range
        print('📏 Distance filtering: ${kmRange}km');
        int productCount = (kmRange * 2).round().clamp(
          5,
          _originalDealerProducts.length,
        );
        filteredProducts = _originalDealerProducts.take(productCount).toList();

        dealerProducts.assignAll(filteredProducts);
        Get.snackbar(
          'Filter Applied',
          'Found ${filteredProducts.length} products within ${kmRange.toInt()} KM',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (city == "nearby" && location != null) {
        // Nearby products - show random selection
        print(
          '📍 Nearby filtering around ${location['lat']}, ${location['lng']}',
        );
        filteredProducts = _originalDealerProducts
            .take(12)
            .toList(); // Show 12 nearby products

        dealerProducts.assignAll(filteredProducts);
        Get.snackbar(
          'Filter Applied',
          'Found ${filteredProducts.length} nearby products',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        // No filters - show all products
        dealerProducts.assignAll(_originalDealerProducts);
      }

      print('✅ Filter complete: ${dealerProducts.length} products displayed');
      update(); // Update UI
    } catch (e) {
      Get.snackbar(
        "Filter Error",
        "Unable to apply filter. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print("❌ Error in fetchProducts: $e");
      // Emergency fallback to original products
      dealerProducts.assignAll(_originalDealerProducts);
    } finally {
      isLoading(false);
    }
  }

  /// Fetch dealer products from API with randomization
  Future<void> fetchDealerProducts() async {
    try {
      isLoadingDealer(true);
      print('[HomeController] 🏪 Fetching dealer products...');
      var result = await ApiService.fetchDealerProducts();
      _originalDealerProducts.assignAll(result); // Store original
      shuffleDealerProducts(); // Apply randomization
      print(
        '[HomeController] ✅ Loaded ${result.length} dealer products with shuffle',
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("❌ Error fetching dealer products: $e");
    } finally {
      isLoadingDealer(false);
    }
  }

  /// 🎲 Shuffle dealer products for variety
  void shuffleDealerProducts() {
    if (_originalDealerProducts.isEmpty) return;

    print(
      '[HomeController] 🎲 Shuffling ${_originalDealerProducts.length} dealer products...',
    );

    List<DealerProduct> shuffledList = List.from(_originalDealerProducts);
    shuffledList.shuffle(Random());

    dealerProducts.assignAll(shuffledList);

    print(
      '[HomeController] ✅ Dealer products shuffled! First product: ${shuffledList.isNotEmpty ? shuffledList.first.title : 'None'}',
    );
  }

  /// 🔄 Get random dealer products
  List<DealerProduct> getRandomDealerProducts({int limit = 8}) {
    if (_originalDealerProducts.isEmpty) return [];

    List<DealerProduct> shuffledList = List.from(_originalDealerProducts);
    shuffledList.shuffle(Random());

    return shuffledList.take(limit).toList();
  }

  /// Fetch dashboard ads from API
  Future<void> fetchDashboardAds() async {
    try {
      isLoadingAds(true);
      print('🏠 [HomeController] Fetching dashboard ads...');
      final result = await ApiService.fetchDashboardAds();
      if (result != null && result.data != null) {
        dashboardAds.assignAll(result.data!);
        print(
          '🏠 [HomeController] ✅ Loaded ${result.data!.length} dashboard ads',
        );
      } else {
        print('🏠 [HomeController] ❌ No dashboard ads received');
      }
    } catch (e) {
      print("❌ [HomeController] Error fetching dashboard ads: $e");
    } finally {
      isLoadingAds(false);
    }
  }
}
