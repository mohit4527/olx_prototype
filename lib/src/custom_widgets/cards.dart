import 'package:flutter/material.dart';
import 'package:get/get.dart';
// app_colors not required in this widget

import '../controller/dealer_wishlist_controller.dart';
import '../controller/user_wishlist_controller.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String roomInfo;
  final String price;
  final String description;
  final String location;
  final DateTime? date;
  final String productId;
  final bool isDealer;

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
                    child: Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.asset("assets/images/placeholder.jpg"),
                    ),
                  ),
                ),
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
