import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/logger.dart';
import '../../../controller/challan_controller.dart';

class ChallanScreen extends StatelessWidget {
  final String vehicleNo;
  final Map<String, dynamic>? rcData;
  const ChallanScreen({super.key, required this.vehicleNo, this.rcData});

  @override
  Widget build(BuildContext context) {
    Logger.d(
      'ChallanScreen',
      'build start - vehicleNo=$vehicleNo rcData=${rcData != null ? "present" : "null"}',
    );
    final controller = Get.put(ChallanController());
    controller.loadChallan(vehicleNo);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Report for $vehicleNo",
          style: TextStyle(
            color: AppColors.appWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green,

        
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Build a column: optional RC details card, then challan list (or none)
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // RC Details Section - Enhanced
            if (rcData != null) ...[
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.appGreen.withOpacity(0.1),
                        Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: AppColors.appGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vehicle RC Details',
                            style: TextStyle(
                              fontSize: AppSizer().fontSize18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.appGreen,
                              AppColors.appGreen.withOpacity(0.3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Display all RC data in organized way
                      ...rcData!.entries.map((entry) {
                        final key = entry.key.toString();
                        final value = entry.value == null
                            ? 'N/A'
                            : entry.value.toString();

                        // Format key name for better readability
                        String displayKey = key
                            .replaceAll('_', ' ')
                            .replaceAll('rc ', '')
                            .toUpperCase();
                        if (displayKey.startsWith('RC ')) {
                          displayKey = displayKey.substring(3);
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.appGreen.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '$displayKey:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.appGreen,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Download Button Section
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Show loading dialog
                  Get.dialog(
                    const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Generating PDF Report...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    barrierDismissible: false,
                  );

                  try {
                    // Generate PDF using controller
                    await controller.generateVehicleReport(
                      vehicleNo: vehicleNo,
                      rcData: rcData,
                    );
                  } finally {
                    // Close loading dialog
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                icon: const Icon(Icons.file_download_outlined, size: 24),
                label: Text(
                  'Download Vehicle Report as PDF',
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}
