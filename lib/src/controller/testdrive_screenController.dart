import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../model/book_test_drivescreen_model/book_test_drive_screen_model.dart';
import '../services/apiServices/apiServices.dart';

class TestDriveController extends GetxController {
  final String carId;
  var isLoading = true.obs;
  var testDrives = <BookTestDriveScreenModel>[].obs;

  TestDriveController(this.carId);

  @override
  void onInit() {
    super.onInit();
    final cleanedCarId = carId.trim();
    print("Controller initialized with carId: '$cleanedCarId'");
    fetchTestDrives(cleanedCarId);
  }

  Future<void> fetchTestDrives(String cleanedCarId) async {
    isLoading.value = true;

    try {
      print("Fetching test drives for carId: '$cleanedCarId'");
      final response = await ApiService.fetchTestDrives(cleanedCarId);

      if (response.isEmpty) {
        testDrives.clear();
        return;
      }

      testDrives.assignAll(response);
      print("Loaded ${response.length} test drives");
    } catch (e) {
      print(" Exception during API call: $e");
      Get.snackbar(
        "Error",
        "Failed to load test drives",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔧 Update status locally and via API
  Future<void> updateTestDriveStatus(int index, String action) async {
    final item = testDrives[index];
    try {
      final success = await ApiService.updateTestDriveStatus(item.id!, action);
      if (success) {
        final updatedStatus = action == "accept" ? "confirmed" : "rejected";
        testDrives[index].status = updatedStatus;
        testDrives.refresh();
        print("Status updated to $updatedStatus for ${item.id}");

        Get.snackbar(
          "Success",
          "Test drive ${updatedStatus.capitalize}!",
          backgroundColor: AppColors.appGreen,
          colorText: AppColors.appWhite,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        throw "API failed";
      }
    } catch (e) {
      print("Failed to update status: $e");
      Get.snackbar(
        "Error",
        "Failed to update status",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );
    }
  }
}
