import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/get_profile_controller.dart';
import '../../../controller/dealer_controller.dart';
import '../../../custom_widgets/profile_page_helper.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final GetProfileController controller = Get.put(GetProfileController());

  // 🔥 Get dealer controller to check profile status
  DealerProfileController get dealerController {
    if (Get.isRegistered<DealerProfileController>()) {
      return Get.find<DealerProfileController>();
    } else {
      return Get.put(DealerProfileController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Profile"),
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizer().height1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSizer().height5),
                Obx(() {
                  final imgPath = controller.imagePath.value;
                  ImageProvider avatarImage;
                  if (imgPath.isNotEmpty) {
                    if (imgPath.startsWith('http')) {
                      avatarImage = NetworkImage(imgPath);
                    } else if (File(imgPath).existsSync()) {
                      avatarImage = FileImage(File(imgPath));
                    } else {
                      avatarImage = const AssetImage(
                        'assets/images/placeholder.jpg',
                      );
                    }
                  } else {
                    // Use an existing bundled placeholder image
                    avatarImage = const AssetImage(
                      'assets/images/placeholder.jpg',
                    );
                  }

                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: avatarImage,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            showImagePickerDialog(
                              onCameraTap: controller.getImageByCamera,
                              onGalleryTap: controller.getImageByGallery,
                            );
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: AppSizer().height2),
                Obx(() {
                  // 🔥 Show business name if vendor, otherwise show username
                  final isVendor = dealerController.isProfileCreated.value;
                  final businessName =
                      controller.profileData['BusinessName'] ?? '';
                  final userName = controller.profileData['Username'] ?? '';

                  final displayName = isVendor && businessName.isNotEmpty
                      ? businessName
                      : userName;

                  return Text(
                    displayName,
                    style: TextStyle(
                      fontSize: AppSizer().fontSize18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }),
                Obx(() {
                  // 🔥 Dynamic role: show 'Vendor' for business accounts
                  final role = dealerController.isProfileCreated.value
                      ? 'Vendor'
                      : (controller.profileData['Role'] ?? 'User');
                  return Text(
                    role,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: dealerController.isProfileCreated.value
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                }),
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
                Obx(() {
                  // Only show selected safe fields
                  final safeKeys = [
                    'Username',
                    'Phone Number',
                    'Email',
                    'Role',
                  ];
                  return Column(
                    children: safeKeys.map((k) {
                      // 🔥 Dynamic value based on field type
                      String v;
                      if (k == 'Role') {
                        // Dynamic role: show 'Vendor' for business accounts
                        v = dealerController.isProfileCreated.value
                            ? 'Vendor'
                            : (controller.profileData[k] ?? 'User');
                      } else {
                        v = controller.profileData[k] ?? '';
                      }

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            k,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizer().fontSize16,
                            ),
                          ),
                          subtitle: Text(
                            v,
                            style: TextStyle(
                              color:
                                  k == 'Role' &&
                                      dealerController.isProfileCreated.value
                                  ? AppColors
                                        .appGreen // Highlight dealer role
                                  : Colors.grey,
                              fontSize: AppSizer().fontSize15,
                              fontWeight:
                                  k == 'Role' &&
                                      dealerController.isProfileCreated.value
                                  ? FontWeight
                                        .w600 // Bold for dealer role
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: AppColors.appGreen,
                            ),
                            onPressed: () {
                              showEditFieldDialog(
                                fieldName: k,
                                initialValue: v,
                                onConfirm: (newValue) =>
                                    controller.updateField(k, newValue),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
