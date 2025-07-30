import 'package:get/get.dart';
import 'package:olx_prototype/src/view/home/cars_market/cars_market.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';
import 'package:olx_prototype/src/view/home/description/description_screen.dart';
import 'package:olx_prototype/src/view/home/home_screen.dart';
import 'package:olx_prototype/src/view/home/logout/logout_screen.dart';
import 'package:olx_prototype/src/view/home/profile/profile_screen.dart';
import 'package:olx_prototype/src/view/home/sellCars/sell_car_screen.dart';
import 'package:olx_prototype/src/view/home/setting/about/about_screen.dart';
import 'package:olx_prototype/src/view/home/setting/setting_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import 'package:olx_prototype/src/view/login/log_in_screen.dart';
import 'package:olx_prototype/src/view/splash/splash_screen.dart';

import '../model/product_description_model/product_description model.dart';


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
}

final Getpages = [
  GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
  GetPage(name: AppRoutes.profile, page: () => ProfilePage()),
  GetPage(name: AppRoutes.login, page: () => LogInScreen()),
  GetPage(name: AppRoutes.logout, page: () => LogoutScreen()),
  GetPage(name: AppRoutes.home, page: () => HomeScreen()),
  GetPage(name: AppRoutes.description, page: () => DescriptionScreen(),),
  GetPage(name: AppRoutes.chat, page: () => ChatScreen()),
  GetPage(name: AppRoutes.shortVideo, page: () => ShortvideoScreen(),),
  GetPage(name: AppRoutes.carsMarket, page: () => CarsMarket()),
  GetPage(name: AppRoutes.setting, page: () => SettingScreen()),
  GetPage(name: AppRoutes.about, page: () => AboutScreen()),
  GetPage(name: AppRoutes.sellCars, page: () => SellCarScreen()),
];
