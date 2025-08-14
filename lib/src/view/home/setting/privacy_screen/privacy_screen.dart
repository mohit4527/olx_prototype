import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:path/path.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.appBlack),
        title: Text(
          "Privacy & Security",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon:
        Icon(Icons.arrow_back,color: AppColors.appWhite,)
        ),
      ),
      body:Container(
      height: AppSizer().height100,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AppColors.appGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    ),
      child:
      Padding(
        padding: EdgeInsets.all(AppSizer().height1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Your Data",),
            _settingTile(
              icon: Icons.lock_outline,
              title: "Password & Login",
              subtitle: "Change your password or manage login options.",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.security,
              title: "Two-Factor Authentication",
              subtitle: "Add an extra layer of security to your account.",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Review how we collect and handle your data.",
              onTap: () {},
            ),
            SizedBox(height: AppSizer().height2),
            _sectionTitle("Permissions"),
            _settingTile(
              icon: Icons.notifications_active_outlined,
              title: "Notification Access",
              subtitle: "Manage app notification settings.",
              onTap: () {},
            ),
            _settingTile(
              icon: Icons.location_on_outlined,
              title: "Location Access",
              subtitle: "Manage app location permissions.",
              onTap: () {},
            ),
          ],
        ),
      ),
      )
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer().height1),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize16,
          fontWeight: FontWeight.bold,
          color: AppColors.appBlack,
        ),
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.appBlack.withOpacity(0.4),
        child: Icon(icon, color: AppColors.appWhite),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: AppSizer().fontSize14,
          color: AppColors.appGrey.shade700,
        ),
      ),
      onTap: onTap,
    );
  }
}
