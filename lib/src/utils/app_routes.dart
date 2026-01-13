import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/view/home/ads/ads_screen.dart';
import 'package:olx_prototype/src/view/home/ads/profile_uploads_screen.dart';
import 'package:olx_prototype/src/view/home/all_products_screen/all_products_screen.dart';
import 'package:olx_prototype/src/view/home/bikes_market/bikes_market.dart';
import 'package:olx_prototype/src/view/home/cars_market/cars_market.dart';
import 'package:olx_prototype/src/view/home/category/category_screen.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';
import 'package:olx_prototype/src/view/home/chat_details/chat_details_screen.dart';
import 'package:olx_prototype/src/view/home/dealer/dealer_screen.dart';
import 'package:olx_prototype/src/view/home/dealer_bookTestDrives_screen/dealer_bookTestDrives_Screen.dart';
import 'package:olx_prototype/src/view/home/dealer_history_screen/dealer_history_screen.dart';
import 'package:olx_prototype/src/view/home/offer_status/offer_status_screen.dart';
import 'package:olx_prototype/src/view/home/dealer_products_description/dealer_product_description_screen.dart';
import 'package:olx_prototype/src/view/home/dealer_products_screen/dealer_products_screen.dart';
import 'package:olx_prototype/src/view/home/all_dealers/all_dealers_screen.dart';
import 'package:olx_prototype/src/view/home/dealer_detail/dealer_detail_screen.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';
import 'package:olx_prototype/src/view/home/edit_dealer_profile/edit_dealer_profile_screen.dart';
import 'package:olx_prototype/src/view/home/fuel_screen/fuel_screen.dart';
import 'package:olx_prototype/src/view/home/history/user_history_screen.dart';
import 'package:olx_prototype/src/view/home/home_screen.dart';
import 'package:olx_prototype/src/view/home/logout/logout_screen.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import 'package:olx_prototype/src/view/home/profile/profile_screen.dart';
import 'package:olx_prototype/src/view/home/sell_dealer_cars/sell_dealer_car_screen.dart';
import 'package:olx_prototype/src/view/home/setting/about/about_screen.dart';
import 'package:olx_prototype/src/view/home/setting/help_support/help_support_screen.dart';
import 'package:olx_prototype/src/view/home/setting/privacy_screen/privacy_screen.dart';
import 'package:olx_prototype/src/view/home/setting/setting_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import 'package:olx_prototype/src/view/home/video_uploadScreen/video_uploadScreen.dart';
import 'package:olx_prototype/src/view/home/wishlist_screen/wishlist_screen.dart';
import 'package:olx_prototype/src/view/login/log_in_screen.dart';
import 'package:olx_prototype/src/view/signup_screen/signup_screen.dart';
import 'package:olx_prototype/src/view/splash/splash_screen.dart';
import 'package:olx_prototype/src/view/verify_otp/verify_otp_screen.dart';
import 'package:olx_prototype/src/view/splash/welcome_screen.dart';
import '../view/home/book_test_driveScreen/book_testdrive_screen.dart';
import '../view/home/sell_user_cars/sell_user_car_screen.dart';
import '../view/home/ads/edit_product_screen.dart';
import '../view/home/city_products_screen/city_products_screen.dart';
import '../model/all_product_model/all_product_model.dart';
import '../view/test/subscription_test_screen_simple.dart';
import '../view/home/location_settings/location_settings_screen.dart';
import '../view/home/location_settings/filtered_products_screen.dart';

