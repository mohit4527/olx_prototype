// DealerProfileScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_controller.dart';
import '../../../custom_widgets/dealer_screen_widgets.dart';

class DealerProfileScreen extends StatelessWidget {
   DealerProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dealerController = Get.put(DealerProfileController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Dealer Profile",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
        backgroundColor: AppColors.appGreen,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSizer().height1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Business Info
              AppCustomWidgets.sectionTitle("Business Information"),
              AppCustomWidgets.buildTextField("Business Name", Icon(Icons.business_center),
                  controller: dealerController.businessNameController),
              AppCustomWidgets.buildTextField("Registration Number", Icon(Icons.pin),
                  controller: dealerController.regNoController),
              AppCustomWidgets.buildTextField("GST Number", Icon(Icons.pin),
                  controller: dealerController.gstNoController),
              AppCustomWidgets.buildTextField("Village", Icon(Icons.location_city),
                  controller: dealerController.villageController),
              AppCustomWidgets.buildTextField("City", Icon(Icons.location_city),
                  controller: dealerController.cityController),
              AppCustomWidgets.buildTextField("State", Icon(Icons.map),
                  controller: dealerController.stateController),
              AppCustomWidgets.buildTextField("Country", Icon(Icons.public),
                  controller: dealerController.countryController),
              AppCustomWidgets.buildTextField(
                "Phone Number",
                Icon(Icons.phone_android),
                controller: dealerController.phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: dealerController.phoneInputFormatters(),
              ),
              AppCustomWidgets.buildTextField("Email Address", Icon(Icons.mail),
                  controller: dealerController.emailController,
                  keyboardType: TextInputType.emailAddress),
              AppCustomWidgets.buildTextField("Business Address", Icon(Icons.pin_drop),
                  controller: dealerController.addressController),

              /// Dealer Type
              AppCustomWidgets.sectionTitle("Dealer Type"),
              Obx(() => Wrap(
                spacing: AppSizer().width1,
                runSpacing: AppSizer().height1,
                children: dealerController.dealerTypes.map((type) {
                  return ChoiceChip(
                    label: Text(type),
                    selected: dealerController.selectedDealerType.value == type,
                    onSelected: (_) => dealerController.selectDealerType(type),
                    selectedColor: AppColors.appGreen,
                    backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                    labelStyle: TextStyle(
                      color: dealerController.selectedDealerType.value == type
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  );

                }).toList(),
              )),

              /// Description
              AppCustomWidgets.sectionTitle("Business Description"),
              AppCustomWidgets.buildTextArea(
                "Tell us about your business...",
                controller: dealerController.descriptionController,
              ),

              /// Logo Upload
              AppCustomWidgets.sectionTitle("Upload Business Logo"),
              Obx(() => GestureDetector(
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
                              dealerController.pickBusinessLogo(ImageSource.gallery);
                              Get.back();
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.camera),
                            title: Text("Camera"),
                            onTap: () {
                              dealerController.pickBusinessLogo(ImageSource.camera);
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  height: AppSizer().height10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizer().height1),
                    border: Border.all(color: AppColors.appGrey.shade700),
                  ),
                  child: Center(
                    child: dealerController.businessLogo.value == null
                        ? Icon(Icons.cloud_upload,
                        color: AppColors.appGrey.shade700, size: 35)
                        : Image.file(dealerController.businessLogo.value!,
                        fit: BoxFit.cover),
                  ),
                ),
              )),

              /// Photos Upload
              AppCustomWidgets.sectionTitle("Upload Business Photo"),
              Obx(() => Row(
                children: [
                  ...dealerController.businessPhotos.map((file) => Container(
                    margin: EdgeInsets.only(right: AppSizer().width1),
                    width: AppSizer().width20,
                    height: AppSizer().height10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSizer().height1),
                      image: DecorationImage(
                          image: FileImage(file), fit: BoxFit.cover),
                    ),
                  )),
                  GestureDetector(
                    onTap: () => dealerController.pickBusinessPhoto(ImageSource.gallery),
                    child: AppCustomWidgets.buildImageUploadBox(),
                  ),
                ],
              )),

              /// Business Hours (New UI with Time Pickers)
              AppCustomWidgets.sectionTitle("Business Hours"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => dealerController.selectStartTime(context),
                      child: Obx(() => Container(
                        height: AppSizer().height6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizer().height1),
                          border: Border.all(color: AppColors.appGrey.shade700),
                        ),
                        child: Center(
                          child: Text(
                            dealerController.startTime.value?.format(context) ?? "Select Start Time",
                            style: TextStyle(
                              color: dealerController.startTime.value == null ? AppColors.appGrey.shade700 : Colors.black,
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                  SizedBox(width: AppSizer().width2),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => dealerController.selectEndTime(context),
                      child: Obx(() => Container(
                        height: AppSizer().height6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizer().height1),
                          border: Border.all(color: AppColors.appGrey.shade700),
                        ),
                        child: Center(
                          child: Text(
                            dealerController.endTime.value?.format(context) ?? "Select End Time",
                            style: TextStyle(
                              color: dealerController.endTime.value == null ? AppColors.appGrey.shade700 : Colors.black,
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                ],
              ),

              /// Payment Methods
              AppCustomWidgets.sectionTitle("Payment Methods Accepted"),
              Obx(() => Wrap(
                spacing: AppSizer().width2,
                runSpacing: AppSizer().height1,
                children: dealerController.paymentMethods.map((method) {
                  return
                    FilterChip(
                      label: Text(method),
                      selected: dealerController.selectedPayments.contains(method),
                      onSelected: (_) => dealerController.togglePayment(method),
                      selectedColor: AppColors.appGreen,
                      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                      labelStyle: TextStyle(
                        color: dealerController.selectedPayments.contains(method)
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    );
                }).toList(),
              )),

              /// Submit Button
              SizedBox(height: AppSizer().height6),
              // Use Obx to change the button state
              Obx(() => SizedBox(
                height: AppSizer().height6,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: dealerController.isLoading.value
                      ? null
                      : () => dealerController.submitForm(Get.context!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.appGreen,
                    padding: EdgeInsets.symmetric(vertical: AppSizer().height1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizer().height1),
                    ),
                  ),
                  child: dealerController.isLoading.value
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    "Create Profile",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize16,
                      color: Colors.white,
                    ),
                  ),
                ),
              )),

              SizedBox(height: AppSizer().height8),
            ],
          ),
        ),
      ),
    );
  }
}