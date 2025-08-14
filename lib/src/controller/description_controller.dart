// description_controller.dart

import 'package:get/get.dart';
import 'package:olx_prototype/src/model/product_description_model/product_description%20model.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';

class DescriptionController extends GetxController{

  var product = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    final carId = Get.arguments;
    if (carId != null && carId is String) {
      fetchProducts(carId);
    } else {
      Get.snackbar("Error", "Product ID not provided.");
    }
  }

  void  fetchProducts(String carId) async {
    try{
      isLoading(true);
      final data = await ApiService.fetchProducts(carId);
      product.assignAll(data);
    }
    catch(e){
      Get.snackbar("Error", e.toString());
    }
    finally {
      isLoading(false);
    }
  }
}