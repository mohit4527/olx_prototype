import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/all_products_controller.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';

class AllProductsScreen extends StatelessWidget {
  AllProductsScreen({super.key});

  final productController = Get.find<ProductController>();

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Products",
          style: TextStyle(color: AppColors.appWhite),
        ),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Container(
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
        child: Obx(() {
          if (productController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: productController.productList.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final product = productController.productList[index];
              final String imageUrl = product.mediaUrl.isNotEmpty
                  ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                  : 'https://picsum.photos/200';

              return InkWell(
                onTap: () {
                  // Navigate directly to DescriptionScreen instance to avoid
                  // any route-argument parsing mismatch.
                  print('[AllProductsScreen] Tapping product id=${product.id}');
                  Get.to(
                    () => DescriptionScreen(
                      carId: product.id,
                      productId: '',
                      sellerId: '',
                      sellerName: '',
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(12),
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
                          ),
                        ),
                        SizedBox(width: AppSizer().width3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppSizer().fontSize17,
                                ),
                              ),
                              SizedBox(height: AppSizer().height1),
                              Text(
                                "₹ ${product.price}",
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppSizer().fontSize17,
                                ),
                              ),
                              SizedBox(height: AppSizer().height1),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(width: AppSizer().width1),
                                  Expanded(
                                    child: Text(
                                      product.location.city,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppSizer().fontSize15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSizer().height1),
                              Text(
                                formatDate(product.createdAt),
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize15,
                                  color: Colors.grey,
                                ),
                              ),
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
      ),
    );
  }
}
