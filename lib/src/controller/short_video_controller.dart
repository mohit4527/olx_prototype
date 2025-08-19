import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/short_video_model/short_video_model.dart';
import '../services/apiServices/apiServices.dart';
import '../constants/app_colors.dart';
import '../services/auth_service/auth_service.dart';

class ShortVideoController extends GetxController {
  var isLoading = true.obs;
  var videoList = <ShortVideoModel>[].obs;
  var currentIndex = 0.obs;
  var isLikeLoading = false.obs;
  final RxMap<String, List<CommentModel>> commentMap = <String, List<CommentModel>>{}.obs;
  final TextEditingController commentController = TextEditingController();
  String? userId; // Store locally
  // Add properties for the current user's info
  String? userName;
  String? userProfilePic;

  @override
  void onInit() async {
    userId = await AuthService.getLoggedInUserId();
    userName = "Your Username";
    userProfilePic = "assets/images/user_avatar.jpg";
    print("Loaded userId: $userId");
    if (userId == null) {
      Get.snackbar("Error", "Please log in first");
      return;
    }
    fetchVideos();
    super.onInit();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
    userName = prefs.getString("userName");
    userProfilePic = prefs.getString("userProfilePic");
    print("Loaded userId: $userId");
  }

  void fetchVideos() async {
    try {
      isLoading.value = true;
      var fetchedVideos = await ApiService.fetchShortVideos();
      for (var video in fetchedVideos) {
        commentMap[video.id] = video.comments;
      }
      videoList.assignAll(fetchedVideos);
    } catch (e) {
      print("Error loading videos: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void likeUnlikeVideo(String videoId, String currentUserId) {
    int index = videoList.indexWhere((video) => video.id == videoId);
    if (index != -1) {
      final video = videoList[index];
      if (video.likedByUsers.contains(currentUserId)) {
        video.isLiked = false;
        video.likedByUsers.remove(currentUserId);
      } else {
        video.isLiked = true;
        video.likedByUsers.add(currentUserId);
      }

      video.likeCount = video.likedByUsers.length;

      // Trigger UI update
      videoList[index] = video;
      videoList.refresh();
    }
  }

  Future<void> addComment(String videoId, String text) async {
    // Make sure we always have the latest userId and other user data
    if (userId == null || userId!.isEmpty) {
      await _loadUserId();
    }

    if (userId == null || userName == null || userName!.isEmpty || userId!.isEmpty) {
      Get.snackbar(
        "Error",
        "User info not available. Please login again.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
      return;
    }

    if (text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Comment cannot be empty",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
      return;
    }

    try {
      await ApiService.postComment(videoId: videoId, userId: userId!, text: text.trim());

      // Pass all required arguments to the CommentModel constructor
      final newComment = CommentModel(
        userId: userId!,
        userName: userName!,
        userProfilePic: userProfilePic!,
        text: text.trim(),
      );

      if (!commentMap.containsKey(videoId)) {
        commentMap[videoId] = [];
      }
      commentMap[videoId]!.add(newComment);
      commentMap.refresh();
      commentController.clear();
    } catch (e) {
      print("Error posting comment: $e");
    }
  }
}