import 'package:flutter/material.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/custom_widgets/dealer_screen_widgets.dart';
import '../../../constants/app_colors.dart';

class DealerProfileScreen extends StatelessWidget {
  const DealerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Dealer Profile",
          style: TextStyle(
            color: AppColors.appWhite,
            fontSize: AppSizer().fontSize18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.appGreen,
      ),
      body: Container(
    height: AppSizer().height100,
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: AppColors.appGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    ),
    ),
    child:SingleChildScrollView(
        padding: EdgeInsets.all(AppSizer().height1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCustomWidgets.sectionTitle("Business Information"),
            AppCustomWidgets.buildTextField("Business Name",Icon(Icons.business_center)),
            AppCustomWidgets.buildTextField("Business Address",Icon(Icons.pin_drop)),
            SizedBox(height: AppSizer().height1),
            Row(
              children: [
                Expanded(child: AppCustomWidgets.buildDropdown("City...")),
                SizedBox(width: AppSizer().width2),
                Expanded(child: AppCustomWidgets.buildDropdown("City...")),
              ],
            ),
            SizedBox(height: AppSizer().height1),
            Row(
              children: [
                Expanded(child: AppCustomWidgets.buildDropdown("State...")),
                SizedBox(width: AppSizer().width2),
                Expanded(child: AppCustomWidgets.buildDropdown("Country...")),
              ],
            ),
            SizedBox(height: AppSizer().height2),
            AppCustomWidgets.buildTextField("Phone Number",Icon(Icons.phone_android)),
            AppCustomWidgets.buildTextField("Email Address",Icon(Icons.mail)),

            AppCustomWidgets.sectionTitle("Dealer Type"),
            SizedBox(height: AppSizer().height1,),
            Wrap(
              spacing: AppSizer().width1,
              runSpacing: AppSizer().height1,

              children: [
                AppCustomWidgets.buildChip("Cars", isSelected: true),
                AppCustomWidgets.buildChip("Motorcycles"),
                AppCustomWidgets.buildChip("Trucks"),
                AppCustomWidgets.buildChip("Parts"),
                AppCustomWidgets.buildChip("Other"),
              ],
            ),

            AppCustomWidgets.sectionTitle("Business Description"),
            AppCustomWidgets.buildTextArea("Tell us about your business..."),

            AppCustomWidgets.sectionTitle("Upload Business Logo"),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: AppSizer().height10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizer().height1),
                  border: Border.all(color: AppColors.appGrey.shade700),
                ),
                child: Center(
                  child: Icon(Icons.cloud_upload, color: AppColors.appGrey.shade700,size:35,),
                ),
              ),
            ),

            AppCustomWidgets.sectionTitle("Upload Business Photo"),
            Row(
              children: [
                AppCustomWidgets.buildImageUploadBox(),
                SizedBox(width: AppSizer().width1),
                AppCustomWidgets.buildImageUploadBox(),
              ],
            ),

            AppCustomWidgets.sectionTitle("Business Hours"),
            AppCustomWidgets.buildHoursRow("Monday - Friday", "9:00 AM - 6:00 PM"),
            AppCustomWidgets.buildHoursRow("Saturday", "10:00 AM - 4:00 PM"),
            AppCustomWidgets.buildHoursRow("Sunday", "Closed"),

            AppCustomWidgets.sectionTitle("Payment Methods Accepted"),
            SizedBox(height: AppSizer().height1,),
            Wrap(
              spacing: AppSizer().width2,
              runSpacing: AppSizer().height1,
              children: [
                AppCustomWidgets.buildChip("Cash", isSelected: true),
                AppCustomWidgets.buildChip("Credit Card"),
                AppCustomWidgets.buildChip("Debit Card"),
                AppCustomWidgets.buildChip("Bank Transfer"),
                AppCustomWidgets.buildChip("Mobile Payment"),
              ],
            ),

            SizedBox(height: AppSizer().height5),
            SizedBox(
              height: AppSizer().height6,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appGreen,
                  padding: EdgeInsets.symmetric(vertical: AppSizer().height1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizer().height1),
                  ),
                ),
                child: Text(
                  "Create Profile",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSizer().height2),
          ],
        ),
      ),
      )
    );
  }
}