class AppRoutes {
  static String splash = "/splash_screen";
  static String login = "/log_in_screen";
  static String home = "/home_screen";
  static String welcome = "/welcome_screen";
  static String profile = "/profile_screen";
  static String carsMarket = "/cars_market";
  static String setting = "/setting_screen";
  static String description = "/description_screen";
  static String chat = "/chat_screen";
  static String chat_details = "/chat_details_screen";
  static String shortVideo = "/shortVideo_screen";
  static String logout = "/logout_screen";
  static String signup_screen = "/signup_screen";
  static String about = "/about_screen";
  static String sell_user_cars = "/sell_user_car_screen";
  static String sell_dealer_cars = "/sell_dealer_car_screen";
  static String notifications = "/notification_screen";
  static String history = "/history_screen";
  static String dealer_history_screen = "/dealer_history_screen";
  static String offer_status = "/offer_status_screen";
  static String verify_otp = "/verify_otp_screen";
  static String privacy_screen = "/privacy_screen";
  static String help_support = "/help_support_screen";
  static String category = "/category_screen";
  static String dealer = "/dealer_screen";
  static String fuel_screen = "/fuel_screen";
  static String bikes_market = "/bikes_market";
  static String subscription_test = "/subscription_test_screen";
  static String wishlist_screen = "/wishlist_screen";
  static String aids_screen = "/aids_screen";
  static String ads = "/ads_screen";
  static String edit_dealer_profile = "/edit_dealer_profile_screen";
  static String edit_product = "/edit_product_screen";
  static String all_products_screen = "/all_products_screen";
  static String dealer_products_screen = "/dealer_products_Screen";
  static String city_products_screen = "/city_products_screen";
  static String video_uploadScreen = "/video_uploadScreen";
  static String book_test_driveScreen = "/book_testdrive_screen";
  static String dealer_bookTestDrives_screen = "/dealer_bookTestDrives_screen";
  static String dealer_product_description =
      "/dealer_product_description_Screen";
  static String all_dealers_screen = "/all_dealers_screen";
  static String dealer_detail_screen = "/dealer_detail_screen";
  static String location_settings = "/location_settings_screen";
  static String filtered_products = "/filtered_products";
}

