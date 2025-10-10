import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showImagePickerDialog({
  required VoidCallback onCameraTap,
  required VoidCallback onGalleryTap,
}) {
  Get.dialog(
    AlertDialog(
      title: const Text(
        "Choose",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    onCameraTap();
                    Get.back();
                  },
                  icon: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                const Text("Camera"),
              ],
            ),
            Column(
              children: [
                IconButton(
                  onPressed: () {
                    onGalleryTap();
                    Get.back();
                  },
                  icon: const Icon(Icons.image, color: Colors.green),
                ),
                const Text("Gallery"),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}

void showEditFieldDialog({
  required String fieldName,
  required String initialValue,
  required Function(String newValue) onConfirm,
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
