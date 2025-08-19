import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

import '../../../../custom_widgets/setting_screen_helper.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.appWhite),
        title: Text(
          "Help & Support",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(onPressed: (){
          Get.back();
        },
            icon:Icon(Icons.arrow_back,color: AppColors.appWhite,)),
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
      child:
      Padding(
        padding: EdgeInsets.all(AppSizer().height1),
        child: ListView(
          children: [
            _helpTile(
              icon: Icons.question_answer_outlined,
              title: "FAQs",
              subtitle: "Find answers to common questions.",
              onTap: () {
                // Navigate to FAQ screen
              },
            ),
            _helpTile(
              icon: Icons.support_agent_outlined,
              title: "Contact Support",
              subtitle: "Get help from our support team.",
              onTap: () {
                // Navigate to chat or support form
              },
            ),
            _helpTile(
              icon: Icons.bug_report_outlined,
              title: "Report a Problem",
              subtitle: "Tell us if something isn't working.",
              onTap: () {
                FeedbackDialog.showReportDialog(context);
              },
            ),
            _helpTile(
              icon: Icons.star_border_outlined,
              title: "Rate this App",
              subtitle: "Share Your experience on this app",
              onTap: () {
                FeedbackDialog.showRatingDialog(context);
              },
            ),
            _helpTile(
              icon: Icons.feedback_outlined,
              title: "Give Feedback",
              subtitle: "Share your thoughts to improve the app.",
              onTap: () {
                FeedbackDialog.showFeedbackDialog(context);
              },
            ),
            _helpTile(
              icon: Icons.privacy_tip_outlined,
              title: "Privacy Policy",
              subtitle: "Read how we handle your data.",
              onTap: () {
                Get.toNamed(AppRoutes.privacy_screen);
                },
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: AppSizer().height1),
      leading: CircleAvatar(
        backgroundColor: AppColors.appBlack.withOpacity(0.6),
        child: Icon(icon, color: AppColors.appWhite),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize16,
          fontWeight: FontWeight.w600,
          color: AppColors.appGrey.shade900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: AppSizer().fontSize14,
          color:AppColors.appGrey.shade700,
        ),
      ),
      onTap: onTap,
    );
  }
}
