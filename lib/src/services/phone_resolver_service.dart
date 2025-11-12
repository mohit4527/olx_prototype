import 'dart:convert';
import 'package:http/http.dart' as http;

/// 🔥 DEDICATED SERVICE FOR PHONE NUMBER RESOLUTION
/// This service is designed to aggressively find phone numbers for any user/product
/// regardless of who is calling the API (uploader or other users)
class PhoneResolverService {
  /// Ultimate phone number resolver - tries ALL possible methods
  static Future<String?> resolvePhoneForUser(String userId) async {
    print(
      '[PhoneResolver] 🔥 Starting ultimate phone resolution for userId: $userId',
    );

    if (userId.isEmpty) {
      print('[PhoneResolver] ❌ Empty userId provided');
      return null;
    }

    // METHOD 1: Direct phone API endpoints
    String? phone = await _tryDirectPhoneEndpoints(userId);
    if (phone != null && phone.isNotEmpty) {
      print('[PhoneResolver] ✅ SUCCESS via direct endpoints: $phone');
      return phone;
    }

    // METHOD 2: User profile endpoints
    phone = await _tryUserProfileEndpoints(userId);
    if (phone != null && phone.isNotEmpty) {
      print('[PhoneResolver] ✅ SUCCESS via user profile: $phone');
      return phone;
    }

    // METHOD 3: User products endpoint (get phone from user's own products)
    phone = await _tryUserProductsEndpoint(userId);
    if (phone != null && phone.isNotEmpty) {
      print('[PhoneResolver] ✅ SUCCESS via user products: $phone');
      return phone;
    }

    // METHOD 4: Search users endpoint
    phone = await _trySearchUsersEndpoint(userId);
    if (phone != null && phone.isNotEmpty) {
      print('[PhoneResolver] ✅ SUCCESS via search users: $phone');
      return phone;
    }

    print('[PhoneResolver] ❌ FAILED to resolve phone for userId: $userId');
    return null;
  }

  /// Try direct phone number specific endpoints
  static Future<String?> _tryDirectPhoneEndpoints(String userId) async {
    final endpoints = [
      'https://oldmarket.bhoomi.cloud/api/users/$userId/phone',
      'http://oldmarket.bhoomi.cloud/api/users/$userId/phone',
      'https://oldmarket.bhoomi.cloud/api/users/$userId/contact',
      'http://oldmarket.bhoomi.cloud/api/users/$userId/contact',
      'https://oldmarket.bhoomi.cloud/api/user/$userId/phone',
      'http://oldmarket.bhoomi.cloud/api/user/$userId/phone',
      'https://oldmarket.bhoomi.cloud/api/user/$userId/contact',
      'http://oldmarket.bhoomi.cloud/api/user/$userId/contact',
    ];

    for (final endpoint in endpoints) {
      try {
        print('[PhoneResolver] Trying direct endpoint: $endpoint');
        final response = await http.get(Uri.parse(endpoint));
        print(
          '[PhoneResolver] Status ${response.statusCode}: ${response.body}',
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final phone =
              data['phone']?.toString() ??
              data['phoneNumber']?.toString() ??
              data['contact']?.toString() ??
              data['data']?['phone']?.toString() ??
              data['data']?['phoneNumber']?.toString();

          if (phone != null && phone.isNotEmpty && phone != 'null') {
            return phone;
          }
        }
      } catch (e) {
        print('[PhoneResolver] Direct endpoint failed: $endpoint - $e');
        continue;
      }
    }
    return null;
  }

