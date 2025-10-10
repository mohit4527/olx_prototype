import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class HelpSupportScreen extends StatelessWidget {
  HelpSupportScreen({super.key});

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
          "Customer Support",
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
              _buildHeader(),
              SizedBox(height: AppSizer().height2),

              _buildSectionTitle("Need Help?",),
              _buildSectionContent(
                "Our team is always here to support you. "
                    "If you face any issues with buying, selling, or using the Old Market app, feel free to reach out to us.",
              ),

              _buildSectionTitle("Contact Us"),
              _buildContactRow(
                icon: Icons.email_outlined,
                label: "Email",
                value: "support@oldmarket.com",
              ),
              _buildContactRow(
                icon: Icons.phone_android,
                label: "Phone",
                value: "+91-9876543210",
              ),

              _buildSectionTitle("Support Hours"),
              _buildSectionContent(
                "📅 Monday - Saturday\n⏰ 9:00 AM - 7:00 PM\n\n"
                    "We aim to respond to all queries within 24 hours.",
              ),

              _buildSectionTitle("Feedback"),
              _buildSectionContent(
                "Your feedback helps us improve! "
                    "If you have suggestions about how we can make Old Market better, "
                    "don’t hesitate to share them with our team.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.support_agent,
            size: AppSizer().height8,
            color: AppColors.appGreen,
          ),
          SizedBox(height: AppSizer().height1),
          Text(
            "We're Here to Help!",
            style: TextStyle(
              fontSize: AppSizer().fontSize19,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: AppSizer().height2, bottom: AppSizer().height1),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize17,
          fontWeight: FontWeight.w600,
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

  Widget _buildContactRow({required IconData icon, required String label, required String value}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizer().height1),
      child: Row(
        children: [
          Icon(icon, color: AppColors.appGreen, size: AppSizer().height3),
          SizedBox(width: AppSizer().width3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: AppSizer().fontSize16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppSizer().fontSize16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
