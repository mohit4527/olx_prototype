import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_book_test_drives_scree_controller.dart';

class DealerTestDriveScreen extends StatelessWidget {
   DealerTestDriveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final args = Get.arguments as Map<String, dynamic>;
    final carId = args["productId"];
    final productTitle = args["productTitle"];
    final controller = Get.put(DealerTestDriveController(carId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        title: Text("Dealer Test Drives - $productTitle", style: const TextStyle(color: AppColors.appWhite)),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.testDrives.isEmpty) {
          return const Center(child: Text("No Test Drives Found", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)));
        }

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
              colors: [Colors.black, Colors.grey.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [AppColors.appGreen, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.testDrives.length,
            itemBuilder: (context, index) {
              final item = controller.testDrives[index];
              final status = item.status?.toLowerCase();

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name ?? "No Name Provided", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),

                      if (item.phone != null)
                        Row(children: [const Icon(Icons.phone, size: 18, color: AppColors.appGreen), const SizedBox(width: 6), Text(item.phone!)]),

                      const SizedBox(height: 6),

                      if (item.date != null)
                        Row(children: [const Icon(Icons.calendar_today, size: 18, color: AppColors.appGreen), const SizedBox(width: 6), Text(item.formattedDate)]),

                      const SizedBox(height: 6),

                      if (item.time != null)
                        Row(children: [const Icon(Icons.access_time, size: 18, color: AppColors.appGreen), const SizedBox(width: 6), Text(item.formattedTime)]),

                      const SizedBox(height: 10),

                      /// 🔹 Status UI
                      if (status == "pending")
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await controller.updateDealerTestDriveStatus(index, "accept");
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text("Accept", style: TextStyle(color: AppColors.appWhite)),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () async {
                                await controller.updateDealerTestDriveStatus(index, "reject");
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text("Reject", style: TextStyle(color: AppColors.appWhite)),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status ?? ""),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Test Drive ${status!.capitalize}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
