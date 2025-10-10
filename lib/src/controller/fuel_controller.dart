import 'package:get/get.dart';
import '../model/fuel_model/fuel_model.dart';
import '../services/apiServices/apiServices.dart';

class FuelController extends GetxController {
  var fuelList = <FuelModel>[].obs;
  var isLoading = false.obs;

  final ApiService _apiService = ApiService();

  Future<void> loadFuelPrices(String city, String state) async {
    try {
      isLoading.value = true;

      // Directly pass city and state to API service
      final data = await _apiService.fetchFuelPrices(city, state);
      fuelList.value = data;
    } catch (e) {
      print("❌ FuelController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
