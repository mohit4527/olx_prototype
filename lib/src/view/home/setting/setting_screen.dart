import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import '../../../controller/theme_controller.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  final ThemeController _themeController = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: Text("Settings"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.dark_mode),
            title: Text("Dark Mode"),
            trailing: Obx(() => Switch(
              value: _themeController.themeMode.value == ThemeMode.dark,
              onChanged: (value) {
                _themeController.toggleTheme(value);
              },
            )),
          ),
          Divider(color: AppColors.appGreen,thickness: 2,),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text("Notifications"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.remove_red_eye),
            title: Text("Appearance"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Privacy & Security"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.support_agent),
            title: Text("Help and Support"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text("About"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(AppRoutes.about);
            },
          ),
        ],
      ),
    );
  }
}
