import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';

class CustomLabelText extends StatelessWidget {
  final String label;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;

  const CustomLabelText({
    super.key,
    required this.label,
    this.color,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color ?? AppColors.appGreen,
        fontWeight: fontWeight ?? FontWeight.bold,
        fontSize: fontSize ?? AppSizer().fontSize18,
      ),
    );
  }
}