import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class AppCustomWidgets {
  // ----- Section Title -----
  static Widget sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(
          top: AppSizer().height2, bottom: AppSizer().height1),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppSizer().fontSize17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// ------- Text Field ------
  static Widget buildTextField(String hint,Icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer().height1),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon,
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.appGrey.shade800),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizer().height1),
            borderSide: BorderSide(color: AppColors.appGrey.shade900),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizer().width2,
            vertical: AppSizer().height1,
          ),
        ),
      ),
    );
  }

  /// ------ Dropdown ------
  static Widget buildDropdown(String hint) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSizer().width2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizer().height1),
        border: Border.all(color: AppColors.appGrey.shade700),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          iconEnabledColor: AppColors.appGreen,
          items: const [],
          onChanged: (value) {},
        ),
      ),
    );
  }

  /// ------ Text Area ------
  static Widget buildTextArea(String hint) {
    return Container(
      padding: EdgeInsets.all(AppSizer().width2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizer().height1),
        border: Border.all(color: AppColors.appGrey.shade700),
      ),
      child: TextField(
        maxLines: 4,
        decoration: InputDecoration.collapsed(hintText: hint),
      ),
    );
  }

  ///------- Chip ------
  static Widget buildChip(String label, {bool isSelected = false}) {
    return Container(
      height: AppSizer().height5,
      width: AppSizer().width30,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.appGreen : AppColors.appWhite,
        borderRadius: BorderRadius.circular(AppSizer().height3),
        border: Border.all(color: AppColors.appGrey.shade700)
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: AppSizer().fontSize15,
          ),
        ),
      ),
    );
  }

  /// -------- Image Upload Box -------
  static Widget buildImageUploadBox() {
    return Container(
      height: AppSizer().height8,
      width: AppSizer().height8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizer().height1),
        border: Border.all(color: AppColors.appGrey.shade700),
      ),
      child:  Icon(Icons.add_a_photo, color: AppColors.appGrey.shade700),
    );
  }

  /// ------ Business Hours Row -------
  static Widget buildHoursRow(String day, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSizer().height1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: TextStyle(fontSize: AppSizer().fontSize15)),
          Text(
            time,
            style: TextStyle(
              fontSize: AppSizer().fontSize15,
              color: AppColors.appGrey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}