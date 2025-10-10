import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class PrivacyScreen extends StatelessWidget {
  PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.appWhite),
        title: Text(
          "Privacy Policy",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [AppColors.appGreen.withOpacity(0.2), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizer().height2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Introduction"),
              _buildSectionContent(
                  "Welcome to Old Market. Your privacy is very important to us. This Privacy Policy explains how we collect, use, and safeguard your personal information when you use our app and services."),

              _buildSectionTitle("Information We Collect"),
              _buildSectionContent(
                  "1. Personal Information: Name, phone number, email address, and account details provided during registration.\n\n"
                      "2. Usage Data: Information on how you use Old Market, including recently viewed items, searches, and clicks.\n\n"
                      "3. Device Data: Device model, operating system, and app version."),

              _buildSectionTitle("How We Use Your Information"),
              _buildSectionContent(
                  "• To provide and improve our marketplace services.\n"
                      "• To personalize your user experience, including showing relevant products.\n"
                      "• To communicate with you about offers, updates, and support.\n"
                      "• To ensure secure transactions and prevent fraud."),

              _buildSectionTitle("Data Sharing & Security"),
              _buildSectionContent(
                  "We do not sell or rent your personal data. Information may only be shared with trusted partners (like payment gateways) to complete your transactions. All personal data is protected using secure encryption and strict access controls."),

              _buildSectionTitle("Your Rights"),
              _buildSectionContent(
                  "• You can access, update, or delete your personal data at any time from account settings.\n"
                      "• You may opt-out of promotional notifications through app settings.\n"
                      "• You have the right to request complete account deletion."),

              _buildSectionTitle("Changes to This Policy"),
              _buildSectionContent(
                  "Old Market may update this Privacy Policy from time to time. We encourage you to review this page periodically for the latest updates."),

              _buildSectionTitle("Contact Us"),
              _buildSectionContent(
                  "If you have any questions or concerns about this Privacy Policy, please contact us at:\n\n"
                      "📧 support@oldmarket.com\n"
                      "📞 +91-XXXXXXXXXX"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizer().height2, bottom: AppSizer().height1),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize18,
          fontWeight: FontWeight.bold,
          color: AppColors.appGreen,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: AppSizer().fontSize16,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }
}
