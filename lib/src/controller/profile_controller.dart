import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetProfileController extends GetxController {
  var profileData = <String, String>{}.obs;
  var imagePath = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  /// Load data from SharedPreferences
  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    profileData.value = {
      "Username": prefs.getString('user_display_name') ?? 'Guest User',
      "Email": prefs.getString('user_email') ?? 'No Email',
      "Phone": prefs.getString('user_phone') ?? 'Not Available',
      "Member Type": "Gold Member",
    };

    imagePath.value = prefs.getString('user_photo_path') ?? '';
  }

  /// Update field in profileData + save to SharedPreferences
  Future<void> updateField(String field, String newValue) async {
    final prefs = await SharedPreferences.getInstance();

    if (field == "Username") {
      await prefs.setString('user_display_name', newValue);
    } else if (field == "Email") {
      await prefs.setString('user_email', newValue);
    } else if (field == "Phone") {
      await prefs.setString('user_phone', newValue);
    }

    profileData[field] = newValue;
    profileData.refresh();
  }

  /// Pick image from gallery
  Future<void> getImageByGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _saveImagePath(image.path);
    }
  }

  /// Pick image from camera
  Future<void> getImageByCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await _saveImagePath(image.path);
    }
  }

  /// Save selected image path
  Future<void> _saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_photo_path', path);
    imagePath.value = path;
  }
}
