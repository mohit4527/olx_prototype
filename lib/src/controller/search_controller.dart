import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../model/product_description_model/product_description model.dart';

class SearchController extends GetxController {
  var products = <ProductModel>[].obs;
  var allProducts = <ProductModel>[].obs;
  var isLoading = false.obs;
  var searchText = "".obs;

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse("https://oldmarket.bhoomi.cloud/api/products?page=1&limit=100"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productList = data['data'];

        allProducts.value =
            productList.map((e) => ProductModel.fromJson(e)).toList();

        products.clear();
      }
    } catch (e) {
      print(" Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter products by search query
  void searchProducts(String query) {
    searchText.value = query;

    if (query.isEmpty) {
      products.clear();
    } else {
      products.value = allProducts.where((p) {
        return p.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }
}
