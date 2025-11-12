import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/theme_controller.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: Text("Settings", style: TextStyle(color: AppColors.appWhite)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: AppSizer().height100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.appGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.dark_mode),
                title: Text("Dark Mode"),
                trailing: Obx(
                  () => Switch(
                    value: _themeController.themeMode.value == ThemeMode.dark,
                    onChanged: (value) {
                      _themeController.toggleTheme(value);
                    },
                  ),
                ),
              ),
              Divider(color: AppColors.appGreen, thickness: 2),
              ListTile(
                leading: Icon(
                  Icons.notifications,
                  color: AppColors.appGrey.shade800,
                ),
                title: Text("Notifications"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.appGrey.shade600,
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.notifications);
                },
              ),
              ListTile(
                leading: Icon(Icons.lock, color: AppColors.appGrey.shade800),
                title: Text("Privacy Policy"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.appGrey.shade600,
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.privacy_screen);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.support_agent,
                  color: AppColors.appGrey.shade800,
                ),
                title: Text("Customer Support"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.appGrey.shade600,
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.help_support);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppColors.appGrey.shade800,
                ),
                title: Text("About"),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.appGrey.shade600,
                ),
                onTap: () {
                  Get.toNamed(AppRoutes.about);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
