import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/short_video_controller.dart';
import '../../../controller/share_video_Controller.dart';
import '../../../custom_widgets/comment_box.dart';
import '../../../custom_widgets/share_video_bottomsheet.dart';
import '../../../custom_widgets/shortVideoWidget.dart';
import '../description/description_screen.dart';

class ShortvideoScreen extends StatelessWidget {
  final shareVideoController = Get.put(ShareVideoController());
  final ShortVideoController videoController = Get.put(ShortVideoController(), permanent: true);

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
                  return const Center(child: CircularProgressIndicator());
                } else if (videoController.videoList.isEmpty) {
                  return const Center(child: Text("No videos found"));
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
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back, color: AppColors.appWhite),
              ),
            ),
            Positioned(
              bottom: AppSizer().height25,
              right: AppSizer().width2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ... inside your Column widget
                  Obx(() {
                    final currentIndex = videoController.currentIndex.value;

                    if (videoController.videoList.isEmpty || currentIndex >= videoController.videoList.length) {
                      return const SizedBox.shrink();
                    }

                    final video = videoController.videoList[currentIndex];
                    final currentUserId = videoController.userId; // Assuming userId is available here

                    // Ensure userId is not null before proceeding
                    if (currentUserId == null) {
                      return const SizedBox.shrink(); // Or show a login message
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () {
                            // Pass both the video ID and the current user's ID
                            videoController.likeUnlikeVideo(video.id, currentUserId);
                          },
                          child: Icon(
                            Icons.favorite,
                            color: video.isLiked ? AppColors.appRed : AppColors.appGrey,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 4),
                        InkWell(
                          onTap: () {
                            Get.dialog(
                              AlertDialog(
                                title:  Text("Likes"),
                                content: Container(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: video.likedByUsers.length,
                                    itemBuilder: (context, index) {
                                      final likedUserId = video.likedByUsers[index];
                                      return ListTile(
                                        leading: const CircleAvatar(),
                                        title: Text("User ID: $likedUserId"),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "${video.likedByUsers.length} Like${video.likedByUsers.length == 1 ? '' : 's'}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: AppSizer().height5),
                  Obx(() {
                    final currentIndex = videoController.currentIndex.value;

                    if (videoController.videoList.isEmpty || currentIndex >= videoController.videoList.length) {
                      return const SizedBox.shrink();
                    }

                    final video = videoController.videoList[currentIndex];

                    return IconButton(
                      icon: const Icon(Icons.comment, color: Colors.white, size: 30),
                      onPressed: () {
                        Get.bottomSheet(
                          CommentBottomSheet(videoId: video.id),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                    );
                  }),
                  SizedBox(height: AppSizer().height5),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 30),
                    onPressed: () {
                      final currentIndex = videoController.currentIndex.value;
                      if (currentIndex < videoController.videoList.length) {
                        final video = videoController.videoList[currentIndex];
                        Get.bottomSheet(
                          ShareBottomSheet(
                            videoId: video.id,
                            userId: "6884b95f75b9d6e99ab5537e",
                          ),
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                        );
                      }
                    },
                  ),
                  SizedBox(height: AppSizer().height5),
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
                      const CircleAvatar(
                        radius: 15,
                        backgroundImage: AssetImage("assets/images/property2.jpg"),
                      ),
                      SizedBox(width: AppSizer().width3),
                      Text(
                        '@username',
                        style: TextStyle(color: AppColors.appWhite, fontSize: AppSizer().fontSize16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer().height1),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Obx(() {
                            final videoList = videoController.videoList;
                            final currentIndex = videoController.currentIndex.value;

                            if (videoController.isLoading.value) {
                              return const Text("Loading...", style: TextStyle(color: AppColors.appWhite));
                            }
                            if (videoList.isEmpty || currentIndex >= videoList.length) {
                              return const Text("No videos available", style: TextStyle(color: AppColors.appWhite));
                            }
                            return Text(
                              videoList[currentIndex].title,
                              style: const TextStyle(color: AppColors.appWhite, fontSize: 14),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            );
                          }),
                        ),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppColors.appBlack.withOpacity(0.95),
                              shape: const RoundedRectangleBorder(
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
                                          width: AppSizer().width10,
                                          height: AppSizer().width1,
                                          decoration: BoxDecoration(
                                            color: AppColors.appGreen,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height2),
                                      const Text(
                                        "Product Title",
                                        style: TextStyle(
                                          color: AppColors.appWhite,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      const Text(
                                        "Price: ₹50,00,000",
                                        style: TextStyle(
                                          color: AppColors.appGreen,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: AppSizer().height1),
                                      const Text(
                                        "This is a short description of the product. It includes details like features, location, condition, and other highlights.",
                                        style: TextStyle(color: AppColors.appWhite),
                                      ),
                                      SizedBox(height: AppSizer().height3),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Get.to(() =>  DescriptionScreen(carId:''));
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.appGreen,
                                          ),
                                          child: const Text("Message for buy", style: TextStyle(color: AppColors.appWhite)),
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
                                          child: const Text("Close", style: TextStyle(color: AppColors.appWhite)),
                                        ),
                                      ),
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
                            child: const Center(
                              child: Text("Buy", style: TextStyle(color: AppColors.appWhite)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}