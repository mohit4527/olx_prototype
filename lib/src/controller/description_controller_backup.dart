import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product_description_model/product_description model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';
import '../services/phone_resolver_service.dart';

class DescriptionController extends GetxController {
  var product = Rxn<ProductModel>();
  var isLoading = false.obs;
  var currentUserId = ''.obs;
  var uploaderPhone = ''.obs;
  var uploaderWhatsApp = ''.obs;

  // 🆕 Uploader profile details
  var uploaderProfile = Rxn<Map<String, dynamic>>();
  var uploaderName = ''.obs;
  var uploaderImage = ''.obs;
  var uploaderProductCount = 0.obs;
  var uploaderVideoCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await AuthService.getLoggedInUserId();
    currentUserId.value = id ?? '';
  }

  Future<void> fetchProductById(String productId) async {
    try {
      print('[DescriptionController] fetchProductById start -> $productId');
      isLoading(true);
      final data = await ApiService.fetchProductById(productId);
      product.value = data;

      // 🆕 Fetch uploader profile details with debug
      if (data?.userId != null && data!.userId!.isNotEmpty) {
        print(
          '[DescriptionController] 🔥 Starting profile fetch for userId: ${data.userId}',
        );
        await fetchUploaderProfile(data.userId!);
        print(
          '[DescriptionController] 🎯 Profile fetch completed. Name: ${uploaderName.value}, Products: ${uploaderProductCount.value}',
        );
      } else {
        print('[DescriptionController] ❌ No userId found in product data');
      }

      // Resolve uploader contact info
      uploaderPhone.value = data?.phoneNumber ?? '';
      uploaderWhatsApp.value = data?.whatsapp ?? '';

      print(
        '[DescriptionController] fetchProductById completed -> ${data?.id}',
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// 🆕 Fetch uploader profile details
  Future<void> fetchUploaderProfile(String userId) async {
    try {
      print(
        '[DescriptionController] 🔥 Fetching uploader profile for: $userId',
      );

      // Simple approach: Get all products and find user's products
      final response = await http.get(
        Uri.parse('http://oldmarket.bhoomi.cloud/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        '[DescriptionController] Products API response: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null && responseData['data'] is List) {
          final allProducts = responseData['data'] as List;

          // Find products by this user
          final userProducts = allProducts.where((product) {
            if (product['userId'] == null) return false;

            // Handle both string userId and object userId
            if (product['userId'] is String) {
              return product['userId'] == userId;
            } else if (product['userId'] is Map) {
              return product['userId']['_id'] == userId;
            }
            return false;
          }).toList();

          print(
            '[DescriptionController] Found ${userProducts.length} products by user $userId',
          );

          if (userProducts.isNotEmpty) {
            // Extract user info from first product
            final firstProduct = userProducts[0];

            if (firstProduct['userId'] is Map) {
              final userInfo = firstProduct['userId'] as Map<String, dynamic>;

              // Set profile data
              uploaderProfile.value = userInfo;
              uploaderName.value = userInfo['name'] ?? 'User';

              // Handle profile image
              String profileImg = userInfo['profileImage'] ?? '';
              if (profileImg.isNotEmpty) {
                profileImg = profileImg.replaceAll('\\', '/');
                if (!profileImg.startsWith('http')) {
                  profileImg = 'http://oldmarket.bhoomi.cloud$profileImg';
                }
              }
              uploaderImage.value = profileImg;

              // Count products and videos
              uploaderProductCount.value = userProducts.length;

              int videoCount = 0;
              for (var product in userProducts) {
                if (product['type'] == 'video') {
                  videoCount++;
                }
              }
              uploaderVideoCount.value = videoCount;

              print('[DescriptionController] ✅ Uploader profile loaded:');
              print('   Name: ${uploaderName.value}');
              print('   Image: ${uploaderImage.value}');
              print('   Products: ${uploaderProductCount.value}');
              print('   Videos: ${uploaderVideoCount.value}');

              return;
            }
          }
        }
      }

      // Fallback: Set basic info
      uploaderName.value = 'User';
      uploaderImage.value = '';
      uploaderProductCount.value = 0;
      uploaderVideoCount.value = 0;
    } catch (e) {
      print('[DescriptionController] ❌ Error fetching uploader profile: $e');
    }
  }

  /// Ensure uploader contact fields are populated
  Future<void> ensureUploaderContact() async {
    try {
      print('[DescriptionController] ensureUploaderContact called');

      final data = product.value;
      if (data == null) {
        print('[DescriptionController] Product data is null');
        return;
      }

      // Use product's direct phone number if available
      if (data.phoneNumber != null &&
          data.phoneNumber!.isNotEmpty &&
          data.phoneNumber != "null") {
        uploaderPhone.value = data.phoneNumber!;
      }

      // Set whatsapp if available
      if (data.whatsapp != null && data.whatsapp!.isNotEmpty) {
        uploaderWhatsApp.value = data.whatsapp!;
      }

      // Try phone resolver service if no phone found
      if (uploaderPhone.value.isEmpty && data.userId != null) {
        final resolvedPhone = await PhoneResolverService.resolvePhoneForUser(
          data.userId!,
        );
        if (resolvedPhone != null && resolvedPhone.isNotEmpty) {
          uploaderPhone.value = resolvedPhone;
        }
      }

      print(
        '[DescriptionController] Final uploaderPhone: ${uploaderPhone.value}',
      );
    } catch (e) {
      print('[DescriptionController] ensureUploaderContact error: $e');
    }
  }
}
