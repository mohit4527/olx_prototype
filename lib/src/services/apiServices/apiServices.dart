import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import '../../utils/logger.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import '../../controller/all_products_controller.dart';
import 'package:olx_prototype/src/model/short_video_model/short_video_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/all_product_model/all_product_model.dart';
import '../../model/book_test_drive_model/book_test_drive_model.dart';
import '../../model/book_test_drivescreen_model/book_test_drive_screen_model.dart';
import '../../model/challan_model/challan_model.dart';
import 'dart:convert';
import '../../model/chat_model/chat_model.dart';
import '../../model/dealer_product_model/dealer_product_model.dart';
import '../../model/fuel_model/fuel_model.dart';
import '../../model/make_offer_model/make_offer_model.dart';
import '../../model/product_description_model/product_description model.dart';
import '../../model/sell_dealer_car_model/sell_dealer_car_model.dart';
import '../../model/sell_user_car_model/sell_car_model.dart';
import '../../model/user_desler_products/user_dealer_product_model.dart';
import '../../model/user_offermodel/user_offermodel.dart';
import '../../model/dashboard_ads_model/dashboard_ads_model.dart';
import '../../model/dealer_profiles_model/dealer_profiles_model.dart';

class ApiService {
  /// Last error message from API calls (helpful for UI and debugging)
  static String apiLastError = '';
  // If the server's `/products/my` endpoint is returning HTML/500 repeatedly,
  // skip hitting it for a short time and use the userId fallback directly.
  static DateTime? _skipMyProductsUntil;
  static const Duration _skipMyProductsDuration = Duration(minutes: 2);
  // get allProducts
  static Future<List<ProductModel>> fetchProducts(String carId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://oldmarket.bhoomi.cloud/api/products?page=1&limit=100",
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> productList = data['data'];
        return productList.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      rethrow;
    }
  }

  // get all products description by id

  static Future<ProductModel?> fetchProductById(String productId) async {
    final response = await http.get(
      Uri.parse("https://oldmarket.bhoomi.cloud/api/products/$productId"),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body['status'] == true) {
        // 🔥 DEBUG: Log API response to see what phone data is actually returned
        print('[ApiService] fetchProductById - Raw API Response:');
        print(jsonEncode(body['data']));

        // Check for phone data in different locations
        final productData = body['data'];
        print('[ApiService] 🔥 API PHONE FIELDS DEBUG:');
        print('[ApiService] number: ${productData['number']}'); // Primary field
        print('[ApiService] phoneNumber: ${productData['phoneNumber']}');
        print('[ApiService] phone: ${productData['phone']}');
        print('[ApiService] whatsapp: ${productData['whatsapp']}');
        print('[ApiService] User phone: ${productData['user']?['phone']}');
        print(
          '[ApiService] Uploader phone: ${productData['uploader']?['phone']}',
        );
        print('[ApiService] UserId: ${productData['userId']}');

        return ProductModel.fromJson(body['data']);
      }
    }
    return null;
  }

  // Get uploader phone number by userId (simple endpoint)
  static Future<String?> getUploaderPhone(String userId) async {
    try {
      // Try simple endpoints first
      final endpoints = [
        "https://oldmarket.bhoomi.cloud/api/users/$userId/phone",
        "https://oldmarket.bhoomi.cloud/api/users/$userId/phone",
        "https://oldmarket.bhoomi.cloud/api/user/$userId/contact",
        "https://oldmarket.bhoomi.cloud/api/user/$userId/contact",
      ];

      for (final endpoint in endpoints) {
        try {
          final response = await http.get(Uri.parse(endpoint));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final phone =
                data['phone'] ?? data['phoneNumber'] ?? data['contact'];
            if (phone != null) return phone.toString();
          }
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      print('[ApiService] getUploaderPhone error: $e');
      return null;
    }
  }

  /// Fetch dashboard ads for carousel slider
  static Future<DashboardAdsModel?> fetchDashboardAds() async {
    try {
      print('📡 [ApiService] Fetching dashboard ads...');
      const url = 'https://oldmarket.bhoomi.cloud/api/dashboard-ads/all';

      final response = await http.get(Uri.parse(url));

      print('📊 [ApiService] Dashboard ads status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('📋 [ApiService] Dashboard ads response: ${response.body}');
        return dashboardAdsModelFromJson(response.body);
      } else {
        print('❌ [ApiService] Dashboard ads error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 [ApiService] Dashboard ads exception: $e');
      return null;
    }
  }

  /// Fetch all dealer profiles for detailed information
  static Future<DealerProfilesModel?> fetchDealerProfiles() async {
    try {
      print('📡 [ApiService] Fetching dealer profiles...');
      const url = 'https://oldmarket.bhoomi.cloud/api/dealers/profiles';

      final response = await http.get(Uri.parse(url));

      print('📊 [ApiService] Dealer profiles status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print(
          '📋 [ApiService] Dealer profiles response length: ${response.body.length}',
        );
        return dealerProfilesModelFromJson(response.body);
      } else {
        print('❌ [ApiService] Dealer profiles error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('💥 [ApiService] Dealer profiles exception: $e');
      return null;
    }
  }

  /// 🔥 NEW: Check if current user has a dealer profile
  static Future<bool> checkUserHasDealerProfile(String userId) async {
    try {
      print(
        '🔍 [ApiService] checkUserHasDealerProfile() called for userId: $userId',
      );

      // Fetch all dealer profiles
      final dealerProfilesModel = await fetchDealerProfiles();

      if (dealerProfilesModel?.data != null &&
          dealerProfilesModel!.data!.isNotEmpty) {
        print(
          '📊 [ApiService] Found ${dealerProfilesModel.data!.length} total dealer profiles',
        );

        // Check if any profile belongs to current user
        bool hasProfile = false;
        for (final profile in dealerProfilesModel.data!) {
          if (profile.userId == userId) {
            hasProfile = true;
            print(
              '✅ [ApiService] Found matching profile - ID: ${profile.id}, BusinessName: ${profile.businessName}',
            );
            break;
          }
        }

        if (!hasProfile) {
          print('❌ [ApiService] No profile found for userId: $userId');
          // Debug: print all userIds to see what's available
          final allUserIds = dealerProfilesModel.data!
              .map((p) => p.userId)
              .toList();
          print('🔍 [ApiService] Available userIds in profiles: $allUserIds');
        }

        print(
          '🏁 [ApiService] Final result - User $userId has dealer profile: $hasProfile',
        );
        return hasProfile;
      }

      print('❌ [ApiService] No dealer profiles found or empty data');
      return false;
    } catch (e) {
      print('💥 [ApiService] Check dealer profile exception: $e');
      return false;
    }
  }

  /// 🔥 NEW: Get current user's dealer profile
  static Future<DealerProfile?> getCurrentUserDealerProfile(
    String userId,
  ) async {
    try {
      print('🔍 [ApiService] Getting dealer profile for userId: $userId');

      // Fetch all dealer profiles
      final dealerProfilesModel = await fetchDealerProfiles();

      if (dealerProfilesModel?.data != null) {
        // Find profile for current user
        final userProfile = dealerProfilesModel!.data!.firstWhere(
          (profile) => profile.userId == userId,
          orElse: () => DealerProfile(),
        );

        if (userProfile.id != null) {
          print('✅ [ApiService] Found dealer profile for user $userId');
          return userProfile;
        }
      }

      print('❌ [ApiService] No dealer profile found for user $userId');
      return null;
    } catch (e) {
      print('💥 [ApiService] Get dealer profile exception: $e');
      return null;
    }
  }

  //ShortVideos ApiService
  static const String base = "https://oldmarket.bhoomi.cloud/api";
  // Key for locally hidden videos when server delete fails
  static const String _kLocallyDeletedVideosKey = 'locally_deleted_videos';
  String fullMediaUrl(String path) {
    if (path.isEmpty) return "";
    final fixed = path.replaceAll("\\", "/");
    if (fixed.startsWith("http")) return fixed;
    final baseAssets = "https://oldmarket.bhoomi.cloud/";
    final rel = fixed.startsWith("/") ? fixed.substring(1) : fixed;
    return "$baseAssets$rel";
  }

  Future<List<VideoModel>> fetchVideos() async {
    final uri = Uri.parse("$base/videos");
    print("[ApiService] GET $uri");
    final res = await http.get(uri);
    print("[ApiService] Response (${res.statusCode}): ${res.body}");
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      final data = body['data'] as List<dynamic>;
      final list = data
          .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception("Failed to load videos: ${res.statusCode}");
    }
  }

  /// Like endpoint: POST /api/videos/{id}/like
  Future<int> likeVideo(String videoId, String userId) async {
    final uri = Uri.parse("$base/videos/$videoId/like");
    print("[ApiService] POST $uri with userId=$userId");
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"userId": userId}),
    );
    print("[ApiService] Like response (${res.statusCode}): ${res.body}");
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = json.decode(res.body);
      final likesCount = body['likesCount'] ?? (body['likes']?.length ?? 0);
      return likesCount;
    } else {
      throw Exception("Like failed: ${res.statusCode}");
    }
  }

  /// Post comment: POST /api/videos/{id}/comment
  Future<void> postComment(String videoId, String userId, String text) async {
    final uri = Uri.parse("$base/videos/$videoId/comment");
    print("[ApiService] POST $uri with userId=$userId text=$text");
    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"text": text, "user": userId}),
    );
    print("[ApiService] Comment response (${res.statusCode}): ${res.body}");
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Post comment failed: ${res.statusCode}");
    }
  }

  /// If you need a dedicated comments fetch endpoint, implement here.
  Future<List<CommentModel>> fetchCommentsFromVideoObject(
    Map<String, dynamic> videoJson,
  ) async {
    final commentsJson = videoJson['comments'] as List<dynamic>? ?? [];
    return commentsJson
        .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  String cleanFileName(String path) {
    String fileName = path.split('/').last;
    fileName = fileName.replaceAll(RegExp(r'[^\w\.\-]'), '_');
    return fileName;
  }

  /// Upload video
  Future<VideoModel> uploadVideo({
    required String videoPath,
    required String title,
    required String productId,
    required int duration,
  }) async {
    print('\n🎬 [ApiService] uploadVideo() CALLED');
    print('🎬 [ApiService] videoPath: $videoPath');
    print('🎬 [ApiService] title: $title');
    print('🎬 [ApiService] productId: $productId');
    print('🎬 [ApiService] duration: $duration');

    try {
      final uri = Uri.parse("$base/videos");
      print('🎬 [ApiService] Target URI: $uri');
      Logger.d('ApiService', 'Uploading video to: $uri');
      Logger.d(
        'ApiService',
        'videoPath: $videoPath, title: $title, productId: $productId, duration: $duration',
      );

      print('📦 [ApiService] Creating MultipartRequest...');
      print('📦 [ApiService] Creating MultipartRequest...');
      final request = http.MultipartRequest('POST', uri);

      // Attach video file with clean filename and proper content type
      // Determine mime type dynamically so we send correct content-type
      print('🔍 [ApiService] Detecting MIME type for: $videoPath');
      final detectedMime = lookupMimeType(videoPath) ?? 'video/mp4';
      print('🔍 [ApiService] Detected MIME: $detectedMime');

      final mimeParts = detectedMime.split('/');
      final mimeTypeTop = mimeParts.isNotEmpty ? mimeParts[0] : 'video';
      final mimeTypeSub = mimeParts.length > 1 ? mimeParts[1] : 'mp4';

      print('📎 [ApiService] Adding video file to request...');
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoPath,
          filename: cleanFileName(videoPath),
          contentType: MediaType(mimeTypeTop, mimeTypeSub),
        ),
      );
      print('✅ [ApiService] Video file added successfully');

      print('📝 [ApiService] Adding form fields...');
      print('📝 [ApiService] Adding form fields...');
      request.fields['title'] = title;
      request.fields['productId'] = productId;

      // Resolve userId robustly for uploads. We prefer SharedPreferences
      // values ('userId' or 'user_uid'), then fall back to decoding the
      // JWT token if TokenController is available. We also log the prefs
      // and token contents (only presence, not secret) to help debug.
      print('🔑 [ApiService] Resolving userId for upload...');
      final resolvedUserId = await _getUserIdForUploads();
      print(
        '🔑 [ApiService] Resolved userId: ${resolvedUserId.isEmpty ? "EMPTY!" : resolvedUserId}',
      );

      if (resolvedUserId.isNotEmpty) {
        request.fields['userId'] = resolvedUserId;
        print('✅ [ApiService] userId added to request');
      } else {
        // Keep an explicit log so developers know why userId is missing.
        print('❌ [ApiService] uploadVideo: no userId found in prefs or token');
        print('[ApiService] uploadVideo: no userId found in prefs or token');
      }

      request.fields['duration'] = duration.toString();

      // Add common alternative field names so backends that expect different
      // names still receive the uploader id. These are harmless duplicates.
      final resolved = request.fields['userId'] ?? '';
      if (resolved.isNotEmpty) {
        request.fields['uploaderId'] = resolved;
        request.fields['uploader_id'] = resolved;
        request.fields['ownerId'] = resolved;
        print(
          '[ApiService] Also setting uploaderId/uploader_id/ownerId = $resolved',
        );
      }

      // Ensure we have SharedPreferences available for headers too
      final prefs = await SharedPreferences.getInstance();
      final headers = <String, String>{"Accept": "application/json"};
      final storedToken = prefs.getString('auth_token') ?? '';
      if (storedToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $storedToken';
      }
      try {
        final tokenCtrl = Get.find<TokenController>();
        if (tokenCtrl.apiToken.value.isNotEmpty) {
          headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
        }
      } catch (_) {
        // TokenController not registered — continue with storedToken (if any)
      }
      request.headers.addAll(headers);
      Logger.d('ApiService', 'Upload headers: $headers');

      // Additional debug: indicate whether prefs have the keys we expect and
      // what userId was resolved (do not print full token)
      try {
        final _prefs = await SharedPreferences.getInstance();
        final hasUserId = _prefs.containsKey('userId');
        final hasUserUid = _prefs.containsKey('user_uid');
        final hasAuth =
            _prefs.containsKey('auth_token') || _prefs.containsKey('token');
        print(
          '[ApiService] Prefs keys -> userId:$hasUserId user_uid:$hasUserUid auth_token:$hasAuth',
        );
        print(
          '[ApiService] Resolved userId for upload: ${resolvedUserId.isNotEmpty ? resolvedUserId : '<none>'}',
        );
        if (hasAuth) {
          final t =
              _prefs.getString('auth_token') ?? _prefs.getString('token') ?? '';
          print('[ApiService] auth_token present length=${t.length} (masked)');
        }
      } catch (e) {
        print('[ApiService] Could not read prefs for debug: $e');
      }

      // Debug: print form fields and files we'll send so we can inspect in logs
      try {
        print('[ApiService] Upload form fields: ${request.fields}');
        print(
          '[ApiService] Upload files: ${request.files.map((f) => f.filename).toList()}',
        );
      } catch (e) {
        print('[ApiService] Could not print upload form debug info: $e');
      }

      // Send with retries and a timeout so the app doesn't hang indefinitely
      // on poor networks. We'll attempt up to 3 times with exponential backoff.
      http.StreamedResponse streamedResponse;
      const int maxAttempts = 3;
      int attempt = 0;
      while (true) {
        attempt++;
        try {
          print('[ApiService] Attempt $attempt to send upload');
          streamedResponse = await request.send().timeout(
            Duration(seconds: 180),
          );
          // if send succeeds, break the retry loop
          break;
        } on TimeoutException catch (te) {
          print('[ApiService] uploadVideo TIMEOUT (attempt $attempt): $te');
          if (attempt >= maxAttempts) {
            try {
              final f = File(videoPath);
              final len = await f.length();
              apiLastError =
                  'Upload timed out after 180s (file ${f.path}, size ${len} bytes). Try on a faster network or compress the video.';
              throw Exception(apiLastError);
            } catch (_) {
              apiLastError =
                  'Upload timed out after 180s. Try on a faster network or compress the video.';
              throw Exception(apiLastError);
            }
          } else {
            final backoff = Duration(seconds: 2 * attempt);
            print('[ApiService] Retrying after ${backoff.inSeconds}s');
            await Future.delayed(backoff);
            continue;
          }
        } on SocketException catch (se) {
          print(
            '[ApiService] uploadVideo SOCKET ERROR (attempt $attempt): $se',
          );
          apiLastError = se.toString();
          if (attempt >= maxAttempts) {
            throw Exception('Network error during upload: $se');
          } else {
            final backoff = Duration(seconds: 2 * attempt);
            print(
              '[ApiService] Retrying after ${backoff.inSeconds}s due to socket error',
            );
            await Future.delayed(backoff);
            continue;
          }
        } catch (e) {
          print('[ApiService] uploadVideo send error (attempt $attempt): $e');
          apiLastError = e.toString();
          rethrow;
        }
      }

      final response = await http.Response.fromStream(streamedResponse);

      Logger.d('ApiService', 'Response Status: ${response.statusCode}');
      Logger.d('ApiService', 'Response Body: ${response.body}');

      try {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final body = json.decode(response.body);
          if (body['status'] == true && body['data'] != null) {
            final videoData = body['data'] as Map<String, dynamic>;
            Logger.d(
              'ApiService',
              'Video uploaded successfully: ${videoData['videoUrl']}',
            );
            return VideoModel.fromJson(videoData);
          } else {
            final msg = body['message'] ?? 'No data returned';
            apiLastError = msg.toString();
            throw Exception('Upload failed: $msg');
          }
        } else if (response.statusCode == 413) {
          // File too large error from nginx/server
          apiLastError =
              'Video file is too large. Maximum allowed size is 50MB. Please compress your video or select a smaller file.';
          print('❌ [ApiService] 413 Error: File too large for server');
          throw Exception(apiLastError);
        } else {
          apiLastError = response.body;
          throw Exception('Upload failed with status: ${response.statusCode}');
        }
      } catch (e) {
        print('[ApiService] uploadVideo processing error: $e');
        rethrow;
      }
    } catch (e) {
      Logger.d('ApiService', 'uploadVideo ERROR: $e');
      rethrow;
    }
  }

  /// Helper used specifically for upload flows to resolve userId when the
  /// TokenController may not be registered yet. Reads SharedPreferences
  /// first, then decodes token from TokenController if available.
  static Future<String> _getUserIdForUploads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefUserId =
          prefs.getString('userId') ?? prefs.getString('user_uid') ?? '';
      if (prefUserId.isNotEmpty) return prefUserId;

      // Try TokenController if present
      try {
        final tokenCtrl = Get.find<TokenController>();
        final token = tokenCtrl.apiToken.value;
        if (token.isNotEmpty) {
          // Reuse existing decoding helper
          final inferred = await _getUserIdFromPrefsOrToken(tokenCtrl);
          if (inferred.isNotEmpty) return inferred;
        }
      } catch (e) {
        print(
          '[ApiService] _getUserIdForUploads: TokenController not available: $e',
        );
      }
    } catch (e) {
      print('[ApiService] _getUserIdForUploads error: $e');
    }
    return '';
  }

  // Book Test Drive ApiService
  static Future<BookTestDriveModel?> bookTestDrive({
    required String preferredDate,
    required String preferredTime,
    required String carId,
    required String name,
    required String phoneNumber,
  }) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/car/$carId/book-test-drive',
    );

    final body = jsonEncode({
      "carId": carId,
      "date": preferredDate,
      "time": preferredTime,
      "name": name,
      "phone": phoneNumber,
    });

    print("📡 API Request → POST $url");
    print("📦 Request Body: $body");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("📬 Response Status: ${response.statusCode}");
      print("📨 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return BookTestDriveModel.fromJson(json);
      } else {
        print("❌ API Error: ${response.statusCode}");
        return null;
      }
    } catch (e, stack) {
      print("🔥 Exception during API call: $e");
      print("📍 Stack Trace:\n$stack");
      return null;
    }
  }

  // -------------------- SELL USER PRODUCTS ----------------------
  static Future<void> uploadCar(SellUserCarModel car, List<File> images) async {
    print("Sending userId: ${car.userId}");

    // 🔹 Retry mechanism for network issues
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("Upload attempt $attempt of $maxRetries");

        final uri = Uri.parse('https://oldmarket.bhoomi.cloud/api/products');
        final request = http.MultipartRequest('POST', uri);

        // Set timeout for the request
        // Note: MultipartRequest doesn't have direct timeout, but we can use Future.timeout

        // Required fields
        request.fields['title'] = car.title;
        request.fields['description'] = car.description;
        request.fields['price'] = car.price.toString();
        request.fields['type'] = car.type;
        request.fields['userId'] = car.userId;
        request.fields['category'] = car.category;
        request.fields['number'] =
            car.phoneNumber; // 🔥 Backend expects "number" field
        request.fields['phoneNumber'] = car.phoneNumber; // 🔥 Backup field

        // Location as country, state, city fields
        request.fields['country'] = car.country;
        request.fields['state'] = car.state;
        request.fields['city'] = car.city;

        // 🔥 DEBUG: Upload API fields
        print('[ApiService] uploadCar - Title: "${car.title}"');
        print('[ApiService] uploadCar - PhoneNumber: "${car.phoneNumber}"');
        print(
          '[ApiService] uploadCar - number field: "${request.fields['number']}"',
        );
        print(
          '[ApiService] uploadCar - phoneNumber field: "${request.fields['phoneNumber']}"',
        );
        print('[ApiService] uploadCar - All fields: ${request.fields}');

        if (car.dealerType != null) {
          request.fields['dealerType'] = car.dealerType!;
        }

        // 🔹 Attach images
        for (final img in images) {
          final compressed = await compressImage(img);
          final fileToSend = compressed ?? img;
          final mimeType = lookupMimeType(fileToSend.path) ?? 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              fileToSend.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }

        // 🔹 Send request with timeout
        final streamed = await request.send().timeout(
          const Duration(seconds: 60), // 60 second timeout
          onTimeout: () {
            throw TimeoutException(
              'Upload request timed out',
              const Duration(seconds: 60),
            );
          },
        );

        final resp = await http.Response.fromStream(streamed);
        print('Upload status: ${resp.statusCode} body: ${resp.body}');

        final responseData = jsonDecode(resp.body);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          if (responseData['status'] == true) {
            Get.snackbar(
              "Success",
              responseData['message'] ?? "Product uploaded successfully",
              backgroundColor: AppColors.appGreen,
              colorText: AppColors.appWhite,
            );
            return; // Success, exit retry loop
          } else {
            Get.snackbar(
              "Error",
              responseData['message'] ?? "Upload failed",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
            return; // Server responded with error, don't retry
          }
        } else if (resp.statusCode == 403) {
          // Handle subscription limit reached specifically
          final message = responseData['message'] ?? '';
          if (message.contains('Post limit reached') ||
              message.contains('Subscribe')) {
            print('🚫 [ApiService] Subscription limit reached on server!');
            // Show subscription popup instead of regular error
            final productController = Get.isRegistered<ProductController>()
                ? Get.find<ProductController>()
                : Get.put(ProductController());
            productController.showSubscriptionPopup();
            throw Exception(
              'Subscription limit reached',
            ); // Throw exception to stop success message
          } else {
            Get.snackbar(
              "Access Denied",
              message.isNotEmpty ? message : "Access denied",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
            return;
          }
        } else {
          // Server error, might be worth retrying
          if (attempt == maxRetries) {
            Get.snackbar(
              "Error",
              responseData['message'] ??
                  "Something went wrong after $maxRetries attempts",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
          } else {
            print(
              "Server error (${resp.statusCode}), retrying in ${retryDelay.inSeconds} seconds...",
            );
            await Future.delayed(retryDelay);
          }
        }
      } catch (e) {
        print("Error during upload attempt $attempt: $e");

        // Check if this is a network-related error that might benefit from retry
        bool shouldRetry =
            e is SocketException ||
            e is TimeoutException ||
            e.toString().contains('Broken pipe') ||
            e.toString().contains('Connection reset') ||
            e.toString().contains('timeout');

        if (shouldRetry && attempt < maxRetries) {
          print(
            "Network error detected, retrying in ${retryDelay.inSeconds} seconds...",
          );
          Get.snackbar(
            "Retry",
            "Upload failed (attempt $attempt/$maxRetries). Retrying...",
            backgroundColor: Colors.orange,
            colorText: AppColors.appWhite,
            duration: Duration(seconds: retryDelay.inSeconds),
          );
          await Future.delayed(retryDelay);
        } else {
          // Final failure or non-retryable error
          String errorMessage = "Failed to upload product";
          if (e is SocketException || e.toString().contains('Broken pipe')) {
            errorMessage =
                "Network connection failed. Please check your internet connection.";
          } else if (e is TimeoutException) {
            errorMessage = "Upload timed out. Please try again.";
          } else if (e.toString().contains('name must end with jpg or jpeg')) {
            errorMessage =
                "Image format error. Please try selecting images again.";
          }

          Get.snackbar(
            "Error",
            "$errorMessage (After $attempt attempts)",
            backgroundColor: AppColors.appRed,
            colorText: AppColors.appWhite,
          );
          rethrow; // Re-throw the error so the controller knows upload failed
        }
      }
    }
  }

  // -------------------- SELL DEALER PRODUCTS --------------------
  static Future<void> uploadDealerCar(
    DealerCarModel car,
    List<File> images,
  ) async {
    // 🔹 Retry mechanism for network issues
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 2);

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print("Dealer car upload attempt $attempt of $maxRetries");

        final uri = Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/cars/dealer/upload',
        );

        final request = http.MultipartRequest('POST', uri);

        //Required fields
        request.fields['title'] = car.title;
        request.fields['description'] = car.description;
        request.fields['price'] = car.price.toString();
        request.fields['sellerType'] = car.sellerType;
        request.fields['dealerId'] = car.dealerId;
        request.fields['userId'] = car.userId;
        request.fields['tags'] = jsonEncode(car.tags);
        request.fields['category'] = car.category;
        request.fields['country'] = car.country;
        request.fields['state'] = car.state;
        request.fields['city'] = car.city;

        // Attach images
        for (final img in images) {
          final compressed = await compressImage(img);
          final fileToSend = compressed ?? img;
          final mimeType = lookupMimeType(fileToSend.path) ?? 'image/jpeg';
          request.files.add(
            await http.MultipartFile.fromPath(
              'images',
              fileToSend.path,
              contentType: MediaType.parse(mimeType),
            ),
          );
        }

        // 🔹 Send request with timeout
        final streamed = await request.send().timeout(
          const Duration(seconds: 60), // 60 second timeout
          onTimeout: () {
            throw TimeoutException(
              'Dealer car upload request timed out',
              const Duration(seconds: 60),
            );
          },
        );

        final resp = await http.Response.fromStream(streamed);
        print(
          'Dealer Car Upload status: ${resp.statusCode} body: ${resp.body}',
        );

        final responseData = jsonDecode(resp.body);

        if (resp.statusCode == 200 || resp.statusCode == 201) {
          if (responseData['status'] == true) {
            Get.snackbar(
              "Success",
              responseData['message'] ?? "Car uploaded successfully",
              backgroundColor: AppColors.appGreen,
              colorText: AppColors.appWhite,
            );
            return; // Success, exit retry loop
          } else {
            Get.snackbar(
              "Error",
              responseData['message'] ?? "Upload failed",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
            return; // Server responded with error, don't retry
          }
        } else if (resp.statusCode == 403) {
          // Handle subscription limit reached specifically for dealer upload
          final message = responseData['message'] ?? '';
          if (message.contains('Post limit reached') ||
              message.contains('Subscribe')) {
            print(
              '🚫 [ApiService] Dealer subscription limit reached on server!',
            );
            // Show subscription popup instead of regular error
            final productController = Get.isRegistered<ProductController>()
                ? Get.find<ProductController>()
                : Get.put(ProductController());
            productController.showSubscriptionPopup();
            throw Exception(
              'Dealer subscription limit reached',
            ); // Throw exception to stop success message
          } else {
            Get.snackbar(
              "Access Denied",
              message.isNotEmpty ? message : "Access denied",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
            return;
          }
        } else {
          // Server error, might be worth retrying
          if (attempt == maxRetries) {
            Get.snackbar(
              "Error",
              responseData['message'] ??
                  "Something went wrong after $maxRetries attempts",
              backgroundColor: AppColors.appRed,
              colorText: AppColors.appWhite,
            );
          } else {
            print(
              "Server error (${resp.statusCode}), retrying in ${retryDelay.inSeconds} seconds...",
            );
            await Future.delayed(retryDelay);
          }
        }
      } catch (e) {
        print("Error during dealer car upload attempt $attempt: $e");

        // Check if this is a network-related error that might benefit from retry
        bool shouldRetry =
            e is SocketException ||
            e is TimeoutException ||
            e.toString().contains('Broken pipe') ||
            e.toString().contains('Connection reset') ||
            e.toString().contains('timeout');

        if (shouldRetry && attempt < maxRetries) {
          print(
            "Network error detected, retrying in ${retryDelay.inSeconds} seconds...",
          );
          Get.snackbar(
            "Retry",
            "Dealer car upload failed (attempt $attempt/$maxRetries). Retrying...",
            backgroundColor: Colors.orange,
            colorText: AppColors.appWhite,
            duration: Duration(seconds: retryDelay.inSeconds),
          );
          await Future.delayed(retryDelay);
        } else {
          // Final failure or non-retryable error
          String errorMessage = "Failed to upload dealer car";
          if (e is SocketException || e.toString().contains('Broken pipe')) {
            errorMessage =
                "Network connection failed. Please check your internet connection.";
          } else if (e is TimeoutException) {
            errorMessage = "Upload timed out. Please try again.";
          }

          Get.snackbar(
            "Error",
            "$errorMessage (After $attempt attempts)",
            backgroundColor: AppColors.appRed,
            colorText: AppColors.appWhite,
          );
          return;
        }
      }
    }
  }

  // -------------------- COMPRESS IMAGE --------------------
  static Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();

    // Ensure the output file has .jpg extension (required by flutter_image_compress)
    final originalBasename = path.basenameWithoutExtension(file.path);
    final targetPath = path.join(
      dir.absolute.path,
      '${DateTime.now().millisecondsSinceEpoch}_$originalBasename.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg, // Explicitly set format to JPEG
    );
    return result != null ? File(result.path) : null;
  }

  // Location-based filtering methods
  /// Fetch products by city name
  static Future<List<DealerProduct>> fetchProductsByCity(
    String cityName,
  ) async {
    try {
      print("🏙️ Fetching products for city: $cityName");

      final response = await http.get(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/products?city=${Uri.encodeComponent(cityName)}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<DealerProduct> cityProducts = [];

        List<dynamic> products = [];
        if (jsonResponse is List) {
          products = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse['data'] != null) {
          products = jsonResponse['data'];
        }

        for (var product in products) {
          // Check if product has city information matching the requested city
          String? productCity = product['city']?.toString();
          if (productCity != null &&
              productCity.toLowerCase().contains(cityName.toLowerCase())) {
            cityProducts.add(_convertToeDealerProduct(product));
          }
        }

        print("🏙️ Found ${cityProducts.length} products in $cityName");
        return cityProducts;
      } else {
        print("❌ City API failed with status: ${response.statusCode}");
        // Fallback: filter from all products
        return _filterProductsByCity(await fetchDealerProducts(), cityName);
      }
    } catch (e) {
      print("❌ Error fetching products by city: $e");
      // Fallback: filter from all products
      return _filterProductsByCity(await fetchDealerProducts(), cityName);
    }
  }

  /// Fetch products within distance range
  static Future<List<DealerProduct>> fetchProductsByDistance(
    double lat,
    double lng,
    double radiusKm,
  ) async {
    try {
      print("📏 Fetching products within ${radiusKm}km of $lat, $lng");

      final response = await http.get(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/products?lat=$lat&lng=$lng&radius=$radiusKm',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<DealerProduct> nearbyProducts = [];

        List<dynamic> products = [];
        if (jsonResponse is List) {
          products = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse['data'] != null) {
          products = jsonResponse['data'];
        }

        for (var product in products) {
          nearbyProducts.add(_convertToeDealerProduct(product));
        }

        print(
          "📏 Found ${nearbyProducts.length} products within ${radiusKm}km",
        );
        return nearbyProducts;
      } else {
        print("❌ Distance API failed with status: ${response.statusCode}");
        print("🔄 Using fallback with all products for ${radiusKm}km radius");
        // Fallback: get all products and simulate distance filtering
        final allProducts = await fetchDealerProducts();
        final filtered = _filterProductsByDistance(
          allProducts,
          lat,
          lng,
          radiusKm,
        );
        print(
          "📍 Fallback returned ${filtered.length} products within ${radiusKm}km",
        );
        return filtered;
      }
    } catch (e) {
      print("❌ Error fetching products by distance: $e");
      print("🔄 Using emergency fallback for distance filtering");
      // Emergency fallback: get all products and simulate distance filtering
      try {
        final allProducts = await fetchDealerProducts();
        final filtered = _filterProductsByDistance(
          allProducts,
          lat,
          lng,
          radiusKm,
        );
        print("📍 Emergency fallback returned ${filtered.length} products");
        return filtered;
      } catch (fallbackError) {
        print("❌ Even fallback failed: $fallbackError");
        return [];
      }
    }
  }

  /// Fetch nearby products (within 10km radius)
  static Future<List<DealerProduct>> fetchNearbyProducts(
    double lat,
    double lng,
  ) async {
    try {
      print("📍 Fetching nearby products around $lat, $lng");

      final response = await http.get(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/products/nearby?lat=$lat&lng=$lng',
        ),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        List<DealerProduct> nearbyProducts = [];

        List<dynamic> products = [];
        if (jsonResponse is List) {
          products = jsonResponse;
        } else if (jsonResponse is Map && jsonResponse['data'] != null) {
          products = jsonResponse['data'];
        }

        for (var product in products) {
          nearbyProducts.add(_convertToeDealerProduct(product));
        }

        print("📍 Found ${nearbyProducts.length} nearby products");
        return nearbyProducts;
      } else {
        print("❌ Nearby API failed with status: ${response.statusCode}");
        print("🔄 Using fallback - getting products within 10km radius");
        // Fallback: get all products and filter for nearby (10km radius)
        final allProducts = await fetchDealerProducts();
        final nearbyFiltered = _filterProductsByDistance(
          allProducts,
          lat,
          lng,
          10.0,
        );
        print("📍 Nearby fallback returned ${nearbyFiltered.length} products");
        return nearbyFiltered;
      }
    } catch (e) {
      print("❌ Error fetching nearby products: $e");
      print("🔄 Using emergency fallback for nearby filtering");
      // Emergency fallback: get some products to show
      try {
        final allProducts = await fetchDealerProducts();
        final nearbyFiltered = _filterProductsByDistance(
          allProducts,
          lat,
          lng,
          15.0,
        ); // Wider radius as emergency
        print("📍 Emergency nearby returned ${nearbyFiltered.length} products");
        return nearbyFiltered;
      } catch (fallbackError) {
        print("❌ Even nearby fallback failed: $fallbackError");
        return [];
      }
    }
  }

  /// Helper method to filter products by city (fallback)
  static List<DealerProduct> _filterProductsByCity(
    List<DealerProduct> allProducts,
    String cityName,
  ) {
    return allProducts
        .where((product) {
          return product.title?.toLowerCase().contains(
                cityName.toLowerCase(),
              ) ??
              false;
        })
        .take(15)
        .toList(); // Limit to 15 results
  }

  /// Helper method to filter products by distance (fallback)
  static List<DealerProduct> _filterProductsByDistance(
    List<DealerProduct> allProducts,
    double lat,
    double lng,
    double radiusKm,
  ) {
    print(
      "📏 Filtering ${allProducts.length} products by ${radiusKm}km radius around $lat, $lng",
    );

    if (allProducts.isEmpty) {
      print("⚠️ No products available to filter");
      return [];
    }

    // For fallback, return products based on radius
    // Simulate distance-based filtering by returning more products for larger radius
    int maxProducts = (radiusKm * 3).round().clamp(
      5,
      allProducts.length,
    ); // At least 5, max all

    final filtered = allProducts.take(maxProducts).toList();
    print(
      "📍 Distance filter returned ${filtered.length} products for ${radiusKm}km radius",
    );

    return filtered;
  }

  /// Helper method to convert API response to DealerProduct
  static DealerProduct _convertToeDealerProduct(Map<String, dynamic> product) {
    try {
      // Handle dealerId field that might be a Map
      String? dealerId;
      String? dealerName;
      String? phone;

      final dealerField = product['dealerId'];
      if (dealerField != null) {
        if (dealerField is String) {
          dealerId = dealerField;
        } else if (dealerField is Map<String, dynamic>) {
          dealerId = dealerField['_id']?.toString();
          dealerName =
              dealerField['name']?.toString() ??
              dealerField['businessName']?.toString();
          phone = dealerField['phone']?.toString();
        }
      }

      // Handle images array or single image
      List<String> images = [];
      if (product['images'] is List) {
        images = List<String>.from(
          product['images'].map((img) => img.toString()),
        );
      } else if (product['imageUrl'] != null) {
        images = [product['imageUrl'].toString()];
      } else if (product['image'] != null) {
        images = [product['image'].toString()];
      }

      return DealerProduct(
        id: product['_id']?.toString() ?? product['id']?.toString() ?? '',
        title:
            product['title']?.toString() ??
            product['name']?.toString() ??
            'Unknown Vehicle',
        description:
            product['description']?.toString() ?? 'No description available',
        price: (product['price'] is int)
            ? product['price']
            : int.tryParse(product['price']?.toString() ?? '0') ?? 0,
        sellerType: product['sellerType']?.toString() ?? 'dealer',
        dealerId: dealerId,
        dealerName: dealerName ?? product['dealerName']?.toString(),
        phone: phone ?? product['phone']?.toString(),
        tags: product['tags'] is List ? List<String>.from(product['tags']) : [],
        images: images,
        createdAt:
            DateTime.tryParse(product['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(product['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        location:
            product['location']?.toString() ?? product['city']?.toString(),
      );
    } catch (e) {
      print("❌ Error converting product: $e");
      print("❌ Product data: $product");
      // Return a minimal valid product
      return DealerProduct(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Error Product',
        description: 'Failed to parse product data',
        price: 0,
        sellerType: 'dealer',
        tags: [],
        images: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Fetch dealer All Products
  static const String _baseUrl = 'https://oldmarket.bhoomi.cloud/api/dealers';

  static Future<List<DealerProduct>> fetchDealerProducts() async {
    try {
      // First try the new getAllDealerCars API
      print("📡 Trying new dealer cars API...");

      final dealerCarsResult = await getAllDealerCars();
      if (dealerCarsResult != null && dealerCarsResult['status'] == true) {
        final data = dealerCarsResult['data'];
        if (data is List && data.isNotEmpty) {
          print("✅ Found ${data.length} dealer cars from new API");
          List<DealerProduct> dealerProducts = [];

          // First fetch all dealers to get their phone numbers
          print("📱 Fetching dealer contact info...");
          final dealersResult = await getAllDealers();
          Map<String, String> dealerPhones = {};

          if (dealersResult != null && dealersResult['status'] == true) {
            final dealers = dealersResult['data'] as List?;
            if (dealers != null) {
              for (var dealer in dealers) {
                if (dealer is Map<String, dynamic>) {
                  final dealerId = dealer['_id']?.toString();
                  final phone =
                      dealer['phone']?.toString() ??
                      dealer['phoneNumber']?.toString() ??
                      dealer['contactNumber']?.toString() ??
                      dealer['businessPhone']?.toString() ??
                      '';
                  if (dealerId != null && phone.isNotEmpty) {
                    dealerPhones[dealerId] = phone;
                    print("📞 Cached dealer phone: $dealerId -> $phone");
                  }
                }
              }
            }
          }

          for (var car in data) {
            try {
              if (car is Map<String, dynamic>) {
                // Ensure required fields exist for dealer cars
                final dealerId =
                    car['dealerId']?.toString() ??
                    car['dealer']?.toString() ??
                    car['_id']?.toString() ??
                    'dealer123';

                car['dealerId'] = dealerId;
                car['dealerName'] =
                    car['dealerName']?.toString() ??
                    car['dealer_name']?.toString() ??
                    'Dealer';

                // Get phone from dealer cache first, then fallback to car data
                String dealerPhone =
                    dealerPhones[dealerId] ??
                    car['phone']?.toString() ??
                    car['phoneNumber']?.toString() ??
                    car['dealerPhone']?.toString() ??
                    car['contactNumber']?.toString() ??
                    car['whatsapp']?.toString() ??
                    '';

                car['phone'] = dealerPhone;
                car['dealerPhone'] = dealerPhone;

                car['sellerType'] = 'dealer';
                car['title'] =
                    car['title']?.toString() ??
                    car['name']?.toString() ??
                    'Car';
                car['description'] =
                    car['description']?.toString() ?? 'No description';

                // Handle price
                if (car['price'] is String) {
                  car['price'] = int.tryParse(car['price']) ?? 0;
                } else {
                  car['price'] = car['price'] ?? 0;
                }

                // Handle arrays
                if (car['tags'] is! List) {
                  car['tags'] = [];
                }
                if (car['images'] is! List) {
                  car['images'] = car['mediaUrl'] ?? [];
                }

                // Debug phone information
                print(
                  "📱 Car ${car['title']}: dealer=$dealerId, phone=$dealerPhone",
                );

                dealerProducts.add(DealerProduct.fromJson(car));
              }
            } catch (e) {
              print("⚠️ Error parsing dealer car: $e");
              continue;
            }
          }

          if (dealerProducts.isNotEmpty) {
            print("✅ Successfully parsed ${dealerProducts.length} dealer cars");
            return dealerProducts;
          }
        }
      }

      // Fallback to existing endpoints if new API fails
      print("📡 Fallback: Trying existing endpoints...");
      List<String> endpoints = [
        'https://oldmarket.bhoomi.cloud/api/products',
        'https://oldmarket.bhoomi.cloud/api/cars',
        'https://oldmarket.bhoomi.cloud/api/products',
      ];

      for (String endpoint in endpoints) {
        try {
          print("📡 Trying endpoint: $endpoint");
          final response = await http.get(Uri.parse(endpoint));
          print("📊 Response Status: ${response.statusCode}");

          if (response.statusCode == 200) {
            final jsonResponse = jsonDecode(response.body);
            List<DealerProduct> dealerProducts = [];

            // Handle different response structures
            List<dynamic> products = [];
            if (jsonResponse is List) {
              products = jsonResponse;
            } else if (jsonResponse is Map) {
              if (jsonResponse['data'] is List) {
                products = jsonResponse['data'];
              } else if (jsonResponse['products'] is List) {
                products = jsonResponse['products'];
              }
            }

            print("🔍 Processing ${products.length} products...");

            // Convert all products to dealer products for now (to show something)
            for (var product in products.take(10)) {
              // Take first 10 to avoid too many
              try {
                // Ensure required fields exist and handle complex types
                if (product is Map<String, dynamic>) {
                  // Handle dealerId field that might be a Map or String
                  if (product['dealerId'] is Map<String, dynamic>) {
                    final dealerIdMap =
                        product['dealerId'] as Map<String, dynamic>;
                    product['dealerId'] =
                        dealerIdMap['_id']?.toString() ?? 'dealer123';
                    product['dealerName'] =
                        dealerIdMap['businessName']?.toString() ??
                        dealerIdMap['name']?.toString() ??
                        'Dealer';
                    product['phone'] = dealerIdMap['phone']?.toString() ?? '';
                    product['dealerPhone'] =
                        dealerIdMap['phone']?.toString() ?? '';
                  } else {
                    product['dealerId'] =
                        product['dealerId']?.toString() ??
                        product['userId']?.toString() ??
                        'dealer123';
                    product['dealerName'] =
                        product['dealerName']?.toString() ??
                        product['userName']?.toString() ??
                        'Dealer';
                    // Handle phone from various fields
                    product['phone'] =
                        product['phone']?.toString() ??
                        product['phoneNumber']?.toString() ??
                        product['dealerPhone']?.toString() ??
                        '';
                    product['dealerPhone'] =
                        product['dealerPhone']?.toString() ??
                        product['phone']?.toString() ??
                        '';
                  }

                  product['sellerType'] =
                      product['sellerType']?.toString() ?? 'dealer';

                  // Ensure basic fields are strings
                  product['title'] =
                      product['title']?.toString() ?? 'Unknown Product';
                  product['description'] =
                      product['description']?.toString() ?? 'No description';

                  // Handle price as int
                  if (product['price'] is String) {
                    product['price'] = int.tryParse(product['price']) ?? 0;
                  } else {
                    product['price'] = product['price'] ?? 0;
                  }

                  // Handle arrays safely
                  if (product['tags'] is! List) {
                    product['tags'] = [];
                  }
                  if (product['images'] is! List) {
                    product['images'] = [];
                  }

                  dealerProducts.add(DealerProduct.fromJson(product));
                }
              } catch (e) {
                print("⚠️ Error parsing product: $e");
                print("⚠️ Product data: $product");
                continue;
              }
            }

            if (dealerProducts.isNotEmpty) {
              print(
                "✅ Found ${dealerProducts.length} dealer products from $endpoint",
              );
              return dealerProducts;
            }
          }
        } catch (e) {
          print("❌ Error with endpoint $endpoint: $e");
          continue;
        }
      }

      // If no endpoint works, return some dummy data for testing
      print("📦 No working endpoint found, returning dummy data for testing");
      return [
        DealerProduct.fromJson({
          '_id': 'dummy1',
          'title': 'Test Car 1',
          'description': 'Test description',
          'price': 500000,
          'dealerId': 'dealer123',
          'dealerName': 'Test Dealer',
          'sellerType': 'dealer',
          'tags': ['car', 'test'],
          'images': ['https://via.placeholder.com/300'],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }),
        DealerProduct.fromJson({
          '_id': 'dummy2',
          'title': 'Test Car 2',
          'description': 'Another test car',
          'price': 750000,
          'dealerId': 'dealer456',
          'dealerName': 'Another Dealer',
          'sellerType': 'dealer',
          'tags': ['car', 'luxury'],
          'images': ['https://via.placeholder.com/300'],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        }),
      ];
    } catch (e) {
      print("💥 fetchDealerProducts error: $e");
      throw Exception('Error fetching dealer products: $e');
    }
  }

  // Helper method to fetch cars from individual dealer
  static Future<List<DealerProduct>> _fetchDealerCars(String dealerId) async {
    try {
      final url =
          "https://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerId/cars";
      print("🚗 Fetching cars for dealer $dealerId from: $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final List<dynamic> carsData = jsonResponse['data'];
          return carsData
              .map((carJson) => DealerProduct.fromJson(carJson))
              .toList();
        }
      }

      return []; // Return empty list if no cars or API failed
    } catch (e) {
      print("⚠️ Error fetching cars for dealer $dealerId: $e");
      return []; // Return empty list on error
    }
  }

  // fetch all products description  of dealer
  Future<DealerProductDescriptionModel?> fetchDealerProductById(
    String productId,
  ) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/dealers/$productId',
    );

    try {
      print("📡 Fetching dealer product by ID: $productId");
      print("🌐 URL: $url");
      final response = await http.get(url);
      print("📊 Description API Status: ${response.statusCode}");
      print("📋 Description API Response: ${response.body}");

      if (response.statusCode == 200) {
        final parsed = dealerProductDescriptionModelFromJson(response.body);
        print("✅ Description parsed - Phone: ${parsed.data?.phone}");
        return parsed;
      } else {
        print('Failed to load dealer product: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching dealer product: $e');
      return null;
    }
  }

  //login ApiService - UPDATED with new API endpoints
  static const String baseUrl = 'https://oldmarket.bhoomi.cloud/api/auth';

  static Future<Map<String, dynamic>> login(
    String phone,
    String countryCode,
  ) async {
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone': phone, 'countryCode': countryCode});

    Logger.d('ApiService', 'Hitting URL: $url');
    Logger.d('ApiService', 'Sending body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);
      print("📊 Status Code: ${response.statusCode}");
      print("📨 Raw Response: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save any necessary data from the response
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // If there's a user object in response, save user ID (both keys) and update TokenController
        if (responseData['user'] != null &&
            responseData['user']['_id'] != null) {
          final String userId = responseData['user']['_id'];
          await prefs.setString('userId', userId);
          // also save under user_uid for TokenController compatibility
          await prefs.setString('user_uid', userId);
          Logger.d('ApiService', 'Saved userId: $userId');
          try {
            final TokenController tc = Get.find<TokenController>();
            await tc.saveUserInfo({
              'uid': userId,
              'email': responseData['user']['email'] ?? '',
              'displayName':
                  responseData['user']['name'] ??
                  responseData['user']['displayName'] ??
                  '',
              'photoURL': responseData['user']['photo'] ?? '',
            });
            Logger.d('ApiService', 'TokenController updated with user info');
          } catch (e) {
            print('⚠️ Could not update TokenController user info: $e');
          }
        }

        // If there's a token in response, save it and update TokenController
        if (responseData['token'] != null) {
          await prefs.setString('auth_token', responseData['token']);
          Logger.d('ApiService', 'Saved auth_token: ${responseData['token']}');
          try {
            final TokenController tc = Get.find<TokenController>();
            await tc.saveApiToken(responseData['token']);
            Logger.d('ApiService', 'TokenController saved API token');
          } catch (e) {
            print('⚠️ Could not update TokenController token: $e');
          }
        }

        return {
          'success': true,
          'message': responseData['message'] ?? 'OTP sent successfully',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login failed',
          'error': responseData,
        };
      }
    } catch (e) {
      print("❌ API ERROR: $e");
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'Exception occurred: $e',
      };
    }
  }

  //verify OTP - UPDATED with new API endpoint
  static Future<Map<String, dynamic>> verifyOtp(
    String phone,
    String otp,
  ) async {
    final url = Uri.parse('$baseUrl/verify-otp');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone': phone, 'otp': otp});

    print("🔗 Hitting URL: $url");
    print("📤 Sending body: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);
      Logger.d('ApiService', 'Status Code: ${response.statusCode}');
      Logger.d('ApiService', 'Raw Response: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save authentication data
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        // Save user data if available and update TokenController
        if (responseData['user'] != null) {
          final user = responseData['user'];
          if (user['_id'] != null) {
            await prefs.setString('userId', user['_id']);
            await prefs.setString('user_uid', user['_id']);
            print("💾 Saved userId: ${user['_id']}");
            try {
              final TokenController tc = Get.find<TokenController>();
              await tc.saveUserInfo({
                'uid': user['_id'],
                'email': user['email'] ?? '',
                'displayName': user['name'] ?? user['displayName'] ?? '',
                'photoURL': user['photo'] ?? '',
              });
              print('✅ TokenController updated with user info');
            } catch (e) {
              print('⚠️ Could not update TokenController user info: $e');
            }
          }
          if (user['phone'] != null) {
            await prefs.setString('phone', user['phone']);
            print("💾 Saved phone: ${user['phone']}");
          }
        }

        // Save token if available and update TokenController
        if (responseData['token'] != null) {
          await prefs.setString('auth_token', responseData['token']);
          print("💾 Saved auth_token: ${responseData['token']}");
          try {
            final TokenController tokenController = Get.find<TokenController>();
            await tokenController.saveApiToken(responseData['token']);
            print("💾 TokenController saved API token");
          } catch (e) {
            print("⚠️ Could not update TokenController: $e");
          }
        }

        // Mark as logged in
        await prefs.setBool('isLoggedIn', true);

        return {
          'success': true,
          'message': responseData['message'] ?? 'Login successful',
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed',
          'error': responseData,
        };
      }
    } catch (e) {
      print("❌ API ERROR: $e");
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'Exception occurred: $e',
      };
    }
  }

  //register/signup API - NEW
  static Future<Map<String, dynamic>> register({
    required String phone,
    required String countryCode,
    required String name,
    required String email,
    File? profileImage,
  }) async {
    final baseUrl = 'https://oldmarket.bhoomi.cloud/api/auth';
    final url = Uri.parse('$baseUrl/register');

    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', url);

      // Add form fields
      request.fields.addAll({
        'phone': phone,
        'countryCode': countryCode,
        'name': name,
        'email': email,
      });

      // Add profile image if provided
      if (profileImage != null) {
        String? mimeType = lookupMimeType(profileImage.path);
        var multipartFile = await http.MultipartFile.fromPath(
          'profileImage',
          profileImage.path,
          contentType: mimeType != null ? MediaType.parse(mimeType) : null,
        );
        request.files.add(multipartFile);
      }

      print("🔄 Sending signup request to: $url");
      print("📝 Request fields: ${request.fields}");
      print("📸 Profile image: ${profileImage?.path ?? 'No image'}");

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      Logger.d('ApiService', 'Signup Response Status: ${response.statusCode}');
      Logger.d('ApiService', 'Signup Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        return {
          'success': true,
          'message': responseData['message'] ?? 'Registration successful',
          'data': responseData,
        };
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registration failed',
          'error': responseData,
        };
      }
    } catch (e) {
      print("❌ SIGNUP API ERROR: $e");
      return {
        'success': false,
        'message': 'Network error occurred',
        'error': 'Exception occurred: $e',
      };
    }
  }

  //Make Offer ApiService
  static Future<MakeOfferResponseModel?> makeOffer({
    required String productId,
    required String buyerId,
    required int offerPrice,
  }) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/products/$productId/make-offer',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"buyerId": buyerId, "offerPrice": offerPrice}),
      );

      print("📩 Offer Request URL: $url");
      print(
        "📩 Offer Request Body: ${jsonEncode({"buyerId": buyerId, "offerPrice": offerPrice})}",
      );
      print("📩 Offer Response Status: ${response.statusCode}");
      print("📩 Offer Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MakeOfferResponseModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      print("Offer Exception: $e");
      return null;
    }
  }

  // Get All Products
  static const String baseUrl1 = "https://oldmarket.bhoomi.cloud/api";
  static Future<List<AllProductModel>> getAllProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl1/products?page=1&limit=100'),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final dynamic rawList = jsonData['data'];

      if (rawList is List) {
        // 🔥 DEBUG: Check first few products for phone numbers
        if (rawList.isNotEmpty) {
          print(
            '[ApiService] getAllProducts - Total products: ${rawList.length}',
          );
          for (int i = 0; i < (rawList.length > 3 ? 3 : rawList.length); i++) {
            final item = rawList[i];
            print(
              '[ApiService] Product $i: title="${item['title']}", phone="${item['phone']}", phoneNumber="${item['phoneNumber']}", userPhone="${item['userPhone']}"',
            );
          }
        }

        return rawList.map((item) => AllProductModel.fromJson(item)).toList();
      } else {
        throw Exception(
          'Expected list in JSON.data but got ${rawList.runtimeType}',
        );
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }

  // register dealer
  static String _getMimeSubtype(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith(".png")) return "png";
    if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "jpeg";
    return "jpeg"; // fallback
  }

  // 🔑 mapping functions (frontend → backend enums)
  static String mapDealerType(String input) {
    switch (input) {
      case "Cars":
        return "car";
      case "Motorcycles":
        return "motorcycle";
      case "Trucks":
        return "truck";
      case "Parts":
        return "parts";
      case "Other":
        return "other";
      default:
        return "other";
    }
  }

  static String mapPaymentMethod(String input) {
    switch (input) {
      case "Cash":
        return "cash";
      case "Credit Card":
        return "credit_card";
      case "Debit Card":
        return "debit_card";
      case "Bank Transfer":
        return "bank_transfer";
      case "Mobile Payment":
        return "mobile_payment";
      default:
        return "cash";
    }
  }

  // register dealer
  static Future<Map<String, dynamic>?> registerDealer({
    required String userId, // 👈 Add this
    required String businessName,
    required String registrationNumber,
    required String village,
    required String city,
    required String state,
    required String country,
    required String phone,
    required String email,
    required String businessAddress,
    required String dealerType, // 👈 Make sure you pass "cars" not "car"
    required String description,
    required String businessHours,
    required List<String> paymentMethods, // 👈 Make sure correct enums
    required File businessLogo,
    required List<File> businessPhotos,
  }) async {
    try {
      var uri = Uri.parse("$_baseUrl/register");
      var request = http.MultipartRequest("POST", uri);

      /// ----- Text Fields -----
      request.fields['userId'] = userId; // ✅ Required
      request.fields['businessName'] = businessName;
      request.fields['registrationNumber'] = registrationNumber;
      request.fields['village'] = village;
      request.fields['city'] = city;
      request.fields['state'] = state;
      request.fields['country'] = country;
      request.fields['phone'] = phone;
      request.fields['email'] = email;
      request.fields['businessAddress'] = businessAddress;
      request.fields['dealerType'] = dealerType; // e.g. "cars"
      request.fields['description'] = description;
      request.fields['businessHours'] = businessHours;

      /// ----- Payment Methods -----
      for (var method in paymentMethods) {
        request.fields['paymentMethods'] = method;
      }

      /// ----- Files -----
      request.files.add(
        await http.MultipartFile.fromPath(
          "businessLogo",
          businessLogo.path,
          contentType: MediaType("image", _getMimeSubtype(businessLogo.path)),
        ),
      );

      for (var photo in businessPhotos) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "businessPhotos",
            photo.path,
            contentType: MediaType("image", _getMimeSubtype(photo.path)),
          ),
        );
      }

      /// ----- Send Request -----
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
        "📩 Dealer Register Response: ${response.statusCode} -> ${response.body}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        /// Save DealerId in SharedPreferences
        if (data["data"] != null && data["data"]["_id"] != null) {
          String dealerId = data["data"]["_id"];
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString("dealerId", dealerId);

          print("✅ DealerId saved in SharedPreferences: $dealerId");
        }

        return data;
      } else {
        print("❌ Failed to register dealer: ${response.body}");
        return null;
      }
    } catch (e) {
      print("DealerService.registerDealer error: $e");
      return null;
    }
  }

  // Get Chats API (GET)
  static Future<List<Chat>> getChats(String userId) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/chat/user/$userId',
    );
    final response = await http.get(url);
    print("===========chat json data===== ${jsonDecode(response.body)}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'] == null) return [];

      List chatsData = jsonResponse['data'];

      return chatsData.map((e) {
        final chat = Chat.fromJson(e);

        // Product image ko properly extract करते हैं अगर Chat.fromJson में नहीं मिला
        String? finalProductImage = chat.productImage;

        if ((finalProductImage == null || finalProductImage.isEmpty) &&
            e['productId'] != null) {
          // productId के through product image nikalne ki कोशिश करते हैं
          final productData = e['productId'];
          if (productData is Map) {
            if (productData['mediaUrl'] is List &&
                (productData['mediaUrl'] as List).isNotEmpty) {
              finalProductImage = (productData['mediaUrl'] as List).first
                  ?.toString();
            } else if (productData['images'] is List &&
                (productData['images'] as List).isNotEmpty) {
              finalProductImage = (productData['images'] as List).first
                  ?.toString();
            } else if (productData['productImages'] is List &&
                (productData['productImages'] as List).isNotEmpty) {
              finalProductImage = (productData['productImages'] as List).first
                  ?.toString();
            }

            // URL formatting
            if (finalProductImage != null &&
                finalProductImage.isNotEmpty &&
                !finalProductImage.startsWith('http')) {
              finalProductImage =
                  'https://oldmarket.bhoomi.cloud/${finalProductImage.replaceAll('\\', '/')}';
            }
          }
        }

        return chat.copyWith(
          productImage:
              finalProductImage ?? e['productImage'] ?? chat.productImage,
          profilePicture: e['profilePicture'] ?? chat.profilePicture,
        );
      }).toList();
    } else {
      throw Exception('Failed to load chats: ${response.statusCode}');
    }
  }

  // Get Messages API (GET)
  static Future<List<Message>> getMessages(String chatId) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/chat/$chatId/messages',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse['data'] == null) return [];

      List messagesData = jsonResponse['data'];

      final messages = messagesData.map((e) => Message.fromJson(e)).toList();
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return messages;
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  }

  // Send Message API (POST)
  static Future<Message> sendMessage(
    String chatId,
    String senderId,
    String content,
  ) async {
    final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/chat/send');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      return Message.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  // Send Media API (POST) - For images, videos, and audio
  static Future<Message> sendMediaMessage({
    required String chatId,
    required String senderId,
    required File mediaFile,
  }) async {
    try {
      print('📤 [ChatMedia] Starting media upload...');
      print('📤 [ChatMedia] chatId: $chatId');
      print('📤 [ChatMedia] senderId: $senderId');
      print('📤 [ChatMedia] File path: ${mediaFile.path}');
      print('📤 [ChatMedia] File size: ${await mediaFile.length()} bytes');

      final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/chat/send');
      var request = http.MultipartRequest('POST', url);

      // Add fields
      request.fields['chatId'] = chatId;
      request.fields['senderId'] = senderId;

      print('📤 [ChatMedia] Request fields: ${request.fields}');

      // Detect MIME type
      final mimeType = lookupMimeType(mediaFile.path);
      print('📤 [ChatMedia] Detected MIME type: $mimeType');

      if (mimeType == null) {
        throw Exception('Could not determine file MIME type');
      }

      final mimeTypeData = mimeType.split('/');

      // Add media file
      var multipartFile = await http.MultipartFile.fromPath(
        'media',
        mediaFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      );

      request.files.add(multipartFile);
      print('📤 [ChatMedia] Added file to request: ${multipartFile.filename}');
      print('📤 [ChatMedia] File field name: media');
      print(
        '📤 [ChatMedia] Content-Type: ${mimeTypeData[0]}/${mimeTypeData[1]}',
      );

      print('📤 [ChatMedia] Sending request to: ${url.toString()}');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 [ChatMedia] Response status: ${response.statusCode}');
      print('📥 [ChatMedia] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print('✅ [ChatMedia] Media uploaded successfully!');
        print('✅ [ChatMedia] Response data: $jsonResponse');
        return Message.fromJson(jsonResponse['data']);
      } else {
        print(
          '❌ [ChatMedia] Upload failed with status: ${response.statusCode}',
        );
        print('❌ [ChatMedia] Error body: ${response.body}');
        throw Exception('Failed to send media: ${response.body}');
      }
    } catch (e) {
      print('❌ [ChatMedia] Exception during upload: $e');
      rethrow;
    }
  }

  // Start Chat API (POST)
  static Future<String> startChat(
    String productId,
    String buyerId,
    String sellerId,
  ) async {
    final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/chat/start');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'buyerId': buyerId,
        'sellerId': sellerId,
      }),
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['data'] != null && jsonResponse['data']['_id'] != null) {
        return jsonResponse['data']['_id'];
      } else {
        throw Exception('Chat ID not found in API response');
      }
    } else {
      throw Exception('Failed to start chat: ${response.body}');
    }
  }

  // dealer_make_offer api
  Future<Map<String, dynamic>?> dealerMakeOffer({
    required String productId,
    required String buyerId,
    required String sellerId,
    required int offerPrice,
  }) async {
    try {
      final url = Uri.parse(
        "https://oldmarket.bhoomi.cloud/api/products/dealer/$productId/offers",
      );
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"offerPrice": offerPrice, "userId": buyerId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        Get.snackbar("Error", "Failed to make offer: ${response.body}");
        return null;
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
      return null;
    }
  }

  // fetch all offers
  Future<Map<String, dynamic>?> fetchUserOffers(String productId) async {
    final url = Uri.parse(
      "https://oldmarket.bhoomi.cloud/api/products/$productId/offers",
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("fetchUserOffers Error: $e");
    }
    return null;
  }

  // Accept an offer
  Future<Map<String, dynamic>?> acceptUserOffer(
    String productId,
    String offerId,
  ) async {
    final url = Uri.parse(
      "https://oldmarket.bhoomi.cloud/api/products/$productId/offers/$offerId/accept",
    );

    try {
      final response = await http.put(url);

      print("Accept Offer API Response Code: ${response.statusCode}");
      print("Accept Offer API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Accept Offer API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Accept Offer Exception: $e");
      return null;
    }
  }

  // Reject an offer
  Future<Map<String, dynamic>?> rejectUserOffer(
    String productId,
    String offerId,
  ) async {
    final url = Uri.parse(
      "https://oldmarket.bhoomi.cloud/api/products/$productId/offers/$offerId/reject",
    );
    try {
      final response = await http.put(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print(" rejectUserOffer Error: $e");
    }
    return null;
  }

  // get all dealer offers

  static Future<List<UserOffer>> fetchDealerOffers(String productId) async {
    final uri = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/products/dealer/$productId/offers',
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'] as List;
      return data.map((e) => UserOffer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch offers');
    }
  }

  static Future<UserOffer> dealerAcceptOffer(
    String productId,
    String offerId,
  ) async {
    final uri = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/products/$productId/offer/accept',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'offerId': offerId}),
    );

    print("Accept Offer Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['acceptedOffer'] != null) {
        return UserOffer.fromJson(jsonResponse['acceptedOffer']);
      } else {
        throw Exception("Accepted offer data missing in response");
      }
    } else {
      throw Exception('Failed to accept offer');
    }
  }

  // Dealer Reject offer
  static Future<UserOffer> dealerRejectOffer(
    String productId,
    String offerId,
  ) async {
    final uri = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/products/$productId/offer/reject',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'offerId': offerId}),
    );

    print("Reject Offer Response: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['rejectedOffer'] != null) {
        return UserOffer.fromJson(jsonResponse['rejectedOffer']);
      } else {
        throw Exception("Rejected offer data missing in response");
      }
    } else {
      throw Exception('Failed to reject offer');
    }
  }

  // see all dealer testdrives
  static Future<List<BookTestDriveScreenModel>> fetchTestDrives(
    String productId,
  ) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/product/$productId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        print("🧪 Full JSON: $json");

        final rawList = (json['data'] is List) ? json['data'] as List : [];
        return rawList.map((e) {
          try {
            return BookTestDriveScreenModel.fromJson(e);
          } catch (err) {
            print(" Parsing error: $e → $err");
            return BookTestDriveScreenModel();
          }
        }).toList();
      } else {
        print(" API Error: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print(" Exception during API call: $e");
      return [];
    }
  }

  /// accept testdrive
  static Future<bool> acceptTestDrive(String testDriveId) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/test-drives/$testDriveId/accept',
    );
    try {
      final response = await http.put(url);
      print(" PUT $url → ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print(" Exception during accept: $e");
      return false;
    }
  }

  /// 🔧 Reject test drive
  static Future<bool> rejectTestDrive(String testDriveId) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/test-drives/$testDriveId/reject',
    );
    try {
      final response = await http.put(url);
      print("📡 PUT $url → ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print(" Exception during reject: $e");
      return false;
    }
  }

  /// 🔧 Unified method for controller
  static Future<bool> updateTestDriveStatus(
    String testDriveId,
    String status,
  ) async {
    if (status == "accept") {
      return await acceptTestDrive(testDriveId);
    } else if (status == "reject") {
      return await rejectTestDrive(testDriveId);
    } else {
      print("Invalid status: $status");
      return false;
    }
  }

  //user book test drive api
  static Future<BookTestDriveData?> userBookTestDrive({
    required String carId,
    required String name,
    required String phoneNumber,
    required String preferredDate,
    required String preferredTime,
  }) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/product/$carId/book-test-drive',
    );

    final body = {
      "name": name,
      "phone": phoneNumber,
      "date": preferredDate,
      "time": preferredTime,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return BookTestDriveData.fromJson(json['data']);
      } else {
        print(" API Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print(" Exception: $e");
      return null;
    }
  }

  // get all dealer bookings test drives
  static Future<List<BookTestDriveScreenModel>> fetchDealerTestDrives(
    String carId,
  ) async {
    final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/cars/car/$carId');

    print("📡 Dealer Test Drive API → GET $url");

    try {
      final response = await http.get(url);
      print(" Response Status: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> dataList = json["data"];
        return dataList
            .map((e) => BookTestDriveScreenModel.fromJson(e))
            .toList();
      } else {
        print(" Dealer Test Drive API Error: ${response.statusCode}");
        return [];
      }
    } catch (e, stack) {
      print(" Exception during dealer test drive fetch: $e");
      print(" Stack Trace:\n$stack");
      return [];
    }
  }

  /// Accept dealer test drive
  static Future<BookTestDriveScreenModel?> acceptDealerTestDrive(
    String bookingId,
  ) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/test-drives/$bookingId/accept',
    );
    print("📡 PUT $url → Accept Dealer Test Drive");

    try {
      final response = await http.put(url);
      print(" Response Status: ${response.statusCode}");
      print(" Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json["status"] == true && json["data"] != null) {
          return BookTestDriveScreenModel.fromJson(json["data"]);
        }
      }
      return null;
    } catch (e) {
      print("Error accepting dealer test drive: $e");
      return null;
    }
  }

  ///  Reject dealer test drive
  static Future<BookTestDriveScreenModel?> rejectDealerTestDrive(
    String bookingId,
  ) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/cars/test-drives/$bookingId/reject',
    );
    print(" PUT $url → Reject Dealer Test Drive");

    try {
      final response = await http.put(url);
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json["status"] == true && json["data"] != null) {
          return BookTestDriveScreenModel.fromJson(json["data"]);
        }
      }
      return null;
    } catch (e) {
      print("Error rejecting dealer test drive: $e");
      return null;
    }
  }

  /// 🔹 Unified method for controller
  static Future<BookTestDriveScreenModel?> updateDealerTestDriveStatus({
    required String bookingId,
    required String action, // "accept" or "reject"
  }) async {
    if (action == "accept") {
      return await acceptDealerTestDrive(bookingId);
    } else if (action == "reject") {
      return await rejectDealerTestDrive(bookingId);
    } else {
      print("Invalid action: $action");
      return null;
    }
  }

  static const String _fuelbaseUrl =
      "https://rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com/api/fuel-city";

  static const Map<String, String> _headers = {
    'x-rapidapi-host':
        'rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com',
    'x-rapidapi-key': '27205fbe49msh6b14a5fdcc37981p10eb35jsnfbe36ee70043',
  };

  Future<List<FuelModel>> fetchFuelPrices(String city, String state) async {
    final keyword = Uri.encodeComponent("$city,$state");
    final url = Uri.parse("$_fuelbaseUrl?keyword=$keyword");

    final response = await http.get(url, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => FuelModel.fromJson(e)).toList();
    } else {
      throw Exception("API Error: ${response.statusCode}");
    }
  }

  static const String _url =
      "https://rto-vehicle-information-india.p.rapidapi.com/getVehicleChallan";

  static const Map<String, String> _challanHeaders = {
    'Content-Type': 'application/json',
    'x-rapidapi-host': 'rto-vehicle-information-india.p.rapidapi.com',
    'x-rapidapi-key': '27205fbe49msh6b14a5fdcc37981p10eb35jsnfbe36ee70043',
  };

  Future<List<ChallanModel>> fetchChallan(String vehicleNo) async {
    final body = jsonEncode({
      "vehicleNo": vehicleNo,
      "consent": "Y",
      "consent_text":
          "I hereby give my consent for Eccentric Labs API to fetch my information",
    });

    print(" Sending API request for vehicleNo: $vehicleNo");

    final response = await http.post(
      Uri.parse(_url),
      headers: _challanHeaders,
      body: body,
    );

    print(" API Response Status: ${response.statusCode}");
    print(" API Raw Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List<dynamic> challans = decoded['data'] ?? [];

      print("API Success: ${challans.length} challan(s) received");

      return challans.map((e) => ChallanModel.fromJson(e)).toList();
    } else {
      print(" API Error: ${response.statusCode} - ${response.reasonPhrase}");
      throw Exception("API Error: ${response.statusCode}");
    }
  }

  static Future<Map<String, dynamic>?> getDealerStats(String dealerId) async {
    print("🔍 [API] getDealerStats called for dealerId: $dealerId");

    // Try multiple possible API endpoints for dealer stats
    final urls = [
      "https://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerId/stats",
      "https://oldmarket.bhoomi.cloud/api/dealers/$dealerId/stats",
      "https://oldmarket.bhoomi.cloud/api/dealers/stats/$dealerId",
      "https://oldmarket.bhoomi.cloud/api/dealers/profile/$dealerId",
    ];

    for (String url in urls) {
      try {
        print("🌐 [API] Trying URL: $url");
        final response = await http.get(Uri.parse(url));
        print("📥 [API] Response Status: ${response.statusCode} for $url");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print("📦 [API] Response Body: ${response.body}");

          if (data != null &&
              (data["status"] == true || data["data"] != null)) {
            print("✅ [API] Found dealer data at: $url");
            return data;
          }
        } else if (response.statusCode != 404) {
          print(
            "⚠️ [API] Non-404 error: ${response.statusCode} - ${response.body}",
          );
        }
      } catch (e) {
        print("❌ [API] Error with URL $url: $e");
      }
    }

    print("❌ [API] All URLs failed for dealerId: $dealerId");
    return null;
  }

  static Future<Map<String, dynamic>?> getDealerCars(String dealerId) async {
    print("🔍 [API] getDealerCars called for dealerId: $dealerId");
    final url =
        "https://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerId/cars";
    print("🌐 [API] URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📥 [API] Response Status: ${response.statusCode}");
      print("📦 [API] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("❌ [API] Error in getDealerCars: $e");
    }
    return null;
  }

  // -------------------- My Videos (user-specific) --------------------
  static Future<List<VideoModel>> getMyVideos() async {
    final tokenCtrl = Get.find<TokenController>();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (tokenCtrl.apiToken.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
    }

    print('[ApiService] getMyVideos called - prefer authenticated /videos/my');
    try {
      // First try the authenticated endpoint which the server owns and should
      // reliably return only the logged-in user's uploads.
      final authUrl = Uri.parse('$base/videos/my');
      print('[ApiService] GET $authUrl with headers: $headers');
      final authRes = await http.get(authUrl, headers: headers);
      print('[ApiService] Response (${authRes.statusCode}): ${authRes.body}');
      if (authRes.statusCode == 200) {
        try {
          final bodyAuth = jsonDecode(authRes.body) as Map<String, dynamic>;
          final dataAuth = bodyAuth['data'] as List<dynamic>? ?? [];
          var listAuth = dataAuth
              .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
              .toList();
          // Filter out any locally-hidden (blacklisted) ids so deleted-but-not-removed
          // server items don't reappear until server actually removes them.
          try {
            final prefs = await SharedPreferences.getInstance();
            final hidden = prefs.getStringList(_kLocallyDeletedVideosKey) ?? [];
            if (hidden.isNotEmpty) {
              listAuth = listAuth.where((v) => !hidden.contains(v.id)).toList();
              Logger.d(
                'ApiService',
                'getMyVideos filtered out ${hidden.length} locally-hidden videos',
              );
            }
          } catch (e) {
            print(
              '[ApiService] getMyVideos: could not read local blacklist: $e',
            );
          }
          Logger.d(
            'ApiService',
            'getMyVideos (auth) returned ${listAuth.length} items',
          );
          // If server returned items via authenticated endpoint, use them.
          if (listAuth.isNotEmpty) return listAuth;
          // If empty, fall through to userid-based fallback below.
        } catch (e) {
          print('[ApiService] Failed to parse /videos/my response: $e');
        }
      }

      // Fallback: attempt userid-based query (used by some older backends).
      final userId = await _getUserIdFromPrefsOrToken(tokenCtrl);
      if (userId.isNotEmpty) {
        final fbUrl = Uri.parse('$base/videos?userid=$userId');
        try {
          print('[ApiService] GET fallback $fbUrl with headers: $headers');
          final fbRes = await http.get(fbUrl, headers: headers);
          print(
            '[ApiService] Fallback Response (${fbRes.statusCode}): ${fbRes.body}',
          );
          if (fbRes.statusCode == 200) {
            final bodyFb = jsonDecode(fbRes.body) as Map<String, dynamic>;
            final dataFb = bodyFb['data'] as List<dynamic>? ?? [];

            // Defensive filter: ensure items really belong to this user. Some
            // servers return related items for a userid query; filter by
            // uploadedBy or uploader._id where possible.
            final filtered = <VideoModel>[];
            for (final item in dataFb) {
              try {
                final map = item as Map<String, dynamic>;
                var ownerId = '';
                if (map['uploadedBy'] is String) {
                  ownerId = map['uploadedBy'] as String;
                } else if (map['uploadedBy'] is Map &&
                    map['uploadedBy']['_id'] != null) {
                  ownerId = map['uploadedBy']['_id'].toString();
                } else if (map['uploader'] is Map &&
                    map['uploader']['_id'] != null) {
                  ownerId = map['uploader']['_id'].toString();
                } else if (map['uploader'] is String) {
                  ownerId = map['uploader'] as String;
                }

                if (ownerId.isEmpty || ownerId == userId) {
                  // If ownerId is empty we still include it — this is a best-effort
                  // fallback so we don't accidentally drop valid items, but we
                  // prefer the authenticated /videos/my path above.
                  filtered.add(VideoModel.fromJson(map));
                }
              } catch (e) {
                print('[ApiService] Skipping malformed video item: $e');
              }
            }

            // Apply local blacklist here too
            try {
              final prefs = await SharedPreferences.getInstance();
              final hidden =
                  prefs.getStringList(_kLocallyDeletedVideosKey) ?? [];
              if (hidden.isNotEmpty) {
                filtered.removeWhere((v) => hidden.contains(v.id));
                Logger.d(
                  'ApiService',
                  'getMyVideos fallback filtered out ${hidden.length} locally-hidden videos',
                );
              }
            } catch (e) {
              print(
                '[ApiService] getMyVideos fallback: could not read local blacklist: $e',
              );
            }
            Logger.d(
              'ApiService',
              'getMyVideos fallback returned ${filtered.length} items for userid=$userId',
            );
            return filtered;
          }
        } catch (e) {
          print('[ApiService] getMyVideos fallback error: $e');
        }
      } else {
        print('[ApiService] getMyVideos: no userId available for fallback');
      }

      // Nothing returned — return empty list
      apiLastError = 'Failed to load my videos';
      return <VideoModel>[];
    } catch (e, st) {
      print('[ApiService] getMyVideos error: $e');
      print(st);
      apiLastError = e.toString();
      return <VideoModel>[];
    }
  }

  /// Fetch videos for the currently logged-in user by user id using the
  /// short videos endpoint (GET /videos?userid=...). This ensures we only
  /// return videos uploaded by that user.
  static Future<List<VideoModel>> getVideosForCurrentUser() async {
    final tokenCtrl = Get.find<TokenController>();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (tokenCtrl.apiToken.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
    }

    try {
      final userId = await _getUserIdFromPrefsOrToken(tokenCtrl);
      if (userId.isEmpty) {
        print('[ApiService] getVideosForCurrentUser: no userId available');
        return <VideoModel>[];
      }
      final url = Uri.parse('$base/videos?userid=$userId');
      print('[ApiService] GET $url with headers: $headers');
      final response = await http.get(url, headers: headers);
      print('[ApiService] Response (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List<dynamic>? ?? [];
        final list = data
            .map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return list;
      }
      apiLastError = 'Failed to load user videos: ${response.statusCode}';
      return <VideoModel>[];
    } catch (e) {
      print('[ApiService] getVideosForCurrentUser error: $e');
      apiLastError = e.toString();
      return <VideoModel>[];
    }
  }

  static Future<bool> deleteVideoById(String videoId) async {
    final url = Uri.parse('$base/videos/$videoId');
    try {
      final tokenCtrl = Get.find<TokenController>();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (tokenCtrl.apiToken.value.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
      }
      print('[ApiService] DELETE $url');
      var response = await http.delete(url, headers: headers);
      print(
        '[ApiService] DELETE Response: ${response.statusCode} -> ${response.body}',
      );
      // Try to print JSON fields if possible for easier debugging
      try {
        final decoded = jsonDecode(response.body);
        print('[ApiService] DELETE parsed body: $decoded');
      } catch (e) {
        print('[ApiService] DELETE body not JSON: ${e}');
      }
      if (response.statusCode == 200 || response.statusCode == 204) {
        apiLastError = '';
        return true;
      }

      // Build a helpful apiLastError from server response
      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = body['message']?.toString() ?? '';
        final err = body['error']?.toString() ?? '';
        if (msg.isNotEmpty && err.isNotEmpty) {
          apiLastError = '$msg — $err';
        } else if (msg.isNotEmpty) {
          apiLastError = msg;
        } else if (err.isNotEmpty) {
          apiLastError = err;
        } else {
          apiLastError = response.body;
        }
      } catch (e) {
        apiLastError = response.body;
      }

      // If server returned a 5xx, treat as a server-side bug and avoid
      // repeatedly attempting fallback endpoints that are likely to fail.
      if (response.statusCode >= 500) {
        print(
          '[ApiService] Server error on delete (${response.statusCode}), will not attempt fallbacks. apiLastError=$apiLastError',
        );
        // Dump body for server team
        print('[ApiService] Server 5xx response body: ${response.body}');
        return false;
      }

      // Try a small set of alternative delete endpoints that some backends use
      final fallbackPaths = [
        Uri.parse('$base/videos/$videoId/delete'),
        Uri.parse('$base/videos/my/$videoId'),
        Uri.parse('$base/videos/my/$videoId/delete'),
      ];

      for (final fb in fallbackPaths) {
        try {
          print(
            '[ApiService] Attempting fallback DELETE $fb with headers: $headers',
          );
          final fbRes = await http.delete(fb, headers: headers);
          print(
            '[ApiService] Fallback DELETE Response: ${fbRes.statusCode} -> ${fbRes.body}',
          );
          try {
            final fbDecoded = jsonDecode(fbRes.body);
            print('[ApiService] Fallback parsed body: $fbDecoded');
          } catch (_) {}
          if (fbRes.statusCode == 200 || fbRes.statusCode == 204) {
            apiLastError = '';
            return true;
          } else {
            try {
              final b = jsonDecode(fbRes.body) as Map<String, dynamic>;
              apiLastError =
                  b['message']?.toString() ??
                  b['error']?.toString() ??
                  fbRes.body;
            } catch (e) {
              apiLastError = fbRes.body;
            }
          }
        } catch (e) {
          print('[ApiService] Fallback delete $fb error: $e');
        }
      }

      return false;
    } catch (e) {
      print('[ApiService] deleteVideoById error: $e');
      apiLastError = e.toString();
      return false;
    }
  }

  // Pending delete queue: store video IDs that failed deletion and retry
  // in the background with exponential backoff. Track attempt counts to
  // avoid infinite retries for permanent server-side errors.
  static final Map<String, int> _pendingDeletes = <String, int>{};

  static void enqueueDelete(String videoId) {
    if (_pendingDeletes.containsKey(videoId)) return;
    _pendingDeletes[videoId] = 0;
    _processPendingDeletes();
  }

  static void cancelPendingDelete(String videoId) {
    if (_pendingDeletes.containsKey(videoId)) {
      _pendingDeletes.remove(videoId);
      print('[ApiService] Pending delete cancelled for $videoId');
    }
  }

  static Future<void> _processPendingDeletes() async {
    if (_pendingDeletes.isEmpty) return;

    // We'll process a copy of keys to avoid concurrent modification issues.
    final keys = _pendingDeletes.keys.toList();
    for (final id in keys) {
      int attempt = _pendingDeletes[id] ?? 0;
      bool success = false;
      while (attempt < 4 && !success && _pendingDeletes.containsKey(id)) {
        attempt++;
        _pendingDeletes[id] = attempt;
        print('[ApiService] Retrying delete for $id (attempt $attempt)');
        try {
          final ok = await deleteVideoById(id);
          if (ok) {
            success = true;
            print('[ApiService] Background delete succeeded for $id');
            _pendingDeletes.remove(id);
            break;
          } else {
            // If apiLastError indicates a server-side 5xx bug, stop retrying.
            if (apiLastError.isNotEmpty &&
                apiLastError.contains('Cannot read properties')) {
              print(
                '[ApiService] Permanent server error detected for $id: $apiLastError; stopping retries.',
              );
              _pendingDeletes.remove(id);
              break;
            }
          }
        } catch (e) {
          print('[ApiService] Background delete error for $id: $e');
        }

        // exponential backoff (increasing delay) between attempts
        final delaySeconds = 2 * attempt;
        await Future.delayed(Duration(seconds: delaySeconds));
      }

      if (!success && _pendingDeletes.containsKey(id)) {
        print(
          '[ApiService] Background delete failed permanently for $id after $attempt attempts',
        );
        // Add to local blacklist so it doesn't reappear in user lists until
        // the backend actually deletes it.
        try {
          final prefs = await SharedPreferences.getInstance();
          final hidden = prefs.getStringList(_kLocallyDeletedVideosKey) ?? [];
          if (!hidden.contains(id)) {
            hidden.add(id);
            await prefs.setStringList(_kLocallyDeletedVideosKey, hidden);
            print('[ApiService] Added $id to local deleted blacklist');
          }
        } catch (e) {
          print('[ApiService] Could not write local blacklist for $id: $e');
        }
        _pendingDeletes.remove(id);
      }
    }
  }

  // -------------------- My Products (user-specific) --------------------
  static Future<List<AllProductModel>> getMyProducts() async {
    final tokenCtrl = Get.find<TokenController>();
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (tokenCtrl.apiToken.value.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
    }

    // First, get current logged-in user ID for proper filtering
    final userId = await _getUserIdFromPrefsOrToken(tokenCtrl);
    print(
      '🔍 [getMyProducts] Starting. userId: $userId, token present: ${tokenCtrl.apiToken.value.isNotEmpty}',
    );

    if (userId.isEmpty) {
      print(
        '⚠️ [getMyProducts] No userId available - cannot filter user products',
      );
      apiLastError = 'User not logged in';
      return <AllProductModel>[];
    }

    // Try primary authenticated endpoint first
    final url = Uri.parse('$base/products/my');
    try {
      print('[ApiService] GET $url with headers: $headers');
      final response = await http.get(url, headers: headers);
      print('[ApiService] Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'] as List<dynamic>? ?? [];
        Logger.d(
          'ApiService',
          'getMyProducts: server returned ${data.length} items',
        );

        if (data.isNotEmpty) {
          // 🔍🔍 DEBUG: Print raw location data from first product
          if (data.isNotEmpty && data[0] is Map) {
            final firstRaw = data[0] as Map<String, dynamic>;
            print('🔍🔍🔍 [ApiService] RAW First Product JSON:');
            print('   Title: ${firstRaw['title']}');
            print('   Location field: ${firstRaw['location']}');
            print('   City field: ${firstRaw['city']}');
            print('   State field: ${firstRaw['state']}');
            print('   Country field: ${firstRaw['country']}');
          }

          final list = data
              .map((e) => AllProductModel.fromJson(e as Map<String, dynamic>))
              .toList();

          // Double-check: Filter by userId to ensure we only get current user's products
          final filteredList = list.where((product) {
            return product.userId == userId ||
                product.userId == userId.toString() ||
                (product.userId.isNotEmpty && product.userId.contains(userId));
          }).toList();

          Logger.d(
            'ApiService',
            'getMyProducts filtered from ${list.length} to ${filteredList.length} items for userId=$userId',
          );
          return filteredList;
        }

        Logger.d(
          'ApiService',
          'getMyProducts returned 0 items, attempting userid fallback',
        );
      }
    } catch (e) {
      print('[ApiService] getMyProducts primary endpoint error: $e');
    }

    // Fallback: Get all products and filter by userId
    try {
      print(
        '[ApiService] Fallback: Getting all products and filtering by userId=$userId',
      );
      final allProducts = await getAllProducts();

      final filteredProducts = allProducts.where((product) {
        // Multiple checks to ensure proper filtering
        bool isMyProduct = false;

        // Check direct userId match
        if (product.userId == userId || product.userId == userId.toString()) {
          isMyProduct = true;
        }

        // Check if userId is contained in the product's userId field
        if (!isMyProduct &&
            product.userId.isNotEmpty &&
            product.userId.contains(userId)) {
          isMyProduct = true;
        }

        // Additional debugging
        if (isMyProduct) {
          print(
            '[ApiService] Found my product: ${product.title} (userId: ${product.userId})',
          );
        }

        return isMyProduct;
      }).toList();

      Logger.d(
        'ApiService',
        'getMyProducts fallback filtered ${filteredProducts.length} products from ${allProducts.length} total for userId=$userId',
      );

      return filteredProducts;
    } catch (e) {
      print('[ApiService] getMyProducts fallback error: $e');
      apiLastError = 'Failed to load my products: $e';
      return <AllProductModel>[];
    }
  }

  /// Helper: try to get user id from SharedPreferences (user_uid/userId) or decode it from JWT token
  static Future<String> _getUserIdFromPrefsOrToken(
    TokenController tokenCtrl,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId =
          prefs.getString('userId') ?? prefs.getString('user_uid') ?? '';
      if (userId.isNotEmpty) return userId;

      final token = tokenCtrl.apiToken.value;
      if (token.isNotEmpty) {
        try {
          final parts = token.split('.');
          if (parts.length >= 2) {
            final payload = parts[1];
            final normalized = base64.normalize(payload);
            final decoded = utf8.decode(base64.decode(normalized));
            final Map<String, dynamic> jwt = jsonDecode(decoded);
            userId =
                jwt['id'] ??
                jwt['uid'] ??
                jwt['_id'] ??
                jwt['userId'] ??
                jwt['userid'] ??
                '';
            if (userId.isNotEmpty) {
              await prefs.setString('userId', userId);
              await prefs.setString('user_uid', userId);
              return userId;
            }
          }
        } catch (e) {
          print('[ApiService] Failed to decode token for userId: $e');
        }
      }
    } catch (e) {
      print('[ApiService] _getUserIdFromPrefsOrToken error: $e');
    }
    return '';
  }

  static Future<bool> deleteMyProduct(String productId) async {
    final url = Uri.parse('$base/products/my/$productId');
    try {
      final tokenCtrl = Get.find<TokenController>();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (tokenCtrl.apiToken.value.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
      }
      print('[ApiService] DELETE $url');
      var response = await http.delete(url, headers: headers);
      print(
        '[ApiService] DELETE Response: ${response.statusCode} -> ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        apiLastError = '';
        return true;
      }

      try {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final msg = body['message']?.toString() ?? '';
        final err = body['error']?.toString() ?? '';
        if (msg.isNotEmpty && err.isNotEmpty) {
          apiLastError = '$msg — $err';
        } else if (msg.isNotEmpty) {
          apiLastError = msg;
        } else if (err.isNotEmpty) {
          apiLastError = err;
        } else {
          apiLastError = response.body;
        }
      } catch (e) {
        apiLastError = response.body;
      }

      final fallbackPaths = [
        Uri.parse('$base/products/$productId'),
        Uri.parse('$base/products/$productId/delete'),
        Uri.parse('$base/products/my/$productId/delete'),
      ];

      for (final fb in fallbackPaths) {
        try {
          print('[ApiService] Attempting fallback DELETE $fb');
          final fbRes = await http.delete(fb, headers: headers);
          print(
            '[ApiService] Fallback DELETE Response: ${fbRes.statusCode} -> ${fbRes.body}',
          );
          if (fbRes.statusCode == 200 || fbRes.statusCode == 204) {
            apiLastError = '';
            return true;
          } else {
            try {
              final b = jsonDecode(fbRes.body) as Map<String, dynamic>;
              apiLastError =
                  b['message']?.toString() ??
                  b['error']?.toString() ??
                  fbRes.body;
            } catch (e) {
              apiLastError = fbRes.body;
            }
          }
        } catch (e) {
          print('[ApiService] Fallback delete $fb error: $e');
        }
      }

      return false;
    } catch (e) {
      print('[ApiService] deleteMyProduct error: $e');
      return false;
    }
  }

  /// Edit/update a product by id. `updates` should be a JSON-serializable map of fields to update.
  static Future<bool> editProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    // Use the "my" namespace as primary to match the server curl example
    // and ensure the request is routed to the user's own product resource.
    final url = Uri.parse('$base/products/my/$productId');
    final body = jsonEncode(updates);
    try {
      final tokenCtrl = Get.find<TokenController>();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (tokenCtrl.apiToken.value.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
      }

      // Primary attempt: PUT
      print('[ApiService] PUT $url');
      print('[ApiService] Request headers: $headers');
      print('[ApiService] Request body: $body');
      var response = await http.put(url, headers: headers, body: body);
      print(
        '[ApiService] PUT Response: ${response.statusCode} -> ${response.body}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        apiLastError = '';
        return true;
      }

      // If PUT not accepted, try PATCH on same URL (many servers use PATCH for partial updates)
      try {
        print('[ApiService] Attempting PATCH $url');
        final patchRes = await http.patch(url, headers: headers, body: body);
        print(
          '[ApiService] PATCH Response: ${patchRes.statusCode} -> ${patchRes.body}',
        );
        if (patchRes.statusCode == 200 || patchRes.statusCode == 201) {
          apiLastError = '';
          return true;
        }
      } catch (e) {
        print('[ApiService] PATCH attempt error: $e');
      }

      // Try fallback endpoint patterns that some backends use
      final fallbackPaths = [
        Uri.parse('$base/products/$productId/edit'),
        Uri.parse('$base/products/$productId/update'),
        Uri.parse('$base/products/my/$productId'),
        Uri.parse('$base/products/my/$productId/update'),
        Uri.parse('$base/products/$productId/patch'),
      ];

      for (final fb in fallbackPaths) {
        try {
          print('[ApiService] Attempting PATCH fallback $fb');
          final fbPatch = await http.patch(fb, headers: headers, body: body);
          print(
            '[ApiService] Fallback PATCH ${fb} -> ${fbPatch.statusCode} -> ${fbPatch.body}',
          );
          if (fbPatch.statusCode == 200 || fbPatch.statusCode == 201) {
            apiLastError = '';
            return true;
          }
        } catch (e) {
          print('[ApiService] Fallback PATCH $fb error: $e');
        }

        try {
          print('[ApiService] Attempting POST fallback $fb');
          final fbPost = await http.post(fb, headers: headers, body: body);
          print(
            '[ApiService] Fallback POST ${fb} -> ${fbPost.statusCode} -> ${fbPost.body}',
          );
          if (fbPost.statusCode == 200 || fbPost.statusCode == 201) {
            apiLastError = '';
            return true;
          }
        } catch (e) {
          print('[ApiService] Fallback POST $fb error: $e');
        }
      }

      // All attempts failed: capture helpful message
      try {
        final Map<String, dynamic> b = jsonDecode(response.body);
        apiLastError =
            b['message']?.toString() ?? b['error']?.toString() ?? response.body;
      } catch (e) {
        apiLastError = response.body;
      }
      return false;
    } catch (e) {
      print('[ApiService] editProduct error: $e');
      apiLastError = e.toString();
      return false;
    }
  }

  // -------------------- Dealer delete car --------------------
  static Future<bool> deleteDealerCar(String dealerType, String carId) async {
    // expects URL: /api/dealers/dealer/{dealerType}/{carId}/delete or similar per your cURL
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerType/$carId/delete',
    );
    try {
      final tokenCtrl = Get.find<TokenController>();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (tokenCtrl.apiToken.value.isNotEmpty) {
        headers['Authorization'] = 'Bearer ${tokenCtrl.apiToken.value}';
      }
      print('[ApiService] DELETE $url');
      final response = await http.delete(url, headers: headers);
      print(
        '[ApiService] DELETE Response: ${response.statusCode} -> ${response.body}',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[ApiService] deleteDealerCar error: $e');
      return false;
    }
  }

  /// Get all dealer cars from all dealers
  static Future<Map<String, dynamic>?> getAllDealerCars() async {
    print("🔍 [API] getAllDealerCars called");
    final url = "https://oldmarket.bhoomi.cloud/api/dealers/dealer/cars";
    print("🌐 [API] URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📥 [API] Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("📊 [API] Successfully fetched dealer cars");
        return data;
      } else {
        print("❌ [API] Failed with status: ${response.statusCode}");
        print("❌ [API] Response body: ${response.body}");
      }
    } catch (e) {
      print("❌ [API] Error in getAllDealerCars: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getAllDealers() async {
    print("🔍 [API] getAllDealers called");
    final url = "https://oldmarket.bhoomi.cloud/api/dealers/profiles";
    print("🌐 [API] URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📥 [API] Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          "📊 [API] Successfully fetched ${(data['data'] as List?)?.length ?? 0} dealers",
        );
        return data;
      } else {
        print("❌ [API] Failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [API] Error in getAllDealers: $e");
    }
    return null;
  }

  /// Get products by location filter (city, state, country)
  static Future<Map<String, dynamic>?> getProductsByLocation({
    String? country,
    String? state,
    String? city,
  }) async {
    print("🔍 [API] getProductsByLocation called");

    // Build query parameters
    List<String> queryParams = [];
    if (country != null && country.isNotEmpty) {
      queryParams.add('country=${Uri.encodeComponent(country)}');
    }
    if (state != null && state.isNotEmpty) {
      queryParams.add('state=${Uri.encodeComponent(state)}');
    }
    if (city != null && city.isNotEmpty) {
      queryParams.add('city=${Uri.encodeComponent(city)}');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';
    final url =
        "https://oldmarket.bhoomi.cloud/api/products/filter/location$queryString";
    print("🌐 [API] URL: $url");

    // Try multiple times with different timeouts
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        print("🔄 [API] Attempt $attempt/3");

        final response = await http
            .get(
              Uri.parse(url),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            )
            .timeout(
              Duration(seconds: 10 + (attempt * 5)),
            ); // Increasing timeout

        print("📥 [API] Response Status: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print(
            "📊 [API] Successfully fetched products by location - ${data['count']} items",
          );
          return data;
        } else {
          print("❌ [API] Failed with status: ${response.statusCode}");
          if (attempt == 3) {
            print("❌ [API] Response body: ${response.body}");
          }
        }
      } catch (e) {
        print("❌ [API] Attempt $attempt failed: $e");
        if (attempt == 3) {
          print("❌ [API] All attempts failed for getProductsByLocation");
        } else {
          print("🔄 [API] Retrying in ${attempt} seconds...");
          await Future.delayed(Duration(seconds: attempt));
        }
      }
    }
    return null;
  }

  /// Try to fetch a user's public profile by id using several common endpoints.
  /// Returns a parsed Map or null if not found.
  static Future<Map<String, dynamic>?> fetchUserProfile(String userId) async {
    // Try several common endpoints and both https/http variants. Some servers
    // expose the user resource under slightly different paths or on http.
    final candidates = [
      // Primary variants (https)
      'https://oldmarket.bhoomi.cloud/api/users/$userId',
      'https://oldmarket.bhoomi.cloud/api/user/$userId',
      'https://oldmarket.bhoomi.cloud/api/auth/user/$userId',
      'https://oldmarket.bhoomi.cloud/api/auth/users/$userId',
      // HTTP fallbacks
      'https://oldmarket.bhoomi.cloud/api/users/$userId',
      'https://oldmarket.bhoomi.cloud/api/user/$userId',
      'https://oldmarket.bhoomi.cloud/api/auth/user/$userId',
      'https://oldmarket.bhoomi.cloud/api/auth/users/$userId',
      // Extra common patterns
      'https://oldmarket.bhoomi.cloud/api/users/get/$userId',
      'https://oldmarket.bhoomi.cloud/api/users/get/$userId',
      'https://oldmarket.bhoomi.cloud/api/users/getUser/$userId',
      'https://oldmarket.bhoomi.cloud/api/users/getUser/$userId',
    ];

    for (final url in candidates) {
      try {
        print('[ApiService] Trying user profile GET $url');
        final res = await http.get(Uri.parse(url));
        print('[ApiService] Response (${res.statusCode}): ${res.body}');
        if (res.statusCode == 200) {
          try {
            final body = jsonDecode(res.body);
            // many endpoints return data under 'data' or directly the object
            if (body is Map && body['data'] != null) {
              final d = body['data'];
              if (d is Map<String, dynamic>) return d;
              if (d is List && d.isNotEmpty && d[0] is Map) return d[0];
            }
            if (body is Map<String, dynamic>) return body;
          } catch (e) {
            print('[ApiService] parse error for $url: $e');
            continue;
          }
        }
      } catch (e) {
        print('[ApiService] fetchUserProfile $url error: $e');
      }
    }
    return null;
  }

  /// Try to resolve the author information for a comment id by querying
  /// several plausible endpoints. This is a best-effort fallback used when
  /// the comment object returned by the videos API doesn't include the
  /// commenter info (user/userId). Returns the resolved user map or null.
  static Future<Map<String, dynamic>?> fetchCommentAuthor(
    String commentId,
  ) async {
    final candidates = [
      'https://oldmarket.bhoomi.cloud/api/comments/$commentId',
      'https://oldmarket.bhoomi.cloud/api/comment/$commentId',
      'https://oldmarket.bhoomi.cloud/api/videos/comments/$commentId',
      'https://oldmarket.bhoomi.cloud/api/videos/comment/$commentId',
      'https://oldmarket.bhoomi.cloud/api/comments/$commentId/author',
      'https://oldmarket.bhoomi.cloud/api/comments/$commentId/user',
    ];

    for (final url in candidates) {
      try {
        print('[ApiService] Trying comment author GET $url');
        final res = await http.get(Uri.parse(url));
        print('[ApiService] Response (${res.statusCode}): ${res.body}');
        if (res.statusCode == 200) {
          try {
            final body = jsonDecode(res.body);
            // Many endpoints wrap result under 'data'
            dynamic data;
            if (body is Map && body['data'] != null)
              data = body['data'];
            else
              data = body;

            if (data == null) continue;

            // If endpoint returned a comment object containing a nested user
            if (data is Map && data['user'] != null) {
              final u = data['user'];
              if (u is Map<String, dynamic>) return u;
              // if user is id string, try fetchUserProfile
              if (u is String && u.isNotEmpty) return await fetchUserProfile(u);
            }

            // If endpoint returned a comment object with userId field
            if (data is Map && data['userId'] != null) {
              final uid = data['userId'].toString();
              if (uid.isNotEmpty) return await fetchUserProfile(uid);
            }

            // Some endpoints might directly return the author object under 'author' or 'createdBy'
            if (data is Map && data['author'] != null && data['author'] is Map)
              return data['author'] as Map<String, dynamic>;
            if (data is Map &&
                data['createdBy'] != null &&
                data['createdBy'] is Map)
              return data['createdBy'] as Map<String, dynamic>;

            // If the endpoint returned a user object directly
            if (data is Map &&
                (data['name'] != null ||
                    data['profileImage'] != null ||
                    data['_id'] != null)) {
              return data as Map<String, dynamic>;
            }

            // If the endpoint returned a list, try to pick the first map with user-like fields
            if (data is List && data.isNotEmpty) {
              for (final item in data) {
                if (item is Map &&
                    (item['name'] != null ||
                        item['profileImage'] != null ||
                        item['_id'] != null))
                  return item as Map<String, dynamic>;
              }
            }
          } catch (e) {
            print('[ApiService] parse error for $url: $e');
            continue;
          }
        }
      } catch (e) {
        print('[ApiService] fetchCommentAuthor $url error: $e');
      }
    }
    return null;
  }

  //RC Check

  // rc_api_service.dart

  static Future<Map<String, dynamic>?> fetchRcDetails(String vehicleNo) async {
    print("🚀 [RC API] Starting fetch for vehicle: $vehicleNo");

    final uri = Uri.parse(
      "https://rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com/api/rc-vehicle/search-data?vehicle_no=$vehicleNo",
    );

    print("🌐 [RC API] Request URI: $uri");

    final response = await http.get(
      uri,
      headers: {
        "X-RapidAPI-Key": "YOUR_RAPIDAPI_KEY", // ✅ Replace with actual key
        "X-RapidAPI-Host":
            "rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com",
      },
    );

    print("📥 [RC API] Response Status: ${response.statusCode}");
    print("📦 [RC API] Response Body: ${response.body}");

    try {
      final decoded = json.decode(response.body);
      print("✅ [RC API] Decoded JSON: $decoded");

      if (response.statusCode == 200) {
        final data = decoded["data"];
        print("📊 [RC API] Extracted Data: $data");
        return data;
      } else {
        final message = decoded["message"] ?? "Unknown error occurred";
        print("⚠️ [RC API] Error Message: $message");
        Get.snackbar(
          "RC API Error",
          message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      print("❌ [RC API] JSON Decode Error: $e");
      Get.snackbar(
        "RC API Error",
        "Invalid response format",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  static Future<http.Response> fetchRcRawResponse(String vehicleNo) async {
    Logger.d('ApiService', 'fetchRcRawResponse called for vehicle: $vehicleNo');
    final uri = Uri.parse(
      "https://rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com/api/rc-vehicle/search-data?vehicle_no=$vehicleNo",
    );

    Logger.d('ApiService', 'RC API Request URI: $uri');

    final response = await http.get(
      uri,
      headers: {
        "X-RapidAPI-Key": "27205fbe49msh6b14a5fdcc37981p10eb35jsnfbe36ee70043",
        "X-RapidAPI-Host":
            "rto-vehicle-details-rc-puc-insurance-mparivahan.p.rapidapi.com",
      },
    );

    Logger.d('ApiService', 'RC API Response Status: ${response.statusCode}');
    Logger.d(
      'ApiService',
      'RC API Response Body length: ${response.body.length}',
    );
    return response;
  }

  static Map<String, dynamic> decodeJson(String body) {
    Logger.d(
      'ApiService',
      'decodeJson called with body length: ${body.length}',
    );
    try {
      final decoded = json.decode(body);
      Logger.d('ApiService', 'JSON decode successful');
      return decoded;
    } catch (e) {
      Logger.e('ApiService', 'JSON Decode Error: $e');
      Logger.e('ApiService', 'Body content: $body');
      return {};
    }
  }

  // ============ COMMENT APIs ============

  /// Add comment on product
  static Future<Map<String, dynamic>?> addCommentOnProduct({
    required String userId,
    required String productId,
    required String comment,
  }) async {
    print('\n🌐 [ApiService.addCommentOnProduct] START');
    print('API Parameters:');
    print('  - userId: $userId');
    print('  - productId: $productId');
    print('  - comment: "$comment"');

    try {
      final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/comments/add');
      print('📍 API URL: $url');

      final requestBody = {
        'userId': userId,
        'targetType': 'product',
        'targetId': productId,
        'comment': comment,
      };
      print('📦 Request Body: $requestBody');
      print('📦 Request Body JSON: ${json.encode(requestBody)}');

      print('🚀 Sending POST request...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📥 Response received:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Headers: ${response.headers}');
      print('  - Body: ${response.body}');
      print('  - Body length: ${response.body.length}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Success! Decoding response...');
        final decodedResponse = json.decode(response.body);
        print('📄 Decoded Response: $decodedResponse');
        print('🌐 [ApiService.addCommentOnProduct] END - SUCCESS\n');
        return decodedResponse;
      } else {
        print('❌ Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('🌐 [ApiService.addCommentOnProduct] END - FAILURE\n');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in addCommentOnProduct:');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('🌐 [ApiService.addCommentOnProduct] END - EXCEPTION\n');
      return null;
    }
  }

  /// Get comments for product
  static Future<Map<String, dynamic>?> getProductComments({
    required String productId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('[ApiService] 📖 Fetching comments for product: $productId');
      final response = await http.get(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/comments/product/$productId?page=$page&limit=$limit',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print('[ApiService] Get comments response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('[ApiService] ❌ Get comments failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ApiService] ❌ Get comments error: $e');
      return null;
    }
  }

  /// Add comment on car (dealer product)
  static Future<Map<String, dynamic>?> addCommentOnCar({
    required String userId,
    required String carId,
    required String comment,
  }) async {
    print('\n🌐 [ApiService.addCommentOnCar] START');
    print('API Parameters:');
    print('  - userId: $userId');
    print('  - carId: $carId');
    print('  - comment: "$comment"');

    try {
      final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/comments/add');
      print('📍 API URL: $url');

      final requestBody = {
        'userId': userId,
        'targetType': 'car',
        'targetId': carId,
        'comment': comment,
      };
      print('📦 Request Body: $requestBody');
      print('📦 Request Body JSON: ${json.encode(requestBody)}');

      print('🚀 Sending POST request...');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('📥 Response received:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Headers: ${response.headers}');
      print('  - Body: ${response.body}');
      print('  - Body length: ${response.body.length}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Success! Decoding response...');
        final decodedResponse = json.decode(response.body);
        print('📄 Decoded Response: $decodedResponse');
        print('🌐 [ApiService.addCommentOnCar] END - SUCCESS\n');
        return decodedResponse;
      } else {
        print('❌ Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('🌐 [ApiService.addCommentOnCar] END - FAILURE\n');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in addCommentOnCar:');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('🌐 [ApiService.addCommentOnCar] END - EXCEPTION\n');
      return null;
    }
  }

  /// Get comments for car (dealer product)
  static Future<Map<String, dynamic>?> getCarComments({
    required String carId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('[ApiService] 📖 Fetching comments for car: $carId');
      final response = await http.get(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/comments/car/$carId?page=$page&limit=$limit',
        ),
        headers: {'Content-Type': 'application/json'},
      );

      print('[ApiService] Get comments response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('[ApiService] ❌ Get comments failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ApiService] ❌ Get comments error: $e');
      return null;
    }
  }

  /// Delete comment
  static Future<bool> deleteComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      print('[ApiService] 🗑️ Deleting comment: $commentId');
      final response = await http.delete(
        Uri.parse('https://oldmarket.bhoomi.cloud/api/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId}),
      );

      print('[ApiService] Delete comment response: ${response.statusCode}');
      if (response.statusCode == 200) {
        return true;
      } else {
        print('[ApiService] ❌ Delete comment failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ApiService] ❌ Delete comment error: $e');
      return false;
    }
  }

  /// Edit comment
  static Future<Map<String, dynamic>?> editComment({
    required String commentId,
    required String userId,
    required String comment,
  }) async {
    try {
      print('[ApiService] ✏️ Editing comment: $commentId');
      final response = await http.put(
        Uri.parse('https://oldmarket.bhoomi.cloud/api/comments/$commentId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userId': userId, 'comment': comment}),
      );

      print('[ApiService] Edit comment response: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[ApiService] ✅ Comment edited successfully');
        return data;
      } else {
        print('[ApiService] ❌ Edit comment failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ApiService] ❌ Edit comment error: $e');
      return null;
    }
  }

  /// Reply to comment
  static Future<Map<String, dynamic>?> replyToComment({
    required String parentCommentId,
    required String userId,
    required String comment,
    required String targetType,
    required String targetId,
  }) async {
    try {
      print('[ApiService] 💬 Replying to comment: $parentCommentId');

      final requestBody = {
        'userId': userId,
        'comment': comment,
        'targetType': targetType,
        'targetId': targetId,
        'parentCommentId': parentCommentId,
      };

      print('[ApiService] 📤 Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://oldmarket.bhoomi.cloud/api/comments/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('[ApiService] Reply comment response: ${response.statusCode}');
      print('[ApiService] 📥 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('[ApiService] ✅ Reply posted successfully');
        print('[ApiService] 📋 Response Data: $data');
        return data;
      } else {
        print('[ApiService] ❌ Reply comment failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ApiService] ❌ Reply comment error: $e');
      return null;
    }
  }

  /// 🔥 Update User Product Status (Active/Sold Out)
  static Future<bool> updateUserProductStatus({
    required String productId,
    required bool status,
  }) async {
    try {
      print(
        '[ApiService] 🔄 Updating user product status: $productId -> $status',
      );

      final response = await http.put(
        Uri.parse(
          'https://oldmarket.bhoomi.cloud/api/products/$productId/status',
        ),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      print('[ApiService] 📊 Status update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ApiService] ✅ User product status updated successfully');
        return true;
      } else {
        print('[ApiService] ❌ Failed to update status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ApiService] ❌ Update status error: $e');
      return false;
    }
  }

  /// 🔥 Update Dealer Product Status (Active/Sold Out)
  static Future<bool> updateDealerProductStatus({
    required String carId,
    required bool status,
  }) async {
    try {
      print(
        '[ApiService] 🔄 Updating dealer product status: $carId -> $status',
      );

      final response = await http.put(
        Uri.parse('https://oldmarket.bhoomi.cloud/api/cars/$carId/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      print('[ApiService] 📊 Status update response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('[ApiService] ✅ Dealer product status updated successfully');
        return true;
      } else {
        print('[ApiService] ❌ Failed to update status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('[ApiService] ❌ Update status error: $e');
      return false;
    }
  }

  // Fetch all offer statuses for current user
  static Future<List<Map<String, dynamic>>> fetchOfferStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? prefs.getString('user_uid');

      if (userId == null || userId.isEmpty) {
        print('[ApiService] ❌ No userId found');
        return [];
      }

      print('[ApiService] 🔍 Fetching offer status for userId: $userId');

      // For now return empty list - backend needs proper endpoint
      // Backend should create: GET /api/users/{userId}/offers
      // which returns all offers made BY that user with product details
      print(
        '[ApiService] ⚠️ Offer status feature requires backend API: /api/users/{userId}/offers',
      );
      return [];
    } catch (e) {
      print('[ApiService] ❌ Fetch offer status error: $e');
      return [];
    }
  }
}
