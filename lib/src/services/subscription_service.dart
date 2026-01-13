import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/subscription/subscription_price_model.dart';
import '../model/subscription/subscription_order_model.dart';
import '../model/subscription/subscription_verify_model.dart';

class SubscriptionService {
  static const String baseUrl =
      'https://oldmarket.bhoomi.cloud/api/users/subscription';

  static Future<SubscriptionPriceModel> getPrice() async {
    try {
      final uri = Uri.parse('$baseUrl/price');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      print('🔥 Subscription Price API Response: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionPriceModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to get subscription price: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Subscription Price Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<SubscriptionOrderModel> createOrder(String userId) async {
    try {
      final uri = Uri.parse('$baseUrl/create-order');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      print('🔥 Create Order API Response: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SubscriptionOrderModel.fromJson(data);
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Create Order Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<SubscriptionVerifyModel> verifyPayment({
    required String userId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/verify-payment');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'paymentId': paymentId,
          'orderId': orderId,
          'signature': signature,
        }),
      );

      print('🔥 Verify Payment API Response: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SubscriptionVerifyModel.fromJson(data);
      } else {
        throw Exception('Failed to verify payment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Verify Payment Error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Dealer subscription API
  static Future<SubscriptionVerifyModel> createDealerSubscription(
    String userId,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/dealer-subscription');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      print('🔥 Dealer Subscription API Response: ${response.statusCode}');
      print('📊 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SubscriptionVerifyModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to create dealer subscription: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Dealer Subscription Error: $e');
      throw Exception('Network error: $e');
    }
  }
}
