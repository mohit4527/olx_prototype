import 'package:get/get.dart';
import 'package:olx_prototype/src/model/product_description_model/product_description%20model.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';

class DescriptionController extends GetxController{

  var product = <ProductModel>[].obs;
  var isLoading = false.obs;

  void  fetchProducts() async {
    try{
      isLoading(true);
      final data = await ApiService.fetchProducts();
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