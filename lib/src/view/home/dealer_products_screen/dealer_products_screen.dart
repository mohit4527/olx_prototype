import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path/path.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_products_controller.dart';
import '../../../utils/app_routes.dart';

class DealerProductsScreen extends StatelessWidget {
  DealerProductsScreen({super.key});

  final dealerController = Get.find<DealerProductsController>();

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dealer Products", style: TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body:Container(
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
    child:
      Obx(() {
        if (dealerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (dealerController.products.isEmpty) {
          return const Center(child: Text("No dealer products found"));
        }

        return ListView.builder(
          itemCount: dealerController.products.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final product = dealerController.products[index];

            final String imageUrl = product.images.isNotEmpty
                ? (product.images.first.startsWith("http")
                ? product.images.first
                : "https://oldmarket.bhoomi.cloud/${product.images.first}")
                : 'https://picsum.photos/200';

            return InkWell(
              onTap: () {
                Get.toNamed(AppRoutes.dealer_product_description, arguments: product.id);
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageUrl,
                          height: AppSizer().height13,
                          width: AppSizer().width28,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      ),
                      SizedBox(width: AppSizer().width3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: AppSizer().fontSize17)),
                            SizedBox(height: AppSizer().height1),
                            Text("₹ ${product.price}",
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizer().fontSize17)),
                            SizedBox(height: AppSizer().height1),
                            Text("Seller: ${product.sellerType ?? 'N/A'}",
                                style: TextStyle(
                                    fontSize: AppSizer().fontSize15, color: Colors.grey)),
                            SizedBox(height: AppSizer().height1),
                            Text(formatDate(product.createdAt),
                                style: TextStyle(
                                    fontSize: AppSizer().fontSize15, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
      )
    );
  }
}
