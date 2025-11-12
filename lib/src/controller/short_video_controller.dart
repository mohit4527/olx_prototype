import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import '../utils/logger.dart';
import '../model/short_video_model/short_video_model.dart';
import '../services/apiServices/apiServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service/auth_service.dart';
import 'ads_controller.dart';
import 'token_controller.dart';
import '../utils/app_routes.dart';

class ShortVideoController extends GetxController {
  final ApiService _api = ApiService();

  // Observable lists
  // In ShortVideoController
  RxBool get isLoading => isLoadingAllVideos;
  RxList<VideoModel> videos = <VideoModel>[].obs;
  RxList<VideoModel> _originalVideos =
      <VideoModel>[].obs; // Store original list
  RxList<VideoModel> suggestedVideos = <VideoModel>[].obs;

  // Loading states
  var isLoadingVideos = false.obs;
  var isLoadingAllVideos = false.obs;

  // Uploading state for showing a progress indicator while a video uploads
  var isUploading = false.obs;

  // User & current video index
  var currentUserId = ''.obs;
  var currentPageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Logger.d('ShortVideoController', 'onInit called');
    _loadUserId();
  }

  // Load user ID from AuthService
  Future<void> _loadUserId() async {
    final id = await AuthService.getLoggedInUserId();
    currentUserId.value = id ?? '';
    Logger.d(
      'ShortVideoController',
      'LoggedInUserId loaded: ${currentUserId.value}',
    );
    // Automatically fetch videos after user ID is loaded
    await loadAllVideos();
    await fetchSuggestedVideos();
  }

  // Fetch all videos with randomization
  Future<void> loadAllVideos() async {
    try {
      isLoadingAllVideos.value = true;
      Logger.d('ShortVideoController', 'loadAllVideos started');

      final list = await _api.fetchVideos();
      _originalVideos.assignAll(list); // Store original
      shuffleVideos(); // Apply randomization
      Logger.d(
        'ShortVideoController',
        'All videos loaded with shuffle: ${videos.length}',
      );
    } catch (e) {
      print("[Controller] loadAllVideos error: $e");
    } finally {
      isLoadingAllVideos.value = false;
      Logger.d('ShortVideoController', 'loadAllVideos finished');
    }
  }

  /// 🎲 Shuffle videos for variety
  void shuffleVideos() {
    if (_originalVideos.isEmpty) return;

    Logger.d(
      'ShortVideoController',
      '🎲 Shuffling ${_originalVideos.length} videos...',
    );

    List<VideoModel> shuffledList = List.from(_originalVideos);
    shuffledList.shuffle(Random());

    videos.assignAll(shuffledList);

    Logger.d(
      'ShortVideoController',
      '✅ Videos shuffled! First video: ${shuffledList.isNotEmpty ? shuffledList.first.id : 'None'}',
    );
  }

  /// 🔄 Refresh videos with new randomization
  Future<void> refreshVideos() async {
    Logger.d(
      'ShortVideoController',
      '🔄 Refreshing videos with new randomization...',
    );
    await loadAllVideos(); // This will fetch fresh data and auto-shuffle
    await fetchSuggestedVideos(); // Refresh suggested videos too
  }

  // Fetch suggested videos with randomization
  Future<void> fetchSuggestedVideos() async {
    try {
      isLoadingVideos.value = true;
      Logger.d('ShortVideoController', 'fetchSuggestedVideos started');

      // Use original videos list for better randomization
      if (_originalVideos.isEmpty) {
        Logger.d('ShortVideoController', 'No videos available to suggest');
        suggestedVideos.clear();
        return;
      }

      // 🎲 Randomize suggested videos selection
      List<VideoModel> shuffledOriginals = List.from(_originalVideos);
      shuffledOriginals.shuffle(Random());

      // Take random 5 videos as suggested
      suggestedVideos.assignAll(shuffledOriginals.take(5).toList());

      Logger.d(
        'ShortVideoController',
        'Suggested videos loaded with randomization: ${suggestedVideos.length}',
      );
    } catch (e) {
      Logger.d('ShortVideoController', 'fetchSuggestedVideos error: $e');
    } finally {
      isLoadingVideos.value = false;
      Logger.d('ShortVideoController', 'fetchSuggestedVideos finished');
    }
  }

  // Get currently playing video
  VideoModel? get currentVideo =>
      videos.isEmpty ? null : videos[currentPageIndex.value];

  // Set current page index
  void setCurrentPage(int idx) {
    currentPageIndex.value = idx;
    Logger.d('ShortVideoController', 'currentPageIndex set: $idx');
  }

  // Toggle like on a video
  Future<void> toggleLike(int index) async {
    try {
      final v = videos[index];
      final userId = currentUserId.value;
      if (userId.isEmpty) return;

      v.toggleLike(userId);
      videos[index] = v; // trigger update
      Logger.d(
        'ShortVideoController',
        'toggleLike called for video ${v.id}, liked=${v.isLikedBy(userId)}',
      );

      await _api.likeVideo(v.id, userId);
    } catch (e) {
      Logger.d('ShortVideoController', 'toggleLike error: $e');
    }
  }

  // Post comment on a video
  Future<void> postComment(int videoIndex, String text) async {
    try {
      final v = videos[videoIndex];
      final userId = currentUserId.value;
      if (userId.isEmpty) return;

      // Try to get user's display name and photo from TokenController (fast)
      String displayName = 'You';
      String userPhoto = '';
      try {
        if (Get.isRegistered<TokenController>()) {
          final tc = Get.find<TokenController>();
          displayName = tc.displayName.value.isNotEmpty
              ? tc.displayName.value
              : 'You';
          userPhoto = tc.photoUrl.value;
        } else {
          // Fallback to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          displayName = prefs.getString('user_display_name') ?? 'You';
          userPhoto = prefs.getString('user_photo_url') ?? '';
        }
      } catch (_) {}

      final newComment = CommentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        userId: userId,
        userName: displayName,
        userImage: userPhoto,
      );

      print(
        '[ShortVideoController] postComment -> creating local comment id=${newComment.id} userId=${newComment.userId} userName=${newComment.userName} userImage=${newComment.userImage}',
      );

      v.addComment(newComment);
      videos[videoIndex] = v;
      Logger.d(
        'ShortVideoController',
        'postComment called for video ${v.id}, text=$text',
      );

      await _api.postComment(v.id, userId, text);

      // Persist the posting user's name/photo to local caches so other views
      // (or later app sessions) can reuse it when resolving comments.
      try {
        final prefs = await SharedPreferences.getInstance();
        final nameJson = prefs.getString('profile_name_cache') ?? '{}';
        final avatarJson = prefs.getString('profile_avatar_cache') ?? '{}';
        Map<String, dynamic> names = {};
        Map<String, dynamic> avs = {};
        try {
          names = json.decode(nameJson) as Map<String, dynamic>;
        } catch (_) {}
        try {
          avs = json.decode(avatarJson) as Map<String, dynamic>;
        } catch (_) {}
        names[userId] = displayName;
        avs[userId] = userPhoto;
        print(
          '[ShortVideoController] persisted cache for user=$userId name=$displayName photo=$userPhoto',
        );
        await prefs.setString('profile_name_cache', json.encode(names));
        await prefs.setString('profile_avatar_cache', json.encode(avs));
        // Also save a quick-access display name/photo used by CommentBottomSheet
        // so the poster's name/photo shows immediately when they post a comment.
        try {
          await prefs.setString('user_display_name', displayName);
          await prefs.setString('user_photo_url', userPhoto);
          print(
            '[ShortVideoController] saved user_display_name/user_photo_url for $userId -> $displayName / ${userPhoto.isNotEmpty ? '<photo set>' : '<no photo>'}',
          );
        } catch (e) {
          print(
            '[ShortVideoController] could not save quick display prefs: $e',
          );
        }
      } catch (_) {}
    } catch (e) {
      Logger.d('ShortVideoController', 'postComment error: $e');
    }
  }

  // Upload a new video
  Future<void> uploadVideo(File file, String title) async {
    try {
      isUploading.value = true;
      final userId = currentUserId.value;
      // If we don't have a userId in controller, attempt to show what's in prefs
      if (userId.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final prefUser =
              prefs.getString('userId') ?? prefs.getString('user_uid') ?? '';
          final hasToken =
              (prefs.getString('auth_token') ?? prefs.getString('token') ?? '')
                  .isNotEmpty;
          Get.snackbar(
            'Debug',
            'Resolved userId: ${prefUser.isNotEmpty ? prefUser : '<none>'} | auth_token present: ${hasToken ? 'yes' : 'no'}',
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        } catch (e) {
          // ignore
        }
        // still return to avoid uploading without user context
        return;
      }

      Logger.d(
        'ShortVideoController',
        'uploadVideo start (file=${file.path}, title=$title)',
      );
      final uploadedVideo = await _api.uploadVideo(
        videoPath: file.path,
        title: title,
        productId: userId,
        duration: 15,
      );

      // Insert into local short videos list immediately so user sees their upload.
      videos.insert(0, uploadedVideo);
      Logger.d(
        'ShortVideoController',
        'Video uploaded and added: ${uploadedVideo.id}',
      );

      // Optionally, update suggested videos as well
      fetchSuggestedVideos();

      // If AdsController exists, optimistically insert the new video into its
      // myVideos list so the uploader sees the item immediately, then trigger
      // a short polling refresh to let the server finish processing and confirm
      // the item on subsequent fetches.
      try {
        if (Get.isRegistered<AdsController>()) {
          // Ensure token is loaded in TokenController so ApiService can include Authorization
          if (Get.isRegistered<TokenController>()) {
            final t = Get.find<TokenController>();
            if (t.apiToken.value.isEmpty) {
              await t.loadTokenFromStorage();
            }
          }

          final ads = Get.find<AdsController>();
          // Optimistic insert into AdsController.myVideos
          try {
            ads.myVideos.insert(0, uploadedVideo);
            Logger.d(
              'ShortVideoController',
              'Optimistically inserted video into AdsController.myVideos',
            );
          } catch (e) {
            Logger.d(
              'ShortVideoController',
              'Could not optimistically insert into AdsController: $e',
            );
          }

          // Trigger a short retry/polling sequence to let server-side processing finish
          final refreshed = await ads.refreshWithRetry(
            retries: 4,
            delayMs: 1500,
          );
          Logger.d(
            'ShortVideoController',
            'Triggered AdsController.refreshWithRetry after upload, refreshed=$refreshed',
          );
        }
      } catch (e) {
        Logger.d('ShortVideoController', 'Could not refresh AdsController: $e');
      }
      // Navigate to short video screen showing the new upload immediately.
      try {
        Get.offNamed(AppRoutes.shortVideo, arguments: uploadedVideo.id);
      } catch (e) {
        Logger.d('ShortVideoController', 'Navigation after upload failed: $e');
      }
    } catch (e) {
      Logger.d('ShortVideoController', 'uploadVideo error: $e');
      try {
        Get.snackbar(
          'Upload failed',
          e.toString(),
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (_) {
        // ignore if Get context not available
      }
    } finally {
      // Ensure uploading flag is cleared regardless of outcome
      isUploading.value = false;
    }
  }
}
