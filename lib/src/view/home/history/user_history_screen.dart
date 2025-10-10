import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/history_controller.dart';
import '../../../controller/testdrive_screenController.dart';
import '../../../custom_widgets/history-card.dart';

class HistoryScreen extends StatelessWidget {
   HistoryScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(UserHistoryController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "User History",
          style: TextStyle(
            fontSize: AppSizer().fontSize20,
            color: AppColors.appWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.productsWithOffers.isEmpty) {
          return Center(child: Text("No products with offers yet"));
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizer().width2),
            child: ListView.builder(
              itemCount: controller.productsWithOffers.length,
              itemBuilder: (context, index) {
                final item = controller.productsWithOffers[index];
                return HistoryCard(
                  productId: item.id,
                  image: item.mediaUrl.isNotEmpty
                      ? "https://oldmarket.bhoomi.cloud/${item.mediaUrl[0]}"
                      : "assets/images/placeholder.jpg",
                  title: item.title,
                  location: item.location.city.isNotEmpty
                      ? item.location.city
                      : "Unknown",
                  price: item.price?.toString() ?? "N/A",
                  controller: controller,
                  role: "user",
                );

              },
            ),
          ),
        );
      }),
    );
  }
}
