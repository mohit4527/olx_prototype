import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GetProfileController extends GetxController {
  RxString imagePath = "".obs;

  var profileData = {
    "Username": "Mohit Kumar",
    "Phone Number": "+91 7270095618",
    "Email": "kumarmohit123@gmail.com",
    "Gender": "Male",
    "Date Of Birth": "01/01/2000"
  }.obs;

  void updateField(String key, String newValue) {
    profileData[key] = newValue;
  }

  String get name => profileData["Username"] ?? "";

  Future getImageByCamera() async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath.value = image.path.toString();
    } else {
      Get.snackbar("Error", "Please Pick any image first");
    }
  }

  Future getImageByGallery() async {
    final ImagePicker picking = ImagePicker();
    final images = await picking.pickImage(source: ImageSource.gallery);
    if (images != null) {
      imagePath.value = images.path.toString();
    } else {
      Get.snackbar("Error", "Please select any photo");
    }
  }
}
