import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/logger.dart';
import '../model/challan_model/challan_model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/vehicle_report_service.dart';
import '../view/home/challan_screen/challan_screen.dart';

class ChallanController extends GetxController {
  var challanList = <ChallanModel>[].obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  Future<void> loadChallan(String vehicleNo) async {
    try {
      Logger.d("ChallanController", "Loading challan for: $vehicleNo");
      isLoading.value = true;

      final data = await _apiService.fetchChallan(vehicleNo);
      Logger.d("ChallanController", "API Response: $data");

      challanList.value = data;
      Logger.d(
        "ChallanController",
        "Challan list updated with ${data.length} item(s)",
      );
    } catch (e) {
      Logger.e("ChallanController", "Error: $e");
      challanList.clear();
    } finally {
      isLoading.value = false;
      Logger.d("ChallanController", "Loading complete");
    }
  }

  void showChallanPopup(BuildContext context) {
    Logger.d("ChallanController", "showChallanPopup called");
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
              Text(
                "Enter Vehicle Number",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer().fontSize17,
                  color: AppColors.appGreen,
                ),
              ),
              Divider(color: AppColors.appGrey.shade800, thickness: 1.5),
              SizedBox(height: 17),
              TextField(
                controller: vehicleController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
                decoration: InputDecoration(
                  hintText: "e.g. UP78BY4420",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.appGrey.shade800),
                  ),
                  prefixIcon: Icon(Icons.directions_car),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      final vehicleNo = vehicleController.text
                          .trim()
                          .toUpperCase();
                      Logger.d(
                        "ChallanController",
                        "Vehicle entered: $vehicleNo",
                      );

                      // Fixed regex pattern - removed escaped $ and made it more flexible for Indian vehicle numbers
                      // Pattern: 2 letters + 2 digits + 1-2 letters + 4 digits
                      // Examples: UP70BR2291, MH03DJ2470, DL01AB1234, KA05MZ9999
                      final isValid = RegExp(
                        r'^[A-Z]{2}\d{2}[A-Z]{1,2}\d{4}$',
                      ).hasMatch(vehicleNo);
                      Logger.d(
                        "ChallanController",
                        "Vehicle validation result: $isValid for pattern: 2letters+2digits+1-2letters+4digits",
                      );
                      Logger.d(
                        "ChallanController",
                        "Vehicle breakdown: State=${vehicleNo.length >= 2 ? vehicleNo.substring(0, 2) : 'N/A'}, RTO=${vehicleNo.length >= 4 ? vehicleNo.substring(2, 4) : 'N/A'}, Series=${vehicleNo.length >= 6 ? vehicleNo.substring(4, vehicleNo.length - 4) : 'N/A'}, Number=${vehicleNo.length >= 4 ? vehicleNo.substring(vehicleNo.length - 4) : 'N/A'}",
                      );

                      if (vehicleNo.isEmpty) {
                        Logger.e("ChallanController", "Empty vehicle number");
                        Get.snackbar(
                          "Missing Info",
                          "Please enter a vehicle number",
                          backgroundColor: Colors.redAccent,
                          colorText: Colors.white,
                        );
                      } else if (!isValid) {
                        Logger.e(
                          "ChallanController",
                          "Invalid vehicle format: $vehicleNo",
                        );
                        Get.snackbar(
                          "Invalid Format",
                          "Enter a valid vehicle number like UP32AB1234",
                          backgroundColor: Colors.orangeAccent,
                          colorText: Colors.white,
                        );
                      } else {
                        // Close input dialog
                        Logger.d(
                          "ChallanController",
                          "Closing input dialog and starting RC fetch",
                        );
                        Get.back();

                        // Show loader while fetching RC
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        try {
                          Logger.d(
                            "ChallanController",
                            "Calling ApiService.fetchRcRawResponse for $vehicleNo",
                          );
                          final response = await ApiService.fetchRcRawResponse(
                            vehicleNo,
                          );
                          Logger.d(
                            "ChallanController",
                            "RC Response status: ${response.statusCode}",
                          );
                          Logger.d(
                            "ChallanController",
                            "RC Response body: ${response.body}",
                          );

                          final decoded = ApiService.decodeJson(response.body);
                          Logger.d(
                            "ChallanController",
                            "Decoded RC data: $decoded",
                          );

                          final rcData = decoded['data'] ?? decoded;
                          Logger.d(
                            "ChallanController",
                            "Final rcData: $rcData",
                          );

                          // Close loader
                          Get.back();

                          // Navigate to challan screen with RC data
                          Logger.d(
                            "ChallanController",
                            "Navigating to challan screen with RC data",
                          );
                          Get.to(
                            () => ChallanScreen(
                              vehicleNo: vehicleNo,
                              rcData: rcData,
                            ),
                          );
                        } catch (e) {
                          // Close loader and show error
                          try {
                            Get.back();
                          } catch (_) {}
                          Logger.e("ChallanController", "RC fetch error: $e");
                          Get.snackbar(
                            'RC Error',
                            'Failed to fetch RC details: $e',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      }
                    },
                    child: Text(
                      "Check Vehicle",
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

  Future<void> generateVehicleReport({
    required String vehicleNo,
    required Map<String, dynamic>? rcData,
  }) async {
    try {
      await VehicleReportService.generateVehicleReport(
        vehicleNo: vehicleNo,
        rcData: rcData,
        challanList: challanList,
      );
    } catch (e) {
      Logger.e("ChallanController", "Report Generation Error: $e");
      Get.snackbar(
        'Error',
        'Failed to generate vehicle report: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

/// Input formatter that forces uppercase characters
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}
