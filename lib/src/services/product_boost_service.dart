import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductBoostService {
  static const String baseUrl =
      'https://oldmarket.bhoomi.cloud/api/products/boost';

  // Create boost order
  static Future<Map<String, dynamic>?> createBoostOrder({
    required String productId,
    required String userId,
  }) async {
    try {
      print('🚀 Creating boost order for product: $productId, user: $userId');

      final response = await http.post(
        Uri.parse('$baseUrl/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productId': productId, 'userId': userId}),
      );

      print('Boost order response status: ${response.statusCode}');
      print('Boost order response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        // Return error response for better error handling
        print('❌ Failed to create boost order: ${response.statusCode}');
        try {
          final errorData = jsonDecode(response.body);
          return errorData;
        } catch (_) {
          return {
            'success': false,
            'message': 'Failed to create boost order',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      print('❌ Create boost order error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Verify boost payment
  static Future<Map<String, dynamic>?> verifyBoostPayment({
    required String productId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      print('✅ Verifying boost payment for product: $productId');

      final response = await http.post(
        Uri.parse('$baseUrl/verify-payment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'productId': productId,
          'paymentId': paymentId,
          'orderId': orderId,
          'signature': signature,
        }),
      );

      print('Boost verification response status: ${response.statusCode}');
      print('Boost verification response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('❌ Failed to verify boost payment: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Verify boost payment error: $e');
      return null;
    }
  }
}
