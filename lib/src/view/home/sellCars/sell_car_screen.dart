import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../constants/app_colors.dart';
import '../../../controller/sell_car_controller.dart';

class SellCarScreen extends StatelessWidget {
  SellCarScreen({super.key});

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
    return Scaffold(
      body: Container(
        height:AppSizer().height100,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AppColors.appGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    ),
     child:  SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSizer().height6,),
            Center(child: Text("Sell Your Products",style: TextStyle(color: AppColors.appBlack,fontWeight: FontWeight.bold,fontSize:AppSizer().fontSize18),)),
            Divider(color: AppColors.appBlack,thickness: 2,),
            SizedBox(height: AppSizer().height5),
            Text(
              "Dealer Type",
              style: TextStyle(
                color: AppColors.appBlack,
                fontSize: AppSizer().fontSize17,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSizer().height1),

            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedDealerType.value.isEmpty
                  ? null
                  : controller.selectedDealerType.value,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:BorderRadius.circular(10),
                ),
                hintStyle: TextStyle(color:AppColors.appGrey),
                hintText: "Select Dealer Type",
              ),
              items: ["Cars", "Motor Cycles", "Trucks","Parts","Other"].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedDealerType.value = value;
                }
              },
            )),
            SizedBox(height: AppSizer().height1),
            Text("Title",style:TextStyle(color: AppColors.appBlack,fontSize: AppSizer().fontSize17,fontWeight: FontWeight.w500),),
            SizedBox(height: AppSizer().height1),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintStyle: TextStyle(color:AppColors.appGrey),
                hintText: 'Enter car title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
             SizedBox(height: AppSizer().height1),
             Text("Description",style: TextStyle(color: AppColors.appBlack,fontSize: AppSizer().fontSize17,fontWeight: FontWeight.w500),),
            SizedBox(height: AppSizer().height1),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration:InputDecoration(
                hintStyle: TextStyle(color:AppColors.appGrey),
                hintText: 'Enter car description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: AppSizer().height1),
            Text("Price (in ₹)",style: TextStyle(color: AppColors.appBlack,fontSize: AppSizer().fontSize17,fontWeight:FontWeight.w500)),
            SizedBox(height: AppSizer().height1),
            TextField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              decoration:InputDecoration(
                hintStyle: TextStyle(color:AppColors.appGrey),
                hintText: 'Enter price',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height:AppSizer().height1),
            ElevatedButton.icon(
              onPressed: pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text("Pick Images"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),

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
            const SizedBox(height: 24),
            Center(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isUploading.value ? null : controller.uploadCarData,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14), backgroundColor: Colors.green),
                child: controller.isUploading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Upload Car", style: TextStyle(fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
      )
    );
  }
}
