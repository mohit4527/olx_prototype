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
      print("🔄 [DealerProductsController] Starting fetchDealerProducts...");
      isLoading(true);
      var result = await ApiService.fetchDealerProducts();
      print(
        "📦 [DealerProductsController] API returned ${result.length} products",
      );

      if (result.isNotEmpty) {
        products.assignAll(result);
        print(
          "✅ [DealerProductsController] Products assigned successfully: ${products.length}",
        );
      } else {
        print("⚠️ [DealerProductsController] No products received from API");
      }
    } catch (e) {
      print("💥 [DealerProductsController] Error fetching dealer products: $e");
      Get.snackbar(
        'Error',
        'Failed to load products. Please try again.',
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    } finally {
      isLoading(false);
      print("🏁 [DealerProductsController] fetchDealerProducts completed");
    }
  }

  void sortProducts(String sortType) {
    List<DealerProduct> sortedList = List.from(products);

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
        sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Newest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'date_asc':
        sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Oldest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }

    products.assignAll(sortedList);
  }
}
