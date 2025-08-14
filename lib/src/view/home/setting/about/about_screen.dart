import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizer.dart';
import '../../../../custom_widgets/setting_screen_helper.dart';


class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(onPressed: (){
          Get.back();
        }, icon:Icon(Icons.arrow_back,color: AppColors.appWhite,)),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
      ),
      body: Container(
    height: AppSizer().height100,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AppColors.appGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    ),
    child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Name and Version
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.appGrey.shade700),
              title: Text(
                "App Name",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Old Market"),
            ),
            ListTile(
              leading: Icon(Icons.update, color: AppColors.appGrey.shade700),
              title: Text(
                "Version",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("1.0.5"),
            ),

            // Developer info
            ListTile(
              leading: Icon(Icons.person, color: AppColors.appGrey.shade700),
              title: Text(
                "Developer",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Mohit Kumar"),
            ),

            // Email / Contact
            ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.appGrey.shade700),
              title: Text(
                "Contact",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("kumarmohit42421@gmail.com"),
            ),

            // Feedback option
            ListTile(
              leading: Icon(Icons.feedback_outlined, color: AppColors.appGrey.shade700),
              title: Text(
                "Send Feedback",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                FeedbackDialog.showFeedbackDialog(context);
              },
            ),
            // Privacy Policy
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: AppColors.appGrey.shade700),
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Get.toNamed(AppRoutes.privacy_screen);
              },
            ),

            // Rate app
            ListTile(
              leading: Icon(Icons.star_border_outlined, color: AppColors.appGrey.shade700),
              title: Text(
                "Rate this App",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                FeedbackDialog.showRatingDialog(context);
              },
            ),
          ],
        ),
      ),
      )
    );
  }
}
