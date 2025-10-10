import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_wishlist_controller.dart';
import '../../../controller/user_wishlist_controller.dart';
import '../../../custom_widgets/wishlist_card.dart';
import '../../../model/wishlist_model/wishlist_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final UserWishlistController userWishlistController =
  Get.put(UserWishlistController());
  final DealerWishlistController dealerWishlistController =
  Get.put(DealerWishlistController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appWhite,
      appBar: AppBar(
        title: Text(
          "My Wishlist",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "User"),
            Tab(text: "Dealer"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /// USER WISHLIST
          Obx(() {
            if (userWishlistController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (userWishlistController.wishlist.isEmpty) {
              return const Center(child: Text("No user wishlist items"));
            }
            return Padding(
              padding: EdgeInsets.all(AppSizer().height2),
              child: GridView.builder(
                itemCount: userWishlistController.wishlist.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizer().width2,
                  mainAxisSpacing: AppSizer().height2,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final WishlistItem item =
                  userWishlistController.wishlist[index];
                  return WishlistCard(
                    id: item.id,
                    image: item.image,
                    title: item.title,
                    description: item.description,
                    price: item.price,
                    onRemove: () =>
                        userWishlistController.toggleWishlist(item.id),
                  );
                },
              ),
            );
          }),

          /// DEALER WISHLIST
          Obx(() {
            if (dealerWishlistController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (dealerWishlistController.wishlist.isEmpty) {
              return const Center(child: Text("No dealer wishlist items"));
            }
            return Padding(
              padding: EdgeInsets.all(AppSizer().height2),
              child: GridView.builder(
                itemCount: dealerWishlistController.wishlist.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizer().width2,
                  mainAxisSpacing: AppSizer().height2,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final itemData = dealerWishlistController.wishlist[index];

                  if (itemData is! Map<String, dynamic>) {
                    return Center(child: Text("Invalid data format"));
                  }

                  final List<dynamic> images = itemData['images'] ?? [];
                  final String imageUrl = images.isNotEmpty
                      ? "https://oldmarket.bhoomi.cloud/${images.first.replaceAll('\\', '/')}"
                      : "assets/images/placeholder.jpg";

                  final String title = itemData['title'] ?? 'N/A';
                  final String description = itemData['description'] ?? 'N/A';
                  final String price = itemData['price']?.toString() ?? 'N/A';
                  final String id = itemData['_id'] ?? '';

                  return WishlistCard(
                    id: id,
                    image: imageUrl,
                    title: title,
                    description: description,
                    price: price,
                    onRemove: () => dealerWishlistController.toggleWishlist(id),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
