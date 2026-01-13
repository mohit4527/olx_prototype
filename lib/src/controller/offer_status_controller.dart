import 'package:get/get.dart';
import '../services/apiServices/apiServices.dart';

class OfferStatusController extends GetxController {
  var isLoading = false.obs;
  var offerStatuses = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOfferStatuses();
  }

  Future<void> fetchOfferStatuses() async {
    try {
      isLoading.value = true;
      final data = await ApiService.fetchOfferStatus();
      offerStatuses.assignAll(data);
      print('[OfferStatusController] ✅ Loaded ${data.length} offer statuses');
    } catch (e) {
      print('[OfferStatusController] ❌ Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOfferStatuses() async {
    await fetchOfferStatuses();
  }
}
