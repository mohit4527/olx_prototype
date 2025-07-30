import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/short_video_controller.dart';
import 'package:olx_prototype/src/model/product_description_model/product_description%20model.dart';
import 'package:olx_prototype/src/model/short_video_model/short_video_model.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';

import '../../../custom_widgets/shortVideoWidget.dart';
import '../description/description_screen.dart';

class ShortvideoScreen extends StatelessWidget {

  final videoController = Get.put(ShortVideoController());

  ShortvideoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Obx(() {
                if (videoController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (videoController.videoList.isEmpty) {
                  return Center(child: Text("No videos found"));
                } else {
                  return PageView.builder(
                    scrollDirection: Axis.vertical,
                    onPageChanged: (index) {
                      videoController.currentIndex.value = index;
                    },
                    itemCount: videoController.videoList.length,
                    itemBuilder: (context, index) {
                      final video = videoController.videoList[index];
                      return VideoPlayerWidget(videoUrl: video.videoUrl);
                    },
                  );
                }
              }),


            ),
            Positioned(
                left: AppSizer().width1,
                top: AppSizer().height2,
                child: IconButton(onPressed: (){
                  Get.back();
                }, icon: Icon(Icons.arrow_back,color: AppColors.appWhite,))),
            Positioned(
              bottom: AppSizer().height25,
              right: AppSizer().width2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.favorite, color:AppColors.appWhite, size: 30),
                  SizedBox(height:AppSizer().height5),
                  Icon(Icons.comment, color:AppColors.appWhite, size: 30),
                  SizedBox(height:AppSizer().height5),
                  Icon(Icons.share, color:AppColors.appWhite, size: 30),
                  SizedBox(height:AppSizer().height5),

                ],
              ),
            ),
            Positioned(
              bottom: AppSizer().height8,
              left: AppSizer().width2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundImage:AssetImage("assets/images/property2.jpg"),
                      ),
                      SizedBox(width: AppSizer().width3,),
                      Text(
                        '@username',
                        style: TextStyle(color:AppColors.appWhite, fontSize:AppSizer().fontSize16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height:AppSizer().height1),
                  SizedBox(
                    width: MediaQuery.of(context).size.width/1.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Obx(() {
                            return Text(
                              videoController.videoList.isNotEmpty
                                  ? videoController.videoList[videoController.currentIndex.value].title
                                  : "Loading...",
                              style: TextStyle(color: AppColors.appWhite, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),


                        InkWell(
                          onTap: (){
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.appBlack.withOpacity(0.95),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.all(AppSizer().height2),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width:AppSizer().width10,
                                          height: AppSizer().width1,
                                          decoration: BoxDecoration(
                                            color: AppColors.appGreen,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height2),
                                      Text(
                                        "Product Title",
                                        style: TextStyle(
                                            color: AppColors.appWhite,
                                            fontSize: AppSizer().fontSize18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      Text(
                                        "Price: ₹50,00,000",
                                        style: TextStyle(
                                            color: AppColors.appGreen,
                                            fontSize: AppSizer().fontSize16,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      Text(
                                        "This is a short description of the product. It includes details like features, location, condition, and other highlights.",
                                        style: TextStyle(color: AppColors.appWhite),
                                      ),
                                      SizedBox(height: AppSizer().height3),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() => DescriptionScreen());
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.appGreen,
                                          ),
                                          child: Text("Message for buy",style: TextStyle(color: AppColors.appWhite),),
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height1),

                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.appGreen,
                                          ),
                                          child: Text("Close",style: TextStyle(color: AppColors.appWhite),),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            );

                          },
                          child: Container(
                            height: AppSizer().height4,
                            width: AppSizer().width10,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.appWhite),
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.appBlack,
                            ),
                            child: Center(
                              child: Text("Buy", style: TextStyle(color: AppColors.appWhite)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}