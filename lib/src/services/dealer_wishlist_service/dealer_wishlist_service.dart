
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/dealer_product_model/dealer_product_model.dart';
import '../../model/product_description_model/product_description model.dart';

class DealerWishlistService {
  final String baseUrl = "https://oldmarket.bhoomi.cloud/api/products/wishlist/car";
  final String productBaseUrl = "https://oldmarket.bhoomi.cloud/api/products";

  /// Add product to dealer wishlist
  Future<bool> addToDealerWishlist(String userId, String itemId) async {
    try {
      print("🔹 Adding to dealer wishlist => userId: $userId, itemId: $itemId");

      final res = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId, "itemId": itemId}),
      );

      print("📩 Add Response: ${res.statusCode} -> ${res.body}");
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      return data["status"] == true;
    } catch (e) {
      print("DealerWishlistService.add error: $e");
      return false;
    }
  }

  /// Get dealer wishlist
  Future<List<Map<String, dynamic>>> getDealerWishlist(String userId) async {
    try {
      print("🔹 Fetching dealer wishlist for userId: $userId");

      final res = await http.get(Uri.parse("$baseUrl/$userId"));
      print("📩 Get Response: ${res.statusCode} -> ${res.body}");

      if (res.statusCode != 200) return [];
      final data = jsonDecode(res.body);
      if (data["status"] == true && data["data"] is List) {
        return (data["data"] as List).map<Map<String, dynamic>>((e) {
          final map = Map<String, dynamic>.from(e);
          if (map.containsKey('_id') && !map.containsKey('id')) {
            map['id'] = map['_id'];
          }
          return map;
        }).toList();
      }
      return [];
    } catch (e) {
      print("DealerWishlistService.get error: $e");
      return [];
    }
  }

  /// Remove product from dealer wishlist
  Future<bool> removeFromDealerWishlist(String userId, String itemId) async {
    try {
      print("🔹 Removing from dealer wishlist => userId: $userId, itemId: $itemId");

      final res = await http.delete(
        Uri.parse("$baseUrl/remove"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"userId": userId, "itemId": itemId}),
      );

      print("📩 Remove Response: ${res.statusCode} -> ${res.body}");

      if (res.statusCode != 200 && res.statusCode != 204) return false;
      final data = jsonDecode(res.body);
      return data["status"] == true;
    } catch (e) {
      print("DealerWishlistService.remove error: $e");
      return false;
    }
  }

  /// ✅ Get product details by ID (productservice ka kaam ab yahan hoga)
  Future<Data?> getProductById(String itemId) async {
    try {
      final res = await http.get(Uri.parse("$productBaseUrl/$itemId"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["status"] == true && data["data"] != null) {
          // ✅ Data.fromJson use karein
          return Data.fromJson(data["data"]);
        }
      }
    } catch (e) {
      print("DealerWishlistService.getProductById error: $e");
    }
    return null;
  }

}