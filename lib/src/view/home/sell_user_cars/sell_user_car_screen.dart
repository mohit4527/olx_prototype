import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../constants/app_colors.dart';
import '../../../controller/sell_user_car_controller.dart';

class SellUserCarScreen extends StatelessWidget {
  SellUserCarScreen({super.key});
  final CarUploadController controller = Get.put(CarUploadController());

  Future<void> pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      controller.selectedImages.assignAll(
        pickedFiles.map((xfile) => File(xfile.path)).toList(),
      );
    } else {
      Get.snackbar(
        "No Image",
        "No images selected.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during upload
        if (controller.isUploading.value) {
          Get.snackbar(
            "Upload in Progress",
            "Please wait for the upload to complete...",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange.shade100,
            colorText: Colors.orange.shade800,
            icon: Icon(Icons.upload, color: Colors.orange),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Sell Product as a User",
            style: TextStyle(
              color: AppColors.appWhite,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.appGreen,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
          ),
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
              padding: const EdgeInsets.all(16),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AppSizer().height3),

                    _buildLabel("Title *"),
                    TextFormField(
                      controller: controller.titleController,
                      decoration: _inputDecoration("Enter Product title"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Title is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Title must be at least 3 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSizer().height1),
                    _buildLabel("Description *"),
                    TextFormField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      decoration: _inputDecoration("Enter Product description"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Description is required';
                        }
                        if (value.trim().length < 10) {
                          return 'Description must be at least 10 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: AppSizer().height1),
                    _buildLabel("Price (in ₹) *"),
                    TextFormField(
                      controller: controller.priceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Enter Product price"),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required';
                        }
                        final price = int.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        if (price < 100) {
                          return 'Price must be at least ₹100';
                        }
                        return null;
                      },
                    ),

                    // 🔥 Location field added
                    SizedBox(height: AppSizer().height1),
                    _buildLabel("Location *"),
                    TextFormField(
                      controller: controller.locationController,
                      maxLines: 2,
                      decoration: _inputDecoration(
                        "Enter location (e.g., City, State, Country)",
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Location is required';
                        }
                        if (value.trim().length < 3) {
                          return 'Please enter a valid location';
                        }
                        return null;
                      },
                    ),

                    // 📞 Phone Number field added
                    SizedBox(height: AppSizer().height1),
                    _buildLabel("Phone Number *"),
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .digitsOnly, // Only allow digits
                        LengthLimitingTextInputFormatter(
                          10,
                        ), // Limit to 10 digits
                      ],
                      decoration:
                          _inputDecoration(
                            "Enter 10-digit phone number",
                          ).copyWith(
                            counterText: "", // Hide character counter
                            prefixIcon: Icon(
                              Icons.phone,
                              color: AppColors.appGreen,
                            ),
                            helperText:
                                "Enter Indian mobile number (10 digits)",
                            helperStyle: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '📞 Phone number is required';
                        }

                        if (value.length != 10) {
                          return '📞 Phone number must be exactly 10 digits';
                        }

                        // Check if it starts with valid Indian mobile numbers (6-9)
                        if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
                          return '📞 Please enter a valid Indian mobile number';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        // Real-time validation feedback
                        if (value.length == 10 &&
                            RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
                          // Valid number - could show green border or checkmark
                          FocusScope.of(
                            context,
                          ).nextFocus(); // Auto move to next field
                        }
                      },
                    ),

                    SizedBox(height: AppSizer().height1),
                    _buildLabel("Category"),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        items: ['all', 'cars', 'two-wheeler', 'others']
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat,
                                child: Text(cat.capitalizeFirst ?? cat),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            controller.selectedCategory.value = value;
                        },
                        decoration: _inputDecoration("Select category"),
                      ),
                    ),

                    SizedBox(height: AppSizer().height1),
                    ElevatedButton.icon(
                      onPressed: pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Pick Images"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),

                    SizedBox(height: AppSizer().height1),
                    Obx(() {
                      if (controller.selectedImages.isEmpty) {
                        return const Text("No images selected.");
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedImages
                            .map(
                              (img) => ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  img,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }),

                    SizedBox(height: AppSizer().height2),
                    Center(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isUploading.value
                              ? null
                              : controller.uploadCarData,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            backgroundColor: Colors.green,
                          ),
                          child: controller.isUploading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Upload",
                                  style: TextStyle(
                                    fontSize: AppSizer().fontSize16,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: TextStyle(
      color: AppColors.appBlack,
      fontSize: AppSizer().fontSize17,
      fontWeight: FontWeight.w500,
    ),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );
}
