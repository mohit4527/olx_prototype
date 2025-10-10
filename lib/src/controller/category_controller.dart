import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryController extends GetxController {
  final selectedTab = RxString('user');
  final selectedCategory = RxString('all');
  final isLoading = false.obs;
  final productList = RxList<Map<String, dynamic>>();

  Future<void> fetchProducts() async {
    isLoading.value = true;
    final tab = selectedTab.value;
    final category = selectedCategory.value;

    final apiUrl = tab == 'user'
        ? 'https://oldmarket.bhoomi.cloud/api/products?page=1&limit=100'
        : 'http://oldmarket.bhoomi.cloud/api/dealers/dealer/cars';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allItems = tab == 'user'
            ? List<Map<String, dynamic>>.from(data['data'])
            : List<Map<String, dynamic>>.from(data['data']);

        List<Map<String, dynamic>> filtered;
        if (category == 'all') {
          filtered = allItems;
        } else if (category == 'others') {
          filtered = allItems.where((item) =>
          item['category'] != 'cars' &&
              item['category'] != 'two-wheeler').toList();
        } else {
          filtered = allItems.where((item) =>
          item['category'] == category).toList();
        }

        productList.assignAll(filtered);
      } else {
        productList.clear();
        Get.snackbar("Error", "Failed to fetch products");
      }
    } catch (e) {
      productList.clear();
      Get.snackbar("Error", "Something went wrong: $e");
    }finally{
      isLoading.value = false;
    }
  }
}
