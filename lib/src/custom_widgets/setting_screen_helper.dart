import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';

class FeedbackDialog {
  static void showFeedbackDialog(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Send Feedback',style: TextStyle(fontWeight: FontWeight.w600),),
          content: TextField(
            controller: feedbackController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: "Write your feedback here...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you for your response!",style: TextStyle(color: AppColors.appWhite),),backgroundColor: AppColors.appGreen,),
                );
              },
              child: const Text("Send",style: TextStyle(color: AppColors.appWhite),),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                )
            ),
          ],
        );
      },
    );
  }

  static void showRatingDialog(BuildContext context) {
    int selectedRating = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Rate this App",style: TextStyle(fontWeight: FontWeight.w600),),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < selectedRating ? Colors.yellow.shade900 : Colors.grey.shade500,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child:  Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(

                   SnackBar(content: Text("Thank you for giving the rate and feedback!",style: TextStyle(color: AppColors.appWhite)),backgroundColor: AppColors.appGreen,),
                    );
                  },
                  child: const Text("Submit",style: TextStyle(color: AppColors.appWhite),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  )
                ),
              ],
            );
          },
        );
      },
    );
  }
}
