import 'package:get/get.dart';
import '../model/dealer_details_model/dealer_details_model.dart';
import '../model/dealer_profiles_model/dealer_profiles_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerController extends GetxController {
  // Data
  var dealers = <DealerStats>[].obs;
  var dealerStats = Rxn<DealerStats>();
  var products = <DealerProduct>[].obs;
  var dealerProfiles = <DealerProfile>[].obs; // 🔥 New: All dealer profiles

  // Loading states
  var isDealerListLoading = false.obs;
  var isDealerStatsLoading = false.obs;
  var isProductListLoading = false.obs;
  var isDealerProfilesLoading = false.obs; // 🔥 New: Loading state for profiles

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
          print(
            "✅ [Controller] Parsed Dealer: imageUrl=${dealer.imageUrl}, businessLogo=${dealer.businessLogo}",
          );
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
    print("🔄 [Controller] fetchDealerStats started for dealerId: '$dealerId'");
    print("🔍 [Controller] dealerId length: ${dealerId.length}");

    try {
      isDealerStatsLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getDealerStats(dealerId);
      print("📊 [Controller] API Response: $data");

      if (data != null && data["status"] == true && data["data"] != null) {
        final dealer = DealerStats.fromJson(data["data"]);
        print(
          "✅ [Controller] Parsed DealerStats: businessName=${dealer.businessName}, imageUrl=${dealer.imageUrl}, businessLogo=${dealer.businessLogo}",
        );
        dealerStats.value = dealer;
        errorMessage.value = '';
      } else if (data != null) {
        dealerStats.value = null;
        errorMessage.value = data["message"] ?? "No dealer data found";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
        print("🔍 [Controller] Full response: $data");
      } else {
        dealerStats.value = null;
        errorMessage.value = "Failed to load dealer information";
        print("⚠️ [Controller] No response data received");
      }
    } catch (e) {
      dealerStats.value = null;
      errorMessage.value = "Error fetching dealer stats: $e";
      print("❌ [Controller] Exception: $e");
    } finally {
      isDealerStatsLoading.value = false;
      print("✅ [Controller] fetchDealerStats completed for '$dealerId'");
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
          print(
            "✅ [Controller] Parsed Product: title=${product.title}, offers=${product.offers.length}",
          );
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

  /// 🔥 NEW: Fetch all dealer profiles for complete details
  Future<void> fetchDealerProfiles() async {
    print("🔄 [Controller] fetchDealerProfiles started");
    try {
      isDealerProfilesLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.fetchDealerProfiles();
      print(
        "📊 [Controller] Dealer Profiles API Response: ${data?.count} dealers",
      );

      if (data != null && data.status == true && data.data != null) {
        dealerProfiles.value = data.data!;
        print("✅ [Controller] Loaded ${data.data!.length} dealer profiles");
      } else {
        dealerProfiles.clear();
        errorMessage.value = data?.message ?? "Failed to load dealer profiles";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
      }
    } catch (e) {
      dealerProfiles.clear();
      errorMessage.value = "Error fetching dealer profiles: $e";
      print("❌ [Controller] Exception: $e");
    } finally {
      isDealerProfilesLoading.value = false;
      print("✅ [Controller] fetchDealerProfiles completed");
    }
  }

  /// 🔥 NEW: Get specific dealer profile by ID
  DealerProfile? getDealerProfileById(String dealerId) {
    try {
      return dealerProfiles.firstWhere((profile) => profile.id == dealerId);
    } catch (e) {
      print("❌ [Controller] Dealer profile not found for ID: $dealerId");
      return null;
    }
  }

  /// Clear all dealer-related data
  void clearDealerData() {
    print("🧹 [Controller] Clearing all dealer data");
    dealers.clear();
    dealerStats.value = null;
    products.clear();
    dealerProfiles.clear();
    errorMessage.value = '';
  }
}
