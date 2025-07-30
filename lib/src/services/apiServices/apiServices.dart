import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:olx_prototype/src/model/short_video_model/short_video_model.dart';

import '../../model/book_test_drive_model/book_test_drive_model.dart';
import '../../model/product_description_model/product_description model.dart';


class ApiService {
  // Description Screen ApiService 
  static Future<List<ProductModel>> fetchProducts() async {

    try {

      final response = await http.get(
        Uri.parse("https://oldmarket.bhoomi.cloud/api/products?page=1&limit=10"),
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
      final res = await http.get(Uri.parse("http://oldmarket.bhoomi.cloud/api/videos"));

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
    required String userId,
    required String preferredDate,
    required String preferredTime,
    required String carId,
  }) async {
    final url = Uri.parse(
        'http://oldmarket.bhoomi.cloud/api/cars/6883656a6acf4dd87f862e41/book-test-drive');

    final body = jsonEncode({
      "userId": userId,
      "preferredDate": preferredDate,
      "preferredTime": preferredTime,
    });

    try {
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
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }



  //Sell Car Screen ApiService

  static const String baseUrl = 'http://oldmarket.bhoomi.cloud/api/products';

  static Future<http.Response> uploadCar({
    required String title,
    required String description,
    required String price,
    required String userId,
    required Map<String, String> location,
    required List<File> images,
  }) async {
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri);

    // Add fields
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['userId'] = userId;
    request.fields['location'] = jsonEncode(location); // send as JSON string

    // Add images (correct field name: 'images')
    for (var image in images) {
      final mimeType = lookupMimeType(image.path);
      if (mimeType != null) {
        final file = await http.MultipartFile.fromPath(
          'images', // ✅ CORRECT field name
          image.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("Status: ${response.statusCode}");
      print("Response: ${response.body}");

      return response;
    } catch (e) {
      print("Upload error: $e");
      rethrow;
    }
  }



}
