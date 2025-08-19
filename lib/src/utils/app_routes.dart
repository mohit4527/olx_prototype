import 'package:get/get.dart';
import 'package:olx_prototype/src/view/home/aids_screen/aids_screen.dart';
import 'package:olx_prototype/src/view/home/bikes_market/bikes_market.dart';
import 'package:olx_prototype/src/view/home/cars_market/cars_market.dart';
import 'package:olx_prototype/src/view/home/category/category_screen.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';
import 'package:olx_prototype/src/view/home/dealer/dealer_screen.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';
import 'package:olx_prototype/src/view/home/history/history_screen.dart';
import 'package:olx_prototype/src/view/home/home_screen.dart';
import 'package:olx_prototype/src/view/home/logout/logout_screen.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import 'package:olx_prototype/src/view/home/profile/profile_screen.dart';
import 'package:olx_prototype/src/view/home/sellCars/sell_car_screen.dart';
import 'package:olx_prototype/src/view/home/setting/about/about_screen.dart';
import 'package:olx_prototype/src/view/home/setting/help_support/help_support_screen.dart';
import 'package:olx_prototype/src/view/home/setting/privacy_screen/privacy_screen.dart';
import 'package:olx_prototype/src/view/home/setting/setting_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import 'package:olx_prototype/src/view/login/log_in_screen.dart';
import 'package:olx_prototype/src/view/splash/splash_screen.dart';
import 'package:olx_prototype/src/view/verify_otp/verify_otp_screen.dart';

class AppRoutes {
  static String splash = "/splash_screen";
  static String login = "/log_in_screen";
  static String home = "/home_screen";
  static String profile = "/profile_screen";
  static String carsMarket = "/cars_market";
  static String setting = "/setting_screen";
  static String description = "/description_screen";
  static String chat = "/chat_screen";
  static String shortVideo = "/shortVideo_screen";
  static String logout = "/logout_screen";
  static String about = "/about_screen";
  static String sellCars = "/sell_car_screen";
  static String notifications = "/notification_screen";
  static String history = "/history_screen";
  static String verify_otp = "/verify_otp_screen";
  static String privacy_screen = "/privacy_screen";
  static String help_support = "/help_support_screen";
  static String category = "/category_screen";
  static String dealer = "/dealer_screen";
  static String bikes_market = "/bikes_market";
  static String aids_screen = "/aids_screen";
}

final Getpages = [
  GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
  GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
  GetPage(name: AppRoutes.login, page: () => LogInScreen()),
  GetPage(name: AppRoutes.logout, page: () => LogoutScreen()),
  GetPage(name: AppRoutes.home, page: () => HomeScreen()),

  GetPage(
    name: AppRoutes.description,
    page: () {
      final String carId = (Get.arguments ?? '') as String;
      return DescriptionScreen(carId: carId,);
    },
  ),
  GetPage(name: AppRoutes.chat, page: () => ChatScreen()),
  GetPage(name: AppRoutes.shortVideo, page: () => ShortvideoScreen()),
  GetPage(name: AppRoutes.carsMarket, page: () => CarsMarket()),
  GetPage(name: AppRoutes.setting, page: () => SettingScreen()),
  GetPage(name: AppRoutes.about, page: () => AboutScreen()),
  GetPage(name: AppRoutes.sellCars, page: () => SellCarScreen()),
  GetPage(name: AppRoutes.notifications, page: () => NotificationScreen()),
  GetPage(name: AppRoutes.history, page: () => HistoryScreen()),
  GetPage(name: AppRoutes.verify_otp, page: () => VerifyOtpScreen()),
  GetPage(name: AppRoutes.privacy_screen, page: () => PrivacyScreen()),
  GetPage(name: AppRoutes.help_support, page: () => HelpSupportScreen()),
  GetPage(name: AppRoutes.category, page: () => CategoryScreen()),
  GetPage(name: AppRoutes.dealer, page: () => DealerProfileScreen()),
  GetPage(name: AppRoutes.bikes_market, page: () => BikesMarket()),
  GetPage(name: AppRoutes.aids_screen, page: () => MyAidsScreen()),
];
