import 'package:get/get.dart';
import 'package:olx_prototype/src/view/home/cars_market/cars_market.dart';
import 'package:olx_prototype/src/view/home/home_screen.dart';
import 'package:olx_prototype/src/view/home/shortVideo/shortVideo_screen.dart';
import 'package:video_player/video_player.dart';
import '../utils/app_routes.dart';

class NavigationController extends GetxController {
  var selectedIndex = 0.obs;

  void onItemTapped(int index) {
    selectedIndex.value = index;

    switch (index) {
      case 0:
        Get.to(HomeScreen());
        break;
      case 1:
        Get.toNamed(AppRoutes.category);
        break;
      case 2:
        Get.toNamed(AppRoutes.shortVideo);
        break;
        case 3:
        Get.toNamed(AppRoutes.aids_screen);
        break;
        case 4:
        Get.toNamed(AppRoutes.chat);
        break;
    }
  }
}
