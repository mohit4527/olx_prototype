import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/all_products_controller.dart';
import '../../../custom_widgets/cards.dart';
import '../../../model/all_product_model/all_product_model.dart';

class FilteredProductsScreen extends StatefulWidget {
  const FilteredProductsScreen({super.key});

  @override
  State<FilteredProductsScreen> createState() => _FilteredProductsScreenState();
}

class _FilteredProductsScreenState extends State<FilteredProductsScreen>
    with RouteAware {
  final ProductController productController = Get.find<ProductController>();

  String? country;
  String? state;
  String? city;

  // Store filtered products locally to prevent reset
  final RxList<AllProductModel> _localFilteredProducts =
      <AllProductModel>[].obs;

  @override
  void initState() {
    super.initState();

    // Get location from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      country = args['country'];
      state = args['state'];
      city = args['city'];

      print('🔍 [FilteredProductsScreen] Received location:');
      print('   Country: $country');
      print('   State: $state');
      print('   City: $city');

      // 🔥 IMPORTANT: Fetch products first if list is empty, then filter
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (productController.productList.isEmpty) {
          print('⚠️ [FilteredProductsScreen] Product list empty, fetching...');
          productController.fetchProducts();

          // Wait a moment for products to load
          await Future.delayed(Duration(milliseconds: 500));
        }

        productController.filterProductsByLocation(
          country: country,
          state: state,
          city: city,
        );

        // Store filtered products locally
        _localFilteredProducts.value = List.from(productController.productList);
        print(
          '💾 [FilteredProductsScreen] Stored ${_localFilteredProducts.length} products locally',
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-apply filter when returning to this screen
    if (_localFilteredProducts.isNotEmpty &&
        productController.productList.length != _localFilteredProducts.length) {
      print('🔄 [FilteredProductsScreen] Reapplying filter on return');
      productController.filterProductsByLocation(
        country: country,
        state: state,
        city: city,
      );
      _localFilteredProducts.value = List.from(productController.productList);
    }
  }

  @override
  void dispose() {
    // Clear filter when leaving screen
    productController.clearLocationFilter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Products in ${city ?? state ?? country}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: AppSizer().fontSize18,
              ),
            ),
            if (city != null && state != null)
              Text(
                '$city, $state',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: AppSizer().fontSize12,
                ),
              ),
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            productController.clearLocationFilter();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          // Sort button
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Colors.white),
            onSelected: (String value) {
              productController.sortProducts(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'name_asc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: AppColors.appGreen),
                    SizedBox(width: 8),
                    Text('Name (A-Z)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name_desc',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, color: AppColors.appGreen),
                    SizedBox(width: 8),
                    Text('Name (Z-A)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_asc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, color: AppColors.appGreen),
                    SizedBox(width: 8),
                    Text('Price (Low to High)'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'price_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward, color: AppColors.appGreen),
                    SizedBox(width: 8),
                    Text('Price (High to Low)'),
                  ],
                ),
              ),
            ],
          ),
          // Clear filter button
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.white),
            onPressed: () {
              productController.clearLocationFilter();
              Navigator.of(context).pop();
            },
            tooltip: 'Clear Filter',
          ),
        ],
      ),
      body: Obx(() {
        // Use local filtered products to prevent reset issues
        final displayProducts = _localFilteredProducts.isNotEmpty
            ? _localFilteredProducts
            : productController.productList;

        if (productController.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.appGreen),
                SizedBox(height: 16),
                Text(
                  'Loading products...',
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }

        if (displayProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizer().height3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 100,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No Products in ${city ?? state ?? country}',
                    style: TextStyle(
                      fontSize: AppSizer().fontSize22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Currently there are no products available in this location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizer().fontSize16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try searching in nearby cities or different locations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppSizer().fontSize14,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      productController.clearLocationFilter();
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back, size: 20),
                    label: Text('Choose Another Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Results count header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSizer().height2),
              decoration: BoxDecoration(
                color: AppColors.appGreen.shade50,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.appGreen.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.appGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Found ${displayProducts.length} products',
                    style: TextStyle(
                      fontSize: AppSizer().fontSize15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appGreen.shade800,
                    ),
                  ),
                ],
              ),
            ),

            // Products grid
            Expanded(
              child: GridView.builder(
                key: ValueKey(
                  'filtered_grid_${displayProducts.length}',
                ), // Force rebuild with correct count
                padding: EdgeInsets.all(AppSizer().height2),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizer().width2,
                  mainAxisSpacing: AppSizer().height2,
                  childAspectRatio: 0.7,
                ),
                itemCount: displayProducts.length,
                itemBuilder: (context, index) {
                  // Safety check to prevent RangeError
                  if (index >= displayProducts.length) {
                    print(
                      '⚠️ [FilteredProductsScreen] Index $index out of range for ${displayProducts.length} products',
                    );
                    return SizedBox.shrink();
                  }

                  final product = displayProducts[index];

                  // Build location string
                  String locationString = '';
                  if (product.city != null && product.city!.isNotEmpty) {
                    locationString = product.city!;
                  }
                  if (product.state != null && product.state!.isNotEmpty) {
                    locationString += locationString.isEmpty
                        ? product.state!
                        : ', ${product.state}';
                  }
                  if (product.country != null && product.country!.isNotEmpty) {
                    locationString += locationString.isEmpty
                        ? product.country!
                        : ', ${product.country}';
                  }

                  // Get first image URL
                  final imageUrl = product.mediaUrl.isNotEmpty
                      ? (product.mediaUrl.first.startsWith('http')
                            ? product.mediaUrl.first
                            : 'https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}')
                      : 'https://via.placeholder.com/300';

                  return GestureDetector(
                    onTap: () {
                      // ✅ Pass carId instead of productId to match app_routes.dart
                      Get.toNamed(
                        '/description_screen',
                        arguments: product.id, // Pass as String directly
                      );
                    },
                    child: ProductCard(
                      imagePath: imageUrl,
                      roomInfo: product.title,
                      price: '₹${product.price}',
                      description: product.description,
                      location: locationString,
                      date: product.createdAt != null
                          ? DateTime.tryParse(product.createdAt!)
                          : null,
                      productId: product.id,
                      isDealer: false,
                      userId: product.userId,
                      isBoosted: product.isBoosted,
                      status: product.status,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
