import 'dart:io';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart' as badges show Badge, BadgePosition;
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/constants/app_strings_constant.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/utils/logger.dart';
import 'package:olx_prototype/src/view/home/ads/ads_screen.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import '../../widgets/filter_section.dart';
import '../../controller/challan_controller.dart';
import '../../controller/dealer_details_controller.dart';
import '../../controller/login_controller.dart';
import '../../controller/rc_controller.dart';
import '../../services/auth_service/auth_service.dart';
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
import '../../controller/location_controller.dart';
import '../../custom_widgets/cards.dart';
import '../../custom_widgets/shortVideoWidget.dart';
// We'll render lightweight thumbnails for most cards and only create a
// VideoPlayerWidget for the centered item to show a short autoplay preview.
import '../../model/recently_product_model/recently_product_model.dart';
import '../../model/all_product_model/all_product_model.dart';
import 'category/category_screen.dart';
import 'chat/chat_screen.dart';
import 'dealer_detail/dealer_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final recentlyViewedController = Get.put(RecentlyViewedController());
  final shortVideoController = Get.put(ShortVideoController());
  final ScrollController _suggestedScrollController = ScrollController();
  int _activePreviewIndex = 0;

  // 🔥 Add GlobalKey for Scaffold to control drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserWishlistController wishlistController = Get.put(
    UserWishlistController(),
  );
  final DealerWishlistController dealerWishlistController = Get.put(
    DealerWishlistController(),
  );
  final NavigationController controller = Get.put(NavigationController());
  late final ProductController productController;
  final dController = Get.put(DealerController());
  final rcController = Get.put(RcController());

  late final TokenController tokenController;
  final loginController = Get.put(LoginController());
  final SearchController searchcontroller = Get.put(SearchController());
  late final HomeController homeController;
  late final DealerProfileController dealerController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers safely
    _initializeControllers();

    // 🔥 Check if we need to open drawer after navigation
    _checkDrawerArguments();

    // One-time setup
    dController.fetchAllDealers();

    // 🎲 Fetch all content with randomization on app start
    searchcontroller.fetchProducts();

    // Add comprehensive shuffle for variety across all sections
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        print('[HomeScreen] 🎲 App startup - shuffling all content...');
        productController.shuffleProducts();
        homeController.shuffleDealerProducts();
        shortVideoController.shuffleVideos();
        shortVideoController
            .fetchSuggestedVideos(); // Also shuffle suggested videos
        print('[HomeScreen] ✅ App startup shuffle completed!');
      }
    });
    // Listen to scroll events on suggested videos to activate a single preview
    _suggestedScrollController.addListener(_onSuggestedScroll);

    // 🔄 Shuffle suggested videos every 30 seconds for variety
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        shortVideoController.fetchSuggestedVideos();
        print('[HomeScreen] 🔄 Suggested videos reshuffled!');
      } else {
        timer.cancel();
      }
    });
  }

  void _initializeControllers() {
    // Initialize ProductController if not present
    try {
      productController = Get.find<ProductController>();
    } catch (e) {
      productController = Get.put(ProductController());
    }

    // Initialize TokenController if not present
    try {
      tokenController = Get.find<TokenController>();
      // ✅ Force reload business account data on app start
      tokenController.loadTokenFromStorage();
      print('🔍 [HomeScreen] TokenController found and reloaded');
      print(
        '   - Business Account: ${tokenController.isBusinessAccount.value}',
      );
      print('   - Business Name: ${tokenController.businessName.value}');
      print('   - Business Role: ${tokenController.businessRole.value}');
    } catch (e) {
      tokenController = Get.put(TokenController(), permanent: true);
      print('⚠️ [HomeScreen] TokenController initialized');
    }

    // Initialize HomeController if not present
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }

    // 🔥 COMPREHENSIVE: Initialize DealerProfileController with full debugging
    try {
      dealerController = Get.find<DealerProfileController>();

      print('🔍 [HomeScreen] INITIALIZATION DEBUG:');
      print('   - Controller found: ✅');
      print(
        '   - isProfileCreated: ${dealerController.isProfileCreated.value}',
      );

      // Debug SharedPreferences state asynchronously with user-specific keys
      SharedPreferences.getInstance().then((prefs) async {
        final userId = await AuthService.getLoggedInUserId();
        final dealerId = prefs.getString('dealerId_$userId');
        final cachedState = prefs.getBool('isProfileCreated_$userId');

        print('🔍 [HomeScreen] SharedPreferences Debug (User-Specific):');
        print('   - userId: $userId');
        print('   - dealerId_$userId: $dealerId');
        print('   - cached isProfileCreated: $cachedState');
      });

      // 🔥 Force immediate profile state refresh with API sync
      print('🔄 [HomeScreen] Forcing immediate profile state refresh...');
      dealerController
          .forceRefreshProfileState()
          .then((_) {
            if (mounted) {
              setState(() {});
              print(
                '✅ [HomeScreen] UI refreshed after profile sync - isProfileCreated: ${dealerController.isProfileCreated.value}',
              );
            }
          })
          .catchError((error) {
            print('💥 [HomeScreen] Error during profile sync: $error');
          });
    } catch (e) {
      print('🚀 [HomeScreen] Creating new DealerProfileController');
      dealerController = Get.put(DealerProfileController());
      print(
        '✅ [HomeScreen] Created DealerProfileController - isProfileCreated: ${dealerController.isProfileCreated.value}',
      );
      // Wait a moment for initialization to complete
      Future.delayed(Duration(milliseconds: 500), () {
        print(
          '⏰ [HomeScreen] After 500ms - isProfileCreated: ${dealerController.isProfileCreated.value}',
        );
      });
    }

    // Initialize GetProfileController if not present
    if (!Get.isRegistered<GetProfileController>()) {
      Get.put(GetProfileController());
    }
  }

  /// Return randomized top products for variety on each app launch
  Future<List<AllProductModel>> _fetchTopItems({int limit = 4}) async {
    try {
      final all = productController.productList;
      if (all.isEmpty) {
        try {
          await searchcontroller.fetchProducts();
        } catch (_) {}
      }

      // 🎲 Use randomized products instead of just taking first ones
      final randomizedItems = productController.getRandomProducts(limit: limit);
      print(
        '[HomeScreen] 🎯 _fetchTopItems returning ${randomizedItems.length} randomized top items',
      );

      return randomizedItems;
    } catch (e) {
      print('[HomeScreen] _fetchTopItems error: $e');
      return [];
    }
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
    const baseAssets = 'https://oldmarket.bhoomi.cloud/';
    final rel = fixed.startsWith('/') ? fixed.substring(1) : fixed;
    return '$baseAssets$rel';
  }

  // Removed static carousel images - now using API data

  List<Map<String, dynamic>> getDrawerItems() {
    final List<Map<String, dynamic>> baseItems = [
      {
        'name': 'Profile',
        'icon': Icons.person,
        'onTap': () => Get.toNamed(AppRoutes.profile),
      },
      {
        'name': 'Location Setting',
        'icon': Icons.location_on,
        'onTap': () => Get.toNamed(AppRoutes.location_settings),
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

    print(
      '🎯 [HomeScreen] getDrawerItems() - dealerController.isProfileCreated.value: ${dealerController.isProfileCreated.value}',
    );

    // 🔥 QUICK FIX: Check if user-specific dealerId exists but state is wrong
    SharedPreferences.getInstance().then((prefs) async {
      final userId = await AuthService.getLoggedInUserId();
      final dealerId = prefs.getString('dealerId_$userId');
      if (dealerId != null &&
          dealerId.isNotEmpty &&
          !dealerController.isProfileCreated.value) {
        print('🚨 [HomeScreen] INCONSISTENT STATE DETECTED!');
        print('   - userId: $userId');
        print('   - dealerId exists: $dealerId');
        print(
          '   - but isProfileCreated: ${dealerController.isProfileCreated.value}',
        );
        print('🔄 [HomeScreen] Triggering force refresh to fix state...');
        await dealerController.forceRefreshProfileState();
      }
    });

    if (dealerController.isProfileCreated.value) {
      print('✅ [HomeScreen] Adding "Edit Business Account" to drawer items');
      baseItems.insert(1, {
        'name': 'Edit Business Account',
        'icon': Icons.person,
        'onTap': () {
          print(
            '🔍 [HomeScreen] Edit Business Account tapped - Navigating to edit screen',
          );
          // 🚀 Navigate directly - EditController will handle data loading from API
          Get.toNamed(AppRoutes.edit_dealer_profile);
        },
      });
    } else {
      print('❌ [HomeScreen] Adding "Create Business Account" to drawer items');
      baseItems.insert(1, {
        'name': 'Create Business Account',
        'icon': Icons.perm_identity,
        'onTap': () {
          print(
            '🚀 [HomeScreen] Create Business Account tapped - Opening dealer profile screen',
          );
          // ✅ Navigate directly to dealer profile screen (no dialog)
          Get.toNamed(AppRoutes.dealer);
        },
      });
    }

    baseItems.insert(2, {
      'name': 'Sell',
      'icon': Icons.directions_car,
      'onTap': () {
        // ✅ Choose route based on dealer profile creation status
        // If dealer profile created: go to dealer products screen
        // If normal user: go to user post upload screen
        final route = dealerController.isProfileCreated.value
            ? AppRoutes.sell_dealer_cars
            : AppRoutes.sell_user_cars;
        print(
          '🚀 [HomeScreen] Sell button tapped - Route: $route (isDealer: ${dealerController.isProfileCreated.value})',
        );
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
    // Safely get profile controller, initialize if not found
    GetProfileController getProfileController;
    try {
      getProfileController = Get.find<GetProfileController>();
    } catch (e) {
      // Controller not found, initialize it
      if (!Get.isRegistered<GetProfileController>()) {
        Get.put(GetProfileController());
      }
      getProfileController = Get.find<GetProfileController>();
    }

    Logger.d(
      'Home',
      'build start - size=${MediaQuery.of(context).size} selectedIndex=${controller.selectedIndex.value}',
    );
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
          key: _scaffoldKey, // 🔥 Add scaffold key to control drawer
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
                              // Show business name if business account, otherwise username
                              final displayName =
                                  dealerController.isProfileCreated.value &&
                                      dealerController
                                          .businessNameController
                                          .text
                                          .isNotEmpty
                                  ? dealerController.businessNameController.text
                                  : (tokenController
                                            .displayName
                                            .value
                                            .isNotEmpty
                                        ? tokenController.displayName.value
                                        : (getProfileController
                                                  .profileData['Username'] ??
                                              'Guest'));
                              return Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.appGreen,
                                  fontSize: AppSizer().fontSize16,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                            // Location Display in AppBar
                            Obx(() {
                              final locationController = Get.put(
                                LocationController(),
                              );
                              String displayLocation =
                                  locationController.formattedLocation;

                              if (displayLocation.isEmpty ||
                                  displayLocation == 'Set Location') {
                                return SizedBox();
                              }

                              return Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      displayLocation,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: AppSizer().fontSize12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
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
                        // Fuel icon removed per UX request
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
                              // Show business logo if business account, otherwise user profile pic
                              if (dealerController.isProfileCreated.value &&
                                  dealerController.businessLogo.value != null) {
                                return CircleAvatar(
                                  radius: 36,
                                  backgroundColor: const Color(0xfffae293),
                                  backgroundImage: FileImage(
                                    dealerController.businessLogo.value!,
                                  ),
                                );
                              }

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
                          Obx(() {
                            // Show business name if business account, otherwise username
                            final displayName =
                                dealerController.isProfileCreated.value &&
                                    dealerController
                                        .businessNameController
                                        .text
                                        .isNotEmpty
                                ? dealerController.businessNameController.text
                                : (tokenController.displayName.value.isNotEmpty
                                      ? tokenController.displayName.value
                                      : (getProfileController
                                                .profileData['Username'] ??
                                            'User'));

                            return Text(
                              displayName,
                              style: TextStyle(
                                fontSize: AppSizer().fontSize17,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                          Obx(() {
                            // ✅ Show role: Vendor for business accounts, User otherwise
                            final role = tokenController.isBusinessAccount.value
                                ? 'Vendor'
                                : (dealerController.isProfileCreated.value
                                      ? 'Dealer'
                                      : 'User');

                            return Text(
                              role,
                              style: TextStyle(
                                color: tokenController.isBusinessAccount.value
                                    ? AppColors.appGreen
                                    : Colors.grey.shade700,
                                fontWeight:
                                    tokenController.isBusinessAccount.value
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            );
                          }),
                          // 🔥 Location Display
                          SizedBox(height: 4),
                          Obx(() {
                            final locationController = Get.put(
                              LocationController(),
                            );

                            // Show saved location from dropdown selection
                            final displayLocation =
                                locationController.formattedLocation;

                            if (displayLocation == 'Set Location') {
                              return SizedBox();
                            }

                            return Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  displayLocation,
                                  style: TextStyle(
                                    fontSize: AppSizer().fontSize13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
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
                      // ✅ Force reactivity by watching both dealer and business account status
                      final isProfileCreated =
                          dealerController.isProfileCreated.value;
                      final isBusinessAccount =
                          tokenController.isBusinessAccount.value;
                      final businessName = tokenController.businessName.value;

                      print(
                        '🔔 [HomeScreen] Drawer Obx triggered - Dealer: $isProfileCreated, Business: $isBusinessAccount ($businessName)',
                      );

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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      print('[HomeScreen] 🔄 COMPREHENSIVE REFRESH triggered');

                      // Show refresh feedback
                      Get.snackbar(
                        "🔄 Refreshing Everything",
                        "Loading fresh randomized content for all sections...",
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );

                      // 🎲 COMPREHENSIVE REFRESH - All sections with randomization
                      print('[HomeScreen] 📱 Refreshing All Products...');
                      productController.refreshProductList();

                      print('[HomeScreen] 🔍 Refreshing Search Products...');
                      searchcontroller.fetchProducts();

                      print('[HomeScreen] 🏪 Refreshing Dealer Products...');
                      homeController.fetchDealerProducts();

                      print('[HomeScreen] 🎬 Refreshing Videos...');
                      shortVideoController.refreshVideos();

                      print('[HomeScreen] 📺 Refreshing Dashboard Ads...');
                      homeController.fetchDashboardAds();

                      // Extra shuffle for immediate variety
                      Timer(const Duration(milliseconds: 500), () {
                        print('[HomeScreen] 🎲 Applying extra shuffle...');
                        productController.shuffleProducts();
                        homeController.shuffleDealerProducts();
                        shortVideoController.shuffleVideos();
                      });

                      // UX delay for smooth experience
                      await Future.delayed(const Duration(milliseconds: 1200));

                      print('[HomeScreen] ✅ COMPREHENSIVE REFRESH completed!');
                    },
                    color: AppColors.appGreen,
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
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
                                      itemCount:
                                          searchcontroller.products.length,
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
                                                        createdAt:
                                                            DateTime.now(),
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
                                                description:
                                                    product.description,
                                                location: product.city,
                                                date: parseDateString(
                                                  product.createdAt,
                                                ),
                                                productId: product.id,
                                                isBoosted: product.isBoosted,
                                                status: product.status,
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
                              // 🔥 NEW: Dashboard Ads Carousel
                              Obx(() {
                                if (homeController.isLoadingAds.value) {
                                  return Container(
                                    height: AppSizer().height26,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 5.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.appGrey,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.grey.shade200,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.appGreen,
                                      ),
                                    ),
                                  );
                                }

                                if (homeController.dashboardAds.isEmpty) {
                                  // Fallback to static images if no ads available
                                  final fallbackImages = [
                                    "assets/images/poster1.jpeg",
                                    "assets/images/poster2.jpg",
                                    "assets/images/poster3.jpg",
                                  ];
                                  return CarouselSlider(
                                    options: CarouselOptions(
                                      autoPlay: true,
                                      autoPlayInterval: const Duration(
                                        seconds: 3,
                                      ),
                                      height: AppSizer().height26,
                                      viewportFraction: 1.0,
                                    ),
                                    items: fallbackImages.map((item) {
                                      return Builder(
                                        builder: (BuildContext context) {
                                          return Container(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 5.0,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.appGrey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: AppColors.appWhite,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                  );
                                }

                                // 🎯 API Dashboard Ads Carousel
                                return CarouselSlider(
                                  options: CarouselOptions(
                                    autoPlay: true,
                                    autoPlayInterval: const Duration(
                                      seconds: 4,
                                    ),
                                    height: AppSizer().height26,
                                    viewportFraction: 1.0,
                                  ),
                                  items: homeController.dashboardAds.map((ad) {
                                    // Get first image from ads or use placeholder
                                    final imageUrl =
                                        ad.images?.isNotEmpty == true
                                        ? "https://oldmarket.bhoomi.cloud/${ad.images!.first}"
                                        : null;

                                    return Builder(
                                      builder: (BuildContext context) {
                                        return Container(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 5.0,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppColors.appGrey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            color: AppColors.appWhite,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: imageUrl != null
                                                ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    height: AppSizer().height16,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Colors
                                                            .grey
                                                            .shade300,
                                                        child: Center(
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color: Colors
                                                                    .grey
                                                                    .shade600,
                                                                size: 40,
                                                              ),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Text(
                                                                ad.title ??
                                                                    'Dashboard Ad',
                                                                style: TextStyle(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade600,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade300,
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.campaign,
                                                            color: AppColors
                                                                .appGreen,
                                                            size: 50,
                                                          ),
                                                          SizedBox(height: 8),
                                                          Text(
                                                            ad.title ??
                                                                'Dashboard Ad',
                                                            style: TextStyle(
                                                              color: AppColors
                                                                  .appGreen,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              }),

                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSizer().width3,
                                  vertical: AppSizer().height2,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: Column(
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
                                            "Check vehicle reports",
                                            style: TextStyle(
                                              fontSize: AppSizer().fontSize18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.appGreen,
                                            ),
                                          ),
                                          SizedBox(height: AppSizer().height1),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                final loginController =
                                                    Get.find<LoginController>();
                                                final challanController =
                                                    Get.find<
                                                      ChallanController
                                                    >();

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
                                                  challanController
                                                      .showChallanPopup(
                                                        Get.context!,
                                                      );
                                                }
                                              },
                                              icon: const Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                "Vehicle Credit Report",
                                                style: TextStyle(
                                                  fontSize:
                                                      AppSizer().fontSize16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(
                                                  double.infinity,
                                                  AppSizer().height5,
                                                ),
                                                backgroundColor:
                                                    AppColors.appGreen,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: AppSizer().height1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        AppSizer().height1,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                                            margin: const EdgeInsets.only(
                                              top: 0,
                                            ),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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
                                                                fit: BoxFit
                                                                    .cover,
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
                                            margin: const EdgeInsets.only(
                                              top: 0,
                                            ),
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
                                // 🎲 Use randomized products for variety
                                final limitedProducts = productController
                                    .getRandomProducts(limit: 8);

                                print(
                                  '[HomeScreen] 🏠 Displaying ${limitedProducts.length} randomized products',
                                );

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
                                        date: parseDateString(
                                          product.createdAt,
                                        ),
                                        isBoosted: product.isBoosted,
                                        status: product.status,
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

                                if (shortVideoController
                                    .isLoadingVideos
                                    .value) {
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
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
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
                                      height: AppSizer().height12 * 3.2,
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
                                              ? _fullVideoUrl(
                                                  video.thumbnailUrl,
                                                )
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
                                              width: 180,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                color: Colors.black12,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                                child: SizedBox(
                                                  width: 180,
                                                  height: double.infinity,
                                                  child: thumbPath.isNotEmpty
                                                      ? VideoPlayerWidget(
                                                          videoUrl:
                                                              _fullVideoUrl(
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
                                                        createdAt:
                                                            DateTime.now(),
                                                      ),
                                                    );
                                                if (tokenController
                                                    .isLoggedIn) {
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
                                                description:
                                                    product.description,
                                                location: product.location.city,
                                                date: createdAt,
                                                isBoosted: product.isBoosted,
                                                status: product.status,
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
                                    // Header with See All button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Top Dealers",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.appGreen,
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              height: 1.5,
                                              width: 100,
                                              color: AppColors.appGreen,
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Get.toNamed(
                                                  '/all_dealers_screen',
                                                );
                                              },
                                              child: const Text(
                                                'See All',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: AppColors.appGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 2,
                                              ),
                                              height: 1.5,
                                              width: 50,
                                              color: AppColors.appGreen,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: AppSizer().height3),

                                    // Dealer List - Full Width Carousel
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
                                            "https://oldmarket.bhoomi.cloud/";

                                        return CarouselSlider.builder(
                                          itemCount: dController.dealers.length,
                                          options: CarouselOptions(
                                            height: AppSizer().height30,
                                            viewportFraction: 1.0, // Full width
                                            autoPlay: true,
                                            autoPlayInterval: const Duration(
                                              seconds: 3,
                                            ),
                                            enlargeCenterPage: false,
                                            enableInfiniteScroll:
                                                dController.dealers.length > 1,
                                          ),
                                          itemBuilder: (context, index, realIndex) {
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

                                            final imageUrl =
                                                imagePath.isNotEmpty
                                                ? "$baseUrl$imagePath"
                                                : "";

                                            print(
                                              "📸 Dealer[$index] => Final imageUrl used: $imageUrl",
                                            );

                                            return Container(
                                              width: MediaQuery.of(
                                                context,
                                              ).size.width,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 5.0,
                                                  ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                    () => DealerDetailScreen(
                                                      dealerId: dealer.dealerId,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        spreadRadius: 1,
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      // Full Width Image with Error Handling
                                                      Container(
                                                        width: double.infinity,
                                                        height:
                                                            AppSizer().height30,
                                                        decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey
                                                              .shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          child:
                                                              imageUrl
                                                                  .isNotEmpty
                                                              ? Image.network(
                                                                  imageUrl,
                                                                  width: double
                                                                      .infinity,
                                                                  height: AppSizer()
                                                                      .height30,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (
                                                                        context,
                                                                        error,
                                                                        stackTrace,
                                                                      ) {
                                                                        print(
                                                                          '❌ Image failed to load: $imageUrl',
                                                                        );
                                                                        return Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              AppSizer().height30,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          child: Center(
                                                                            child: Icon(
                                                                              Icons.store,
                                                                              size: 50,
                                                                              color: Colors.grey.shade400,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                  loadingBuilder:
                                                                      (
                                                                        context,
                                                                        child,
                                                                        loadingProgress,
                                                                      ) {
                                                                        if (loadingProgress ==
                                                                            null)
                                                                          return child;
                                                                        return Container(
                                                                          width:
                                                                              double.infinity,
                                                                          height:
                                                                              AppSizer().height30,
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                          child: Center(
                                                                            child: CircularProgressIndicator(
                                                                              value:
                                                                                  loadingProgress.expectedTotalBytes !=
                                                                                      null
                                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                                        loadingProgress.expectedTotalBytes!
                                                                                  : null,
                                                                              color: AppColors.appGreen,
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                )
                                                              : Center(
                                                                  child: Icon(
                                                                    Icons.store,
                                                                    size: 50,
                                                                    color: Colors
                                                                        .grey
                                                                        .shade400,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                      // Black overlay container with dealer name
                                                      Positioned(
                                                        top: 12,
                                                        left: 12,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 6,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            dealer.businessName,
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      // Verified badge at bottom right
                                                      Positioned(
                                                        bottom: 12,
                                                        right: 12,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: AppColors
                                                                .appGreen
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.verified,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                "Certified",
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSizer().height2),
                              // 🔐 Dealer Products Section - Only show when user is logged in
                              if (tokenController.isLoggedIn) ...[
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
                                            margin: const EdgeInsets.only(
                                              top: 0,
                                            ),
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
                                              margin: const EdgeInsets.only(
                                                top: 0,
                                              ),
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
                                  final dealerProducts =
                                      homeController.dealerProducts;
                                  print(
                                    "🏠 Home Screen - Dealer Products: ${dealerProducts.length} items",
                                  );

                                  if (dealerProducts.isEmpty) {
                                    return Center(
                                      child: Column(
                                        children: [
                                          const Text(
                                            "No dealer products found",
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () => homeController
                                                .fetchDealerProducts(),
                                            child: const Text("Retry"),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  // 🎲 Use randomized dealer products for variety
                                  final limitedProducts = homeController
                                      .getRandomDealerProducts(limit: 8);

                                  print(
                                    '[HomeScreen] 🏪 Displaying ${limitedProducts.length} randomized dealer products',
                                  );
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                          product.location ?? "Unknown";
                                      final String title = product.title;
                                      final String description =
                                          product.description;
                                      final String price = "₹ ${product.price}";
                                      final DateTime? createdAt =
                                          product.createdAt;
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
                                              AppRoutes
                                                  .dealer_product_description,
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
                                          status: product.status,
                                        ),
                                      );
                                    },
                                  );
                                }),
                                SizedBox(height: AppSizer().height2),
                              ], // End of dealer products conditional section
                            ],
                          ),
                        ], // Column children
                      ), // Column
                    ), // SingleChildScrollView
                  ), // RefreshIndicator
                ); // SafeArea
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
                // Check if user is logged in for Ads and Chat tabs
                if (index == 3 || index == 4) {
                  if (!tokenController.isLoggedIn) {
                    Get.snackbar(
                      "Login Required",
                      "Please login first",
                      backgroundColor: AppColors.appRed,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                    Get.toNamed(AppRoutes.login);
                    return;
                  }
                }

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

  /// 🔥 Check if we need to open drawer based on navigation arguments
  void _checkDrawerArguments() {
    // Check for openDrawer argument from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = Get.arguments;
      if (arguments != null &&
          arguments is Map<String, dynamic> &&
          arguments['openDrawer'] == true) {
        print('🔥 [HomeScreen] Opening drawer due to navigation argument');
        // Open drawer after a small delay to ensure scaffold is built
        Future.delayed(Duration(milliseconds: 500), () {
          if (_scaffoldKey.currentState != null && mounted) {
            _scaffoldKey.currentState!.openDrawer();
            print('✅ [HomeScreen] Drawer opened successfully');
          }
        });
      }
    });
  }

  /// ✅ Show Create Business Account Dialog
  void _showCreateBusinessAccountDialog(BuildContext context) {
    final TextEditingController businessNameController =
        TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.business, color: AppColors.appGreen, size: 28),
            SizedBox(width: 12),
            Text(
              'Create Business Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your business name to create a vendor account:',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            SizedBox(height: 16),
            TextField(
              controller: businessNameController,
              decoration: InputDecoration(
                labelText: 'Business Name',
                hintText: 'e.g., ABC Motors',
                prefixIcon: Icon(Icons.storefront, color: AppColors.appGreen),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.appGreen, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will become a Vendor and can post products as a business.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final businessName = businessNameController.text.trim();
              if (businessName.isEmpty) {
                Get.snackbar(
                  'Business Name Required',
                  'Please enter your business name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange.shade600,
                  colorText: Colors.white,
                  margin: EdgeInsets.all(16),
                  icon: Icon(Icons.warning, color: Colors.white),
                );
                return;
              }

              // Create business account
              await tokenController.createBusinessAccount(businessName);

              print('✅ [HomeScreen] Business account created successfully');
              print(
                '   - Business Name: ${tokenController.businessName.value}',
              );
              print(
                '   - Is Business Account: ${tokenController.isBusinessAccount.value}',
              );
              print(
                '   - Business Role: ${tokenController.businessRole.value}',
              );

              Get.back(); // Close dialog

              // ✅ Force immediate UI refresh
              setState(() {});

              // Show success message
              Get.snackbar(
                'Business Account Created!',
                'Welcome to Vendor mode, $businessName! 🎉',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.appGreen,
                colorText: Colors.white,
                margin: EdgeInsets.all(16),
                duration: Duration(seconds: 4),
                icon: Icon(Icons.check_circle, color: Colors.white, size: 28),
              );

              print(
                '🔔 [HomeScreen] UI refreshed - drawer should now show business account',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Create Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// ✅ Show Manage Business Account Dialog
  void _showManageBusinessAccountDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.business, color: AppColors.appGreen, size: 28),
            SizedBox(width: 12),
            Text(
              'Business Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.appGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.appGreen.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.storefront,
                        color: AppColors.appGreen,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Business Name:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    tokenController.businessName.value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appGreen,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.verified, color: AppColors.appGreen, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Role: Vendor',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Would you like to remove your business account and revert to a normal user?',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Confirm removal
              Get.back(); // Close manage dialog

              final confirmed = await Get.dialog<bool>(
                AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 28),
                      SizedBox(width: 12),
                      Text('Confirm Removal'),
                    ],
                  ),
                  content: Text(
                    'Are you sure you want to remove your business account?\n\nYou will revert to a normal user account.',
                    style: TextStyle(fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                // Remove business account
                await tokenController.removeBusinessAccount();

                print('✅ [HomeScreen] Business account removed');
                print(
                  '   - Is Business Account: ${tokenController.isBusinessAccount.value}',
                );
                print(
                  '   - Reverted to: ${tokenController.businessRole.value}',
                );

                // ✅ Force immediate UI refresh
                setState(() {});

                // Show success message
                Get.snackbar(
                  'Business Account Removed',
                  'You have been reverted to a User account.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange.shade600,
                  colorText: Colors.white,
                  margin: EdgeInsets.all(16),
                  icon: Icon(Icons.info, color: Colors.white),
                );

                print(
                  '🔔 [HomeScreen] UI refreshed - drawer should now show user account',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Remove Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
