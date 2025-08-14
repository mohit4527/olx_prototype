import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';

import '../constants/app_sizer.dart';

class ProductCard extends StatelessWidget {
  final String imagePath;
  final String price;
  final String roomInfo;
  final String description;
  final String location;
  final String date;

  const ProductCard({
    super.key,
    required this.imagePath,
    required this.price,
    required this.roomInfo,
    required this.description,
    required this.location,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          AspectRatio(
            aspectRatio: 0.9,
            child: Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                );
              },
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizer().fontSize18,
                    color: Colors.black,
                  ),
                ),
                // Title
                // Text(
                //   roomInfo,
                //   maxLines: 1,
                //   overflow: TextOverflow.ellipsis,
                //   style: TextStyle(
                //     fontSize: AppSizer().fontSize14,
                //     fontWeight: FontWeight.w500,
                //     color: Colors.grey[800],
                //   ),
                // ),
                //
                // // Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize14,
                        color: AppColors.appGrey.shade700,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize14,
                        color: AppColors.appGrey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
