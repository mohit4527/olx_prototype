import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
      appBar: AppBar(title: const Text("Sell Your Car")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Title"),
            TextField(
              controller: controller.titleController,
              decoration: const InputDecoration(
                hintText: 'Enter car title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            const Text("Description"),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter car description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            const Text("Price (in ₹)"),
            TextField(
              controller: controller.priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

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
                onPressed: controller.isUploading.value
                    ? null
                    : () async {
                  await controller.uploadCarData();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  backgroundColor: Colors.green,
                ),
                child: controller.isUploading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload Car",
                    style: TextStyle(fontSize: 16)),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
