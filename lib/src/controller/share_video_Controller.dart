// ==================== share_video_controller.dart ====================
import 'package:get/get.dart';
import '../model/share_video_model/share_video_model.dart';
import '../services/apiServices/apiServices.dart';

class ShareVideoController extends GetxController {
  var isSharing = false.obs;
  var sharedVideos = <SharedVideo>[].obs;

  Future<SharedVideo> shareVideo(String videoId, String userId, String token) async {
    try {
      isSharing.value = true;
      final response = await ApiService.shareVideo(
        videoId: videoId,
        userId: userId,
        token: token,
      );
      return response;
    } catch (e) {
      rethrow;
    } finally {
      isSharing.value = false;
    }
  }

  // ✅ Get all shared videos
  Future<void> fetchSharedVideos(String token) async {
    try {
      final videos = await ApiService.getSharedVideos(token);
      sharedVideos.assignAll(videos);
    } catch (e) {
      rethrow;
    }
  }
}
