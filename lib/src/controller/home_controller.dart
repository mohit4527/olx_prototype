import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  var token = "".obs;

  @override
  void onInit() {
    super.onInit();
    loadToken();
  }

  void loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token.value = prefs.getString("auth_token") ?? "No Token Found";
  }
}
