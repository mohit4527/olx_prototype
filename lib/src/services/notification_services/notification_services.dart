import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/view/home/notifications/notification_screen.dart';
import '../../controller/notification_controller.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:olx_prototype/src/controller/chat_controller.dart';

class NotificationServices {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Request Notification Permission
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("✅ User granted permission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("⚠️ User granted provisional permission");
    } else {
      print("❌ User denied permission");
    }
  }

  /// Local Notification Init
  void initLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _handleNavigationFromPayload(response.payload!);
        }
      },
    );
  }

  /// Firebase Foreground + Background Listener
  void firebaseInit() {
    final notifController = Get.put(NotificationsController());

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground Message: ${message.notification?.title}");

      final data = message.data;
      final title =
          message.notification?.title ??
          data['title'] ??
          data['notification_title'] ??
          'No Title';
      final body =
          message.notification?.body ??
          data['body'] ??
          data['message'] ??
          data['notification_body'] ??
          'No Body';

      // save in controller
      try {
        notifController.addNotification(title, body);
      } catch (e) {
        print(
          'NotificationServices: failed to add notification to controller: $e',
        );
      }

      // show local notification for foreground messages
      try {
        showNotification(message);
      } catch (e) {
        print('NotificationServices: showNotification failed: $e');
      }

      // If this is a chat message payload, update local chat unread count
      try {
        final type = data['type'] ?? '';
        final chatId = data['chatId'] ?? data['chat_id'] ?? '';
        final lastMessage = data['lastMessage'] ?? body;
        final time = data['time'] ?? DateTime.now().toIso8601String();
        if ((type == 'chat' || chatId.isNotEmpty)) {
          if (Get.isRegistered<ChatController>()) {
            final chatCtrl = Get.find<ChatController>();
            chatCtrl.markIncomingMessage(chatId, lastMessage, time);
          }
        }
      } catch (e) {
        print('NotificationServices: failed to mark incoming chat: $e');
      }
    });

    // Background / App opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📲 Notification Tapped (Opened App): ${message.data}");
      // If user tapped a chat notification, mark chat as read locally (set unread count to 0)
      try {
        final data = message.data;
        final chatId = data['chatId'] ?? data['chat_id'] ?? '';
        if (chatId.isNotEmpty && Get.isRegistered<ChatController>()) {
          final chatCtrl = Get.find<ChatController>();
          // mark as read and update last message/time
          final lastMessage = data['lastMessage'] ?? '';
          final time = data['time'] ?? DateTime.now().toIso8601String();
          chatCtrl.markIncomingMessage(
            chatId,
            lastMessage,
            time,
            incrementUnread: false,
            unreadCount: 0,
          );
        }
      } catch (e) {
        print('NotificationServices: failed to clear unread on open: $e');
      }
      _handleNavigationFromData(message.data);
    });
  }

  /// Show Local Notification
  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "No Title",
      message.notification?.body ?? "No Body",
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  /// Handle Navigation from data payload
  void _handleNavigationFromData(Map<String, dynamic> data) {
    final type = data['type'];
    if (type == 'notification') {
      Get.to(() => NotificationScreen());
    } else if (type == 'product') {
      final productId = data['productId'];
      if (productId != null && productId.toString().isNotEmpty) {
        if (Get.isRegistered<TokenController>()) {
          final tokenController = Get.find<TokenController>();
          if (tokenController.isLoggedIn) {
            Get.toNamed(AppRoutes.description, arguments: productId);
          } else {
            Get.toNamed(AppRoutes.login);
          }
        } else {
          // TokenController not registered - default to login
          Get.toNamed(AppRoutes.login);
        }
      } else {
        print("productId missing or empty");
      }
    } else if (data['route'] != null) {
      Get.toNamed(data['route']);
    } else {
      print("Unknown notification type/data: $data");
    }
  }

  /// Handle Navigation from string payload (local notification tap)
  void _handleNavigationFromPayload(String payload) {
    try {
      final Map<String, dynamic> data = {};
      payload.replaceAll(RegExp(r'[{} ]'), '').split(',').forEach((pair) {
        final kv = pair.split(':');
        if (kv.length == 2) data[kv[0]] = kv[1];
      });

      _handleNavigationFromData(data);
    } catch (e) {
      print("Payload parsing error: $e");
    }
  }

  /// Terminated state ke liye
  Future<void> setupInteractMessage() async {
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNavigationFromData(initialMessage.data);
    }
  }
}
