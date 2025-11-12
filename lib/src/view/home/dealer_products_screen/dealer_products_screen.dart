import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_products_controller.dart';
import '../../../utils/app_routes.dart';

class DealerProductsScreen extends StatelessWidget {
  DealerProductsScreen({super.key});

  final dealerController = Get.put(DealerProductsController());

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }
    return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
  }

  /// Call dealer using phone number from API
  Future<void> _callDealer(String? phoneNumber, String productTitle) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar(
        "📞 Call Not Available",
        "Phone number not available for this product",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.phone_disabled, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      print(
        "📞 [DealerProductsScreen] Calling dealer at: $phoneNumber for product: $productTitle",
      );

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        Get.snackbar(
          "📞 Calling Dealer",
          "Dialing $phoneNumber...",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.phone, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          "❌ Call Failed",
          "Cannot make phone calls on this device",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print("❌ [DealerProductsScreen] Call error: $e");
      Get.snackbar(
        "❌ Call Error",
        "Failed to make call: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Sort Products By',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.sort_by_alpha,
                  color: AppColors.appGreen,
                ),
                title: const Text('Name (A-Z)'),
                onTap: () {
                  dealerController.sortProducts('name_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.sort_by_alpha,
                  color: AppColors.appGreen,
                ),
                title: const Text('Name (Z-A)'),
                onTap: () {
                  dealerController.sortProducts('name_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.currency_rupee,
                  color: AppColors.appGreen,
                ),
                title: const Text('Price (Low to High)'),
                onTap: () {
                  dealerController.sortProducts('price_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.currency_rupee,
                  color: AppColors.appGreen,
                ),
                title: const Text('Price (High to Low)'),
                onTap: () {
                  dealerController.sortProducts('price_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.date_range,
                  color: AppColors.appGreen,
                ),
                title: const Text('Date (Newest First)'),
                onTap: () {
                  dealerController.sortProducts('date_desc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.date_range,
                  color: AppColors.appGreen,
                ),
                title: const Text('Date (Oldest First)'),
                onTap: () {
                  dealerController.sortProducts('date_asc');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dealer Products",
          style: TextStyle(color: AppColors.appWhite),
        ),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSortDialog(context),
            icon: const Icon(Icons.sort, color: AppColors.appWhite),
            tooltip: 'Sort Products',
          ),
        ],
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
          print(
            "🖥️ [DealerProductsScreen] Building UI - Loading: ${dealerController.isLoading.value}, Products: ${dealerController.products.length}",
          );

          // Force refresh if products are empty and not loading
          if (!dealerController.isLoading.value &&
              dealerController.products.isEmpty) {
            print(
              "⚠️ [DealerProductsScreen] Products empty, forcing refresh...",
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              dealerController.fetchDealerProducts();
            });
          }

          if (dealerController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dealerController.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  const Text(
                    "No dealer products found",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print(
                        "🔄 [DealerProductsScreen] Manual refresh triggered",
                      );
                      dealerController.fetchDealerProducts();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appGreen,
                    ),
                    child: const Text(
                      "Refresh",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
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
                  Get.toNamed(
                    AppRoutes.dealer_product_description,
                    arguments: {
                      'productId': product.id,
                      'phoneNumber': product.phone,
                      'dealerName': product.dealerName,
                      'sellerType': product.sellerType,
                    },
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
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
                                const Icon(
                                  Icons.broken_image,
                                  size: 60,
                                  color: Colors.grey,
                                ),
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
                              Text(
                                "Seller: ${product.sellerType}",
                                style: TextStyle(
                                  fontSize: AppSizer().fontSize15,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: AppSizer().height1),
                              if (product.phone != null &&
                                  product.phone!.isNotEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "📞 ${product.phone}",
                                      style: TextStyle(
                                        fontSize: AppSizer().fontSize13,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () => _callDealer(
                                        product.phone,
                                        product.title,
                                      ),
                                      icon: const Icon(
                                        Icons.call,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Call",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        minimumSize: const Size(60, 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (product.phone == null ||
                                  product.phone!.isEmpty)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "📵 No Contact Info",
                                      style: TextStyle(
                                        fontSize: AppSizer().fontSize13,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _callDealer(null, product.title),
                                      icon: const Icon(
                                        Icons.phone_disabled,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "No Call",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 6,
                                        ),
                                        minimumSize: const Size(60, 30),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
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
