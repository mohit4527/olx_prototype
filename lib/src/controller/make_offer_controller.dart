import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../model/make_offer_model/make_offer_model.dart';
import '../services/apiServices/apiServices.dart';

class MakeOfferController extends GetxController {
  final offerController = TextEditingController();

  void showMakeOfferDialog(
    BuildContext context, {
    required String productId,
    required String userId,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppSizer().height2),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade800, Colors.green.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Enter Your Offer Price",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appWhite,
                  ),
                ),
                SizedBox(height: AppSizer().height2),

                // Offer Input
                SizedBox(
                  height: AppSizer().height6,
                  child: TextFormField(
                    // validator: (value) {
                    // },
                    controller: offerController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppColors.appWhite),

                    decoration: InputDecoration(
                      labelText: "Offer Price",
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixText: "₹ ",
                      prefixStyle: const TextStyle(color: AppColors.appWhite),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.appWhite),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppSizer().height2),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: AppColors.appWhite,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final response = await ApiService.makeOffer(
                          productId: productId,
                          userId: userId,
                          offerPrice: int.parse(
                            offerController.text.toString(),
                          ),
                        );

                        if (response != null && response.status) {
                          Navigator.of(context).pop();
                          Get.snackbar("Success", response.message);
                        } else {
                          Get.snackbar(
                            "Failed",
                            response?.message ?? "Offer failed",
                          );
                        }
                      },

                      child: const Text(
                        "Post Offer",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    offerController.dispose();
    super.onClose();
  }
}
