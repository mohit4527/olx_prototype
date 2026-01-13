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
    print("=" * 80);
    try {
      isDealerListLoading.value = true;
      errorMessage.value = '';

      final data = await ApiService.getAllDealers();
      print("📊 [Controller] Dealers API Response status: ${data?["status"]}");
      print(
        "📊 [Controller] Total dealers in response: ${(data?["data"] as List?)?.length ?? 0}",
      );

      if (data != null && data["status"] == true) {
        // Fetch all products to count per dealer
        print("\n🔍 [Controller] Fetching all products...");
        final productsList = await ApiService.getAllProducts();
        print("📦 [Controller] Total products fetched: ${productsList.length}");

        // Debug: Print first 5 products to see their structure
        print("\n🔬 [Controller] Sample products (first 5):");
        for (
          int i = 0;
          i < (productsList.length > 5 ? 5 : productsList.length);
          i++
        ) {
          print(
            "   Product $i: id=${productsList[i].id}, userId=${productsList[i].userId}",
          );
        }

        // Count products per dealer/userId
        Map<String, int> dealerProductCounts = {};
        for (var product in productsList) {
          final userId = product.userId; // userId is the dealer/seller ID
          if (userId.isNotEmpty) {
            dealerProductCounts[userId] =
                (dealerProductCounts[userId] ?? 0) + 1;
          }
        }
        print("\n📈 [Controller] Product counts by userId:");
        dealerProductCounts.forEach((userId, count) {
          print("   userId: $userId => $count products");
        });

        print("\n🏪 [Controller] Processing dealers...");
        dealers.value = (data["data"] as List).map((e) {
          final dealerProfileId = e['_id']?.toString() ?? '';

          // Extract userId - try multiple variations
          String dealerUserId = '';
          if (e['userId'] != null && e['userId'].toString().isNotEmpty) {
            dealerUserId = e['userId'].toString();
          } else if (e['user_id'] != null &&
              e['user_id'].toString().isNotEmpty) {
            dealerUserId = e['user_id'].toString();
          }

          final businessName = e['businessName']?.toString() ?? 'Unknown';

          print("\n🧩 [Dealer] businessName: $businessName");
          print("   Profile _id: $dealerProfileId");
          print("   🔍 ALL DEALER FIELDS: ${e.keys.toList()}");
          print("   Raw userId field exists: ${e.containsKey('userId')}");
          print("   Raw userId value: ${e['userId']}");
          print("   Extracted userId: '$dealerUserId'");

          // Try matching with both _id and userId
          int vehicleCountById = dealerProductCounts[dealerProfileId] ?? 0;
          int vehicleCountByUserId = dealerProductCounts[dealerUserId] ?? 0;

          print("   Products matched by _id: $vehicleCountById");
          print("   Products matched by userId: $vehicleCountByUserId");

          // Use whichever has more products (prefer userId match)
          final vehicleCount = vehicleCountByUserId > 0
              ? vehicleCountByUserId
              : vehicleCountById;

          print("   ✅ Final vehicle count: $vehicleCount");

          // Add vehicle count to dealer data
          e['totalVehicles'] = vehicleCount;
          e['totalStock'] = vehicleCount;
          e['totalSold'] = 0; // We don't have sold data from products

          final dealer = DealerStats.fromJson(e);
          return dealer;
        }).toList();

        // 🔥 Sort dealers by vehicle count - DESCENDING (highest first)
        dealers.sort((a, b) => b.totalVehicles.compareTo(a.totalVehicles));
        print("\n🔄 [Controller] Dealers sorted by vehicle count (descending)");
        print("   Top 3 dealers:");
        for (int i = 0; i < (dealers.length > 3 ? 3 : dealers.length); i++) {
          print(
            "   ${i + 1}. ${dealers[i].businessName} => ${dealers[i].totalVehicles} vehicles",
          );
        }

        print("\n✅ [Controller] Total dealers loaded: ${dealers.length}");
        print("=" * 80);
      } else {
        dealers.clear();
        errorMessage.value = data?["message"] ?? "Failed to load dealers";
        print("⚠️ [Controller] Error Message: ${errorMessage.value}");
      }
    } catch (e, stackTrace) {
      dealers.clear();
      errorMessage.value = "Error fetching dealers: $e";
      print("❌ [Controller] Exception: $e");
      print("❌ [Controller] StackTrace: $stackTrace");
    } finally {
      isDealerListLoading.value = false;
      print("✅ [Controller] fetchAllDealers completed");
      print("=" * 80);
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
