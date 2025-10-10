// lib/src/controller/home_controller.dart

import 'package:get/get.dart';
import 'package:olx_prototype/src/model/user_desler_products/user_dealer_product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/apiServices/apiServices.dart';

class HomeController extends GetxController {
  var token = "".obs;
  var dealerProducts = <DealerProduct>[].obs; // Correct type
  var isLoadingDealer = false.obs;

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
  }

  /// Fetch dealer products from API
  Future<void> fetchDealerProducts() async {
    try {
      isLoadingDealer(true);
      var result = await ApiService.fetchDealerProducts();
      dealerProducts.assignAll(result);
    } catch (e) {
      Get.snackbar("Error", e.toString());
      print("❌ Error fetching dealer products: $e");
    } finally {
      isLoadingDealer(false);
    }
  }
}
