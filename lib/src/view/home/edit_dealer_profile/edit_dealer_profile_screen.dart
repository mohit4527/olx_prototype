// lib/src/view/home/edit_dealer_profile/edit_dealer_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:path/path.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/edit_dealer_profile_controller.dart';
import '../../../custom_widgets/dealer_screen_widgets.dart';

class EditDealerProfilePage extends StatelessWidget {
  EditDealerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    print(
      "🎯 [EditDealerProfileScreen] Building screen - arguments: $arguments",
    );

    // 🔥 Delete any existing controller first
    if (Get.isRegistered<EditDealerProfileController>()) {
      Get.delete<EditDealerProfileController>();
      print("🗑️ [EditDealerProfileScreen] Deleted existing controller");
    }

    // Create fresh controller and pass arguments manually if available
    final EditDealerProfileController controller = Get.put(
      EditDealerProfileController(),
      permanent: false,
    );

    // 🔥 Manually load arguments if available
    if (arguments != null && arguments is Map<String, dynamic>) {
      print(
        "🚀 [EditDealerProfileScreen] Manually triggering data load with arguments",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(
          Duration(milliseconds: 100),
        ); // Small delay for controller setup
        controller.loadDataFromArguments(arguments);
      });
    }

    print("✅ [EditDealerProfileScreen] Controller setup completed");
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Prevent default back navigation
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          // Handle phone back button - navigate to home
          print(
            '📱 [EditDealerProfile] Phone back button pressed - navigating to home screen',
          );
          Get.offAllNamed(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appGreen,
          title: Text(
            "Edit Profile",
            style: TextStyle(
              color: AppColors.appWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              // 🏠 Navigate directly to home screen (not dealer profile)
              print(
                '🏠 [EditDealerProfile] Back button pressed - navigating to home screen',
              );
              Get.offAllNamed(AppRoutes.home);
            },
            icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
          ),
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSizer().height1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppSizer().height1),

                /// -------- Business Logo --------
                Center(
                  child: Obx(
                    () => Stack(
                      children: [
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: controller.businessLogo.value != null
                              ? FileImage(controller.businessLogo.value!)
                              : null,
                          child: controller.businessLogo.value == null
                              ? const Icon(Icons.store, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              Get.bottomSheet(
                                Container(
                                  color: Colors.white,
                                  child: Wrap(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.photo),
                                        title: Text("Gallery"),
                                        onTap: () {
                                          controller.pickBusinessLogo(
                                            ImageSource.gallery,
                                          );
                                          Get.back();
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.camera),
                                        title: Text("Camera"),
                                        onTap: () {
                                          controller.pickBusinessLogo(
                                            ImageSource.camera,
                                          );
                                          Get.back();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: AppSizer().height2),

                /// -------- Business Name --------
                Center(
                  child: TextField(
                    controller: controller.businessNameController,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Business Name",
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizer().fontSize17,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: AppSizer().fontSize17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Dealer Profile",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

                SizedBox(height: AppSizer().height3),

                /// -------- Business Info Fields --------
                AppCustomWidgets.sectionTitle("Business Information"),
                AppCustomWidgets.buildTextField(
                  "Business Name",
                  Icon(Icons.business_center),
                  controller: controller.businessNameController,
                ),
                AppCustomWidgets.buildTextField(
                  "Registration Number",
                  Icon(Icons.pin),
                  controller: controller.regNoController,
                ),
                AppCustomWidgets.buildTextField(
                  "Village",
                  Icon(Icons.location_city),
                  controller: controller.villageController,
                ),
                AppCustomWidgets.buildTextField(
                  "City",
                  Icon(Icons.location_city),
                  controller: controller.cityController,
                ),
                AppCustomWidgets.buildTextField(
                  "State",
                  Icon(Icons.map),
                  controller: controller.stateController,
                ),
                AppCustomWidgets.buildTextField(
                  "Country",
                  Icon(Icons.public),
                  controller: controller.countryController,
                ),
                AppCustomWidgets.buildTextField(
                  "Phone Number",
                  Icon(Icons.phone_android),
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
                AppCustomWidgets.buildTextField(
                  "Email Address",
                  Icon(Icons.mail),
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                AppCustomWidgets.buildTextField(
                  "Business Address",
                  Icon(Icons.pin_drop),
                  controller: controller.addressController,
                ),

                /// -------- Dealer Type --------
                AppCustomWidgets.sectionTitle("Dealer Type"),
                Obx(
                  () => Wrap(
                    spacing: AppSizer().width1,
                    runSpacing: AppSizer().height1,
                    children:
                        [
                          "Cars",
                          "Motorcycles",
                          "Trucks",
                          "Parts",
                          "Other",
                        ].map((type) {
                          return ChoiceChip(
                            label: Text(type),
                            selected:
                                controller.selectedDealerType.value == type,
                            onSelected: (_) =>
                                controller.selectedDealerType.value = type,
                            selectedColor: AppColors.appGreen,
                            labelStyle: TextStyle(
                              color: controller.selectedDealerType.value == type
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                ),

                /// -------- Description --------
                AppCustomWidgets.sectionTitle("Business Description"),
                AppCustomWidgets.buildTextArea(
                  "Tell us about your business...",
                  controller: controller.descriptionController,
                ),

                SizedBox(height: AppSizer().height2),

                /// -------- Business Photos --------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "BUSINESS PHOTOS",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: AppSizer().fontSize17,
                    ),
                  ),
                ),
                SizedBox(height: AppSizer().height1),
                Obx(
                  () => Wrap(
                    spacing: 10,
                    children: [
                      ...controller.businessPhotos
                          .asMap()
                          .entries
                          .map(
                            (entry) => GestureDetector(
                              onTap: () =>
                                  controller.removeBusinessPhoto(entry.key),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      entry.value,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Icon(
                                      Icons.cancel,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            Container(
                              color: Colors.white,
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.photo),
                                    title: Text("Gallery"),
                                    onTap: () {
                                      controller.pickBusinessPhoto(
                                        ImageSource.gallery,
                                      );
                                      Get.back();
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.camera),
                                    title: Text("Camera"),
                                    onTap: () {
                                      controller.pickBusinessPhoto(
                                        ImageSource.camera,
                                      );
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizer().height2),

                /// -------- Business Hours --------
                AppCustomWidgets.sectionTitle("Business Hours"),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.businessHours.value.isEmpty
                            ? "Not set"
                            : controller.formatRawTime(
                                controller.businessHours.value,
                              ),
                        style: TextStyle(
                          fontSize: AppSizer().fontSize17,
                          color: AppColors.appGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appGreen,
                        ),
                        onPressed: () {
                          controller.pickBusinessHours(context);
                        },
                        child: Text(
                          "Set Time",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppSizer().height2),

                /// -------- Payment Methods --------
                AppCustomWidgets.sectionTitle("Payment Methods Accepted"),
                Obx(
                  () => Wrap(
                    spacing: AppSizer().width2,
                    runSpacing: AppSizer().height1,
                    children:
                        [
                          "Cash",
                          "Credit Card",
                          "Debit Card",
                          "Bank Transfer",
                          "Mobile Payment",
                        ].map((method) {
                          return FilterChip(
                            label: Text(method),
                            selected: controller.selectedPayments.contains(
                              method,
                            ),
                            onSelected: (_) =>
                                controller.selectedPayments.contains(method)
                                ? controller.selectedPayments.remove(method)
                                : controller.selectedPayments.add(method),
                            selectedColor: AppColors.appGreen,
                            labelStyle: TextStyle(
                              color:
                                  controller.selectedPayments.contains(method)
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }).toList(),
                  ),
                ),

                SizedBox(height: AppSizer().height4),

                /// -------- Submit Button --------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appGreen,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        controller.submitDealerProfile();
                      },
                      child: Text(
                        "Save Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizer().fontSize16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(AppRoutes.dealer);
                      },
                      child: Text(
                        "Go to Profile",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizer().fontSize16,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizer().height2),
              ],
            ),
          ),
        ),
      ), // Scaffold
    ); // PopScope
  }
}
