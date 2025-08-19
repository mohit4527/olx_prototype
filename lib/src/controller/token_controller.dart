import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenController extends GetxController {
  final RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('token') ?? '';
  }

  Future<void> saveToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    token.value = newToken; // reactive update
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token.value = '';
  }
}
