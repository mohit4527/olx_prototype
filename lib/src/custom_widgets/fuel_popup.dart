import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../view/home/fuel_screen/fuel_screen.dart';

void showFuelLocationPopup(BuildContext context) {
  final cityController = TextEditingController();
  final stateController = TextEditingController();

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSizer().width4,
          vertical: AppSizer().height2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Location",
              style: TextStyle(
                fontSize: AppSizer().fontSize18,
                fontWeight: FontWeight.bold,
                color: AppColors.appGreen,
              ),
            ),
            SizedBox(height: AppSizer().height2),
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: "City",
                labelStyle: TextStyle(
                  color: AppColors.appGrey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.appGrey.shade700),
                ),
                prefixIcon: Icon(
                  Icons.location_city,
                  color: AppColors.appGrey.shade800,
                ),
              ),
            ),
            SizedBox(height: AppSizer().height2),
            TextField(
              controller: stateController,
              decoration: InputDecoration(
                labelText: "State",
                labelStyle: TextStyle(
                  color: AppColors.appGrey.shade700,
                  fontWeight: FontWeight.w600,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.appGrey.shade700),
                ),
                prefixIcon: Icon(Icons.map, color: AppColors.appGrey.shade800),
              ),
            ),
            SizedBox(height: AppSizer().height3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: AppSizer().fontSize16,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width4,
                      vertical: AppSizer().height1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(
                    Icons.local_gas_station,
                    size: 18,
                    color: AppColors.appWhite,
                  ),
                  label: Text(
                    "See Prices",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize16,
                      color: AppColors.appWhite,
                    ),
                  ),
                  onPressed: () {
                    final city = cityController.text.trim();
                    final state = stateController.text.trim();
                    if (city.isNotEmpty && state.isNotEmpty) {
                      Get.back();
                      Get.to(() => CheckFuelScreen(city: city, state: state));
                    } else {
                      Get.snackbar(
                        "Missing Info",
                        "Please enter both city and state",
                        backgroundColor: Colors.redAccent,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
