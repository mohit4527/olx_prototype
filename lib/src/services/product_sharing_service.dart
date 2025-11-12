import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'dart:io';

class ProductSharingService {
  static final ProductSharingService _instance =
      ProductSharingService._internal();
  factory ProductSharingService() => _instance;
  ProductSharingService._internal();

  /// Share product with image and text to any platform
  static Future<void> shareProductWithImage({
    required String message,
    required String? imageUrl,
    String? subject,
  }) async {
    try {
      Get.snackbar(
        "तैयार हो रहा है...",
        "प्रोडक्ट की इमेज WhatsApp के लिए तैयार की जा रही है",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      File? imageFile;

      // Download image if URL is provided
      if (imageUrl != null && imageUrl.isNotEmpty) {
        imageFile = await _downloadImage(imageUrl);
      }

      if (imageFile != null) {
        // Share with image and text
        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: message,
          subject: subject ?? 'Old Market पर यह प्रोडक्ट देखें!',
        );

        Get.snackbar(
          "सफल! 🎉",
          "इमेज के साथ शेयर किया गया",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      } else {
        // Fallback to text-only sharing
        await Share.share(
          message,
          subject: subject ?? 'Old Market पर यह प्रोडक्ट देखें!',
        );

        Get.snackbar(
          "शेयर किया गया",
          "टेक्स्ट शेयर किया गया (इमेज उपलब्ध नहीं)",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      print('Error sharing product: $e');

      // Final fallback
      try {
        await Share.share(message);
      } catch (fallbackError) {
        Get.snackbar("Error", "शेयर नहीं हो सका: $fallbackError");
      }
    }
  }

  /// Download image from URL
  static Future<File?> _downloadImage(String imageUrl) async {
    try {
      // Ensure proper URL format
      String finalUrl = imageUrl;
      if (!imageUrl.startsWith('http')) {
        finalUrl = 'https://oldmarket.bhoomi.cloud/$imageUrl';
      }

      print('Downloading image from: $finalUrl');

      // Download the image
      final response = await http.get(Uri.parse(finalUrl));
      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');

        // Write image data to file
        await file.writeAsBytes(response.bodyBytes);
        print('Image downloaded successfully: ${file.path}');
        return file;
      } else {
        print('Failed to download image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error downloading image: $e');
      return null;
    }
  }

  /// Create rich sharing message for products
  static String createProductMessage({
    required String title,
    required String price,
    required String shareUrl,
    String? location,
    bool isDealer = false,
  }) {
    String message = "हाय! 👋 मुझे यह प्रोडक्ट पसंद आया है:\n\n";

    if (isDealer) {
      message += "🚗 $title\n";
    } else {
      message += "🏷️ $title\n";
    }

    message += "💰 ₹$price\n";

    if (location != null && location.isNotEmpty) {
      message += "📍 $location\n";
    }

    message += "\n🔗 पूरी जानकारी देखें: $shareUrl\n";
    message += "\n📱 बेहतर अनुभव के लिए Old Market app डाउनलोड करें!";

    return message;
  }

  /// Share product for user products
  static Future<void> shareUserProduct({
    required String productId,
    required String title,
    required String price,
    String? imageUrl,
    String? location,
  }) async {
    final shareUrl = 'https://oldmarket.bhoomi.cloud/app/product/$productId';
    final message = createProductMessage(
      title: title,
      price: price,
      shareUrl: shareUrl,
      location: location,
      isDealer: false,
    );

    await shareProductWithImage(message: message, imageUrl: imageUrl);
  }

  /// Share product for dealer products
  static Future<void> shareDealerProduct({
    required String productId,
    required String title,
    required String price,
    String? imageUrl,
    String? location,
  }) async {
    final shareUrl = 'https://oldmarket.bhoomi.cloud/app/dealer/$productId';
    final message = createProductMessage(
      title: title,
      price: price,
      shareUrl: shareUrl,
      location: location,
      isDealer: true,
    );

    await shareProductWithImage(message: message, imageUrl: imageUrl);
  }
}
