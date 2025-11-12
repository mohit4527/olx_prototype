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
      Uri.parse("http://oldmarket.bhoomi.cloud/api/products/$productId"),
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
        "http://oldmarket.bhoomi.cloud/api/users/$userId/phone",
        "https://oldmarket.bhoomi.cloud/api/user/$userId/contact",
        "http://oldmarket.bhoomi.cloud/api/user/$userId/contact",
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
    try {
      final uri = Uri.parse("$base/videos");
      Logger.d('ApiService', 'Uploading video to: $uri');
      Logger.d(
        'ApiService',
        'videoPath: $videoPath, title: $title, productId: $productId, duration: $duration',
      );

      final request = http.MultipartRequest('POST', uri);

      // Attach video file with clean filename and proper content type
      // Determine mime type dynamically so we send correct content-type
      final detectedMime = lookupMimeType(videoPath) ?? 'video/mp4';
      final mimeParts = detectedMime.split('/');
      final mimeTypeTop = mimeParts.isNotEmpty ? mimeParts[0] : 'video';
      final mimeTypeSub = mimeParts.length > 1 ? mimeParts[1] : 'mp4';

      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoPath,
          filename: cleanFileName(videoPath),
          contentType: MediaType(mimeTypeTop, mimeTypeSub),
        ),
      );

      request.fields['title'] = title;
      request.fields['productId'] = productId;

      // Resolve userId robustly for uploads. We prefer SharedPreferences
      // values ('userId' or 'user_uid'), then fall back to decoding the
      // JWT token if TokenController is available. We also log the prefs
      // and token contents (only presence, not secret) to help debug.
      final resolvedUserId = await _getUserIdForUploads();
      if (resolvedUserId.isNotEmpty) {
        request.fields['userId'] = resolvedUserId;
      } else {
        // Keep an explicit log so developers know why userId is missing.
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
      'http://oldmarket.bhoomi.cloud/api/cars/car/$carId/book-test-drive',
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

        final uri = Uri.parse('http://oldmarket.bhoomi.cloud/api/products');
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
        request.fields['location'] = jsonEncode({
          'country': car.location.country,
          'state': car.location.state,
          'city': car.location.city,
        });

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
          'http://oldmarket.bhoomi.cloud/api/cars/dealer/upload',
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
    final targetPath = path.join(
      dir.absolute.path,

      '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}',
    );
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );
    return result != null ? File(result.path) : null;
  }

  // Fetch dealer All Products
  static const String _baseUrl = 'http://oldmarket.bhoomi.cloud/api/dealers';

  static Future<List<DealerProduct>> fetchDealerProducts() async {
    final uri = Uri.parse(
      'http://oldmarket.bhoomi.cloud/api/dealers/dealer/cars',
    );
    print("📡 Fetching dealer products from: $uri");
    try {
      final response = await http.get(uri);
      print("📊 Dealer Products API Status: ${response.statusCode}");
      print("📋 Dealer Products Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final dealerProductModel = DealerProductModel.fromJson(jsonResponse);
        print(
          "✅ Dealer Products parsed: ${dealerProductModel.data.length} items",
        );
        return dealerProductModel.data;
      } else {
        print("❌ Dealer Products API failed: ${response.statusCode}");
        throw Exception(
          'Failed to load dealer products. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("💥 Dealer Products API error: $e");
      throw Exception('Error fetching dealer products: $e');
    }
  }

  // fetch all products description  of dealer
  Future<DealerProductDescriptionModel?> fetchDealerProductById(
    String productId,
  ) async {
    final url = Uri.parse(
      'http://oldmarket.bhoomi.cloud/api/dealers/$productId',
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
      'http://oldmarket.bhoomi.cloud/api/chat/user/$userId',
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
      'http://oldmarket.bhoomi.cloud/api/chat/$chatId/messages',
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
    final url = Uri.parse('http://oldmarket.bhoomi.cloud/api/chat/send');
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

  // Start Chat API (POST)
  static Future<String> startChat(
    String productId,
    String buyerId,
    String sellerId,
  ) async {
    final url = Uri.parse('http://oldmarket.bhoomi.cloud/api/chat/start');
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
        "http://oldmarket.bhoomi.cloud/api/products/dealer/$productId/offers",
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
      "http://oldmarket.bhoomi.cloud/api/products/$productId/offers",
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
      "http://oldmarket.bhoomi.cloud/api/products/$productId/offers/$offerId/accept",
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
      "http://oldmarket.bhoomi.cloud/api/products/$productId/offers/$offerId/reject",
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
      'http://oldmarket.bhoomi.cloud/api/products/dealer/$productId/offers',
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
      'http://oldmarket.bhoomi.cloud/api/products/$productId/offer/accept',
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
      'http://oldmarket.bhoomi.cloud/api/products/$productId/offer/reject',
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
      'http://oldmarket.bhoomi.cloud/api/cars/product/$productId',
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
      'http://oldmarket.bhoomi.cloud/api/cars/test-drives/$testDriveId/accept',
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
      'http://oldmarket.bhoomi.cloud/api/cars/test-drives/$testDriveId/reject',
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
      'http://oldmarket.bhoomi.cloud/api/cars/product/$carId/book-test-drive',
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
    final url = Uri.parse('http://oldmarket.bhoomi.cloud/api/cars/car/$carId');

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
      'http://oldmarket.bhoomi.cloud/api/cars/test-drives/$bookingId/accept',
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
      'http://oldmarket.bhoomi.cloud/api/cars/test-drives/$bookingId/reject',
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
      "http://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerId/stats",
      "http://oldmarket.bhoomi.cloud/api/dealers/$dealerId/stats",
      "http://oldmarket.bhoomi.cloud/api/dealers/stats/$dealerId",
      "http://oldmarket.bhoomi.cloud/api/dealers/profile/$dealerId",
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
        "http://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerId/cars";
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
      '[ApiService] getMyProducts called. userId: $userId, token present=${tokenCtrl.apiToken.value.isNotEmpty}',
    );

    if (userId.isEmpty) {
      print(
        '[ApiService] getMyProducts: no userId available - cannot filter user products',
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
      'http://oldmarket.bhoomi.cloud/api/dealers/dealer/$dealerType/$carId/delete',
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

  static Future<Map<String, dynamic>?> getAllDealers() async {
    print("🔍 [API] getAllDealers called");
    final url = "http://oldmarket.bhoomi.cloud/api/dealers/all";
    print("🌐 [API] URL: $url");

    try {
      final response = await http.get(Uri.parse(url));
      print("📥 [API] Response Status: ${response.statusCode}");
      print("📦 [API] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("❌ [API] Error in getAllDealers: $e");
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
      'http://oldmarket.bhoomi.cloud/api/users/$userId',
      'http://oldmarket.bhoomi.cloud/api/user/$userId',
      'http://oldmarket.bhoomi.cloud/api/auth/user/$userId',
      'http://oldmarket.bhoomi.cloud/api/auth/users/$userId',
      // Extra common patterns
      'https://oldmarket.bhoomi.cloud/api/users/get/$userId',
      'http://oldmarket.bhoomi.cloud/api/users/get/$userId',
      'https://oldmarket.bhoomi.cloud/api/users/getUser/$userId',
      'http://oldmarket.bhoomi.cloud/api/users/getUser/$userId',
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
}
