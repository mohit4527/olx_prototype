import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';
import '../controller/share_video_Controller.dart';
import '../model/share_video_model/share_video_model.dart';

class ShareBottomSheet extends StatelessWidget {
  final String videoId;
  final String userId;

  ShareBottomSheet({super.key, required this.videoId, required this.userId});

  final videoController = Get.put(ShareVideoController());

  /// API call + Share
  Future<void> handleShare(BuildContext context, String platformName) async {
    try {
      ShareVideoResponse response = await videoController.shareVideo(videoId, userId);

      if (response.videoUrl.isNotEmpty) {
        String link = response.videoUrl;

        if (platformName == "whatsapp") {
          link = "https://wa.me/?text=$link";
        } else if (platformName == "facebook") {
          link = "https://www.facebook.com/sharer/sharer.php?u=$link";
        } else if (platformName == "instagram") {
          link = link;
        }

        await Share.share(
          link,
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
        );
      } else {
        Get.snackbar("Error", "Video link nahi mila",backgroundColor: AppColors.appBlue,);
      }

      Get.back();
    } catch (e) {
      Get.snackbar("Error", "Kuch gadbad ho gayi",backgroundColor: AppColors.appRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.facebook, color: Colors.blue),
            title: const Text("Share on Facebook"),
            onTap: () => handleShare(context, "facebook"),
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.purple),
            title: const Text("Share on Instagram"),
            onTap: () => handleShare(context, "instagram"),
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.whatsapp, color: Colors.green),
            title: const Text("Share on WhatsApp"),
            onTap: () => handleShare(context, "whatsapp"),
          ),
        ],
      ),
    );
  }
}
