import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/dealer_product_model/dealer_product_model.dart';
import '../services/apiServices/apiServices.dart';

class DealerDescriptionController extends GetxController {
  final ApiService _apiService = ApiService();
  final String productId;

  DealerDescriptionController({required this.productId});

  var productData = Rx<Data?>(null);
  var isLoading = true.obs;
  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('Received Product ID: $productId');
    fetchProductDetails();
  }

  // API call function
  Future<void> fetchProductDetails() async {
    try {
      isLoading.value = true;
      final response = await _apiService.fetchDealerProductById(productId);
      if (response != null && response.data != null) {
        productData.value = response.data;
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Function to launch phone call
  Future<void> callDealer() async {
    const phoneNumber = '+919876543210';
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar("Error", "Could not launch call functionality.");
    }
  }

  Future<void> whatsappDealer() async {
    const phoneNumber = '919876543210';
    final url = "whatsapp://send?phone=$phoneNumber&text=Hi, I am interested in your car: ${productData.value?.title ?? ''}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar("Error", "Could not launch WhatsApp.");
    }
  }

  void updateImageIndex(int index) {
    currentIndex.value = index;
  }
}