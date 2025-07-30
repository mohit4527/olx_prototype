import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class CarUploadController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  final RxBool isUploading = false.obs;
  final RxList<File> selectedImages = <File>[].obs;

  final String userId = '64fdb1e8a9187a81b1cd9b17';
  final Map<String, String> location = {
    'country': 'India',
    'state': 'Maharashtra',
    'city': 'Pune',
  };

  final List<String> allowedExtensions = ['.jpg', '.jpeg', '.png'];

  bool isValidExtension(String path) {
    return allowedExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    priceController.clear();
    selectedImages.clear();
  }

  Future<void> uploadCarData() async {
    if (titleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        selectedImages.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields and select at least one image',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isUploading.value = true;

      final response = await _uploadCar(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        price: priceController.text.trim(),
        userId: userId,
        location: location,
        images: selectedImages,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = jsonDecode(response.body);

          if (data['status'] == true || data['data'] != null) {
            Get.snackbar(
              'Success',
              'Car uploaded successfully!',
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade800,
              snackPosition: SnackPosition.TOP,
            );
            clearForm();
          } else {
            Get.snackbar(
              'Upload Failed',
              data['message'] ?? 'Something went wrong',
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              snackPosition: SnackPosition.TOP,
            );
          }
        } catch (e) {
          // In case response is HTML or non-JSON
          Get.snackbar(
            'Success',
            'Car uploaded successfully (non-JSON response)',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade800,
            snackPosition: SnackPosition.TOP,
          );
          clearForm();
        }
      } else {
        Get.snackbar(
          'Failed',
          'Server responded with status: ${response.statusCode}',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isUploading.value = false;
    }
  }

  Future<http.Response> _uploadCar({
    required String title,
    required String description,
    required String price,
    required String userId,
    required Map<String, String> location,
    required List<File> images,
  }) async {
    final uri = Uri.parse('http://oldmarket.bhoomi.cloud/api/products');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['price'] = price;
    request.fields['userId'] = userId;
    request.fields['location'] = jsonEncode(location);

    for (var image in images) {
      final mimeType = _getMimeType(image.path);
      final multipartFile = await http.MultipartFile.fromPath(
        'images[]',
        image.path,
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  String _getMimeType(String path) {
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    return 'application/octet-stream';
  }
}
