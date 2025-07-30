import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';

import '../../../constants/app_sizer.dart';
import '../../../utils/app_routes.dart';

class LogoutScreen extends StatelessWidget {
   LogoutScreen({super.key});

  final controller = Get.put(GetProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        centerTitle: true,
        title: Text("LogOut",style: TextStyle(color: AppColors.appWhite),),
      ),
      body:Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            SizedBox(height: AppSizer().height2,),
            Obx(
                  () => Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: controller.imagePath.value.isNotEmpty
                                ? Image.file(File(controller.imagePath.value))
                                : CircleAvatar(
                              radius: 80,
                              backgroundColor: Color(0xfffae293),
                              child: Icon(Icons.person, size: 80),
                            ),
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Color(0xfffae293),
                      radius: 36,
                      backgroundImage:controller.imagePath.value.isNotEmpty
                          ? FileImage(File(controller.imagePath.value))
                          : null,
                      child: controller.imagePath.value.isEmpty
                          ? Icon(Icons.person, size: 45)
                          : null,
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                "Choose",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: AppSizer().fontSize19,
                                  color: AppColors.appPurple,
                                ),
                              ),
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            controller.getImageByCamera();
                                            Get.back();
                                          },
                                          icon: Icon(Icons.camera_alt, color: AppColors.appBlue),
                                        ),
                                        Text(
                                          "Camera",
                                          style: TextStyle(
                                            color: AppColors.appPurple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizer().fontSize16,
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            controller.getImageByGallery();
                                            Get.back();
                                          },
                                          icon: Icon(Icons.image, color: AppColors.appBlue),
                                        ),
                                        Text(
                                          "Gallery",
                                          style: TextStyle(
                                            color: AppColors.appPurple,
                                            fontWeight: FontWeight.w500,
                                            fontSize: AppSizer().fontSize16,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              ],
                            );
                          },
                        );
                      },
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor:AppColors.appBlack,
                        child: Icon(Icons.camera_alt, size: AppSizer().height2, color: AppColors.appWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizer().height2,),
            Text("Mohit Kumar",style:
            TextStyle(fontWeight: FontWeight.w500,fontSize: AppSizer().fontSize18,fontStyle: FontStyle.italic),),
            Text("kumarmohit123@gmail.com",style:
            TextStyle(fontWeight: FontWeight.w500,fontSize: AppSizer().fontSize18,fontStyle: FontStyle.italic),),
            Text("+91 7270095618",style:
            TextStyle(fontWeight: FontWeight.w500,fontSize: AppSizer().fontSize18,fontStyle: FontStyle.italic),),
            SizedBox(height: AppSizer().height10,),
            Icon(Icons.logout_outlined,size: 100,color: AppColors.appBlue,),
            SizedBox(height: AppSizer().height6,),
            InkWell(
              onTap: (){
                showDialog(context: context, builder:(BuildContext context){
                  return AlertDialog(
                    title: Text("Confirm LogOut",style: TextStyle(fontWeight: FontWeight.w600,fontSize: AppSizer().fontSize19),),
                    content: Text("Are you sure you want to logout ?"),
                    actions: [
                      TextButton(onPressed: (){
                        Get.toNamed(AppRoutes.login);
                      }, child:
                      Text("Yes"),
                      ),
                      TextButton(onPressed: (){
                        Get.back();
                      }, child:
                      Text("Cancel"),
                      )
                    ],
                  );
                });
              },
              child: Container(
                height:AppSizer().height6,
                // width: AppSizer().width50,
                decoration: BoxDecoration(
                color: AppColors.appGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text("LogOut",style: TextStyle(color:AppColors.appWhite,fontWeight: FontWeight.bold,fontSize: AppSizer().fontSize18),)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
