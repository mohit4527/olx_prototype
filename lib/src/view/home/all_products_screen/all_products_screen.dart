import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/all_products_controller.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AllProductsScreen extends StatelessWidget {
  AllProductsScreen({super.key});

  final productController = Get.find<ProductController>();

  /// Call user using phone number from API
  Future<void> _callUser(String? phoneNumber, String productTitle) async {
    print(
      "[AllProductsScreen] 🔥 _callUser called with phone: $phoneNumber, product: $productTitle",
    );

    // Enhanced phone validation
    if (phoneNumber == null ||
        phoneNumber.isEmpty ||
        phoneNumber == "null" ||
        phoneNumber.length < 10 ||
        !RegExp(
          r'^[6-9][0-9]{9}$',
        ).hasMatch(phoneNumber.replaceAll(RegExp(r'[^\d]'), ''))) {
      print("[AllProductsScreen] ❌ Invalid phone number: $phoneNumber");
      Get.snackbar(
        "📞 Call Not Available",
        "Valid phone number not available for this product",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.phone_disabled, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      print(
        "📞 [AllProductsScreen] Calling user at: $phoneNumber for product: $productTitle",
      );

      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        Get.snackbar(
          "📞 Calling User",
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
      print("❌ [AllProductsScreen] Call error: $e");
      Get.snackbar(
        "❌ Call Error",
        "Failed to make call: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime dateTime = DateTime.parse(dateStr).toLocal();
      return "${dateTime.day}-${dateTime.month}-${dateTime.year}";
    } catch (e) {
      return '';
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
                  productController.sortProducts('name_asc');
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
                  productController.sortProducts('name_desc');
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
                  productController.sortProducts('price_asc');
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
                  productController.sortProducts('price_desc');
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
                  productController.sortProducts('date_desc');
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
                  productController.sortProducts('date_asc');
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
          "All Products",
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

              // 🔥 Debug phone numbers
              print(
                '[AllProductsScreen] Product ${index}: ${product.title}, Phone: "${product.phone}"',
              );

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
                              // 🔥 Call functionality section - Enhanced validation
                              if (product.phone != null &&
                                  product.phone!.isNotEmpty &&
                                  product.phone != "null" &&
                                  product.phone!.length >= 10)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "📞 ${product.phone}",
                                        style: TextStyle(
                                          fontSize: AppSizer().fontSize13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        print(
                                          '[AllProductsScreen] 🔥 Call button pressed for: ${product.title}, Phone: ${product.phone}',
                                        );
                                        _callUser(product.phone, product.title);
                                      },
                                      icon: const Icon(
                                        Icons.call,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        "Call",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
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
                                  product.phone!.isEmpty ||
                                  product.phone == "null" ||
                                  product.phone!.length < 10)
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
                                          _callUser(null, product.title),
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