  /// Try user profile endpoints
  static Future<String?> _tryUserProfileEndpoints(String userId) async {
    final endpoints = [
      'https://oldmarket.bhoomi.cloud/api/users/$userId',
      'http://oldmarket.bhoomi.cloud/api/users/$userId',
      'https://oldmarket.bhoomi.cloud/api/user/$userId',
      'http://oldmarket.bhoomi.cloud/api/user/$userId',
      'https://oldmarket.bhoomi.cloud/api/auth/user/$userId',
      'http://oldmarket.bhoomi.cloud/api/auth/user/$userId',
    ];

    for (final endpoint in endpoints) {
      try {
        print('[PhoneResolver] Trying profile endpoint: $endpoint');
        final response = await http.get(Uri.parse(endpoint));
        print(
          '[PhoneResolver] Status ${response.statusCode}: ${response.body}',
        );

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);

          // Try different response structures
          Map<String, dynamic>? userData;
          if (body is Map && body['data'] != null) {
            userData = body['data'] is Map
                ? Map<String, dynamic>.from(body['data'])
                : null;
          } else if (body is Map) {
            userData = Map<String, dynamic>.from(body);
          }

          if (userData != null) {
            final phone =
                userData['phone']?.toString() ??
                userData['phoneNumber']?.toString() ??
                userData['mobile']?.toString() ??
                userData['contactNumber']?.toString();

            if (phone != null && phone.isNotEmpty && phone != 'null') {
              return phone;
            }
          }
        }
      } catch (e) {
        print('[PhoneResolver] Profile endpoint failed: $endpoint - $e');
        continue;
      }
    }
    return null;
  }

  /// Try to get phone from user's own products
  static Future<String?> _tryUserProductsEndpoint(String userId) async {
    final endpoints = [
      'https://oldmarket.bhoomi.cloud/api/products?userId=$userId',
      'http://oldmarket.bhoomi.cloud/api/products?userId=$userId',
      'https://oldmarket.bhoomi.cloud/api/products/user/$userId',
      'http://oldmarket.bhoomi.cloud/api/products/user/$userId',
    ];

    for (final endpoint in endpoints) {
      try {
        print('[PhoneResolver] Trying products endpoint: $endpoint');
        final response = await http.get(Uri.parse(endpoint));
        print(
          '[PhoneResolver] Status ${response.statusCode}: ${response.body.length} chars',
        );

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);

          // Look for products data
          List? products;
          if (body is Map && body['data'] is List) {
            products = body['data'];
          } else if (body is List) {
            products = body;
          }

          if (products != null && products.isNotEmpty) {
            // Check each product for phone number
            for (final product in products) {
              if (product is Map) {
                final phone =
                    product['phoneNumber']?.toString() ??
                    product['phone']?.toString() ??
                    product['whatsapp']?.toString();

                if (phone != null && phone.isNotEmpty && phone != 'null') {
                  print('[PhoneResolver] Found phone in user product: $phone');
                  return phone;
                }
              }
            }
          }
        }
      } catch (e) {
        print('[PhoneResolver] Products endpoint failed: $endpoint - $e');
        continue;
      }
    }
    return null;
  }

  /// Try search/all users endpoint
  static Future<String?> _trySearchUsersEndpoint(String userId) async {
    final endpoints = [
      'https://oldmarket.bhoomi.cloud/api/users',
      'http://oldmarket.bhoomi.cloud/api/users',
      'https://oldmarket.bhoomi.cloud/api/auth/users',
      'http://oldmarket.bhoomi.cloud/api/auth/users',
    ];

    for (final endpoint in endpoints) {
      try {
        print('[PhoneResolver] Trying search endpoint: $endpoint');
        final response = await http.get(Uri.parse(endpoint));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);

          // Look for users array
          List? users;
          if (body is Map && body['data'] is List) {
            users = body['data'];
          } else if (body is List) {
            users = body;
          }

          if (users != null) {
            // Find our user in the list
            for (final user in users) {
              if (user is Map &&
                  (user['_id']?.toString() == userId ||
                      user['id']?.toString() == userId)) {
                final phone =
                    user['phone']?.toString() ??
                    user['phoneNumber']?.toString() ??
                    user['mobile']?.toString();

                if (phone != null && phone.isNotEmpty && phone != 'null') {
                  print('[PhoneResolver] Found phone in users list: $phone');
                  return phone;
                }
              }
            }
          }
        }
      } catch (e) {
        print('[PhoneResolver] Search endpoint failed: $endpoint - $e');
        continue;
      }
    }
    return null;
  }
}
