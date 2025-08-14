import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

Widget buildLongPressImage(BuildContext context, String imagePath) {
  return GestureDetector(
    onLongPress: () {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: AppSizer().height34,
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.appWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      );
    },
    child: Image.asset(imagePath, fit: BoxFit.cover),
  );
}
