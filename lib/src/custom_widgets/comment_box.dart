import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../controller/short_video_controller.dart';

class CommentBottomSheet extends StatelessWidget {
  final String videoId;

  const CommentBottomSheet({Key? key, required this.videoId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ShortVideoController controller = Get.find<ShortVideoController>();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.appBlack,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Title
              Text(
                'Comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appWhite,
                ),
              ),
              Divider(color: AppColors.appBlue),
              SizedBox(height: AppSizer().height1),

              // Comments list
              Expanded(
                child: Obx(() {
                  final comments = controller.commentMap[videoId] ?? [];
                  if (comments.isEmpty) {
                    return const Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: comments.length,
                    itemBuilder: (_, index) {
                      final c = comments[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.appBlue,
                              radius: 18,
                              child: Text(
                                c.userId.isNotEmpty
                                    ? c.userId[0].toUpperCase()
                                    : "?",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.userId,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.appWhite,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.text,
                                    style: TextStyle(color: AppColors.appWhite),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),

              Divider(color: AppColors.appBlue),

              // Input box
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: AppSizer().height6,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: controller.commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle:
                          TextStyle(color: Colors.grey.shade400),
                          border: InputBorder.none,
                        ),
                        cursorColor: AppColors.appBlue,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: AppColors.appWhite),
                    onPressed: () {
                      final text =
                      controller.commentController.text.trim();
                      if (text.isNotEmpty) {
                        controller.addComment(videoId, text);
                        controller.commentController.clear();
                      } else {
                        Get.snackbar(
                          "Empty",
                          "Please type a comment",
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      }
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
