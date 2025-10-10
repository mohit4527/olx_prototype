import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/apiServices/apiServices.dart';

class VideoUploadController extends GetxController {
  var isLoading = false.obs;
  var videoFile = Rx<XFile?>(null);
  var title = ''.obs;
  var productId = ''.obs;
  var duration = 15.obs;

  final ApiService _apiService = ApiService();

  Future<void> pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      videoFile.value = file;
      duration.value = 15;
    }
  }

  Future<void> uploadVideo() async {
    if (videoFile.value == null) {
      Get.snackbar('Error', 'Please select a video first');
      return;
    }

    isLoading.value = true;
    try {
      await _apiService.uploadVideo(
        videoPath: videoFile.value!.path,
        title: title.value.isEmpty ? 'Untitled Video' : title.value,
        productId: productId.value.isEmpty
            ? '64f9a1c5e2a1234567890abc'
            : productId.value,
        duration: duration.value,
      );
      Get.snackbar('Success', 'Video uploaded successfully!');
      Get.back();
    } catch (e) {
      Get.snackbar('Error', 'Video upload failed: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
