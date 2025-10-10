import 'package:get/get.dart';
import '../model/dealer_details_model/dealer_details_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerDetailsController extends GetxController {
  // Data
  var dealerStats = Rxn<DealerStats>();
  var products = <DealerProduct>[].obs;
  var dealers = <DealerStats>[].obs;

  // Loading states
  var isDealerStatsLoading = false.obs;
  var isProductListLoading = false.obs;
  var isDealerListLoading = false.obs;

  // Error message
  var errorMessage = ''.obs;

  /// Fetch single dealer details
  Future<void> fetchDealerDetails(String dealerId) async {
    try {
      isDealerStatsLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getDealerStats(dealerId);
      if (data != null && data["status"] == true) {
        dealerStats.value = DealerStats.fromJson(data["data"]);
      } else {
        dealerStats.value = null;
        errorMessage.value = data?["message"] ?? "Failed to load dealer details";
      }
    } catch (e) {
      dealerStats.value = null;
      errorMessage.value = "Error fetching dealer details: $e";
    } finally {
      isDealerStatsLoading.value = false;
    }
  }

  /// Fetch dealer products
  Future<void> fetchDealerProducts(String dealerId) async {
    try {
      isProductListLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getDealerCars(dealerId);
      if (data != null && data["status"] == true) {
        products.value = (data["data"] as List).map((e) => DealerProduct.fromJson(e)).toList();
      } else {
        products.clear();
        errorMessage.value = data?["message"] ?? "No products found";
      }
    } catch (e) {
      products.clear();
      errorMessage.value = "Error fetching products: $e";
    } finally {
      isProductListLoading.value = false;
    }
  }

  /// Get only sold products
  List<DealerProduct> get soldProducts {
    return products.where((product) =>
        product.offers.any((offer) => offer.status == 'accepted')
    ).toList();
  }

  /// Fetch all dealers
  Future<void> fetchAllDealers() async {
    try {
      isDealerListLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getAllDealers();
      if (data != null && data["status"] == true) {
        dealers.value = (data["data"] as List).map((e) => DealerStats.fromJson(e)).toList();
      } else {
        dealers.clear();
        errorMessage.value = data?["message"] ?? "Failed to load dealers";
      }
    } catch (e) {
      dealers.clear();
      errorMessage.value = "Error fetching dealers: $e";
    } finally {
      isDealerListLoading.value = false;
    }
  }

  /// Clear all data
  void clearData() {
    dealerStats.value = null;
    dealers.clear();
    products.clear();
    errorMessage.value = '';
  }
}
