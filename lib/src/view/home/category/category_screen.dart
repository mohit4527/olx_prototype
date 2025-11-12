import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../controller/category_controller.dart';
import '../../../controller/token_controller.dart';
import '../../../utils/app_routes.dart';

class CategoryScreen extends StatefulWidget {
  CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  final CategoryController controller = Get.put(CategoryController());
  final List<String> categories = ['all', 'cars', 'two-wheeler', 'others'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    // Update the controller based on tab index
    final newTab = _tabController.index == 0 ? 'user' : 'dealer';
    if (controller.selectedTab.value != newTab) {
      controller.selectedTab.value = newTab;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.appWhite),
        title: Text("Category", style: TextStyle(color: AppColors.appWhite)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: "User"),
            Tab(text: "Dealer"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // User tab
          Column(
            children: [
              SizedBox(height: AppSizer().height1),
              _buildCategoryFilter(),
              SizedBox(height: AppSizer().height1),
              Expanded(child: _buildProductList()),
            ],
          ),
          // Dealer tab
          Column(
            children: [
              SizedBox(height: AppSizer().height1),
              _buildCategoryFilter(),
              SizedBox(height: AppSizer().height1),
              Expanded(child: _buildProductList()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSizer().width2),
        child: Row(
          children: categories.map((cat) {
            final isSelected = controller.selectedCategory.value == cat;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: ChoiceChip(
                label: Text(cat.capitalizeFirst ?? cat),
                selected: isSelected,
                onSelected: (_) {
                  // Use optimized filtering method
                  controller.filterByCategory(cat);
                },
                selectedColor: AppColors.appGreen,
                backgroundColor: Colors.grey.shade300,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: AppColors.appGreen),
        );
      }

      if (controller.productList.isEmpty) {
        return Center(child: Text("No products found"));
      }

      return RefreshIndicator(
        color: AppColors.appGreen,
        onRefresh: () => controller.refreshData(),
        child: GridView.builder(
          padding: EdgeInsets.all(6),
          itemCount: controller.productList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 8,
            childAspectRatio: 0.63,
          ),
          itemBuilder: (context, index) {
          final item = controller.productList[index];
          final isUser = controller.selectedTab.value == 'user';
          final imageList = isUser ? item['mediaUrl'] : item['images'];

          Widget imageWidget;
          if (imageList != null &&
              imageList.isNotEmpty &&
              imageList[0] != null &&
              imageList[0].toString().isNotEmpty) {
            final imageUrl = "https://oldmarket.bhoomi.cloud/${imageList[0]}";
            imageWidget = Image.network(
              imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
            );
          } else {
            imageWidget = Image.asset(
              "assets/images/placeholder.jpg",
              width: double.infinity,
              fit: BoxFit.cover,
            );
          }

          final location = isUser
              ? (item['location'] != null && item['location']['city'] != null
                    ? item['location']['city']
                    : 'Unknown')
              : (item['dealerName'] ?? 'Dealer');

          return GestureDetector(
            onTap: () {
              final productId = item['_id']?.toString() ?? '';

              if (productId.isEmpty) {
                print("Product ID missing for item: $item");
                Get.snackbar("Error", "Product ID is missing");
                return;
              }

              final token = Get.find<TokenController>();
              if (!token.isLoggedIn) {
                Get.toNamed(AppRoutes.login);
                return;
              }

              if (controller.selectedTab.value == 'user') {
                Get.toNamed(AppRoutes.description, arguments: productId);
              } else {
                Get.toNamed(
                  AppRoutes.dealer_product_description,
                  arguments: productId,
                );
              }
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: imageWidget,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] ?? 'No Title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: AppSizer().height1),
                          Text(
                            item['description'] ?? 'No Title',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: AppSizer().height1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹ ${item['price'] ?? '₹--'} ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                location,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ),
                ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}