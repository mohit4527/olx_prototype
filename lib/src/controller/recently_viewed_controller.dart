import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/recently_product_model/recently_product_model.dart';

class RecentlyViewedController extends GetxController {
  RxList<RecentlyViewedModel> recentlyViewed = <RecentlyViewedModel>[].obs;
  static const String _prefsKey = "recently_viewed_products";

  @override
  void onInit() {
    super.onInit();
    loadFromPrefs();
  }

  Future<void> addProduct(RecentlyViewedModel product) async {
    recentlyViewed.removeWhere((p) => p.id == product.id);

    recentlyViewed.insert(0, product);

    if (recentlyViewed.length > 10) {
      recentlyViewed.removeRange(10, recentlyViewed.length);
    }

    await saveToPrefs();
  }
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = recentlyViewed.map((e) => e.toJson()).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey) ?? [];
    recentlyViewed.value =
        jsonList.map((e) => RecentlyViewedModel.fromJson(e)).toList();
  }
}
