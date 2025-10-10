import 'package:get/get.dart';
import '../model/product_description_model/product_description model.dart';
import '../services/apiServices/apiServices.dart';
import '../services/auth_service/auth_service.dart';

class DescriptionController extends GetxController {
  var product = Rxn<ProductModel>();
  var isLoading = false.obs;
  // Make currentUserId reactive so UI can rebuild when the logged-in id is loaded
  var currentUserId = ''.obs;
  // Resolved contact details for uploader (phone/whatsapp)
  var uploaderPhone = ''.obs;
  var uploaderWhatsApp = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await AuthService.getLoggedInUserId();
    currentUserId.value = id ?? '';
  }

  Future<void> fetchProductById(String productId) async {
    try {
      print('[DescriptionController] fetchProductById start -> $productId');
      isLoading(true);
      final data = await ApiService.fetchProductById(productId);
      product.value = data;
      // Resolve uploader contact info: prefer explicit phone/whatsapp in product,
      // otherwise try to fetch user profile by userId for their phone.
      uploaderPhone.value = data?.phoneNumber ?? '';
      uploaderWhatsApp.value = data?.whatsapp ?? '';
      if ((uploaderPhone.value.isEmpty || uploaderWhatsApp.value.isEmpty) &&
          (data?.userId != null && data!.userId!.isNotEmpty)) {
        try {
          final profile = await ApiService.fetchUserProfile(data.userId!);
          if (profile != null) {
            uploaderPhone.value = uploaderPhone.value.isNotEmpty
                ? uploaderPhone.value
                : (profile['phone']?.toString() ??
                      profile['phoneNumber']?.toString() ??
                      '');
            uploaderWhatsApp.value = uploaderWhatsApp.value.isNotEmpty
                ? uploaderWhatsApp.value
                : (profile['whatsapp']?.toString() ??
                      profile['whatsappNumber']?.toString() ??
                      '');
          }
        } catch (e) {
          print('[DescriptionController] Could not fetch uploader profile: $e');
        }
      }
      print(
        '[DescriptionController] fetchProductById completed -> ${data?.id}',
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// Ensure uploader contact fields are populated. This is safe to call
  /// multiple times; it will only fetch profile data when needed.
  Future<void> ensureUploaderContact() async {
    try {
      if (uploaderPhone.value.isNotEmpty && uploaderWhatsApp.value.isNotEmpty)
        return;

      final data = product.value;
      if (data == null) return;

      // Prefer product fields first
      uploaderPhone.value = uploaderPhone.value.isNotEmpty
          ? uploaderPhone.value
          : (data.phoneNumber ?? '');
      uploaderWhatsApp.value = uploaderWhatsApp.value.isNotEmpty
          ? uploaderWhatsApp.value
          : (data.whatsapp ?? '');

      // If still missing, try to fetch from user profile
      if ((uploaderPhone.value.isEmpty || uploaderWhatsApp.value.isEmpty) &&
          (data.userId != null && data.userId!.isNotEmpty)) {
        final profile = await ApiService.fetchUserProfile(data.userId!);
        if (profile != null) {
          uploaderPhone.value = uploaderPhone.value.isNotEmpty
              ? uploaderPhone.value
              : (profile['phone']?.toString() ??
                    profile['phoneNumber']?.toString() ??
                    '');
          uploaderWhatsApp.value = uploaderWhatsApp.value.isNotEmpty
              ? uploaderWhatsApp.value
              : (profile['whatsapp']?.toString() ??
                    profile['whatsappNumber']?.toString() ??
                    '');
        }
      }
    } catch (e) {
      print('[DescriptionController] ensureUploaderContact error: $e');
    }
  }
}
