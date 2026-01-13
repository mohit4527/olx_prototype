import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/city_products_controller.dart';
import '../../../custom_widgets/shortVideoWidget.dart';
import '../../../custom_widgets/cards.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';

class CityProductsScreen extends StatelessWidget {
  final String cityName;

  const CityProductsScreen({super.key, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CityProductsController(cityName));

    return Scaffold(
      backgroundColor: AppColors.appWhite,
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        elevation: 2,
        iconTheme: IconThemeData(color: AppColors.appWhite),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
          onPressed: () {
            Navigator.of(context).pop();
            // Also try Get.back() as fallback
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          'Products in $cityName',
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.appGreen),
            ),
          );
        }

        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 80, color: AppColors.appGrey),
                SizedBox(height: 16),
                Text(
                  'No products found in $cityName',
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    color: AppColors.appGrey,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    foregroundColor: AppColors.appWhite,
                  ),
                  onPressed: () => controller.retryFetch(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCityProducts(),
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with count
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.appGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.appGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: AppColors.appGreen,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Found ${controller.products.length} products in $cityName',
                          style: TextStyle(
                            fontSize: AppSizer().fontSize16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.appGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizer().height2),

                // Products grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: controller.products.length,
                    itemBuilder: (context, index) {
                      final product = controller.products[index];

                      // Get first image URL
                      String imageUrl = '';
                      if (product.images != null &&
                          product.images!.isNotEmpty) {
                        imageUrl = product.images!.first;
                        if (!imageUrl.startsWith('http')) {
                          imageUrl = 'https://oldmarket.bhoomi.cloud/$imageUrl';
                        }
                      }

                      return GestureDetector(
                        onTap: () {
                          // Navigate to description screen
                          try {
                            Get.toNamed(
                              '/description_screen',
                              arguments: {
                                'productData': {
                                  'id': product.id ?? '',
                                  'title': product.title ?? 'Product',
                                  'description': product.description ?? '',
                                  'price': product.price ?? 0,
                                  'images': product.images ?? [],
                                  'location': product.city ?? cityName,
                                  'userId': product.userId ?? '',
                                  'dealerId': product.dealerId ?? '',
                                  'phone': product.phone ?? '',
                                  'category': product.category ?? 'general',
                                  'condition': product.condition ?? 'used',
                                },
                              },
                            );
                          } catch (e) {
                            print('❌ Navigation error: $e');
                            // Fallback navigation
                            Navigator.pushNamed(
                              context,
                              '/description_screen',
                              arguments: {
                                'productData': {
                                  'id': product.id ?? '',
                                  'title': product.title ?? 'Product',
                                  'description': product.description ?? '',
                                  'price': product.price ?? 0,
                                  'images': product.images ?? [],
                                  'location': product.city ?? cityName,
                                },
                              },
                            );
                          }
                        },
                        child: ProductCard(
                          imagePath: imageUrl,
                          roomInfo: product.title ?? 'Product',
                          price: '₹${product.price ?? 0}',
                          description: product.description ?? '',
                          location: '$cityName, India',
                          productId: product.id ?? '',
                          isDealer: true,
                          status: product.status,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
