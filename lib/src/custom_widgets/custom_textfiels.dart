import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

Widget buildTextField(String label, OutlineInputBorder border, {TextInputType keyboard = TextInputType.text, Widget? prefixIcon, }) {
  return TextField(
    keyboardType: keyboard,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: AppColors.appGrey.shade700),
      focusedBorder: border,
      prefixIcon:prefixIcon,
      enabledBorder: border,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}