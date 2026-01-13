import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizer.dart';

class AboutScreen extends StatelessWidget {
  AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
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
                  colors: [AppColors.appGreen, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Name and Version
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: AppColors.appGrey.shade700,
                ),
                title: Text(
                  "App Name",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text("Old Market"),
              ),
              ListTile(
                leading: Icon(Icons.update, color: AppColors.appGrey.shade700),
                title: Text(
                  "Version",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text("1.0.5"),
              ),

              // Developer info
              ListTile(
                leading: Icon(Icons.person, color: AppColors.appGrey.shade700),
                title: Text(
                  "Developer",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text("Mohit Kumar"),
              ),

              // Email / Contact
              ListTile(
                leading: Icon(
                  Icons.email_outlined,
                  color: AppColors.appGrey.shade700,
                ),
                title: Text(
                  "Contact",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text("kumarmohit42421@gmail.com"),
              ),

              // Feedback option
              ListTile(
                leading: Icon(
                  Icons.feedback_outlined,
                  color: AppColors.appGrey.shade700,
                ),
                title: Text(
                  "Send Feedback",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  FeedbackDialog.showFeedbackDialog(context);
                },
              ),

              // Rate app
              ListTile(
                leading: Icon(
                  Icons.star_border_outlined,
                  color: AppColors.appGrey.shade700,
                ),
                title: Text(
                  "Rate this App",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  FeedbackDialog.showRatingDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ✅ FeedbackDialog Helper Class
//
class FeedbackDialog {
  // Feedback dialog
  static void showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Send Feedback"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("We’d love to hear your thoughts!"),
            const SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter your feedback here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final feedback = feedbackController.text.trim();
              if (feedback.isNotEmpty) {
                Get.back();
                Get.snackbar(
                  'Thanks',
                  'Thank you for your feedback!',
                  backgroundColor: AppColors.appGreen,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Rating dialog
  static void showRatingDialog(BuildContext context) {
    double rating = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Rate this App"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("How was your experience?"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () => setState(() => rating = index + 1.0),
                    );
                  }),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Thanks for rating $rating stars!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
