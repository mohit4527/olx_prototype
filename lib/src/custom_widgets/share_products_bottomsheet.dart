import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../controller/description_controller.dart';
import '../controller/dealer_product_description_controller.dart';

class ShareBottomSheet extends StatelessWidget {
  final String productId;
  final bool isDealer; // 👈 new flag

  const ShareBottomSheet({
    super.key,
    required this.productId,
    this.isDealer = false, // default user product
  });

  @override
  Widget build(BuildContext context) {
    /// Create enhanced sharing content with product details
    return FutureBuilder<Map<String, String>>(
      future: _getProductDetails(),
      builder: (context, snapshot) {
        final productData =
            snapshot.data ??
            {
              'title': 'Check this product',
              'price': '',
              'image': '',
              'shareUrl': isDealer
                  ? "https://oldmarket.bhoomi.cloud/app/dealer/$productId"
                  : "https://oldmarket.bhoomi.cloud/app/product/$productId",
            };

        return _buildShareSheet(productData);
      },
    );
  }

  Future<Map<String, String>> _getProductDetails() async {
    try {
      String title = 'Check this amazing product!';
      String price = '';
      String image = '';
      String city = '';
      String description = '';

      if (isDealer) {
        // Try to get dealer product details
        if (Get.isRegistered<DealerDescriptionController>()) {
          final controller = Get.find<DealerDescriptionController>();
          final product = controller.productData.value;
          if (product != null) {
            title = product.title ?? 'Amazing Dealer Product';
            price = product.price != null ? '₹${product.price}' : '';
            city = product.dealerName ?? ''; // Use dealer name instead of city
            description = product.description ?? '';
            if (product.images != null && product.images!.isNotEmpty) {
              image = product.images!.first.startsWith('http')
                  ? product.images!.first
                  : 'https://oldmarket.bhoomi.cloud/${product.images!.first}';
            }
          }
        }
      } else {
        // Try to get user product details
        if (Get.isRegistered<DescriptionController>()) {
          final controller = Get.find<DescriptionController>();
          final product = controller.product.value;
          if (product != null) {
            title = product.title;
            price = '₹${product.price}';
            city = product.city;
            description = product.description;
            if (product.mediaUrl.isNotEmpty) {
              image = product.mediaUrl.first.startsWith('http')
                  ? product.mediaUrl.first
                  : 'https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}';
            }
          }
        }
      }

      final shareUrl = isDealer
          ? "https://oldmarket.bhoomi.cloud/app/dealer/$productId"
          : "https://oldmarket.bhoomi.cloud/app/product/$productId";

      return {
        'title': title,
        'price': price,
        'image': image,
        'city': city,
        'description': description,
        'shareUrl': shareUrl,
      };
    } catch (e) {
      print('Error getting product details: $e');
      final shareUrl = isDealer
          ? "https://oldmarket.bhoomi.cloud/app/dealer/$productId"
          : "https://oldmarket.bhoomi.cloud/app/product/$productId";

      return {
        'title': 'Check this product',
        'price': '',
        'image': '',
        'city': '',
        'description': '',
        'shareUrl': shareUrl,
      };
    }
  }

  Widget _buildShareSheet(Map<String, String> productData) {
    final shareUrl = productData['shareUrl']!;
    final title = productData['title']!;
    final price = productData['price']!;
    final city = productData['city']!;
    final description = productData['description']!;
    final imageUrl = productData['image']!;

    // Create rich sharing message with all details
    String shareMessage = '🛍️ *${title}*\n';
    if (price.isNotEmpty) shareMessage += '💰 Price: *${price}*\n';
    if (city.isNotEmpty) {
      if (isDealer) {
        shareMessage += '🏪 Dealer: *${city}*\n';
      } else {
        shareMessage += '📍 Location: *${city}*\n';
      }
    }
    if (description.isNotEmpty) {
      final shortDesc = description.length > 100
          ? '${description.substring(0, 100)}...'
          : description;
      shareMessage += '📝 Description: ${shortDesc}\n';
    }
    shareMessage += '\n🔗 View full details: ${shareUrl}\n';
    shareMessage += '\n📱 Download Old Market app for better experience!';

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 600,
      ), // Add height constraint
      padding: const EdgeInsets.all(16), // Reduce padding
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        // Make it scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Share Product",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(color: AppColors.appGreen),

