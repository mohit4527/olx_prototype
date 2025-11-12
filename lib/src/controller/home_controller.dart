// lib/src/controller/home_controller.dart

import 'dart:math';
import 'package:get/get.dart';
import 'package:olx_prototype/src/model/user_desler_products/user_dealer_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiServices/apiServices.dart';
import '../model/dashboard_ads_model/dashboard_ads_model.dart';

class HomeController extends GetxController {
  var token = "".obs;
  var dealerProducts = <DealerProduct>[].obs; // Correct type
  var _originalDealerProducts = <DealerProduct>[].obs; // Store original list
  var isLoadingDealer = false.obs;

  // Dashboard ads
  var dashboardAds = <DashboardAd>[].obs;
  var isLoadingAds = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
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
