import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class CategoryItem extends StatelessWidget {
  final String imagePath;
  final String title;

  const CategoryItem({
    super.key,
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 37,
          backgroundImage: AssetImage(imagePath),
        ),
        SizedBox(height: AppSizer().height2),
        Text(
          title,
          style: TextStyle(fontSize: AppSizer().fontSize15,fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}
