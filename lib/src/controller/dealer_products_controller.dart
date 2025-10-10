// lib/src/controller/dealer_products_controller.dart

import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../model/user_desler_products/user_dealer_product_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerProductsController extends GetxController {
  var isLoading = false.obs;
  var products = <DealerProduct>[].obs; // Use the new model

  @override
  void onInit() {
    super.onInit();
    fetchDealerProducts();
  }

  Future<void> fetchDealerProducts() async {
    try {
      isLoading(true);
      var result = await ApiService.fetchDealerProducts();
      if (result.isNotEmpty) {
        products.assignAll(result);
      }
    } catch (e) {
      print("Error fetching dealer products: $e");
      Get.snackbar('Error', 'Failed to load products. Please try again.',
          backgroundColor: AppColors.appRed, colorText: AppColors.appWhite);
    } finally {
      isLoading(false);
    }
  }
}