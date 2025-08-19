import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:olx_prototype/src/model/short_video_model/short_video_model.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/all_product_model/all_product_model.dart';
import '../../model/book_test_drive_model/book_test_drive_model.dart';
import '../../model/make_offer_model/make_offer_model.dart';
import '../../model/product_description_model/product_description model.dart';
import '../../model/sell_car_model/sell_car_model.dart';
import '../../model/share_video_model/share_video_model.dart';

class ApiService {
  // Description Screen ApiService
  static Future<List<ProductModel>> fetchProducts(String carId) async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://oldmarket.bhoomi.cloud/api/products?page=1&limit=10",
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

  //ShortVideos Screen ApiService
  static Future<List<ShortVideoModel>> fetchShortVideos() async {
    try {
      final res = await http.get(
        Uri.parse("http://oldmarket.bhoomi.cloud/api/videos"),
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data["status"] == true) {
          List videoList = data["data"];
          return videoList.map((e) => ShortVideoModel.fromJson(e)).toList();
        } else {
          throw Exception("No videos found");
        }
      } else {
        throw Exception("Failed to load videos");
      }
    } catch (e) {
      rethrow;
    }
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
      'http://oldmarket.bhoomi.cloud/api/cars/6883656a6acf4dd87f862e41/book-test-drive',
    );

    final body = jsonEncode({
      "carId": carId,
      "date": preferredDate,
      "time": preferredTime,
      "name": name,
      "phone": phoneNumber,
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return BookTestDriveModel.fromJson(json);
    } else {
      print("API Error: ${response.statusCode}");
      return null;
    }
  }

  //Sell Car Screen ApiService

  static Future<bool> uploadCar(CarProductModel car, List<File> images) async {
    print("Sending userId: ${car.userId}");
    final uri = Uri.parse('http://oldmarket.bhoomi.cloud/api/products');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = car.title;
    request.fields['description'] = car.description;
    request.fields['price'] = car.price.toString();
    request.fields['type'] = car.type;
    request.fields['userId'] = car.userId;
    request.fields['location'] = jsonEncode({
      'country': car.location.country,
      'state': car.location.state,
      'city': car.location.city,
    });

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

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    print('Upload status: ${resp.statusCode}    body: ${resp.body}');
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      return json['status'] == true;
    }
    return false;
  }

  static Future<File?> compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(
      dir.absolute.path,
      '${DateTime
          .now()
          .millisecondsSinceEpoch}_${path.basename(file.path)}',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // adjust quality if needed
    );
  }






  //login ApiService
  static const String baseUrl = 'http://oldmarket.bhoomi.cloud/api/auth';

  static Future<Map<String, dynamic>> login(String phone, String countryCode) async {
    final url = Uri.parse('$baseUrl/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'phone': phone, 'countryCode': countryCode});

    print(" Hitting URL: $url");
    print(" Sending body: $body");

    try {
      final response = await http.post(url, headers: headers, body: body);

      print("Status Code: ${response.statusCode}");
      print("Raw Response: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['user'] != null) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();

        final String userId = responseData['user']['_id'];
        await prefs.setString('userId', userId);

        print("Saved userId: $userId");

        if (responseData['token'] != null) {
          await prefs.setString('auth_token', responseData['token']);
          print("Saved auth_token: ${responseData['token']}");
        }
      }

      return responseData;
    } catch (e) {
      print("API ERROR: $e");
      return {'error': 'Exception occurred: $e'};
    }
  }





  //verify OTP
  static Future<Map<String, dynamic>> verifyOtp(String phone,
      String otp,) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    return jsonDecode(response.body);
  }

  //Make Offer ApiService

  static Future<MakeOfferResponseModel?> makeOffer({
    required String productId,
    required String userId,
    required int offerPrice,
  }) async {
    final url = Uri.parse(
      'https://oldmarket.bhoomi.cloud/api/products/$userId/make-offer',
    );

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": userId, "offerPrice": offerPrice}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MakeOfferResponseModel.fromJson(data);
      } else {
        print("Offer API Error: ${response.statusCode} - ${response.body}");
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
        Uri.parse('$baseUrl1/products?page=1&limit=100'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final dynamic rawList = jsonData['data'];

      if (rawList is List) {
        return rawList.map((item) => AllProductModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Expected list in JSON.data but got ${rawList.runtimeType}');
      }
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  }




  //Video like api

  static Future<Map<String, dynamic>?> likeUnlikeVideo(String videoId) async {
    final url = Uri.parse(
        'https://oldmarket.bhoomi.cloud/api/videos/$videoId/like');

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }





  // post Comment Api
  static Future<void> postComment({
    required String videoId,
    required String userId,
    required String text,
  }) async {
    final url = Uri.parse('https://oldmarket.bhoomi.cloud/api/videos/$videoId/comment');

    final body = jsonEncode({
      "userId": userId,
      "text": text,
    });

    final headers = {
      "Content-Type": "application/json",
    };

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Comment posted successfully");
    } else {
      print("Failed to post comment: ${response.body}");
      throw Exception("Failed to post comment");
    }
  }



  static const String baseUrl3 = "https://oldmarket.bhoomi.cloud/api";

  // ✅ Share Video API
  static Future<SharedVideo> shareVideo({
    required String videoId,
    required String userId,
    required String token,
  }) async {
    final url = Uri.parse("$baseUrl3/videos/$videoId/share");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"userId": userId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // agar response me sharedWith hai to usko parse karna hai
      if (data["sharedWith"] != null && data["sharedWith"] is List) {
        return SharedVideo.fromJson(data["sharedWith"][0]);
      } else {
        throw Exception("❌ Unexpected response format: ${response.body}");
      }
    } else {
      throw Exception("❌ Failed to share video: ${response.body}");
    }
  }

  // ✅ Get Shared Videos API
  static Future<List<SharedVideo>> getSharedVideos(String token) async {
    final url = Uri.parse("$baseUrl3/videos/shared");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["sharedWith"] != null && data["sharedWith"] is List) {
        return (data["sharedWith"] as List)
            .map((json) => SharedVideo.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception("❌ Failed to fetch shared videos: ${response.body}");
    }
  }


}




