import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:olx_prototype/src/services/apiServices/apiServices.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/controller/get_profile_controller.dart';

class SignupController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  final TokenController tokenController = Get.find<TokenController>();

  RxBool isOtpSent = false.obs;
  RxBool isOtpVerified = false.obs;
  RxBool isVerifyingOtp = false.obs;
  RxBool isLoading = false.obs;
  Rx<File?> selectedProfileImage = Rx<File?>(null);

  String? _registrationOtp;
  String? _registeredPhone;

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        selectedProfileImage.value = File(image.path);
        Get.snackbar("Image Selected", "Profile image selected successfully");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to pick image: $e");
    }
  }

  void removeProfileImage() {
    selectedProfileImage.value = null;
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    String accountType = "User", // Default as User
  }) async {
    try {
      isLoading.value = true;
      final result = await ApiService.register(
        phone: phone,
        countryCode: "+91",
        name: name,
        email: email,
        profileImage: selectedProfileImage.value,
      );

      if (result['success'] == true) {
        final responseData = result['data']['data'];
        _registrationOtp = responseData['otp'].toString();
        _registeredPhone = responseData['phone']?.toString() ?? phone;
        isOtpSent.value = true;

        // Save user info locally for profile display
        final prefs = await SharedPreferences.getInstance();
        // Save global keys
        await prefs.setString('user_display_name', name);
        await prefs.setString('user_email', email);
        await prefs.setString('user_phone', phone);
        await prefs.setString('user_type', accountType);
        if (selectedProfileImage.value != null) {
          await prefs.setString(
            'user_profile_image',
            selectedProfileImage.value!.path,
          );
        }

        // Also save per-phone profile entries and mark active phone
        await prefs.setString('active_user_phone', phone);
        final prefix = 'profile_${phone}_';
        await prefs.setString('${prefix}display_name', name);
        await prefs.setString('${prefix}email', email);
        await prefs.setString('${prefix}phone', phone);
        if (selectedProfileImage.value != null) {
          await prefs.setString(
            '${prefix}image',
            selectedProfileImage.value!.path,
          );
        }

        print("✅ Saved profile info locally");

        // Notify GetProfileController (if registered) to reload saved profile
        if (Get.isRegistered<GetProfileController>()) {
          try {
            final gp = Get.find<GetProfileController>();
            gp.loadProfileFromPrefs();
          } catch (_) {}
        }

        Get.snackbar("OTP Sent", "OTP sent successfully!");
      } else {
        Get.snackbar("Registration Failed", result['message'] ?? "Error");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp(String otp) async {
    try {
      isVerifyingOtp.value = true;
      String cleanEnteredOtp = otp.trim();
      String cleanExpectedOtp = _registrationOtp?.trim() ?? '';

      if (cleanEnteredOtp == cleanExpectedOtp && cleanExpectedOtp.isNotEmpty) {
        final apiResult = await ApiService.verifyOtp(
          _registeredPhone ?? '',
          otp,
        );

        if (apiResult['success'] == true) {
          await tokenController.loadTokenFromStorage();
          isOtpVerified.value = true;
          Get.snackbar("Success", "OTP Verified Successfully ✅");
          await Future.delayed(Duration(seconds: 1));
          Get.offAllNamed(AppRoutes.home);
        } else {
          Get.snackbar("Error", "Invalid OTP");
        }
      } else {
        Get.snackbar("Error", "Incorrect OTP");
      }
    } finally {
      isVerifyingOtp.value = false;
    }
  }

  void resetForm() {
    isOtpSent.value = false;
    isOtpVerified.value = false;
    selectedProfileImage.value = null;
    _registrationOtp = null;
  }

  @override
  void onClose() {
    resetForm();
    super.onClose();
  }
}
