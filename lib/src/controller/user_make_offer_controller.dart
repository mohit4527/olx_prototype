import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../services/apiServices/apiServices.dart';

class MakeOfferController extends GetxController {
  final offerController = TextEditingController();

  void showMakeOfferDialog({
    required String productId,
    required String buyerId,
    required String sellerId,
  }) {
    Get.dialog(
      Dialog(
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

              // Offer Input Field
              SizedBox(
                height: AppSizer().height6,
                child: TextFormField(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
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
                  // Cancel Button
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: AppColors.appWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Post Offer Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (offerController.text.trim().isEmpty) {
                        Get.snackbar("Error", "Please enter a valid price",
                            backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      final requestBody = {
                        "productId": productId,
                        "buyerId": buyerId,
                        "sellerId": sellerId,
                        "offerPrice": int.parse(offerController.text),
                      };


                      print("📩 Make Offer Request Body: $requestBody");

                      final response = await ApiService.makeOffer(
                        productId: productId,
                        buyerId: buyerId,
                        offerPrice: requestBody["offerPrice"] as int,
                      );
                      print("Make Offer API Response: ${response?.message}");
                      print("Make Offer API Status: ${response?.status}");
                      Get.back();
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (response != null && response.status) {
                          offerController.clear();
                          Get.snackbar("Success", response.message ?? "Offer posted successfully",
                              backgroundColor: Colors.green, colorText: Colors.white);
                        } else {
                          Get.snackbar("Failed", response?.message ?? "Offer failed",
                              backgroundColor: Colors.red, colorText: Colors.white);
                        }
                      });
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
      ),
      barrierDismissible: false,
    );
  }
}