final Getpages = [
  GetPage(name: AppRoutes.splash, page: () => const AnimatedBrandedSplash()),
  GetPage(name: AppRoutes.welcome, page: () => const WelcomeScreen()),
  GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
  GetPage(name: AppRoutes.login, page: () => LogInScreen()),
  GetPage(name: AppRoutes.logout, page: () => LogoutScreen()),
  GetPage(name: AppRoutes.home, page: () => HomeScreen()),

  GetPage(
    name: AppRoutes.description,
    page: () {
      final dynamic arg = Get.arguments;
      String carId = '';

      // Handle different argument types
      if (arg is String) {
        carId = arg;
      } else if (arg is Map) {
        // Check if it's productData format from city_products_screen
        if (arg['productData'] != null) {
          final productData = arg['productData'] as Map<String, dynamic>;
          carId = productData['id']?.toString() ?? '';
          print('[AppRoutes] Found productData format with id: $carId');
        } else if (arg['carId'] != null) {
          carId = arg['carId'].toString();
        } else {
          // Try to extract any ID field
          carId = arg['id']?.toString() ?? arg['_id']?.toString() ?? '';
        }
      } else if (arg != null) {
        carId = arg.toString();
      }

      // Detailed diagnostic logging to help find improper navigations
      print(
        '[AppRoutes] Description route invoked. raw arg: ${arg.runtimeType} -> $arg; parsed carId: "$carId"',
      );

      // If carId is empty, avoid opening DescriptionScreen with an empty id.
      // Redirect to AllProductsScreen as a safe fallback and log a warning.
      if (carId.isEmpty) {
        print(
          '[AppRoutes] Warning: empty carId passed to DescriptionScreen. Redirecting to AllProductsScreen.',
        );
        return AllProductsScreen();
      }

      try {
        return DescriptionScreen(
          carId: carId,
          productId: '',
          sellerId: '',
          sellerName: '',
        );
      } catch (e, st) {
        // Log and return a minimal error screen so navigation doesn't fail silently
        print('[AppRoutes] Error building DescriptionScreen: $e\n$st');
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Failed to open description: $e')),
        );
      }
    },
  ),
  GetPage(name: AppRoutes.chat, page: () => OldMarketChatsScreen()),
  GetPage(name: AppRoutes.chat_details, page: () => ChatDetailsScreen()),

  GetPage(name: AppRoutes.shortVideo, page: () => ShortVideoScreen()),
  GetPage(name: AppRoutes.carsMarket, page: () => CarsMarket()),
  GetPage(name: AppRoutes.setting, page: () => SettingScreen()),
  GetPage(name: AppRoutes.about, page: () => AboutScreen()),
  GetPage(name: AppRoutes.ads, page: () => AdsScreen()),
  GetPage(
    name: '/profile_uploads',
    page: () {
      final args = Get.arguments;
      String userId = '';
      String mode = 'products';
      if (args is Map) {
        userId = args['userId']?.toString() ?? '';
        mode = args['mode']?.toString() ?? 'products';
      }
      return ProfileUploadsScreen(userId: userId, mode: mode);
    },
  ),

  GetPage(name: AppRoutes.sell_user_cars, page: () => SellUserCarScreen()),
  GetPage(name: AppRoutes.sell_dealer_cars, page: () => SellDealerCarScreen()),
  GetPage(name: AppRoutes.notifications, page: () => NotificationScreen()),
  GetPage(name: AppRoutes.history, page: () => HistoryScreen()),
  GetPage(
    name: AppRoutes.dealer_history_screen,
    page: () => DealerHistoryScreen(),
  ),
  GetPage(name: AppRoutes.offer_status, page: () => OfferStatusScreen()),
  GetPage(name: AppRoutes.verify_otp, page: () => VerifyOtpScreen()),
  GetPage(name: AppRoutes.book_test_driveScreen, page: () => TestDriveScreen()),
  GetPage(
    name: AppRoutes.dealer_bookTestDrives_screen,
    page: () => DealerTestDriveScreen(),
  ),
  GetPage(name: AppRoutes.privacy_screen, page: () => PrivacyScreen()),
  GetPage(name: AppRoutes.signup_screen, page: () => SignUpScreen()),
  GetPage(name: AppRoutes.help_support, page: () => HelpSupportScreen()),
  GetPage(name: AppRoutes.category, page: () => CategoryScreen()),
  GetPage(name: AppRoutes.dealer, page: () => DealerProfileScreen()),
  GetPage(
    name: AppRoutes.fuel_screen,
    page: () {
      final args = Get.arguments;
      String city = '';
      String state = '';
      if (args is Map) {
        city = args['city']?.toString() ?? '';
        state = args['state']?.toString() ?? '';
      }
      return CheckFuelScreen(city: city, state: state);
    },
  ),
  GetPage(name: AppRoutes.bikes_market, page: () => BikesMarket()),
  GetPage(name: AppRoutes.wishlist_screen, page: () => WishlistScreen()),
  GetPage(name: AppRoutes.video_uploadScreen, page: () => PostVideoScreen()),
  GetPage(
    name: AppRoutes.location_settings,
    page: () => LocationSettingsScreen(),
  ),
  GetPage(
    name: AppRoutes.filtered_products,
    page: () => const FilteredProductsScreen(),
  ),
  GetPage(
    name: AppRoutes.city_products_screen,
    page: () {
      final args = Get.arguments;
      String cityName = '';
      if (args is Map) {
        cityName = args['cityName']?.toString() ?? 'Unknown City';
      } else if (args is String) {
        cityName = args;
      }
      return CityProductsScreen(cityName: cityName);
    },
  ),
  GetPage(
    name: AppRoutes.edit_product,
    page: () {
      final arg = Get.arguments;
      if (arg is Map && arg['product'] is AllProductModel) {
        return EditProductScreen(product: arg['product'] as AllProductModel);
      }
      // If invalid args, show a placeholder
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Product')),
        body: const Center(child: Text('No product provided')),
      );
    },
  ),
  GetPage(name: AppRoutes.all_products_screen, page: () => AllProductsScreen()),
  GetPage(
    name: AppRoutes.dealer_products_screen,
    page: () => DealerProductsScreen(),
  ),
  GetPage(
    name: AppRoutes.edit_dealer_profile,
    page: () => EditDealerProfilePage(),
  ),
  GetPage(
    name: AppRoutes.dealer_product_description,
    page: () {
      final dynamic arg = Get.arguments;
      String productId = '';
      if (arg is String) {
        productId = arg;
      } else if (arg is Map && arg['productId'] != null) {
        productId = arg['productId'].toString();
      } else if (arg != null) {
        productId = arg.toString();
      }
      return DealerDescriptionScreen(productId: productId);
    },
  ),
  GetPage(
    name: AppRoutes.subscription_test,
    page: () => const SubscriptionTestScreenSimple(),
  ),
  GetPage(
    name: AppRoutes.all_dealers_screen,
    page: () => const AllDealersScreen(),
  ),
  GetPage(
    name: AppRoutes.dealer_detail_screen,
    page: () {
      final dynamic arg = Get.arguments;
      String dealerId = '';
      if (arg is String) {
        dealerId = arg;
      } else if (arg is Map && arg['dealerId'] != null) {
        dealerId = arg['dealerId'].toString();
      } else if (arg != null) {
        dealerId = arg.toString();
      }
      return DealerDetailScreen(dealerId: dealerId);
    },
  ),
];
