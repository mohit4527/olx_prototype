import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/controller/all_products_controller.dart';
import 'package:olx_prototype/src/controller/dealer_controller.dart';
import 'package:olx_prototype/src/controller/edit_dealer_profile_controller.dart';
import 'package:olx_prototype/src/controller/home_controller.dart';
import 'package:olx_prototype/src/controller/theme_controller.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(TokenController(), permanent: true);
  Get.put(DealerProfileController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(EditDealerProfileController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.put(ThemeController());

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Obx(() => GetMaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeController.theme,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.purple,
            scaffoldBackgroundColor: Colors.white,
            popupMenuTheme: PopupMenuThemeData(
              color: AppColors.appGreen,
              textStyle: TextStyle(
                color: AppColors.appWhite,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: AppColors.appGreen,
            scaffoldBackgroundColor: Colors.black,
            popupMenuTheme: PopupMenuThemeData(
              color: AppColors.appGreen,
              textStyle: TextStyle(
                color: AppColors.appWhite,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          initialRoute: AppRoutes.splash,
          getPages: Getpages,
        ));
      },
    );
  }
}