import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
  var isDealer = false.obs;

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

      // Reset flags for new profile
      isDealer.value = false;

      // METHOD 1: Try to get user details via products with populate
      await _fetchUserViaPopulatedProducts(userId);

      // METHOD 2: If no detailed data found, try direct user endpoints
      if (uploaderName.value == 'User' || uploaderName.value == 'Seller') {
        await _fetchUserViaDirectAPI(userId);
      }

      // METHOD 2.5: Try users listing API
      if (uploaderName.value == 'User' || uploaderName.value == 'Seller') {
        await _fetchUserViaUsersAPI(userId);
      }

      // METHOD 2.7: Try alternative approaches for user data
      if (uploaderName.value == 'User' || uploaderName.value == 'Seller') {
        await _tryAlternativeUserData(userId);
      }

      // METHOD 3: Try user-specific product endpoints
      if (uploaderProductCount.value == 0) {
        await _fetchUserSpecificProducts(userId);
      }

      // METHOD 4: Try dealer profile endpoints if regular user profile not found
      if (uploaderName.value == 'User' || uploaderName.value == 'Seller') {
        await _fetchDealerProfile(userId);
      }

      // METHOD 5: Try videos specific API
      await _fetchVideosCount(userId);

      // METHOD 6: Try dealer products if marked as dealer
      if (isDealer.value && uploaderProductCount.value == 0) {
        await _fetchDealerProductsCount(userId);
      }

      // METHOD 7: Final fallback - count products from all products API
      if (uploaderProductCount.value == 0) {
        await _fetchProductCountOnly(userId);
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error fetching uploader profile: $e');
    }
  }

  /// Try to get user data via products API with population
  Future<void> _fetchUserViaPopulatedProducts(String userId) async {
    try {
      // Try with populate parameter
      var response = await http.get(
        Uri.parse('http://oldmarket.bhoomi.cloud/api/products?populate=userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print(
        '[DescriptionController] 🔥 POPULATE API Response: ${response.statusCode}',
      );
      print(
        '[DescriptionController] 🔥 POPULATE API Body Preview: ${response.body.length > 500 ? response.body.substring(0, 500) + "..." : response.body}',
      );

      // If populate doesn't work, try regular products API
      if (response.statusCode != 200) {
        response = await http.get(
          Uri.parse('http://oldmarket.bhoomi.cloud/api/products'),
          headers: {'Content-Type': 'application/json'},
        );
        print(
          '[DescriptionController] 🔥 REGULAR API Response: ${response.statusCode}',
        );
      }

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

            print(
              '[DescriptionController] 🔍 DEBUG: First product userId type: ${firstProduct['userId'].runtimeType}',
            );
            print(
              '[DescriptionController] 🔍 DEBUG: First product userId value: ${firstProduct['userId']}',
            );
            print(
              '[DescriptionController] 🔍 DEBUG: First product full data: ${firstProduct}',
            );

            // Check if userId is object format (with user details)
            if (firstProduct['userId'] is Map) {
              final userInfo = firstProduct['userId'] as Map<String, dynamic>;

              // Set profile data from user object
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

              print('[DescriptionController] ✅ Using object format user data');
            } else {
              // userId is just a string, we still have products count but no user details
              uploaderName.value = 'Seller'; // More meaningful default name
              uploaderImage.value = ''; // No image available
              print(
                '[DescriptionController] ⚠️ Using string format userId, limited data available',
              );
            }

            // Count products and videos (this works regardless of userId format)
            uploaderProductCount.value = userProducts.length;

            int videoCount = 0;
            print(
              '[DescriptionController] 🔍 DEBUG: Counting videos from ${userProducts.length} products',
            );
            for (var product in userProducts) {
              print(
                '[DescriptionController] 🔍 DEBUG: Product type: ${product['type']}, title: ${product['title']}',
              );
              if (product['type'] == 'video') {
                videoCount++;
                print(
                  '[DescriptionController] 🔍 DEBUG: ✅ Found video: ${product['title']}',
                );
              }
            }
            // Set initial video count - this may be overridden by validated video endpoints later
            uploaderVideoCount.value = videoCount;
            print(
              '[DescriptionController] 🔍 DEBUG: Initial video count from products: $videoCount (may be validated later)',
            );

            print('[DescriptionController] ✅ Uploader profile loaded:');
            print('   Name: ${uploaderName.value}');
            print('   Image: ${uploaderImage.value}');
            print('   Products: ${uploaderProductCount.value}');
            print('   Videos: ${uploaderVideoCount.value}');

            return;
          }
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error in populated products: $e');
    }
  }

  /// Try direct user API endpoints
  Future<void> _fetchUserViaDirectAPI(String userId) async {
    try {
      print('[DescriptionController] 🔥 Trying direct user API for: $userId');

      final endpoints = [
        'http://oldmarket.bhoomi.cloud/api/users/$userId/profile',
        'http://oldmarket.bhoomi.cloud/api/users/$userId',
        'http://oldmarket.bhoomi.cloud/api/user/$userId/profile',
        'http://oldmarket.bhoomi.cloud/api/user/$userId',
        'http://oldmarket.bhoomi.cloud/api/profile/$userId',
      ];

      for (final endpoint in endpoints) {
        try {
          print('[DescriptionController] 🔥 Trying direct API: $endpoint');
          final response = await http.get(Uri.parse(endpoint));

          print(
            '[DescriptionController] 🔥 Direct API Response: ${response.statusCode}',
          );
          print('[DescriptionController] 🔥 Direct API Body: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            Map<String, dynamic>? userInfo;
            if (data['data'] is Map) {
              userInfo = Map<String, dynamic>.from(data['data']);
              print('[DescriptionController] 🔥 Found user in data field');
            } else if (data is Map && data['name'] != null) {
              userInfo = Map<String, dynamic>.from(data);
              print('[DescriptionController] 🔥 Found user in root');
            } else {
              print(
                '[DescriptionController] 🔥 No user data found in response structure',
              );
            }

            if (userInfo != null) {
              uploaderProfile.value = userInfo;
              uploaderName.value = userInfo['name'] ?? 'User';

              String profileImg = userInfo['profileImage'] ?? '';
              if (profileImg.isNotEmpty) {
                profileImg = profileImg.replaceAll('\\', '/');
                if (!profileImg.startsWith('http')) {
                  profileImg = 'http://oldmarket.bhoomi.cloud$profileImg';
                }
              }
              uploaderImage.value = profileImg;

              print('[DescriptionController] ✅ Got user data from: $endpoint');
              return;
            }
          }
        } catch (e) {
          print('[DescriptionController] ❌ Direct API failed: $endpoint - $e');
          continue;
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error in direct user API: $e');
    }
  }

  /// Try users listing API to find user
  Future<void> _fetchUserViaUsersAPI(String userId) async {
    try {
      print('[DescriptionController] 🔥 Trying users listing API for: $userId');

      final endpoints = [
        'http://oldmarket.bhoomi.cloud/api/users',
        'http://oldmarket.bhoomi.cloud/api/users/all',
        'http://oldmarket.bhoomi.cloud/api/auth/users',
      ];

      for (final endpoint in endpoints) {
        try {
          print(
            '[DescriptionController] 🔥 Trying users listing API: $endpoint',
          );
          final response = await http.get(Uri.parse(endpoint));

          print(
            '[DescriptionController] 🔥 Users API Response: ${response.statusCode}',
          );
          if (response.statusCode == 200) {
            print(
              '[DescriptionController] 🔥 Users API Body Preview: ${response.body.length > 300 ? response.body.substring(0, 300) + "..." : response.body}',
            );

            final data = jsonDecode(response.body);

            List? usersList;
            if (data['data'] is List) {
              usersList = data['data'];
              print('[DescriptionController] 🔥 Found users in data field');
            } else if (data is List) {
              usersList = data;
              print('[DescriptionController] 🔥 Found users in root');
            } else if (data['users'] is List) {
              usersList = data['users'];
              print('[DescriptionController] 🔥 Found users in users field');
            } else {
              print(
                '[DescriptionController] 🔥 No users list found in response',
              );
            }

            if (usersList != null) {
              // Find user by ID
              final user = usersList.firstWhere(
                (u) => u['_id'] == userId || u['id'] == userId,
                orElse: () => null,
              );

              if (user != null) {
                uploaderProfile.value = Map<String, dynamic>.from(user);
                uploaderName.value = user['name'] ?? user['username'] ?? 'User';

                String profileImg =
                    user['profileImage'] ?? user['avatar'] ?? '';
                if (profileImg.isNotEmpty) {
                  profileImg = profileImg.replaceAll('\\', '/');
                  if (!profileImg.startsWith('http')) {
                    profileImg = 'http://oldmarket.bhoomi.cloud$profileImg';
                  }
                }
                uploaderImage.value = profileImg;

                print(
                  '[DescriptionController] ✅ Found user in listing: ${user['name']}',
                );
                return;
              }
            }
          }
        } catch (e) {
          print('[DescriptionController] ❌ Users API failed: $endpoint - $e');
          continue;
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error in users listing API: $e');
    }
  }

  /// Try user-specific product endpoints
  Future<void> _fetchUserSpecificProducts(String userId) async {
    try {
      print(
        '[DescriptionController] 🔥 Trying user-specific product endpoints for: $userId',
      );

      final endpoints = [
        'http://oldmarket.bhoomi.cloud/api/products/user/$userId',
        'http://oldmarket.bhoomi.cloud/api/products/by-user/$userId',
        'http://oldmarket.bhoomi.cloud/api/user/$userId/products',
        'http://oldmarket.bhoomi.cloud/api/users/$userId/products',
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await http.get(Uri.parse(endpoint));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            List? products;
            Map<String, dynamic>? userInfo;

            if (data['data'] is List) {
              products = data['data'];
              // Check if user info is included
              if (data['user'] != null) {
                userInfo = Map<String, dynamic>.from(data['user']);
              }
            } else if (data is List) {
              products = data;
            }

            if (products != null && products.isNotEmpty) {
              // Set user info if available
              if (userInfo != null) {
                uploaderProfile.value = userInfo;
                uploaderName.value = userInfo['name'] ?? 'User';

                String profileImg = userInfo['profileImage'] ?? '';
                if (profileImg.isNotEmpty) {
                  profileImg = profileImg.replaceAll('\\', '/');
                  if (!profileImg.startsWith('http')) {
                    profileImg = 'http://oldmarket.bhoomi.cloud$profileImg';
                  }
                }
                uploaderImage.value = profileImg;
              }

              // Count products and videos
              uploaderProductCount.value = products.length;

              // Only set video count if it hasn't been validated by _fetchVideosCount
              if (uploaderVideoCount.value == 0) {
                int videoCount = 0;
                for (var product in products) {
                  if (product['type'] == 'video') {
                    videoCount++;
                  }
                }
                uploaderVideoCount.value = videoCount;
                print(
                  '[DescriptionController] ✅ Got user products from: $endpoint',
                );
                print(
                  '[DescriptionController] Products: ${products.length}, Videos (fallback): $videoCount',
                );
              } else {
                print(
                  '[DescriptionController] ✅ Got user products from: $endpoint',
                );
                print(
                  '[DescriptionController] Products: ${products.length}, Videos: ${uploaderVideoCount.value} (preserved)',
                );
              }
              return;
            }
          }
        } catch (e) {
          print(
            '[DescriptionController] ❌ User products API failed: $endpoint - $e',
          );
          continue;
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error in user-specific products: $e');
    }
  }

  /// Fallback method to get product count only
  Future<void> _fetchProductCountOnly(String userId) async {
    try {
      print(
        '[DescriptionController] 🔥 Getting product count only for: $userId',
      );

      final response = await http.get(
        Uri.parse('http://oldmarket.bhoomi.cloud/api/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['data'] != null && responseData['data'] is List) {
          final allProducts = responseData['data'] as List;

          // Find products by this user
          final userProducts = allProducts.where((product) {
            if (product['userId'] == null) return false;

            if (product['userId'] is String) {
              return product['userId'] == userId;
            } else if (product['userId'] is Map) {
              return product['userId']['_id'] == userId;
            }
            return false;
          }).toList();

          uploaderProductCount.value = userProducts.length;

          // Only set video count if it hasn't been validated by _fetchVideosCount
          // (Don't override validated video counts from dedicated video endpoints)
          if (uploaderVideoCount.value == 0) {
            int videoCount = 0;
            for (var product in userProducts) {
              if (product['type'] == 'video') {
                videoCount++;
              }
            }
            uploaderVideoCount.value = videoCount;
            print(
              '[DescriptionController] ✅ Product count updated: ${userProducts.length}, Videos (fallback): $videoCount',
            );
          } else {
            print(
              '[DescriptionController] ✅ Product count updated: ${userProducts.length}, Videos: ${uploaderVideoCount.value} (preserved from validation)',
            );
          }
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error getting product count: $e');
    }
  }

  /// Try to fetch videos count specifically
  Future<void> _fetchVideosCount(String userId) async {
    try {
      print('[DescriptionController] 🔥 Fetching videos count for: $userId');

      // Try video-specific endpoints
      final videoEndpoints = [
        'http://oldmarket.bhoomi.cloud/api/videos/user/$userId',
        'http://oldmarket.bhoomi.cloud/api/user/$userId/videos',
        'http://oldmarket.bhoomi.cloud/api/products?type=video&userId=$userId',
        'http://oldmarket.bhoomi.cloud/api/videos?userId=$userId',
      ];

      for (final endpoint in videoEndpoints) {
        try {
          print('[DescriptionController] 🔥 Trying videos API: $endpoint');
          final response = await http.get(Uri.parse(endpoint));

          print(
            '[DescriptionController] 🔥 Videos API Response: ${response.statusCode}',
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            List? videos;
            if (data['data'] is List) {
              videos = data['data'];
            } else if (data is List) {
              videos = data;
            } else if (data['videos'] is List) {
              videos = data['videos'];
            }

            if (videos != null && videos.isNotEmpty) {
              // Validate that the returned items actually belong to the requested user
              final int totalReturned = videos.length;
              int filteredCount = 0;

              print(
                '[DescriptionController] 🔍 DEBUG: Validating $totalReturned videos for userId: $userId',
              );

              for (final item in videos) {
                try {
                  if (item == null) continue;

                  // normalize item to Map
                  Map<String, dynamic> v;
                  if (item is Map<String, dynamic>) {
                    v = item;
                  } else if (item is Map) {
                    v = Map<String, dynamic>.from(item);
                  } else {
                    continue;
                  }

                  print(
                    '[DescriptionController] 🔍 DEBUG: Video item - title: "${v['title']}", uploadedBy: "${v['uploadedBy']}", userId field: "${v['userId']}"',
                  );

                  // Several possible fields to check for uploader identity
                  String? ownerId;

                  // direct uploadedBy / uploaded_by
                  if (v['uploadedBy'] != null) {
                    ownerId = v['uploadedBy'].toString();
                    print(
                      '[DescriptionController] 🔍 DEBUG: Found uploadedBy: $ownerId',
                    );
                  } else if (v['uploaded_by'] != null) {
                    ownerId = v['uploaded_by'].toString();
                    print(
                      '[DescriptionController] 🔍 DEBUG: Found uploaded_by: $ownerId',
                    );
                  }

                  // uploader nested object
                  if (ownerId == null && v['uploader'] != null) {
                    final u = v['uploader'];
                    if (u is Map && (u['_id'] != null || u['id'] != null)) {
                      ownerId = (u['_id'] ?? u['id']).toString();
                    }
                  }

                  // userId field on the video/product
                  if (ownerId == null && v['userId'] != null) {
                    ownerId = v['userId'].toString();
                  }

                  // productId may be nested and carry user info
                  if (ownerId == null && v['productId'] != null) {
                    final p = v['productId'];
                    if (p is Map &&
                        (p['userId'] != null || p['user'] != null)) {
                      if (p['userId'] != null) {
                        ownerId = p['userId'].toString();
                      } else if (p['user'] is Map &&
                          (p['user']['_id'] != null ||
                              p['user']['id'] != null)) {
                        ownerId = (p['user']['_id'] ?? p['user']['id'])
                            .toString();
                      }
                    }
                  }

                  if (ownerId != null && ownerId == userId) {
                    filteredCount++;
                    print(
                      '[DescriptionController] 🔍 DEBUG: ✅ Video matches! ownerId: $ownerId == userId: $userId',
                    );
                  } else {
                    print(
                      '[DescriptionController] 🔍 DEBUG: ❌ Video does not match. ownerId: $ownerId, userId: $userId',
                    );
                  }
                } catch (e) {
                  // ignore individual item parse errors
                  continue;
                }
              }

              print(
                '[DescriptionController] ✅ Videos API $endpoint returned total=$totalReturned, filtered=$filteredCount',
              );

              if (filteredCount > 0) {
                uploaderVideoCount.value = filteredCount;
                return;
              }
              // If no filtered matches, continue to the next endpoint
            }
          }
        } catch (e) {
          print('[DescriptionController] ❌ Videos API failed: $endpoint - $e');
          continue;
        }
      }

      // If nothing matched specifically, ensure we set 0 (or keep previous value)
      print(
        '[DescriptionController] ⚠️ No validated videos found for $userId. Setting count to 0.',
      );
      uploaderVideoCount.value = 0;
    } catch (e) {
      print('[DescriptionController] ❌ Error fetching videos count: $e');
    }
  }

  /// Try alternative approaches for user data
  Future<void> _tryAlternativeUserData(String userId) async {
    try {
      print(
        '[DescriptionController] 🔥 Trying alternative user data approaches for: $userId',
      );

      // Try authentication/profile endpoints
      final altEndpoints = [
        'http://oldmarket.bhoomi.cloud/api/auth/profile/$userId',
        'http://oldmarket.bhoomi.cloud/api/profile/user/$userId',
        'http://oldmarket.bhoomi.cloud/api/accounts/$userId',
        'http://oldmarket.bhoomi.cloud/api/members/$userId',
        'http://oldmarket.bhoomi.cloud/api/users/$userId/info',
        'http://oldmarket.bhoomi.cloud/api/user-info/$userId',
      ];

      for (final endpoint in altEndpoints) {
        try {
          print('[DescriptionController] 🔥 Trying alternative API: $endpoint');
          final response = await http.get(Uri.parse(endpoint));

          print(
            '[DescriptionController] 🔥 Alternative API Response: ${response.statusCode}',
          );

          if (response.statusCode == 200) {
            print(
              '[DescriptionController] 🔥 Alternative API Body: ${response.body}',
            );
            final data = jsonDecode(response.body);

            Map<String, dynamic>? userInfo;

            // Try multiple response structures
            if (data['user'] != null) {
              userInfo = Map<String, dynamic>.from(data['user']);
            } else if (data['profile'] != null) {
              userInfo = Map<String, dynamic>.from(data['profile']);
            } else if (data['data'] != null) {
              userInfo = Map<String, dynamic>.from(data['data']);
            } else if (data['account'] != null) {
              userInfo = Map<String, dynamic>.from(data['account']);
            } else if (data is Map &&
                (data['name'] != null || data['username'] != null)) {
              userInfo = Map<String, dynamic>.from(data);
            }

            if (userInfo != null) {
              uploaderProfile.value = userInfo;
              final userName =
                  userInfo['name'] ??
                  userInfo['username'] ??
                  userInfo['displayName'] ??
                  userInfo['fullName'] ??
                  'User';

              uploaderName.value = userName;

              // Check if name suggests it's a dealer
              final lowerName = userName.toLowerCase();
              if (lowerName.contains('dealer') ||
                  lowerName.contains('business') ||
                  lowerName.contains('store') ||
                  lowerName.contains('shop') ||
                  lowerName.contains('motors') ||
                  lowerName.contains('auto') ||
                  lowerName.contains('cars') ||
                  lowerName.contains('garage') ||
                  lowerName.contains('showroom')) {
                isDealer.value = true;
                print(
                  '[DescriptionController] 🏢 Detected dealer from name: $userName',
                );
              }

              String profileImg =
                  userInfo['profileImage'] ??
                  userInfo['avatar'] ??
                  userInfo['photo'] ??
                  userInfo['picture'] ??
                  '';
              if (profileImg.isNotEmpty) {
                profileImg = profileImg.replaceAll('\\', '/');
                if (!profileImg.startsWith('http')) {
                  profileImg = 'http://oldmarket.bhoomi.cloud$profileImg';
                }
              }
              uploaderImage.value = profileImg;

              print(
                '[DescriptionController] ✅ Got alternative user data from: $endpoint',
              );
              print(
                '[DescriptionController] ✅ Name: ${uploaderName.value}, Image: ${uploaderImage.value}',
              );
              return;
            }
          }
        } catch (e) {
          print(
            '[DescriptionController] ❌ Alternative API failed: $endpoint - $e',
          );
          continue;
        }
      }
    } catch (e) {
      print('[DescriptionController] ❌ Error in alternative user data: $e');
    }
  }

  /// Try to fetch dealer products count
  Future<void> _fetchDealerProductsCount(String userId) async {
    try {
      print(
        '[DescriptionController] 🏭 Fetching dealer products count for: $userId',
      );

      // Try dealer products endpoints
      final dealerProductEndpoints = [
        'http://oldmarket.bhoomi.cloud/api/dealer-products?dealerId=$userId',
        'http://oldmarket.bhoomi.cloud/api/dealer-products?userId=$userId',
        'http://oldmarket.bhoomi.cloud/api/products?sellerType=dealer&userId=$userId',
        'http://oldmarket.bhoomi.cloud/api/products?dealerId=$userId',
      ];

      for (final endpoint in dealerProductEndpoints) {
        try {
          print(
            '[DescriptionController] 🏭 Trying dealer products API: $endpoint',
          );
          final response = await http.get(Uri.parse(endpoint));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            // Extract products list
            List<dynamic>? products;
            if (data['data'] is List) {
              products = data['data'];
            } else if (data['products'] is List) {
              products = data['products'];
            } else if (data is List) {
              products = data;
            }

            if (products != null) {
              final count = products.length;
              if (count > 0) {
                uploaderProductCount.value = count;
                print('[DescriptionController] ✅ Found $count dealer products');
                return;
              }
            }
          }
        } catch (e) {
          print(
            '[DescriptionController] ❌ Dealer products API failed: $endpoint - $e',
          );
          continue;
        }
      }

      print(
        '[DescriptionController] ℹ️ No dealer products found for userId: $userId',
      );
    } catch (e) {
      print('[DescriptionController] ❌ Error fetching dealer products: $e');
    }
  }

  /// Try to fetch dealer profile information
  Future<void> _fetchDealerProfile(String userId) async {
    try {
      print(
        '[DescriptionController] 🏢 Trying dealer profile endpoints for: $userId',
      );

      // Try multiple dealer profile endpoints
      final dealerEndpoints = [
        'http://oldmarket.bhoomi.cloud/api/dealer-profiles',
        'http://oldmarket.bhoomi.cloud/api/dealers/profiles',
        'http://oldmarket.bhoomi.cloud/api/auth/dealer-profiles',
        'http://oldmarket.bhoomi.cloud/api/dealers',
      ];

      for (final endpoint in dealerEndpoints) {
        try {
          print('[DescriptionController] 🏢 Trying dealer API: $endpoint');
          final response = await http.get(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/json'},
          );

          print(
            '[DescriptionController] 🏢 Dealer API Response: ${response.statusCode}',
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);

            // Look for dealer profiles list
            List<dynamic>? dealerProfiles;
            if (data['data'] is List) {
              dealerProfiles = data['data'];
            } else if (data['profiles'] is List) {
              dealerProfiles = data['profiles'];
            } else if (data['dealers'] is List) {
              dealerProfiles = data['dealers'];
            } else if (data is List) {
              dealerProfiles = data;
            }

            if (dealerProfiles != null && dealerProfiles.isNotEmpty) {
              print(
                '[DescriptionController] 🏢 Found ${dealerProfiles.length} dealer profiles, searching for userId: $userId',
              );

              // Find dealer profile matching the userId
              final dealerProfile = dealerProfiles.firstWhere(
                (dealer) =>
                    dealer['userId'] == userId || dealer['_id'] == userId,
                orElse: () => null,
              );

              if (dealerProfile != null) {
                print(
                  '[DescriptionController] 🎉 Found dealer profile: ${dealerProfile['businessName']}',
                );

                // Update uploader details with dealer information
                uploaderName.value = dealerProfile['businessName'] ?? 'Dealer';
                isDealer.value = true; // Mark as dealer

                // Handle dealer logo/image
                String dealerLogo = dealerProfile['businessLogo'] ?? '';
                if (dealerLogo.isNotEmpty) {
                  dealerLogo = dealerLogo.replaceAll('\\', '/');
                  if (!dealerLogo.startsWith('http')) {
                    dealerLogo = 'http://oldmarket.bhoomi.cloud$dealerLogo';
                  }
                  uploaderImage.value = dealerLogo;
                }

                // Set dealer phone if available
                if (dealerProfile['phone'] != null &&
                    dealerProfile['phone'].isNotEmpty) {
                  uploaderPhone.value = dealerProfile['phone'];
                }

                print(
                  '[DescriptionController] ✅ Dealer profile loaded: ${uploaderName.value}',
                );
                print(
                  '[DescriptionController] ✅ Dealer logo: ${uploaderImage.value}',
                );
                print('[DescriptionController] ✅ Marked as dealer profile');
                return;
              }
            }
          }
        } catch (e) {
          print('[DescriptionController] ❌ Dealer API failed: $endpoint - $e');
          continue;
        }
      }

      print(
        '[DescriptionController] ℹ️ No dealer profile found for userId: $userId',
      );
    } catch (e) {
      print('[DescriptionController] ❌ Error fetching dealer profile: $e');
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
