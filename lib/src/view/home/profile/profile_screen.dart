import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/get_profile_controller.dart';
import '../../../custom_widgets/profile_page_helper.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GetProfileController controller = Get.put(GetProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Container(
        height: AppSizer().height100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.appGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer().height1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: AppSizer().height10,),
            Obx(() => Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: controller.imagePath.isNotEmpty
                      ? FileImage(File(controller.imagePath.value))
                      : null,
                  child: controller.imagePath.isEmpty
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: () {
                      showImagePickerDialog(
                        context: context,
                        onCameraTap: controller.getImageByCamera,
                        onGalleryTap: controller.getImageByGallery,
                      );
                    },
                    child: const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.edit, size: 18, color: Colors.black),
                    ),
                  ),
                )
              ],
            )),
            SizedBox(height: AppSizer().height2),
            Obx(() => Text(
              controller.profileData['Username'] ?? '',
              style: TextStyle(
                  fontSize: AppSizer().fontSize17,
                  fontWeight: FontWeight.bold),
            )),
             Text("Gold Member", style: TextStyle(color: Colors.grey.shade700)),
            SizedBox(height: AppSizer().height3),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "INFORMATION",
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: AppSizer().fontSize17,
                ),
              ),
            ),
            SizedBox(height: AppSizer().height1),
            Obx(() => Column(
              children: controller.profileData.entries.map((entry) {
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(entry.key,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: AppSizer().fontSize16)),
                    subtitle: Text(entry.value,
                        style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: AppSizer().fontSize15)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.appGreen),
                      onPressed: () {
                        showEditFieldDialog(
                          context: context,
                          fieldName: entry.key,
                          initialValue: entry.value,
                          onConfirm: (newValue) =>
                              controller.updateField(entry.key, newValue),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            )),
          ],
        ),
      ),
    ),

    );
  }
}
