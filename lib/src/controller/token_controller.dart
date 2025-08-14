import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenController extends GetxController {
  RxString token = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  void loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString('token') ?? '';
  }

  void saveToken(String newToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', newToken);
    token.value = newToken;
  }

  void clearToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token.value = '';
  }
}
