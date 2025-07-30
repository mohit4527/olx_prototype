import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import '../constants/app_colors.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
            side: BorderSide(color: AppColors.appBlueGrey,width: 1),
          ),
          margin: EdgeInsets.all(AppSizer().width1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(3),
                      topRight: Radius.circular(3),
                    ),
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: constraints.maxHeight * 0.5,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: AppSizer().height1,
                    right: AppSizer().height1,
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite_border,
                        color: AppColors.appBlack,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(AppSizer().width3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ' $roomInfo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizer().fontSize15,
                      ),
                    ),
                     SizedBox(height: AppSizer().height1),
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize15,
                      ),
                    ),
                    SizedBox(height: AppSizer().height1),

                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize15,
                        color: AppColors.appGrey,
                      ),
                    ),
                    SizedBox(height: AppSizer().height2),

                    Center(
                      child: SizedBox(
                        width: AppSizer().width30,
                        height: AppSizer().height4,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed(AppRoutes.description);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.appGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.symmetric(vertical: AppSizer().height1),
                          ),
                          child: Text(
                            'Deal',
                            style: TextStyle(
                              color: AppColors.appWhite,
                              fontSize: AppSizer().fontSize16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizer().height1),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize14,
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize14,
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
      },
    );
  }
}