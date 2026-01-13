import 'package:flutter/material.dart';
import 'package:get/get.dart';
// app_colors not required in this widgetfix karo ya fir only city hi show a

import '../controller/dealer_wishlist_controller.dart';
import '../controller/user_wishlist_controller.dart';
import '../controller/product_boost_controller.dart';
import '../controller/token_controller.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String roomInfo;
  final String price;
  final String description;
  final String location;
  final DateTime? date;
  final String productId;
  final bool isDealer;
  final String? userId; // Add userId to check ownership
  final bool isBoosted; // Add boosted flag
  final bool? status; // 🔥 Product status (true=active, false=sold)

  ProductCard({
    super.key,
    required this.imagePath,
    required this.roomInfo,
    required this.price,
    required this.description,
    required this.location,
    this.date,
    required this.productId,
    this.isDealer = false,
    this.userId, // Optional userId
    this.isBoosted = false, // Default false
    this.status, // 🔥 Optional status
  });

  @override
  Widget build(BuildContext context) {
    final userWishlistController = Get.isRegistered<UserWishlistController>()
        ? Get.find<UserWishlistController>()
        : Get.put(UserWishlistController());
    final dealerWishlistController =
        Get.isRegistered<DealerWishlistController>()
        ? Get.find<DealerWishlistController>()
        : Get.put(DealerWishlistController());

    final boostController = Get.isRegistered<ProductBoostController>()
        ? Get.find<ProductBoostController>()
        : Get.put(ProductBoostController());

    final tokenController = Get.isRegistered<TokenController>()
        ? Get.find<TokenController>()
        : Get.put(TokenController());

    // Check if current user owns this product
    final currentUserId = tokenController.userUid.value;
    final isOwner = userId != null && userId == currentUserId;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(5),
                    ),
                    child: imagePath.startsWith('http')
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/images/placeholder.jpg"),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset("assets/images/placeholder.jpg"),
                          ),
                  ),
                ),
                // 🔥 Status Badge (Active/Sold Out)
                if (status != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == true ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == true ? 'ACTIVE' : 'SOLD OUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Obx(() {
                    final isInWishlist = isDealer
                        ? dealerWishlistController.isInWishlist(productId)
                        : userWishlistController.isInWishlist(productId);

                    return GestureDetector(
                      onTap: () {
                        if (isDealer) {
                          dealerWishlistController.toggleWishlist(productId);
                        } else {
                          userWishlistController.toggleWishlist(productId);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.withOpacity(0.6),
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.black54,
                        ),
                      ),
                    );
                  }),
                ),

                // Boost Icon (only for product owners)
                if (isOwner)
                  Positioned(
                    top: 8,
                    right: 56, // Position to the left of wishlist icon
                    child: Obx(() {
                      return GestureDetector(
                        onTap: () {
                          if (boostController.isProcessing.value) {
                            Get.snackbar(
                              'Processing',
                              'A boost payment is already in progress...',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          // Show boost confirmation dialog
                          Get.dialog(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.rocket_launch,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 8),
                                  Text('Boost Product'),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Boost your product for better visibility!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text('• Higher position in search results'),
                                  Text('• More views and inquiries'),
                                  Text('• Increased chances of quick sale'),
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Price will be determined by our system',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(),
                                  child: Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    boostController.startBoostPayment(
                                      productId,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: Text(
                                    'Boost Now',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.orange.withOpacity(0.9),
                          child: Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomInfo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
