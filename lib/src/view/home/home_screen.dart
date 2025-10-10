import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart' as badges show Badge, BadgePosition;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/constants/app_strings_constant.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/view/home/ads/ads_screen.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import '../../controller/challan_controller.dart';
import '../../controller/dealer_details_controller.dart';
import '../../controller/login_controller.dart';
import '../../controller/rc_controller.dart';
import '../../controller/recently_viewed_controller.dart';
import '../../controller/search_controller.dart';
import '../../controller/all_products_controller.dart';
import '../../controller/dealer_controller.dart';
import '../../controller/dealer_wishlist_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/navigation_controller.dart';
import '../../controller/short_video_controller.dart';
import '../../controller/token_controller.dart';
import '../../controller/user_wishlist_controller.dart';
import '../../custom_widgets/cards.dart';
import '../../custom_widgets/fuel_popup.dart';
import '../../custom_widgets/shortVideoWidget.dart';
// We'll render lightweight thumbnails for most cards and only create a
// VideoPlayerWidget for the centered item to show a short autoplay preview.
import '../../model/recently_product_model/recently_product_model.dart';
import '../../model/all_product_model/all_product_model.dart';
import 'category/category_screen.dart';
import 'chat/chat_screen.dart';
import 'dealer_detail/dealer_detail_screen.dart';
// removed unused imports

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recentlyViewedController = Get.put(RecentlyViewedController());
  final shortVideoController = Get.put(ShortVideoController());
  // Controller for the horizontal suggested videos list to detect visible item
  final ScrollController _suggestedScrollController = ScrollController();
  int _activePreviewIndex = 0;
  final UserWishlistController wishlistController = Get.put(
    UserWishlistController(),
  );
  final DealerWishlistController dealerWishlistController = Get.put(
    DealerWishlistController(),
  );
  final NavigationController controller = Get.put(NavigationController());
  final productController = Get.find<ProductController>();
  final dController = Get.put(DealerController());
  final rcController = Get.put(RcController());

  TokenController tokenController = Get.find<TokenController>();
  final loginController = Get.put(LoginController());
  final SearchController searchcontroller = Get.put(SearchController());
  final HomeController homeController = Get.find<HomeController>();
  final dealerController = Get.find<DealerProfileController>();

  /// Try to return up to [limit] of the logged-in user's products.
  /// Return up to [limit] top products from the global product list.
  /// This shows items uploaded by any user (recent/featured)
  Future<List<AllProductModel>> _fetchTopItems({int limit = 4}) async {
    try {
      final all = productController.productList;
      if (all.isEmpty) {
        // Try to trigger a fetch if list is empty and wait briefly
        try {
          await searchcontroller.fetchProducts();
        } catch (_) {}
      }
      return productController.productList
          .take(limit)
          .toList()
          .cast<AllProductModel>();
    } catch (e) {
      print('[HomeScreen] _fetchTopItems error: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    // One-time setup
    dController.fetchAllDealers();
    // Register profile controller if not present
    if (!Get.isRegistered<GetProfileController>()) {
      Get.put(GetProfileController());
    }
    // Fetch products once
    searchcontroller.fetchProducts();
    // Listen to scroll events on suggested videos to activate a single preview
    _suggestedScrollController.addListener(_onSuggestedScroll);
  }

  void _onSuggestedScroll() {
    try {
      // Estimated width per item: 150 + margin (8 left + 8 right)
      const double itemExtent = 166.0;
      final offset = _suggestedScrollController.offset;
      final screenWidth = MediaQuery.of(context).size.width;
      final center = offset + (screenWidth / 2);
      int index = (center / itemExtent).floor();
      final maxIndex = shortVideoController.suggestedVideos.length - 1;
      if (index < 0) index = 0;
      if (index > maxIndex) index = maxIndex;
      if (index != _activePreviewIndex) {
        setState(() {
          _activePreviewIndex = index;
        });
      }
    } catch (e) {
      // ignore layout timing errors
    }
  }

  DateTime? parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateStr).toLocal();
      } catch (e) {
        return null;
      }
    }
  }

  String _fullVideoUrl(String path) {
    if (path.isEmpty) return '';
    final fixed = path.replaceAll('\\', '/');
    if (fixed.startsWith('http')) return fixed;
    const baseAssets = 'http://oldmarket.bhoomi.cloud/';
    final rel = fixed.startsWith('/') ? fixed.substring(1) : fixed;
    return '$baseAssets$rel';
  }

  final List<String> carouselImages = [
    "assets/images/poster1.jpeg",
    "assets/images/poster2.jpg",
    "assets/images/poster3.jpg",
    "assets/images/poster4.jpg",
    "assets/images/poster5.jpg",
  ];

  List<Map<String, dynamic>> getDrawerItems() {
    final List<Map<String, dynamic>> baseItems = [
      {
        'name': 'Profile',
        'icon': Icons.person,
        'onTap': () => Get.toNamed(AppRoutes.profile),
      },
      {
        'name': 'History',
        'icon': Icons.history,
        'isDropdown': true,
        'dropdownItems': [
          {
            'label': 'User History',
            'style': const TextStyle(color: Colors.green),
            'value': 'user',
            'route': AppRoutes.history,
          },
          {
            'label': 'Dealer History',
            'style': const TextStyle(color: Colors.orange),
            'value': 'dealer',
            'route': AppRoutes.dealer_history_screen,
          },
        ],
      },
      {
        'name': 'Setting',
        'icon': Icons.settings,
        'onTap': () => Get.toNamed(AppRoutes.setting),
      },
      {
        'name': 'LogOut',
        'icon': Icons.logout,
        'onTap': () => Get.toNamed(AppRoutes.logout),
      },
    ];

    if (dealerController.isProfileCreated.value) {
      baseItems.insert(1, {
        'name': 'Edit Dealer Profile',
        'icon': Icons.person,
        'onTap': () => Get.toNamed(AppRoutes.edit_dealer_profile),
      });
    } else {
      baseItems.insert(1, {
        'name': 'Dealer',
        'icon': Icons.perm_identity,
        'onTap': () => Get.toNamed(AppRoutes.dealer),
      });
    }

    baseItems.insert(2, {
      'name': 'Sell',
      'icon': Icons.directions_car,
      'onTap': () {
        // Choose route based on dealer profile existence
        final route = dealerController.isProfileCreated.value
            ? AppRoutes.sell_dealer_cars
            : AppRoutes.sell_user_cars;
        Get.toNamed(route);
      },
    });
    // Add Ads entry
    // baseItems.insert(3, {
    //   'name': 'My Ads',
    //   'icon': Icons.sell,
    //   'onTap': () => Get.toNamed(AppRoutes.ads),
    // });
    return baseItems;
  }

  @override
  Widget build(BuildContext context) {
    final getProfileController = Get.find<GetProfileController>();
    return Obx(() {
      int selectedIndex = controller.selectedIndex.value;
      return WillPopScope(
        onWillPop: () async {
          if (controller.selectedIndex.value != 0) {
            controller.selectedIndex.value = 0;
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: selectedIndex == 0
              ? AppBar(
                  iconTheme: const IconThemeData(color: AppColors.appGreen),
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/OldMarketLogo.png',
                        height: 45,
                      ),
                      SizedBox(width: AppSizer().width2),
                      // Ensure username text doesn't overflow the app bar by
                      // constraining space with Expanded and using maxLines
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStringConstant.appTitle,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: AppSizer().fontSize15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Obx(() {
                              // Prefer TokenController stored displayName (from signup/google), else profile controller
                              final savedName =
                                  tokenController.displayName.value;
                              final username = (savedName.isNotEmpty)
                                  ? savedName
                                  : (getProfileController
                                            .profileData['Username'] ??
                                        'Guest');
                              return Text(
                                username,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.appGreen,
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() {
                          int totalWishlistItems =
                              wishlistController.wishlist.length +
                              dealerWishlistController.wishlist.length;
                          return badges.Badge(
                            badgeContent: Text(
                              totalWishlistItems.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            showBadge: totalWishlistItems > 0,
                            position: badges.BadgePosition.topEnd(
                              top: -4,
                              end: -4,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: AppColors.appGreen,
                              ),
                              onPressed: () {
                                if (tokenController.apiToken.value.isEmpty) {
                                  Get.snackbar(
                                    "Login Required",
                                    "Please login first",
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                  Get.toNamed(AppRoutes.login);
                                } else {
                                  Get.toNamed(AppRoutes.wishlist_screen);
                                }
                              },
                            ),
                          );
                        }),
                        IconButton(
                          icon: const Icon(
                            Icons.notifications,
                            color: AppColors.appGreen,
                          ),
                          onPressed: () {
                            if (tokenController.apiToken.value.isEmpty) {
                              Get.snackbar(
                                "Login Required",
                                "Please login first",
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                              Get.toNamed(AppRoutes.login);
                            } else {
                              Get.to(NotificationScreen());
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.local_gas_station,
                            color: AppColors.appGreen,
                          ),
                          onPressed: () => showFuelLocationPopup(context),
                        ),
                      ],
                    ),
                  ],
                )
              : null,
          drawer: Drawer(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizer().height5),
                  Row(
                    children: [
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate directly to profile when avatar tapped
                              Get.toNamed(AppRoutes.profile);
                            },
                            child: Obx(() {
                              final savedPhoto = tokenController.photoUrl.value;
                              final localPath =
                                  getProfileController.imagePath.value;
                              if (savedPhoto.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xfffae293),
                                  backgroundImage: NetworkImage(savedPhoto),
                                );
                              } else if (localPath.isNotEmpty) {
                                return CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xfffae293),
                                  backgroundImage: FileImage(File(localPath)),
                                );
                              } else {
                                return const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Color(0xfffae293),
                                  child: Icon(Icons.person, size: 45),
                                );
                              }
                            }),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        "Choose",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: AppSizer().fontSize19,
                                          color: AppColors.appPurple,
                                        ),
                                      ),
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    getProfileController
                                                        .getImageByCamera();
                                                    Get.back();
                                                  },
                                                  icon: const Icon(
                                                    Icons.camera_alt,
                                                    color: AppColors.appBlue,
                                                  ),
                                                ),
                                                Text(
                                                  "Camera",
                                                  style: TextStyle(
                                                    color: AppColors.appPurple,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        AppSizer().fontSize16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    getProfileController
                                                        .getImageByGallery();
                                                    Get.back();
                                                  },
                                                  icon: const Icon(
                                                    Icons.image,
                                                    color: AppColors.appBlue,
                                                  ),
                                                ),
                                                Text(
                                                  "Gallery",
                                                  style: TextStyle(
                                                    color: AppColors.appPurple,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize:
                                                        AppSizer().fontSize16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.appBlack,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: AppSizer().height2,
                                  color: AppColors.appWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: AppSizer().width5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => Text(
                              getProfileController.profileData['Username'] ??
                                  '',
                              style: TextStyle(
                                fontSize: AppSizer().fontSize17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(() {
                            final role =
                                getProfileController.profileData['Role'] ??
                                'User';
                            return Text(
                              role,
                              style: TextStyle(color: Colors.grey.shade700),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer().height3),
                  const Divider(
                    height: 1.2,
                    thickness: 2,
                    color: AppColors.appGrey,
                  ),
                  SizedBox(height: AppSizer().height1),
                  Expanded(
                    child: Obx(() {
                      final drawerItems = getDrawerItems();
                      return ListView.builder(
                        itemCount: drawerItems.length,
                        itemBuilder: (context, index) {
                          final item = drawerItems[index];

                          if (item['isDropdown'] == true) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: AppSizer().height6,
                                width: AppSizer().width100,
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: PopupMenuButton<String>(
                                  color: AppColors.appGreen,
                                  icon: Row(
                                    children: [
                                      SizedBox(width: AppSizer().width3),
                                      Icon(
                                        item['icon'],
                                        color: AppColors.appWhite,
                                      ),
                                      SizedBox(width: AppSizer().width2),
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          color: AppColors.appWhite,
                                          fontSize: AppSizer().fontSize16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.appBlack,
                                      ),
                                    ],
                                  ),
                                  onSelected: (String result) {
                                    final selected =
                                        (item['dropdownItems'] as List)
                                            .firstWhere(
                                              (element) =>
                                                  element['value'] == result,
                                            );
                                    Get.toNamed(selected['route']);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return (item['dropdownItems'] as List)
                                        .map<PopupMenuEntry<String>>((
                                          dropdownItem,
                                        ) {
                                          return PopupMenuItem<String>(
                                            value: dropdownItem['value'],
                                            child: Text(
                                              dropdownItem['label'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        })
                                        .toList();
                                  },
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => item['onTap']?.call(),
                                child: Container(
                                  height: AppSizer().height6,
                                  width: AppSizer().width100,
                                  decoration: BoxDecoration(
                                    color: AppColors.appGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: AppSizer().width3),
                                      Icon(
                                        item['icon'],
                                        color: AppColors.appWhite,
                                      ),
                                      SizedBox(width: AppSizer().width2),
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          color: AppColors.appWhite,
                                          fontSize: AppSizer().fontSize16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          body: Obx(() {
            switch (controller.selectedIndex.value) {
              case 0:
                return SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: AppSizer().height2),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: AppSizer().height6,
                                child: TextField(
                                  onChanged: searchcontroller.searchProducts,
                                  decoration: InputDecoration(
                                    fillColor: AppColors.appGreen.withOpacity(
                                      0.3,
                                    ),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        searchcontroller.searchProducts(
                                          "",
                                        ); // reset search
                                      },
                                      icon: const Icon(
                                        Icons.search,
                                        color: Color(0xff11a35a),
                                      ),
                                    ),
                                    hintText: 'Search Products...',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: AppSizer().height1),
                            Obx(() {
                              if (searchcontroller.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (searchcontroller.products.isNotEmpty) {
                                return SizedBox(
                                  height: AppSizer().height30,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: searchcontroller.products.length,
                                    itemBuilder: (context, index) {
                                      final product =
                                          searchcontroller.products[index];
                                      final imageUrl =
                                          product.mediaUrl.isNotEmpty
                                          ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                                          : 'https://via.placeholder.com/150';
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: AppSizer().width1,
                                        ),
                                        child: AspectRatio(
                                          aspectRatio: 2.3 / 3,
                                          child: InkWell(
                                            onTap: () {
                                              recentlyViewedController
                                                  .addProduct(
                                                    RecentlyViewedModel(
                                                      id: product.id,
                                                      title: product.title,
                                                      image:
                                                          product
                                                              .mediaUrl
                                                              .isNotEmpty
                                                          ? product
                                                                .mediaUrl
                                                                .first
                                                          : "",
                                                      price: product.price
                                                          .toString(),
                                                      type: "all",
                                                      createdAt: DateTime.now(),
                                                    ),
                                                  );
                                              Get.toNamed(
                                                AppRoutes.description,
                                                arguments: product.id,
                                              );
                                            },
                                            child: ProductCard(
                                              imagePath: imageUrl,
                                              roomInfo: product.title,
                                              price: "₹ ${product.price}",
                                              description: product.description,
                                              location: product.city,
                                              date: parseDateString(
                                                product.createdAt,
                                              ),
                                              productId: product.id,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
                            SizedBox(height: AppSizer().height3),
                            CarouselSlider(
                              options: CarouselOptions(
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 2),
                                height: AppSizer().height26,
                                viewportFraction: 1.0,
                              ),
                              items: carouselImages.map((item) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.appGrey,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColors.appWhite,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.asset(
                                          item,
                                          fit: BoxFit.cover,
                                          height: AppSizer().height16,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizer().width3,
                                vertical: AppSizer().height2,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ✅ Check Challan Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.receipt_long,
                                        size: AppSizer().height10,
                                        color: AppColors.appGreen,
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      Text(
                                        "Check Challan",
                                        style: TextStyle(
                                          fontSize: AppSizer().fontSize18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appGreen,
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          final loginController =
                                              Get.find<LoginController>();
                                          final challanController =
                                              Get.find<ChallanController>();

                                          if (loginController
                                              .tokenController
                                              .apiToken
                                              .value
                                              .isEmpty) {
                                            Get.snackbar(
                                              "Login Required",
                                              "Please login first to continue",
                                              backgroundColor: Colors.red,
                                              colorText: Colors.white,
                                            );
                                            Get.toNamed(AppRoutes.login);
                                          } else {
                                            challanController.showChallanPopup(
                                              Get.context!,
                                            );
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Check Challan",
                                          style: TextStyle(
                                            fontSize: AppSizer().fontSize16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                            AppSizer().width40,
                                            AppSizer().height5,
                                          ),
                                          backgroundColor: AppColors.appGreen,
                                          padding: EdgeInsets.symmetric(
                                            vertical: AppSizer().height1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSizer().height1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // ✅ Check RC Section
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.car_repair,
                                        size: AppSizer().height10,
                                        color: AppColors.appGreen,
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      Text(
                                        "Check RC",
                                        style: TextStyle(
                                          fontSize: AppSizer().fontSize18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appGreen,
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          rcController.showRcPopup(context);
                                        },
                                        icon: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Check RC",
                                          style: TextStyle(
                                            fontSize: AppSizer().fontSize16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size(
                                            AppSizer().width40,
                                            AppSizer().height5,
                                          ),
                                          backgroundColor: AppColors.appGreen,
                                          padding: EdgeInsets.symmetric(
                                            vertical: AppSizer().height1,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppSizer().height1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Obx(() {
                              final recentlyViewed =
                                  recentlyViewedController.recentlyViewed;

                              if (recentlyViewed.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizer().height1,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Recently Viewed",
                                          style: TextStyle(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppSizer().fontSize19,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 0),
                                          height: 1.5,
                                          width: 140,
                                          color: AppColors.appGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: AppSizer().height4),
                                  SizedBox(
                                    height: 130,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: recentlyViewed.length,
                                      itemBuilder: (context, index) {
                                        final product = recentlyViewed[index];
                                        final bool hasImage =
                                            product.image.isNotEmpty;
                                        final String imageUrl =
                                            "https://oldmarket.bhoomi.cloud/${product.image}";

                                        return GestureDetector(
                                          onTap: () {
                                            if (product.type == "dealer") {
                                              Get.toNamed(
                                                AppRoutes
                                                    .dealer_product_description,
                                                arguments: product.id,
                                              );
                                            } else {
                                              Get.toNamed(
                                                AppRoutes.description,
                                                arguments: product.id,
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: 120,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: hasImage
                                                  ? Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return Image.asset(
                                                              "assets/images/placeholder.jpg",
                                                              fit: BoxFit.cover,
                                                            );
                                                          },
                                                    )
                                                  : Image.asset(
                                                      "assets/images/placeholder.jpg",
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                            SizedBox(height: AppSizer().height3),
                            Padding(
                              padding: EdgeInsets.only(
                                left: AppSizer().height1,
                                right: AppSizer().height1,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(
                                        "All Products.",
                                        style: TextStyle(
                                          color: AppColors.appGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: AppSizer().fontSize19,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 0),
                                        height: 1.5,
                                        width: 105,
                                        color: AppColors.appGreen,
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (tokenController.isLoggedIn) {
                                        Get.toNamed(AppRoutes.description);
                                      } else {
                                        Get.toNamed(AppRoutes.login);
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "View More",
                                          style: TextStyle(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizer().fontSize17,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 0),
                                          height: 1.5,
                                          width: 75,
                                          color: AppColors.appGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSizer().height3),
                            Obx(() {
                              if (productController.isLoading.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final limitedProducts = productController
                                  .productList
                                  .take(8)
                                  .toList();
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: limitedProducts.length,
                                padding: const EdgeInsets.all(6),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 2,
                                      childAspectRatio: 0.70,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = limitedProducts[index];
                                  final String imageUrl =
                                      product.mediaUrl.isNotEmpty
                                      ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                                      : 'assets/images/placeholder.jpg';
                                  // wishlist usage intentionally omitted here
                                  return InkWell(
                                    onTap: () {
                                      recentlyViewedController.addProduct(
                                        RecentlyViewedModel(
                                          id: product.id,
                                          title: product.title,
                                          image: product.mediaUrl.isNotEmpty
                                              ? product.mediaUrl.first
                                              : "",
                                          price: product.price.toString(),
                                          type: "all",
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      if (tokenController.isLoggedIn) {
                                        Get.toNamed(
                                          AppRoutes.description,
                                          arguments: product.id,
                                        );
                                      } else {
                                        Get.toNamed(AppRoutes.login);
                                      }
                                    },
                                    child: ProductCard(
                                      productId: product.id,
                                      imagePath: imageUrl,
                                      roomInfo: product.title,
                                      price: "₹ ${product.price}",
                                      description: product.description,
                                      location: product.location.city,
                                      date: parseDateString(product.createdAt),
                                    ),
                                  );
                                },
                              );
                            }),
                            SizedBox(height: AppSizer().height2),
                            Obx(() {
                              print(
                                "Suggested Videos Length: ${shortVideoController.suggestedVideos.length}",
                              );

                              if (shortVideoController.isLoadingVideos.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (shortVideoController
                                  .suggestedVideos
                                  .isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Section title
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSizer().height1,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Suggested Videos",
                                          style: TextStyle(
                                            color: AppColors.appGreen,
                                            fontSize: AppSizer().fontSize19,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          height: 1.5,
                                          width: 145,
                                          color: AppColors.appGreen,
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(height: AppSizer().height2),

                                  // Horizontal video list - only the centered item will
                                  // show an autoplaying, muted VideoPlayerWidget. Others
                                  // show static thumbnails to conserve resources.
                                  SizedBox(
                                    height: AppSizer().height12 * 2.5,
                                    child: ListView.builder(
                                      controller: _suggestedScrollController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: shortVideoController
                                          .suggestedVideos
                                          .length,
                                      itemBuilder: (context, index) {
                                        final video = shortVideoController
                                            .suggestedVideos[index];

                                        final thumbPath =
                                            video.thumbnailUrl.isNotEmpty
                                            ? _fullVideoUrl(video.thumbnailUrl)
                                            : (video.videoUrl.isNotEmpty
                                                  ? _fullVideoUrl(
                                                      video.videoUrl,
                                                    )
                                                  : '');

                                        // previously used to show only one active preview

                                        return GestureDetector(
                                          onTap: () {
                                            final vid = shortVideoController
                                                .suggestedVideos[index]
                                                .id;
                                            print(
                                              '[HomeScreen] Tapped suggested video id: $vid',
                                            );
                                            Get.toNamed(
                                              AppRoutes.shortVideo,
                                              arguments: {
                                                'videos': shortVideoController
                                                    .suggestedVideos,
                                                'currentIndex': index,
                                                'id': vid,
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: 150,
                                            margin: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.black12,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: SizedBox(
                                                width: 150,
                                                height: double.infinity,
                                                child: thumbPath.isNotEmpty
                                                    ? VideoPlayerWidget(
                                                        videoUrl: _fullVideoUrl(
                                                          video.videoUrl,
                                                        ),
                                                        muted: true,
                                                        enableTapToToggle:
                                                            false,
                                                      )
                                                    : Image.asset(
                                                        'assets/images/placeholder.jpg',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                            // --- Top Items (User's products) - inserted after Certified Dealers ---
                            FutureBuilder<List<AllProductModel>>(
                              future: _fetchTopItems(limit: 4),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting)
                                  return const SizedBox.shrink();
                                final items = snap.data ?? [];
                                if (items.isEmpty)
                                  return const SizedBox.shrink();
                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: AppSizer().height1,
                                    right: AppSizer().height1,
                                    top: AppSizer().height2,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Top Items',
                                        style: TextStyle(
                                          color: AppColors.appGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: AppSizer().fontSize19,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 0),
                                        height: 1.5,
                                        width: 105,
                                        color: AppColors.appGreen,
                                      ),
                                      SizedBox(height: AppSizer().height2),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: items.length,
                                        padding: const EdgeInsets.all(0),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisSpacing: 6,
                                              crossAxisSpacing: 6,
                                              childAspectRatio: 0.70,
                                            ),
                                        itemBuilder: (context, index) {
                                          final product = items[index];
                                          final imageUrl =
                                              product.mediaUrl.isNotEmpty
                                              ? "https://oldmarket.bhoomi.cloud/${product.mediaUrl.first}"
                                              : 'assets/images/placeholder.jpg';
                                          final DateTime? createdAt =
                                              parseDateString(
                                                product.createdAt,
                                              );
                                          return InkWell(
                                            onTap: () {
                                              recentlyViewedController
                                                  .addProduct(
                                                    RecentlyViewedModel(
                                                      id: product.id,
                                                      title: product.title,
                                                      image:
                                                          product
                                                              .mediaUrl
                                                              .isNotEmpty
                                                          ? product
                                                                .mediaUrl
                                                                .first
                                                          : '',
                                                      price: product.price
                                                          .toString(),
                                                      type: 'all',
                                                      createdAt: DateTime.now(),
                                                    ),
                                                  );
                                              if (tokenController.isLoggedIn) {
                                                Get.toNamed(
                                                  AppRoutes.description,
                                                  arguments: product.id,
                                                );
                                              } else {
                                                Get.toNamed(AppRoutes.login);
                                              }
                                            },
                                            child: ProductCard(
                                              productId: product.id,
                                              imagePath: imageUrl,
                                              roomInfo: product.title,
                                              price: '₹ ${product.price}',
                                              description: product.description,
                                              location: product.location.city,
                                              date: createdAt,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: AppSizer().height1),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Certified Dealers",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.appGreen,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 2),
                                        height: 1.5,
                                        width: 140,
                                        color: AppColors.appGreen,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: AppSizer().height3),

                                  // Dealer List
                                  SizedBox(
                                    height: AppSizer().height30,
                                    child: Obx(() {
                                      if (dController
                                          .isDealerListLoading
                                          .value) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.appGreen,
                                          ),
                                        );
                                      }

                                      if (dController.dealers.isEmpty) {
                                        return Center(
                                          child: Text(
                                            dController
                                                    .errorMessage
                                                    .value
                                                    .isEmpty
                                                ? "No dealers found"
                                                : dController
                                                      .errorMessage
                                                      .value,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      }

                                      const baseUrl =
                                          "http://oldmarket.bhoomi.cloud/";

                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: dController.dealers.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 15),
                                        itemBuilder: (context, index) {
                                          final dealer =
                                              dController.dealers[index];

                                          print(
                                            "🧩 Dealer[$index] => imageUrl: ${dealer.imageUrl}, businessLogo: ${dealer.businessLogo}",
                                          );

                                          final imagePath =
                                              dealer.imageUrl?.isNotEmpty ==
                                                  true
                                              ? dealer.imageUrl!
                                              : dealer
                                                        .businessLogo
                                                        ?.isNotEmpty ==
                                                    true
                                              ? dealer.businessLogo!
                                              : "";

                                          final imageUrl = imagePath.isNotEmpty
                                              ? "$baseUrl$imagePath"
                                              : "";

                                          print(
                                            "📸 Dealer[$index] => Final imageUrl used: $imageUrl",
                                          );

                                          return GestureDetector(
                                            onTap: () {
                                              Get.to(
                                                () => DealerDetailScreen(
                                                  dealerId: dealer.dealerId,
                                                ),
                                              );
                                            },
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: AppSizer().width43,
                                                  height: AppSizer().height25,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    image: imageUrl.isNotEmpty
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                              imageUrl,
                                                            ),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                  ),
                                                  child: imageUrl.isEmpty
                                                      ? const Icon(
                                                          Icons.person,
                                                          size: 30,
                                                          color: Colors.grey,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(height: 6),
                                                SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    dealer.businessName,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSizer().height2),
                            Padding(
                              padding: EdgeInsets.only(
                                left: AppSizer().height1,
                                right: AppSizer().height1,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Dealer Products",
                                        style: TextStyle(
                                          color: AppColors.appGreen,
                                          fontWeight: FontWeight.w700,
                                          fontSize: AppSizer().fontSize19,
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(top: 0),
                                        height: 1.5,
                                        width: 140,
                                        color: AppColors.appGreen,
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      // If user logged in, navigate to dealer products screen
                                      // otherwise send to login.
                                      if (tokenController.isLoggedIn) {
                                        Get.toNamed(
                                          AppRoutes.dealer_products_screen,
                                        );
                                      } else {
                                        Get.toNamed(AppRoutes.login);
                                      }
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          "View More",
                                          style: TextStyle(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizer().fontSize18,
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(top: 0),
                                          height: 1.5,
                                          width: 75,
                                          color: AppColors.appGreen,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: AppSizer().height3),
                            Obx(() {
                              if (homeController.isLoadingDealer.value) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final List<dynamic> dealerProducts =
                                  homeController.dealerProducts;
                              if (dealerProducts.isEmpty) {
                                return const Center(
                                  child: Text("No products uploaded yet"),
                                );
                              }
                              final limitedProducts = dealerProducts
                                  .take(8)
                                  .toList();
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: limitedProducts.length,
                                padding: const EdgeInsets.all(6),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 2,
                                      childAspectRatio: 0.70,
                                    ),
                                itemBuilder: (context, index) {
                                  final product = limitedProducts[index];
                                  final String imageUrl =
                                      (product.images.isNotEmpty)
                                      ? "https://oldmarket.bhoomi.cloud/${product.images.first}"
                                      : 'assets/images/placeholder.jpg';
                                  final String city =
                                      product.location != null &&
                                          product.location is Map
                                      ? product.location['city'] ?? "Unknown"
                                      : "Unknown";
                                  final String title =
                                      product.title ?? "No Title";
                                  final String description =
                                      product.description ?? "";
                                  final String price =
                                      "₹ ${product.price ?? '0'}";

                                  final DateTime? createdAt =
                                      product.createdAt is String
                                      ? parseDateString(product.createdAt)
                                      : (product.createdAt is DateTime
                                            ? product.createdAt
                                            : null);
                                  return InkWell(
                                    onTap: () {
                                      recentlyViewedController.addProduct(
                                        RecentlyViewedModel(
                                          id: product.id,
                                          title: product.title,
                                          image: product.images.isNotEmpty
                                              ? product.images.first
                                              : "",
                                          price: product.price.toString(),
                                          type: "dealer",
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                      if (tokenController.isLoggedIn) {
                                        Get.toNamed(
                                          AppRoutes.dealer_product_description,
                                          arguments: product.id,
                                        );
                                      } else {
                                        Get.toNamed(AppRoutes.login);
                                      }
                                    },
                                    child: ProductCard(
                                      imagePath: imageUrl,
                                      roomInfo: title,
                                      price: price,
                                      description: description,
                                      location: city,
                                      date: createdAt,
                                      productId: product.id,
                                      isDealer: true,
                                    ),
                                  );
                                },
                              );
                            }),
                            SizedBox(height: AppSizer().height2),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              case 1:
                return CategoryScreen();
              case 2:
                return ShortVideoScreen();
              case 3:
                return AdsScreen();
              case 4:
                return OldMarketChatsScreen();
              default:
                // Fallback: return an empty view to avoid recursive instantiation
                return const SizedBox.shrink();
            }
          }),
          bottomNavigationBar: Obx(() {
            return BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: (index) {
                // Open dedicated Ads route when Ads tab pressed (index 3)
                if (index == 3) {
                  Get.toNamed(AppRoutes.ads);
                } else {
                  controller.onItemTapped(index);
                }
              },
              backgroundColor: AppColors.appGreen,
              selectedItemColor: AppColors.appWhite,
              unselectedItemColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                BottomNavigationBarItem(
                  icon: Icon(Icons.category),
                  label: "Category",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.video_library),
                  label: "Reels",
                ),
                BottomNavigationBarItem(icon: Icon(Icons.sell), label: "Ads"),
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
              ],
            );
          }),
        ),
      );
    });
  }
}
