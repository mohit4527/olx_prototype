import 'package:get/get.dart';

import '../model/short_video_model/short_video_model.dart';
import '../services/apiServices/apiServices.dart';



class ShortVideoController extends GetxController {
  var isLoading = true.obs;
  var videoList = <ShortVideoModel>[].obs;
  var currentIndex = 0.obs;


  @override
  void onInit() {
    fetchVideos();
    super.onInit();
  }

  void fetchVideos() async {
    try {
      isLoading.value = true;
      var fetchedVideos = await ApiService.fetchShortVideos();

      for (var video in fetchedVideos) {
        print("Fetched Video URL: ${video.videoUrl}");
      }

      videoList.assignAll(fetchedVideos);
    } catch (e) {
      print("Error loading videos: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
