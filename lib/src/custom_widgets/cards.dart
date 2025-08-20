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
    double cardWidth = MediaQuery.of(context).size.width * 0.55;

    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          AspectRatio(
            aspectRatio: 1,
            child: (imagePath != null && imagePath.trim().isNotEmpty)
                ? (imagePath.startsWith("http")
                ? Image.network(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                );
              },
            )
                : Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/images/placeholder.jpg",
                  fit: BoxFit.cover,
                );
              },
            ))
                : Image.asset(
              "assets/images/placeholder.jpg",
              fit: BoxFit.cover,
            ),
          ),


          // Details Section
          SizedBox(height: AppSizer().height1,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppSizer().fontSize16,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        location,
                        style: TextStyle(
                          fontSize: AppSizer().fontSize14,
                          color: AppColors.appGrey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize14,
                        color: AppColors.appGrey,
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
