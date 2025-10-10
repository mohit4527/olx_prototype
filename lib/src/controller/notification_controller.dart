import 'package:get/get.dart';

class NotificationsController extends GetxController {
  var notifications = <Map<String, String>>[].obs;

  void addNotification(String title, String body) {
    notifications.insert(0, {
      "title": title,
      "subtitle": body,
      "time": DateTime.now().toLocal().toString().substring(0, 16),
    });
  }
}
