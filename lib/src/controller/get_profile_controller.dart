import 'dart:convert';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:olx_prototype/src/controller/token_controller.dart';

class GetProfileController extends GetxController {
  RxString imagePath = "".obs;

  var profileData = {
    "Username": "",
    "Phone Number": "",
    "Email": "",
    "Gender": "",
    "Date Of Birth": "",
    "BusinessName": "",
  }.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileFromPrefs();
    // Attempt to fetch fresh profile from backend if we have a user id
    _fetchRemoteProfileIfAvailable();
  }

  Future<void> _fetchRemoteProfileIfAvailable() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('user_uid') ?? prefs.getString('userId') ?? '';
      if (userId.isNotEmpty) {
        await fetchProfile(userId);
      }
    } catch (e) {
      print('[GetProfileController] _fetchRemoteProfileIfAvailable error: $e');
    }
  }

  /// Fetch a profile from the backend and update local state + prefs.
  Future<void> fetchProfile(String id) async {
    try {
      final base = 'https://oldmarket.bhoomi.cloud/api/auth';
      final url = Uri.parse('$base/profile/$id');
      print('[GetProfileController] Fetching profile: $url');
      final res = await http.get(url);
      print('[GetProfileController] Response: ${res.statusCode}');
      if (res.statusCode == 200) {
        final body = json.decode(res.body) as Map<String, dynamic>;
        // Some endpoints wrap data inside { status: true, data: { ... } }
        final data = (body['data'] is Map)
            ? body['data'] as Map<String, dynamic>
            : (body.containsKey('user')
                  ? body['user'] as Map<String, dynamic>
                  : body);

        final name =
            (data['name'] ??
                    data['displayName'] ??
                    data['username'] ??
                    data['Username'])
                ?.toString() ??
            '';
        final phone =
            (data['phone'] ?? data['Phone'] ?? data['mobile'] ?? '')
                ?.toString() ??
            '';
        final email = (data['email'] ?? data['Email'] ?? '')?.toString() ?? '';
        String photo =
            (data['photo'] ?? data['profileImage'] ?? data['image'] ?? '')
                ?.toString() ??
            '';
        String role = '';
        if (data.containsKey('role')) role = data['role']?.toString() ?? '';
        if (role.isEmpty) {
          // Try common flags
          if ((data['isDealer'] ?? false) == true) role = 'Dealer';
        }

        // Normalize photo path to absolute URL when necessary
        if (photo.isNotEmpty && !photo.startsWith('http')) {
          final baseAssets = 'https://oldmarket.bhoomi.cloud/';
          final fixed = photo.replaceAll('\\', '/');
          final rel = fixed.startsWith('/') ? fixed.substring(1) : fixed;
          photo = '$baseAssets$rel';
        }

        profileData['Username'] = name.isNotEmpty
            ? name
            : (profileData['Username'] ?? '');
        profileData['Phone Number'] = phone.isNotEmpty
            ? phone
            : (profileData['Phone Number'] ?? '');
        profileData['Email'] = email.isNotEmpty
            ? email
            : (profileData['Email'] ?? '');
        profileData['Role'] = role.isNotEmpty
            ? role
            : (profileData['Role'] ?? 'User');

        if (photo.isNotEmpty) {
          imagePath.value = photo;
        }

        // Update TokenController's displayName/photo so AppBar and other UI update
        try {
          final TokenController tc = Get.find<TokenController>();
          await tc.saveUserInfo({
            'uid': id,
            'displayName': profileData['Username'] ?? '',
            'photoURL': imagePath.value.isNotEmpty
                ? imagePath.value
                : tc.photoUrl.value,
          });
        } catch (e) {
          print('[GetProfileController] Could not update TokenController: $e');
        }

        // Persist results
        await saveProfileToPrefs();

        profileData.refresh();
        imagePath.refresh();
        print('[GetProfileController] Profile loaded and saved for id=$id');
      } else {
        print('[GetProfileController] fetchProfile non-200: ${res.body}');
      }
    } catch (e, st) {
      print('[GetProfileController] fetchProfile error: $e');
      print(st);
    }
  }

  Future<void> loadProfileFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer active user phone specific data if available
    final activePhone = prefs.getString('active_user_phone') ?? '';
    if (activePhone.isNotEmpty) {
      final prefix = 'profile_${activePhone}_';
      profileData['Username'] =
          prefs.getString('${prefix}display_name') ??
          prefs.getString('user_display_name') ??
          profileData['Username'] ??
          '';
      profileData['Phone Number'] = activePhone;
      profileData['Email'] =
          prefs.getString('${prefix}email') ??
          prefs.getString('user_email') ??
          profileData['Email'] ??
          '';
      final savedImage =
          prefs.getString('${prefix}image') ??
          prefs.getString('user_profile_image') ??
          '';
      if (savedImage.isNotEmpty) {
        imagePath.value = savedImage;
      }
    } else {
      profileData['Username'] =
          prefs.getString('user_display_name') ?? profileData['Username'] ?? '';
      profileData['Phone Number'] =
          prefs.getString('user_phone') ?? profileData['Phone Number'] ?? '';
      profileData['Email'] =
          prefs.getString('user_email') ?? profileData['Email'] ?? '';
      final savedImage = prefs.getString('user_profile_image') ?? '';
      if (savedImage.isNotEmpty) {
        imagePath.value = savedImage;
      }
    }
    // Load business name if available
    profileData['BusinessName'] = prefs.getString('user_business_name') ?? '';
    // notify listeners
    profileData.refresh();
    imagePath.refresh();
  }

  void updateField(String key, String newValue) {
    profileData[key] = newValue;
    saveProfileToPrefs();
    profileData.refresh();
  }

  Future<void> saveProfileToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Save legacy/global keys
    await prefs.setString('user_display_name', profileData['Username'] ?? '');
    await prefs.setString('user_phone', profileData['Phone Number'] ?? '');
    await prefs.setString('user_email', profileData['Email'] ?? '');
    if (imagePath.value.isNotEmpty) {
      await prefs.setString('user_profile_image', imagePath.value);
    }

    // Also save under active phone prefix if available
    final activePhone = prefs.getString('active_user_phone') ?? '';
    if (activePhone.isNotEmpty) {
      final prefix = 'profile_${activePhone}_';
      await prefs.setString(
        '${prefix}display_name',
        profileData['Username'] ?? '',
      );
      await prefs.setString('${prefix}email', profileData['Email'] ?? '');
      await prefs.setString('${prefix}phone', activePhone);
      if (imagePath.value.isNotEmpty) {
        await prefs.setString('${prefix}image', imagePath.value);
      }
    }
  }

  String get name => profileData["Username"] ?? "";

  /// 🔥 Update role to Vendor when business account is created
  Future<void> updateRoleToDealer() async {
    profileData['Role'] = 'Vendor';
    await _loadBusinessName();
    saveProfileToPrefs();
    profileData.refresh();
    print('✅ [GetProfileController] Role updated to Vendor');
  }

  /// 🔥 Load business name from dealer profile API
  Future<void> _loadBusinessName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId =
          prefs.getString('user_uid') ?? prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        print(
          '⚠️ [GetProfileController] No userId found, cannot load business name',
        );
        return;
      }

      final url = Uri.parse(
        'https://oldmarket.bhoomi.cloud/api/dealer-profiles',
      );
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final profiles = body['data'] as List?;

        if (profiles != null) {
          for (var profile in profiles) {
            if (profile['userId'] == userId) {
              final businessName = profile['businessName']?.toString() ?? '';
              if (businessName.isNotEmpty) {
                profileData['BusinessName'] = businessName;
                await prefs.setString('user_business_name', businessName);
                print(
                  '✅ [GetProfileController] Business name loaded: $businessName',
                );
              }
              break;
            }
          }
        }
      }
    } catch (e) {
      print('❌ [GetProfileController] Error loading business name: $e');
    }
  }

  /// 🔥 Update role to User when dealer profile is removed
  Future<void> updateRoleToUser() async {
    profileData['Role'] = 'User';
    profileData['BusinessName'] = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_business_name');
    saveProfileToPrefs();
    profileData.refresh();
    print('✅ [GetProfileController] Role updated to User');
  }

  Future getImageByCamera() async {
    final ImagePicker _picker = ImagePicker();
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      imagePath.value = image.path.toString();
      // persist
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', imagePath.value);
    } else {
      Get.snackbar("Error", "Please Pick any image first");
    }
  }

  Future getImageByGallery() async {
    final ImagePicker picking = ImagePicker();
    final images = await picking.pickImage(source: ImageSource.gallery);
    if (images != null) {
      imagePath.value = images.path.toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_image', imagePath.value);
    } else {
      Get.snackbar("Error", "Please select any photo");
    }
  }
}
