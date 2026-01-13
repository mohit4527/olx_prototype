import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/user_desler_products/user_dealer_product_model.dart';
import '../services/apiServices/apiServices.dart';

class CityProductsController extends GetxController {
  final String cityName;

  CityProductsController(this.cityName);

  var isLoading = false.obs;
  var products = <DealerProduct>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCityProducts();
  }

  Future<void> fetchCityProducts() async {
    try {
      isLoading(true);
      print('🏙️ Fetching products for city: $cityName');

      final locationResult = await ApiService.getProductsByLocation(
        country: "India",
        city: cityName,
      );

      if (locationResult != null && locationResult['status'] == true) {
        final data = locationResult['data'];
        if (data is List) {
          List<DealerProduct> fetchedProducts = [];

          for (var product in data) {
            try {
              if (product is Map<String, dynamic>) {
                // Clean mapping based on actual API response
                final cleanProduct = <String, dynamic>{
                  '_id': product['_id']?.toString() ?? '',
                  'dealerId': product['userId']?.toString() ?? 'unknown',
                  'dealerName': 'Product Seller',
                  'sellerType': 'individual',
                  'phone': product['number']?.toString() ?? 'N/A',
                  'title': product['title']?.toString() ?? 'Untitled Product',
                  'description': product['description']?.toString() ?? '',
                  'price': _parsePrice(product['price']),
                  'tags': [],
                  'images': _parseImages(product),
                  'city': _parseLocationField(product, 'city'),
                  'state': _parseLocationField(product, 'state'),
                  'country': _parseLocationField(product, 'country'),
                  'userId': product['userId']?.toString() ?? '',
                  'category': product['category']?.toString() ?? 'general',
                  'subcategory': product['subcategory']?.toString() ?? '',
                  'condition': product['condition']?.toString() ?? 'used',
                  'brand': product['brand']?.toString() ?? '',
                  'model': product['model']?.toString() ?? '',
                  'year': product['year']?.toString() ?? '',
                  'isActive': true,
                  'createdAt': product['createdAt']?.toString() ?? '',
                  'updatedAt': product['updatedAt']?.toString() ?? '',
                };

                fetchedProducts.add(DealerProduct.fromJson(cleanProduct));
              }
            } catch (e) {
              print("⚠️ Error parsing city product: $e");
              continue;
            }
          }

          products.assignAll(fetchedProducts);
          print('✅ Loaded ${fetchedProducts.length} products for $cityName');
        }
      } else {
        print('❌ No products found for $cityName');
      }
    } catch (e) {
      print("❌ Error fetching city products: $e");
    } finally {
      isLoading(false);
    }
  }

  void retryFetch() {
    fetchCityProducts();
  }

  // Helper functions for safe data parsing
  int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.toInt();
    if (price is String) {
      return int.tryParse(price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return 0;
  }

  List<String> _parseImages(Map<String, dynamic> product) {
    // Try multiple possible image field names
    dynamic images =
        product['mediaUrl'] ?? product['images'] ?? product['image'];

    if (images == null) return [];
    if (images is String) return [images];
    if (images is List) {
      return images.map((img) => img.toString()).toList();
    }
    return [];
  }

  String _parseLocationField(Map<String, dynamic> product, String field) {
    // Handle nested location object
    if (product['location'] is Map) {
      final loc = product['location'] as Map<String, dynamic>;
      return loc[field]?.toString() ?? '';
    }
    return product[field]?.toString() ?? '';
  }
}
