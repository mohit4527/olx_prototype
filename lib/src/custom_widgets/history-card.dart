import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../utils/app_routes.dart';
import 'offer_bottomsheet.dart';

class HistoryCard extends StatelessWidget {
  final String image;
  final String productId;
  final String title;
  final String location;
  final dynamic controller;
  final String price;
  final String role;

  const HistoryCard({
    super.key,
    required this.image,
    required this.title,
    required this.productId,
    required this.location,
    this.controller,
    required this.price,
    required this.role,
  });

  String getFullImage(String path) {
    if (path.startsWith("http")) return path;
    if (path.isEmpty) return "assets/images/placeholder.jpg";
    return "https://oldmarket.bhoomi.cloud/$path";
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = getFullImage(image);

    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizer().height2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizer().height2),
            child: SizedBox(
              width: AppSizer().width28,
              height: AppSizer().height14,
              child: displayImage.startsWith("http")
                  ? Image.network(
                      displayImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Image.asset(
                        "assets/images/placeholder.jpg",
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      "assets/images/placeholder.jpg",
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: AppSizer().width3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizer().height1),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizer().fontSize17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: AppSizer().height1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.pin_drop,
                          color: AppColors.appGrey.shade700,
                          size: AppSizer().height2,
                        ),
                        SizedBox(width: AppSizer().width1),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize15,
                            color: AppColors.appGrey.shade700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            Get.bottomSheet(
                              OffersBottomSheet(
                                productTitle: title,
                                productId: productId,
                                controller: controller,
                              ),
                              isScrollControlled: true,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: AppSizer().width6),
                            child: Text(
                              "See Offers",
                              style: TextStyle(
                                color: AppColors.appPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizer().fontSize16,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: AppSizer().width3),
                          child: Container(
                            margin: EdgeInsets.only(top: 2),
                            height: 1.2,
                            width: 90,
                            color: AppColors.appWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSizer().height1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹ $price",
                      style: TextStyle(
                        fontSize: AppSizer().fontSize16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appRed,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            print("🟣 Tapped See Test Drives");
                            print("🔹 Role: $role");
                            print("🔹 Product ID: ${productId.trim()}");

                            final route = role == "dealer"
                                ? AppRoutes.dealer_bookTestDrives_screen
                                : AppRoutes.book_test_driveScreen;

                            Get.toNamed(
                              route,
                              arguments: {
                                "productId": productId.trim(),
                                "productTitle": title,
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: AppSizer().width3),
                            child: Text(
                              "See Test Drives",
                              style: TextStyle(
                                color: AppColors.appPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: AppSizer().fontSize16,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 2),
                          height: 1.2,
                          width: 120,
                          color: AppColors.appWhite,
                        ),
                      ],
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
