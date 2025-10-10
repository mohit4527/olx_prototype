import 'package:get/get.dart';
import '../model/all_product_model/all_product_model.dart';
import '../services/apiServices/apiServices.dart';

class ProductController extends GetxController {
  RxList<AllProductModel> productList = <AllProductModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void fetchProducts() async {
    try {
      isLoading.value = true;
      final response = await ApiService.getAllProducts();

      if (response.isNotEmpty) {
        productList.value = response;
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
    fetchProducts();
  }
}
