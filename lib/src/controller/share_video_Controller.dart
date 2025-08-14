import 'package:get/get.dart';
import '../model/share_video_model/share_video_model.dart';
import '../services/apiServices/apiServices.dart';


class ShareVideoController extends GetxController {
  var isSharing = false.obs;

  Future<ShareVideoResponse> shareVideo(String videoId, String userId) async {
    try {
      isSharing.value = true;
      final response = await ApiService.shareVideo(
        videoId: videoId,
        userId: userId,
      );
      return response;
    } catch (e) {
      rethrow;
    } finally {
      isSharing.value = false;
    }
  }

}
