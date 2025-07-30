import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/get_profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GetProfileController controller = Get.put(GetProfileController());

  final Map<String, String> userInfo = {
    "Username": "Mohit Kumar",
    "Phone Number": "+91 7270095618",
    "Email": "kumarmohit123@gmail.com",
    "Gender": "Male",
    "Date Of Birth": "01/01/2000"
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile",style: TextStyle(color: AppColors.appWhite),),
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        elevation: 0,
        leading: BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer().height2),
        child: Column(
          children: [
            Obx(() => Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: controller.imagePath.isNotEmpty
                      ? FileImage(File(controller.imagePath.toString()))
                      : null,
                  child: controller.imagePath.isEmpty
                      ? Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _showImagePicker(context),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ),
                )
              ],
            )),
            SizedBox(height: AppSizer().height2),
            Text(
              "Mohit Kumar",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Gold Member",
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: AppSizer().height3),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("INFORMATION", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: AppSizer().height1),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(AppSizer().height2),
              child: Column(
                children: userInfo.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(entry.key,
                              style: TextStyle(fontWeight: FontWeight.w600,color: AppColors.appBlack)),
                        ),
                        Expanded(
                          flex: 4,
                          child: Text(entry.value,
                              style: TextStyle(color: Colors.grey.shade800)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Choose", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      controller.getImageByCamera();
                      Get.back();
                    },
                    icon: Icon(Icons.camera_alt, color: Colors.blue),
                  ),
                  Text("Camera"),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      controller.getImageByGallery();
                      Get.back();
                    },
                    icon: Icon(Icons.image, color: Colors.green),
                  ),
                  Text("Gallery"),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
