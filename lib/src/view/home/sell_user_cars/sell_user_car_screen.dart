import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:path/path.dart';
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
      Get.snackbar("No Image", "No images selected.",
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Sell Car as a User",
            style: TextStyle(color: AppColors.appWhite, fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: AppColors.appGreen,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height3),

              _buildLabel("Title"),
              TextField(
                controller: controller.titleController,
                decoration: _inputDecoration("Enter car title"),
              ),

              SizedBox(height: AppSizer().height1),
              _buildLabel("Description"),
              TextField(
                controller: controller.descriptionController,
                maxLines: 3,
                decoration: _inputDecoration("Enter car description"),
              ),

              SizedBox(height: AppSizer().height1),
              _buildLabel("Price (in ₹)"),
              TextField(
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Enter price"),
              ),

              // 🔥 Location field added
              SizedBox(height: AppSizer().height1),
              _buildLabel("Location"),
              TextField(
                controller: controller.locationController,
                maxLines: 2,
                decoration: _inputDecoration("Enter location (e.g., City, State, Country)"),
              ),

              SizedBox(height: AppSizer().height1),
              _buildLabel("Category"),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                items: ['all', 'cars', 'two-wheeler', 'others']
                    .map((cat) => DropdownMenuItem(
                  value: cat,
                  child: Text(cat.capitalizeFirst ?? cat),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) controller.selectedCategory.value = value;
                },
                decoration: _inputDecoration("Select category"),
              )),

              SizedBox(height: AppSizer().height1),
              ElevatedButton.icon(
                onPressed: pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text("Pick Images"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
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
                      .map((img) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      img,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ))
                      .toList(),
                );
              }),

              SizedBox(height: AppSizer().height2),
              Center(
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isUploading.value ? null : controller.uploadCarData,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    backgroundColor: Colors.green,
                  ),
                  child: controller.isUploading.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Upload", style: TextStyle(fontSize: AppSizer().fontSize16)),
                )),
              ),
            ],
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
