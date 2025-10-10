import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path/path.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_history_controller.dart';
import '../../../custom_widgets/history-card.dart';

class DealerHistoryScreen extends StatelessWidget {
   DealerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(DealerHistoryController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProducts();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Dealer History", style: TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: AppColors.appWhite)),
      ),
      body: Obx(() {
        if (controller.isLoadingProducts.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.dealerProducts.isEmpty) {
          return Center(child: Text("No products found"));
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
        child:Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.builder(
            itemCount: controller.dealerProducts.length,
            itemBuilder: (context, index) {
              final product = controller.dealerProducts[index];
              return HistoryCard(
                image: product.images.isNotEmpty ? product.images[0] : "assets/images/placeholder.png",
                productId: product.id,
                title: product.title,
                location: product.location.toString(),
                price: product.price.toString(),
                controller: controller,
                role: "dealer",
              );

            },
          ),
        ),
        );
      }),
    );
  }
}
