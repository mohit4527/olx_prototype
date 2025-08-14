import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';

class HistoryCard extends StatelessWidget {
  final String image;
  final String title;
  final String location;
  final String price;

  const HistoryCard({
    super.key,
    required this.image,
    required this.title,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppSizer().height2),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizer().height2),
            child: Image.asset(
              image,
              width: AppSizer().width26,
              height: AppSizer().height12,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: AppSizer().width5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppSizer().fontSize17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appBlack,
                  ),
                ),
                SizedBox(height: AppSizer().height1),
                Row(
                  children: [
                    Icon(Icons.pin_drop,color: AppColors.appGrey.shade700,size: AppSizer().height2,),
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
                SizedBox(height: AppSizer().height1),
                Text(
                  "₹ " + price,
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appRed,
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
