import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import '../model/all_product_model/all_product_model.dart';
import '../model/product_description_model/product_description model.dart';
import '../model/user_offermodel/user_offermodel.dart';
import '../services/apiServices/apiServices.dart';

class UserHistoryController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var productsWithOffers = <AllProductModel>[].obs; // products with offers
  var offers = <UserOffer>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductsWithOffers();
  }

  Future<void> fetchProductsWithOffers() async {
    try {
      isLoading.value = true;
      // Use the authenticated endpoint which returns only the logged-in user's products
      // ApiService.getMyProducts() will attempt /products/my and fall back to userid query
      final List<AllProductModel> myProducts = await ApiService.getMyProducts();
      productsWithOffers.assignAll(
        myProducts.where((p) => (p.title.isNotEmpty)).toList(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch offers for single product
  Future<void> getUserOffers(String productId) async {
    try {
      isLoading.value = true;
      final response = await _apiService.fetchUserOffers(productId);
      if (response != null && response["status"] == true) {
        final List data = response["data"];
        offers.value = data.map((e) => UserOffer.fromJson(e)).toList();
        print("Offers API Response: $response");
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// offer accepted
  Future<void> acceptOffer(String productId, String offerId) async {
    final response = await _apiService.acceptUserOffer(productId, offerId);
    if (response != null && response["status"] == true) {
      Get.snackbar(
        "Success",
        "Offer accepted successfully",
        backgroundColor: AppColors.appGreen,
        colorText: AppColors.appWhite,
      );

      // 👇 Update local list
      int index = offers.indexWhere((o) => o.id == offerId);
      if (index != -1) {
        offers[index] = UserOffer(
          id: offers[index].id,
          offerPrice: offers[index].offerPrice,
          userId: offers[index].userId,
          status: "accepted",
          username: '',
        );
        offers.refresh();
      }
    }
  }

  /// offer rejected
  Future<void> rejectOffer(String productId, String offerId) async {
    final response = await _apiService.rejectUserOffer(productId, offerId);
    if (response != null && response["status"] == true) {
      Get.snackbar(
        "Rejected",
        "Offer rejected successfully",
        backgroundColor: AppColors.appRed,
        colorText: AppColors.appWhite,
      );

      int index = offers.indexWhere((o) => o.id == offerId);
      if (index != -1) {
        offers[index] = UserOffer(
          id: offers[index].id,
          offerPrice: offers[index].offerPrice,
          userId: offers[index].userId,
          status: "rejected",
          username: '',
        );
        offers.refresh();
      }
    }
  }
}
