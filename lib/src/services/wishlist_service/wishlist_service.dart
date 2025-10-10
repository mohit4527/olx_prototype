import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../model/wishlist_model/wishlist_model.dart';

class WishlistService {
  final String baseUrl = "https://oldmarket.bhoomi.cloud/api/products/wishlist/product";

  Future<List<WishlistItem>> getWishlist(String userId) async {
    final url = Uri.parse("$baseUrl/$userId");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        return (data['data'] as List)
            .map((json) => WishlistItem.fromJson(json))
            .toList();
      }
    }
    return [];
  }





  Future<bool> addToWishlist(String userId, String itemId) async {
    final url = Uri.parse("$baseUrl/add");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "itemId": itemId}),
    );

    final data = jsonDecode(response.body);
    return data['status'] ?? false;
  }




  Future<bool> removeFromWishlist(String userId, String itemId) async {
    final url = Uri.parse("$baseUrl/remove");
    final response = await http.delete(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"userId": userId, "itemId": itemId}),
    );

    final data = jsonDecode(response.body);
    return data['status'] ?? false;
  }
}
