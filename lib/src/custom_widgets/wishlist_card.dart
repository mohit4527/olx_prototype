import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';


class WishlistCard extends StatelessWidget {
  final String id;
  final String image;
  final String title;
  final String description;
  final String price;
  final VoidCallback onRemove;

  const WishlistCard({
    super.key,
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.price,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.network(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    Image.asset(
                    "assets/images/placeholder.jpg",
                    fit: BoxFit.cover,
                    ),
                        )
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: AppColors.appWhite,
                        size: AppSizer().fontSize17,
                      ),
                    ),
                  ),
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
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizer().fontSize16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: AppSizer().height1),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: AppSizer().fontSize14,
                    color: AppColors.appGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AppSizer().height1),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal:12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.appRed,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "₹ $price",
                    style: TextStyle(
                      color: AppColors.appWhite,
                      fontSize: AppSizer().fontSize14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
