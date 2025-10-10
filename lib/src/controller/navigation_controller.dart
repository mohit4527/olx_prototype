import 'package:get/get.dart';
import '../utils/logger.dart';
import 'package:olx_prototype/src/view/home/ads/ads_screen.dart';
import 'package:olx_prototype/src/view/home/category/category_screen.dart';
import 'package:olx_prototype/src/view/home/home_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import 'package:olx_prototype/src/view/home/chat/chat_screen.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  final screens = [
    () => HomeScreen(),
    () => CategoryScreen(),
    () => ShortVideoScreen(),
    () => AdsScreen(),

    () => OldMarketChatsScreen(),
  ];

  void onItemTapped(int index) {
    selectedIndex.value = index;
    Logger.d('NavigationController', 'onItemTapped -> index=$index');
  }
}
