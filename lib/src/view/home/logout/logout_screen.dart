import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/app_sizer.dart';
import '../../../utils/app_routes.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';

class LogoutScreen extends StatelessWidget {
  LogoutScreen({super.key});

  final profileController = Get.put(GetProfileController());

  @override
  Widget build(BuildContext context) {
    final tokenController = Get.find<TokenController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        title: Text("LogOut", style: TextStyle(color: AppColors.appWhite)),
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
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              SizedBox(height: AppSizer().height2),
              Obx(
                () => Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.dialog(
                          Dialog(
                            backgroundColor: Colors.transparent,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: tokenController.photoUrl.value.isNotEmpty
                                  ? Image.network(
                                      tokenController.photoUrl.value,
                                    )
                                  : (profileController
                                            .imagePath
                                            .value
                                            .isNotEmpty
                                        ? Image.file(
                                            File(
                                              profileController.imagePath.value,
                                            ),
                                          )
                                        : CircleAvatar(
                                            radius: 80,
                                            backgroundColor: Color(0xfffae293),
                                            child: Icon(Icons.person, size: 80),
                                          )),
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: Color(0xfffae293),
                        radius: 36,
                        backgroundImage:
                            tokenController.photoUrl.value.isNotEmpty
                            ? NetworkImage(tokenController.photoUrl.value)
                            : (profileController.imagePath.value.isNotEmpty
                                  ? FileImage(
                                          File(
                                            profileController.imagePath.value,
                                          ),
                                        )
                                        as ImageProvider
                                  : null),
                        child:
                            tokenController.photoUrl.value.isEmpty &&
                                profileController.imagePath.value.isEmpty
                            ? Icon(Icons.person, size: 45)
                            : null,
                      ),
                    ),

                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          Get.dialog(
                            AlertDialog(
                              title: Text(
                                "Choose",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppSizer().fontSize19,
                                  color: AppColors.appPurple,
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            profileController
                                                .getImageByCamera();
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: AppColors.appBlue,
                                          ),
                                        ),
                                        Text(
                                          "Camera",
                                          style: TextStyle(
                                            color: AppColors.appPurple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizer().fontSize16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            profileController
                                                .getImageByGallery();
                                            Get.back();
                                          },
                                          icon: Icon(
                                            Icons.image,
                                            color: AppColors.appBlue,
                                          ),
                                        ),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(
                                            color: AppColors.appPurple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizer().fontSize16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 15,
                          backgroundColor: AppColors.appBlack,
                          child: Icon(
                            Icons.camera_alt,
                            size: AppSizer().height2,
                            color: AppColors.appWhite,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizer().height2),
              // Display dynamic user info: prefer TokenController, then profileController, then SharedPreferences
              FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snap) {
                  final prefs = snap.data;
                  final displayName =
                      tokenController.displayName.value.isNotEmpty
                      ? tokenController.displayName.value
                      : (profileController.profileData['Username'] ??
                            prefs?.getString('user_display_name') ??
                            'Guest');
                  final email =
                      (profileController.profileData['Email'] ??
                      prefs?.getString('user_email') ??
                      '');
                  final phone =
                      (profileController.profileData['Phone'] ??
                      prefs?.getString('phone') ??
                      '');

                  return Column(
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizer().fontSize18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizer().fontSize18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: AppSizer().fontSize18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: AppSizer().height10),
              Icon(Icons.logout_outlined, size: 100, color: AppColors.appBlue),
              SizedBox(height: AppSizer().height6),
              InkWell(
                onTap: () {
                  Get.dialog(
                    AlertDialog(
                      title: Text(
                        "Confirm LogOut",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSizer().fontSize19,
                        ),
                      ),
                      content: const Text("Are you sure you want to logout ?"),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final TokenController tokenController =
                                Get.find<TokenController>();
                            await tokenController.clearToken();
                            Get.offAllNamed(AppRoutes.login);
                          },
                          child: const Text("Yes"),
                        ),
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  height: AppSizer().height6,
                  decoration: BoxDecoration(
                    color: AppColors.appGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "LogOut",
                      style: TextStyle(
                        color: AppColors.appWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizer().fontSize18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
