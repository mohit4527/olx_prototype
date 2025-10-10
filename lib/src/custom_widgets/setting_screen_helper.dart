import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showImagePickerDialog({
  required VoidCallback onCameraTap,
  required VoidCallback onGalleryTap,
}) {
  // Use Get.bottomSheet for consistency with GetX navigation flow
  Get.bottomSheet(
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take Photo"),
            onTap: () {
              Get.back();
              onCameraTap();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Get.back();
              onGalleryTap();
            },
          ),
        ],
      ),
    ),
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
  );
}

void showEditFieldDialog({
  required String fieldName,
  required String initialValue,
  required Function(String) onConfirm,
}) {
  final TextEditingController textController = TextEditingController(
    text: initialValue,
  );

  Get.dialog(
    AlertDialog(
      title: Text(
        "Edit $fieldName",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: textController,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Enter new value",
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () {
            onConfirm(textController.text.trim());
            Get.back();
          },
          child: const Text("Update"),
        ),
      ],
    ),
  );
}
