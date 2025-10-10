import 'dart:ui';

import 'package:get/get.dart';
import 'package:olx_prototype/src/model/book_test_drivescreen_model/book_test_drive_screen_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerTestDriveController extends GetxController {
  final String carId;

  DealerTestDriveController(this.carId);

  var testDrives = <BookTestDriveScreenModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDealerTestDrives();
  }

  /// 🔹 Fetch all test drives for dealer's car
  Future<void> fetchDealerTestDrives() async {
    print("📡 Fetching dealer test drives for carId: $carId");
    try {
      isLoading.value = true;
      final result = await ApiService.fetchDealerTestDrives(carId);
      print("✅ Received ${result.length} test drives");
      testDrives.assignAll(result);
    } catch (e) {
      print("❌ Error fetching dealer test drives: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔹 Accept or Reject test drive
  Future<void> updateDealerTestDriveStatus(int index, String action) async {
    final booking = testDrives[index];
    final bookingId = booking.id;

    if (bookingId == null) {
      print("⚠️ Booking ID is null for index $index");
      return;
    }

    print("📡 Updating status for bookingId: $bookingId → $action");

    try {
      isLoading.value = true;

      final updated = await ApiService.updateDealerTestDriveStatus(
        bookingId: bookingId,
        action: action,
      );

      if (updated != null) {
        testDrives[index] = updated;
        testDrives.refresh();
        print("✅ Status updated: ${updated.status}");

        // Optional: Show snackbar feedback
        Get.snackbar(
          "Success",
          "Test Drive ${action == "accept" ? "Accepted" : "Rejected"}",
          backgroundColor: action == "accept" ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        print("⚠️ No updated data returned from API");
      }
    } catch (e) {
      print("❌ Error updating status: $e");
      Get.snackbar("Error", "Failed to update test drive status", backgroundColor: const Color(0xFFF44336), colorText: const Color(0xFFFFFFFF));
    } finally {
      isLoading.value = false;
    }
  }
}
