import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../controller/dealer_details_controller.dart';
import '../dealer_details_product_screen/dealer_product_details_screen.dart';

class DealerDetailScreen extends StatefulWidget {
  final String dealerId;
  const DealerDetailScreen({required this.dealerId});

  @override
  State<DealerDetailScreen> createState() => _DealerDetailScreenState();
}

class _DealerDetailScreenState extends State<DealerDetailScreen> {
  final DealerController controller = Get.find<DealerController>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      controller.fetchDealerStats(widget.dealerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    const baseUrl = "http://oldmarket.bhoomi.cloud/";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
            "Dealer Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
      ),
      body: Obx(() {
        if (controller.isDealerStatsLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.green));
        }

        final dealer = controller.dealerStats.value;
        if (dealer == null) {
          return Center(
            child: Text(
              controller.errorMessage.value.isEmpty
                  ? "No data found"
                  : controller.errorMessage.value,
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final imagePath = dealer.imageUrl?.isNotEmpty == true
            ? dealer.imageUrl!
            : dealer.businessLogo?.isNotEmpty == true
            ? dealer.businessLogo!
            : "";

        final imageUrl = imagePath.isNotEmpty
            ? "$baseUrl${imagePath.replaceFirst(RegExp(r'^/+'), '')}"
            : "";

        print("📸 Dealer Detail => Final imageUrl used: $imageUrl");

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height2,),
              Container(
                width: double.infinity,
                height: AppSizer().height28,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                  child: Icon(
                      Icons.image_not_supported, size: 40, color: Colors.grey),
                )
                    : null,
              ),

              // Business Info
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Business Name:", style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                      Text(dealer.businessName, style: const TextStyle(
                          fontSize: 18)),
                      const SizedBox(height: 10),
                      const Text("Phone:", style: TextStyle(color: Colors.green,
                          fontWeight: FontWeight.bold)),
                      Text(dealer.phone ?? "Not available",
                          style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Stats", style: TextStyle(fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox(
                      "Total Vehicles", dealer.totalVehicles, showSold: false,
                      showStock: false),
                  _statBox("Total Sold", dealer.totalSold, showSold: true,
                      showStock: false),
                  _statBox("Total Stock", dealer.totalStock, showSold: false,
                      showStock: true),
                ],
              )

            ],
          ),
        );
      }),
    );
  }

  Widget _statBox(String title, int count,
      {bool showSold = false, bool showStock = false}) {
    return GestureDetector(
      onTap: () {
        Get.to(() =>
            DealerDetailsProductScreen(
              dealerId: widget.dealerId,
              showSoldOnly: showSold,
              showStockOnly: showStock,
            ));
      },
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.green.shade50,
        child: Container(
          width: 100,
          height: 80,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800),
              ),
              const SizedBox(height: 5),
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.green.shade600),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}