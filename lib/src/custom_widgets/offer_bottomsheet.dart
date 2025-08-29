import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../controller/history_controller.dart';

class DealerOffersBottomSheet extends StatelessWidget {
  final String productTitle;
  const DealerOffersBottomSheet({super.key, required this.productTitle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HistoryController>();
    final offers = controller.getOffersForProduct(productTitle);

    return Container(
      padding: EdgeInsets.all(AppSizer().height2),
      decoration: BoxDecoration(
        color: AppColors.appWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Offers for $productTitle",
            style: TextStyle(
              fontSize: AppSizer().fontSize18,
              fontWeight: FontWeight.bold,
              color: AppColors.appBlack,
            ),
          ),
          Divider(color: AppColors.appGreen,),
          SizedBox(height: AppSizer().height2),
          offers.isEmpty
              ? Text(
            "No offers yet",
            style: TextStyle(color: AppColors.appGrey),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Buyer name
                    Row(
                      children: [
                        Icon(Icons.person, color: AppColors.appGreen),
                        const SizedBox(width: 8),
                        Text(
                          offer["buyer"]!,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Offer price (center)
                    Expanded(
                      child: Center(
                        child: Text(
                          "₹ ${offer["offerPrice"]}",
                          style: TextStyle(
                            color: AppColors.appRed,
                            fontWeight: FontWeight.bold,
                            fontSize: AppSizer().fontSize16,
                          ),
                        ),
                      ),
                    ),

                    // Action buttons (Accept + Reject)
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              "Offer Accepted",
                              "You accepted offer of ₹ ${offer["offerPrice"]}",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.appGreen,
                              colorText: AppColors.appWhite,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(AppSizer().width20, AppSizer().height4),
                            backgroundColor: AppColors.appGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Accept",
                            style: TextStyle(
                              color: AppColors.appWhite,
                              fontSize: AppSizer().fontSize15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Get.snackbar(
                              "Offer Rejected",
                              "You rejected offer of ₹ ${offer["offerPrice"]}",
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: AppColors.appRed,
                              colorText: AppColors.appWhite,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(AppSizer().width20, AppSizer().height4),
                            backgroundColor: AppColors.appRed,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            "Reject",
                            style: TextStyle(
                              color: AppColors.appWhite,
                              fontSize: AppSizer().fontSize15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
