import 'dart:math';
import 'package:get/get.dart';
import '../model/all_product_model/all_product_model.dart';
import '../services/apiServices/apiServices.dart';

class ProductController extends GetxController {
  RxList<AllProductModel> productList = <AllProductModel>[].obs;
  RxList<AllProductModel> _originalProductList =
      <AllProductModel>[].obs; // Store original list
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
        _originalProductList.value = response; // Store original
        shuffleProducts(); // Apply randomization
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
    print(
      '[ProductController] 🔄 Refreshing products with new randomization...',
    );
    fetchProducts(); // This will fetch fresh data and auto-shuffle
  }

  /// 🔥 Shuffle products for varied home screen experience
  void shuffleProducts() {
    if (_originalProductList.isEmpty) return;

    print(
      '[ProductController] 🎲 Shuffling ${_originalProductList.length} products...',
    );

    // Create a copy and shuffle it
    List<AllProductModel> shuffledList = List.from(_originalProductList);
    shuffledList.shuffle(Random());

    // Update the displayed list
    productList.value = shuffledList;

    print(
      '[ProductController] ✅ Products shuffled! First product: ${shuffledList.isNotEmpty ? shuffledList.first.title : 'None'}',
    );
  }

  /// 🔄 Get different random subset each time
  List<AllProductModel> getRandomProducts({int limit = 8}) {
    if (_originalProductList.isEmpty) return [];

    List<AllProductModel> shuffledList = List.from(_originalProductList);
    shuffledList.shuffle(Random());

    return shuffledList.take(limit).toList();
  }

  void sortProducts(String sortType) {
    List<AllProductModel> sortedList = List.from(productList);

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
        sortedList.sort((a, b) {
          DateTime? dateA = a.createdAt != null
              ? DateTime.tryParse(a.createdAt!)
              : null;
          DateTime? dateB = b.createdAt != null
              ? DateTime.tryParse(b.createdAt!)
              : null;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateB.compareTo(dateA);
        });
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Newest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case 'date_asc':
        sortedList.sort((a, b) {
          DateTime? dateA = a.createdAt != null
              ? DateTime.tryParse(a.createdAt!)
              : null;
          DateTime? dateB = b.createdAt != null
              ? DateTime.tryParse(b.createdAt!)
              : null;
          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;
          return dateA.compareTo(dateB);
        });
        Get.snackbar(
          'Sorted',
          'Products sorted by Date (Oldest First)',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }

    productList.assignAll(sortedList);
  }
}
