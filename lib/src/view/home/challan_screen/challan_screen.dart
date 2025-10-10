import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../../../controller/challan_controller.dart';

class ChallanScreen extends StatelessWidget {
  final String vehicleNo;
  const ChallanScreen({super.key, required this.vehicleNo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChallanController());
    controller.loadChallan(vehicleNo);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Challan for $vehicleNo",
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

        if (controller.challanList.isEmpty) {
          return const Center(child: Text("✅ No Challan Found"));
        }

        return ListView.builder(
          itemCount: controller.challanList.length,
          itemBuilder: (context, index) {
            final challan = controller.challanList[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text("Reason: ${challan.reason}"),
                subtitle: Text("Date: ${challan.date}"),
                trailing: Text(challan.amount),
              ),
            );
          },
        );
      }),
    );
  }
}
