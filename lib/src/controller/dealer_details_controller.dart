import 'package:get/get.dart';
import '../model/dealer_details_model/dealer_details_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerController extends GetxController {
  // Data
  var dealers = <DealerStats>[].obs;
  var dealerStats = Rxn<DealerStats>();
  var products = <DealerProduct>[].obs;

  // Loading states
  var isDealerListLoading = false.obs;
  var isDealerStatsLoading = false.obs;
  var isProductListLoading = false.obs;

  // Error messages
  var errorMessage = ''.obs;

  /// Fetch all dealers for home screen
  Future<void> fetchAllDealers() async {
    print("🔄 [Controller] fetchAllDealers started");
    try {
      isDealerListLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getAllDealers();
      print("📊 [Controller] API Response: $data");

      if (data != null && data["status"] == true) {
        dealers.value = (data["data"] as List).map((e) {
          print("🧩 [Controller] Dealer JSON: $e");
          final dealer = DealerStats.fromJson(e);
          print("✅ [Controller] Parsed Dealer: imageUrl=${dealer.imageUrl}, businessLogo=${dealer.businessLogo}");
          return dealer;
        }).toList();
      } else {
        dealers.clear();
        errorMessage.value = data?["message"] ?? "Failed to load dealers";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
      }
    } catch (e) {
      dealers.clear();
      errorMessage.value = "Error fetching dealers: $e";
      print("❌ [Controller] Exception: $e");
    } finally {
      isDealerListLoading.value = false;
      print("✅ [Controller] fetchAllDealers completed");
    }
  }

  /// Fetch single dealer stats
  Future<void> fetchDealerStats(String dealerId) async {
    print("🔄 [Controller] fetchDealerStats started for $dealerId");
    try {
      isDealerStatsLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getDealerStats(dealerId);
      print("📊 [Controller] API Response: $data");

      if (data != null && data["status"] == true) {
        final dealer = DealerStats.fromJson(data["data"]);
        print("✅ [Controller] Parsed DealerStats: imageUrl=${dealer.imageUrl}, businessLogo=${dealer.businessLogo}");
        dealerStats.value = dealer;
      } else {
        dealerStats.value = null;
        errorMessage.value = data?["message"] ?? "Failed to load dealer stats";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
      }
    } catch (e) {
      dealerStats.value = null;
      errorMessage.value = "Error fetching dealer stats: $e";
      print("❌ [Controller] Exception: $e");
    } finally {
      isDealerStatsLoading.value = false;
      print("✅ [Controller] fetchDealerStats completed");
    }
  }

  /// Fetch all products for a dealer
  Future<void> fetchDealerCars(String dealerId) async {
    print("🔄 [Controller] fetchDealerCars started for $dealerId");
    try {
      isProductListLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getDealerCars(dealerId);
      print("📊 [Controller] API Response: $data");

      if (data != null && data["status"] == true) {
        products.value = (data["data"] as List).map((e) {
          print("🚗 [Controller] Product JSON: $e");
          final product = DealerProduct.fromJson(e);
          print("✅ [Controller] Parsed Product: title=${product.title}, offers=${product.offers.length}");
          return product;
        }).toList();
      } else {
        products.clear();
        errorMessage.value = data?["message"] ?? "No products found";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
      }
    } catch (e) {
      products.clear();
      errorMessage.value = "Error fetching dealer cars: $e";
      print("❌ [Controller] Exception: $e");
    } finally {
      isProductListLoading.value = false;
      print("✅ [Controller] fetchDealerCars completed");
    }
  }

  /// Clear all dealer-related data
  void clearDealerData() {
    print("🧹 [Controller] Clearing all dealer data");
    dealers.clear();
    dealerStats.value = null;
    products.clear();
    errorMessage.value = '';
  }
}