            // Product preview card
            if (title != 'Check this product')
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.appGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.appGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.appGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (price.isNotEmpty)
                            Text(
                              price,
                              style: TextStyle(
                                color: AppColors.appGreen,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 20, // Reduce spacing
              runSpacing: 15, // Reduce spacing
              children: [
                _shareIcon(
                  icon: FontAwesomeIcons.whatsapp,
                  color: Colors.green,
                  label: "WhatsApp",
                  onTap: () => _shareToWhatsApp(shareMessage),
                ),
                _shareIcon(
                  icon: FontAwesomeIcons.facebook,
                  color: Colors.blue,
                  label: "Facebook",
                  onTap: () => _shareToFacebook(shareMessage),
                ),
                _shareIcon(
                  icon: FontAwesomeIcons.telegram,
                  color: Colors.blueAccent,
                  label: "Telegram",
                  onTap: () => _shareToTelegram(shareMessage),
                ),
                _shareIcon(
                  icon: FontAwesomeIcons.instagram,
                  color: Colors.purple,
                  label: "Instagram",
                  onTap: () => _shareToInstagram(shareMessage),
                ),
                _shareIcon(
                  icon: Icons.sms,
                  color: Colors.teal,
                  label: "SMS",
                  onTap: () => _shareToSMS(shareMessage),
                ),
                _shareIcon(
                  icon: Icons.share,
                  color: Colors.grey,
                  label: "Others",
                  onTap: () => _shareToOthers(shareMessage),
                ),
              ],
            ),
            const SizedBox(height: 10), // Add bottom padding
          ],
        ),
      ),
    );
  }

  /// Small reusable widget
  Widget _shareIcon({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 40),
          onPressed: onTap,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // Enhanced sharing methods with image and direct app launching
  Future<void> _shareToWhatsApp(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      // Show loading message
      Get.snackbar(
        "Preparing Share",
        "Downloading product image...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Try to get and share product image
      final productImage = await _downloadProductImage();

      if (productImage != null) {
        // Share with image and text
        await Share.shareXFiles(
          [XFile(productImage.path)],
          text: message,
          subject: 'Check out this product!',
        );
        return;
      }

      // Fallback to text-only sharing
      final encoded = Uri.encodeComponent(message);
      final whatsappUrl = Uri.parse('whatsapp://send?text=$encoded');

      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // Final fallback
      await Share.share(message);
    } catch (e) {
      print('Error sharing to WhatsApp: $e');
      Get.snackbar(
        "Error",
        "Could not share to WhatsApp: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _shareToFacebook(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      Get.snackbar(
        "Preparing Share",
        "Downloading product image for Facebook...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Try to get and share product image
      final productImage = await _downloadProductImage();

      if (productImage != null) {
        // Share with image and text to Facebook
        await Share.shareXFiles(
          [XFile(productImage.path)],
          text: message,
          subject: 'Check out this product on Old Market!',
        );
        return;
      }

      // Fallback to Facebook web sharing
      final shareUrl = message.contains('https://')
          ? message.split('View full details: ')[1].split('\n')[0]
          : 'https://oldmarket.bhoomi.cloud';

      final facebookUrl = Uri.parse(
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(shareUrl)}',
      );
      if (await canLaunchUrl(facebookUrl)) {
        await launchUrl(facebookUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // Final fallback
      await Share.share(message);
    } catch (e) {
      print('Error sharing to Facebook: $e');
      Get.snackbar(
        "Error",
        "Could not share to Facebook: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _shareToTelegram(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      Get.snackbar(
        "Preparing Share",
        "Downloading product image for Telegram...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Try to get and share product image
      final productImage = await _downloadProductImage();

      if (productImage != null) {
        // Share with image and text to Telegram
        await Share.shareXFiles(
          [XFile(productImage.path)],
          text: message,
          subject: 'Check out this product!',
        );
        return;
      }

      // Fallback to text-only sharing
      final encoded = Uri.encodeComponent(message);
      final telegramUrl = Uri.parse('tg://msg?text=$encoded');

      if (await canLaunchUrl(telegramUrl)) {
        await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to Telegram web
      final webUrl = Uri.parse('https://t.me/share/url?text=$encoded');
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // Final fallback
      await Share.share(message);
    } catch (e) {
      print('Error sharing to Telegram: $e');
      Get.snackbar(
        "Error",
        "Could not share to Telegram: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _shareToInstagram(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      Get.snackbar(
        "Preparing Share",
        "Downloading product image for Instagram...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Try to get and share product image (Instagram works best with images)
      final productImage = await _downloadProductImage();

      if (productImage != null) {
        // Share image with text to Instagram
        await Share.shareXFiles(
          [XFile(productImage.path)],
          text: message,
          subject: 'Check out this product!',
        );
        return;
      }

      // Fallback to text sharing if no image
      await Share.share(message);
    } catch (e) {
      print('Error sharing to Instagram: $e');
      Get.snackbar(
        "Error",
        "Could not share to Instagram: $e",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _shareToSMS(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      Get.snackbar(
        "Opening SMS",
        "Preparing SMS message...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      // Encode message for SMS
      final encoded = Uri.encodeComponent(message);
      final smsUrl = Uri.parse('sms:?body=$encoded');

      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to regular sharing
      await Share.share(message);
    } catch (e) {
      print('Error sharing to SMS: $e');
      Get.snackbar(
        "Error",
        "Could not open SMS app.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _shareToOthers(String message) async {
    try {
      Get.back(); // Close the bottom sheet first

      Get.snackbar(
        "Opening Share Menu",
        "Opening system share options...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 1),
      );

      // This will open the system's native share dialog
      await Share.share(
        message,
        subject: 'Check out this product on Old Market!',
      );
    } catch (e) {
      print('Error sharing: $e');
      Get.snackbar(
        "Error",
        "Could not open share menu.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Download product image for sharing
  Future<File?> _downloadProductImage() async {
    try {
      String? imageUrl;

      // Get image URL from controllers
      if (isDealer) {
        if (Get.isRegistered<DealerDescriptionController>()) {
          final controller = Get.find<DealerDescriptionController>();
          final product = controller.productData.value;
          if (product != null &&
              product.images != null &&
              product.images!.isNotEmpty) {
            imageUrl = product.images!.first.startsWith('http')
                ? product.images!.first
                : 'https://oldmarket.bhoomi.cloud/${product.images!.first}';
          }
        }
      } else {
        if (Get.isRegistered<DescriptionController>()) {
          final controller = Get.find<DescriptionController>();
          final product = controller.product.value;
          if (product != null && product.mediaUrl.isNotEmpty) {
            imageUrl = product.mediaUrl.first.startsWith('http')
                ? product.mediaUrl.first
                : 'https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}';
          }
        }
      }

      if (imageUrl == null || imageUrl.isEmpty) {
        print('No image URL found for product');
        return null;
      }

      print('Downloading image from: $imageUrl');

      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        final fileName =
            'product_${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
      print('Error downloading product image: $e');
      return null;
    }
  }
}
