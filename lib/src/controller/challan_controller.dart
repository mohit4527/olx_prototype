import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../model/challan_model/challan_model.dart';
import '../services/apiServices/apiServices.dart';
import '../view/home/challan_screen/challan_screen.dart';

class ChallanController extends GetxController {
  var challanList = <ChallanModel>[].obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  Future<void> loadChallan(String vehicleNo) async {
    try {
      print("🔄 [ChallanController] Loading challan for: $vehicleNo");
      isLoading.value = true;

      final data = await _apiService.fetchChallan(vehicleNo);
      print("📥 [ChallanController] API Response: $data");

      challanList.value = data;
      print("✅ [ChallanController] Challan list updated with ${data.length} item(s)");
    } catch (e) {
      print("❌ [ChallanController] Error: $e");
      challanList.clear();
    } finally {
      isLoading.value = false;
      print("✅ [ChallanController] Loading complete");
    }
  }

  void showChallanPopup(BuildContext context) {
    final vehicleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter Vehicle Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppSizer().fontSize17, color: AppColors.appGreen)),
              Divider(color: AppColors.appGrey.shade800, thickness: 1.5),
              SizedBox(height: 17),
              TextField(
                controller: vehicleController,
                decoration: InputDecoration(
                  hintText: "e.g. UP78BY4420",
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.appGrey.shade800)),
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      final vehicleNo = vehicleController.text.trim().toUpperCase();
                      print("🚗 [ChallanController] Vehicle entered: $vehicleNo");

                      final isValid = RegExp(r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{4}$').hasMatch(vehicleNo);

                      if (vehicleNo.isEmpty) {
                        Get.snackbar("Missing Info", "Please enter a vehicle number", backgroundColor: Colors.redAccent, colorText: Colors.white);
                      } else if (!isValid) {
                        Get.snackbar("Invalid Format", "Enter a valid vehicle number like UP32AB1234", backgroundColor: Colors.orangeAccent, colorText: Colors.white);
                      } else {
                        Get.back();
                        Get.to(() => ChallanScreen(vehicleNo: vehicleNo));
                      }
                    },
                    child: Text("Check Challan", style: TextStyle(color: AppColors.appWhite)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

