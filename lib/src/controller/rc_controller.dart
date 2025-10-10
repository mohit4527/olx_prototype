import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../services/apiServices/apiServices.dart';

class RcController extends GetxController {
  var isLoading = false.obs;
  var rcData = Rxn<Map<String, dynamic>>();
  var errorMessage = ''.obs;

  final vehicleNoController = TextEditingController();

  /// Show input popup
  void showRcPopup(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Enter Vehicle Number",
                style: TextStyle(
                  fontSize: AppSizer().fontSize17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appGreen,
                ),
              ),
              Divider(thickness: 1.5, color: AppColors.appBlack),
              const SizedBox(height: 16),

              /// Input field
              TextField(
                controller: vehicleNoController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.directions_car),
                  hintText: "e.g. UP78BY4420",
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final vehicleNo =
                      vehicleNoController.text.trim().toUpperCase();
                      print("🚗 [RcController] Vehicle entered: $vehicleNo");

                      if (vehicleNo.isEmpty) {
                        Get.snackbar(
                          "Missing Info",
                          "Please enter a vehicle number",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      } else {
                        /// ✅ Popup close + TextField clear turant
                        Get.back();
                        vehicleNoController.clear();

                        /// ✅ API call chalu
                        fetchRcDetails(vehicleNo);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Check RC",
                      style: TextStyle(color: AppColors.appWhite),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch RC details
  Future<void> fetchRcDetails(String vehicleNo) async {
    print("🔄 [RcController] Fetching RC details for: $vehicleNo");
    isLoading.value = true;
    errorMessage.value = '';
    rcData.value = null;

    // ✅ Loading dialog show
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await ApiService.fetchRcRawResponse(vehicleNo);

      print("📥 [RC API] Response Status: ${response.statusCode}");
      print("📥 [RcController] Raw API Response: ${response.body}");

      final decoded = ApiService.decodeJson(response.body);

      if (response.statusCode == 200 && decoded["data"] != null) {
        rcData.value = decoded["data"];
        print("✅ [RcController] RC data parsed successfully");

        Get.back(); // loader band karo
        showRcResultPopup(decoded["data"]);
      } else {
        final message = decoded["messages"] ?? "Failed to fetch RC details";
        errorMessage.value = message;
        print("⚠️ [RcController] API Error Message: $message");

        Get.back(); // loader band karo
        Get.snackbar("RC Error", message,
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      errorMessage.value = "Exception: $e";
      print("❌ [RcController] Exception: $e");

      Get.back(); // loader band karo
      Get.snackbar("RC Error", errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      print("✅ [RcController] Loading complete");
    }
  }


  /// Show RC result popup
  void showRcResultPopup(Map<String, dynamic> data) {
    print("📊 [RcController] Showing RC result popup");

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.appWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "RC Details for ${data['rc_vehicle_no']}",
                style: TextStyle(
                  fontSize: AppSizer().fontSize17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appGreen,
                ),
              ),
              Divider(thickness: 1.5, color: AppColors.appGreen),
              const SizedBox(height: 10),

              _rcDetailRow("Owner", data['rc_owner_name']),
              _rcDetailRow("Model", data['rc_maker_model']),
              _rcDetailRow("Fuel", data['rc_fuel_desc']),
              _rcDetailRow("Insurance", data['rc_insurance_comp']),
              _rcDetailRow("Valid Till", data['rc_fit_upto']),
              _rcDetailRow("Chassis No", data['rc_chasi_no']),
              _rcDetailRow("Engine No", data['rc_eng_no']),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Close",
                    style: TextStyle(color: AppColors.appWhite),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rcDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.appGreen,
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(color: AppColors.appBlack),
            ),
          ),
        ],
      ),
    );
  }
}
