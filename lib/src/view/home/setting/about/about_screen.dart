import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizer.dart';


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
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Name and Version
            ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.appPrimaryColor),
              title: Text(
                "App Name",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Green Bazaar"),
            ),
            ListTile(
              leading: Icon(Icons.update, color: AppColors.appPrimaryColor),
              title: Text(
                "Version",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("1.0.5"),
            ),

            // Developer info
            ListTile(
              leading: Icon(Icons.person, color: AppColors.appPrimaryColor),
              title: Text(
                "Developer",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("Mohit Kumar"),
            ),

            // Email / Contact
            ListTile(
              leading: Icon(Icons.email_outlined, color: AppColors.appPrimaryColor),
              title: Text(
                "Contact",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              subtitle: Text("kumarmohit42421@gmail.com"),
            ),

            // Feedback option
            ListTile(
              leading: Icon(Icons.feedback_outlined, color: AppColors.appPrimaryColor),
              title: Text(
                "Send Feedback",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // Email ya feedback screen open
              },
            ),

            // Privacy Policy
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined, color: AppColors.appPrimaryColor),
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // privacy page ya link open karo
              },
            ),

            // Rate app
            ListTile(
              leading: Icon(Icons.star_border_outlined, color: AppColors.appPrimaryColor),
              title: Text(
                "Rate this App",
                style: TextStyle(fontSize: AppSizer().fontSize16, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                // playstore link ya dialog open
              },
            ),
          ],
        ),
      ),
    );
  }
}
