import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../utils/app_routes.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: const Text(
          "Chat Screen",
          style: TextStyle(color: AppColors.appWhite),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.offAllNamed(AppRoutes.home);
          },
          icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }
}
