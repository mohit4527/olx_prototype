import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'firebase_options.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/controller/challan_controller.dart';
import 'package:olx_prototype/src/controller/all_products_controller.dart';
import 'package:olx_prototype/src/controller/chat_controller.dart';
import 'package:olx_prototype/src/controller/chat_details_controller.dart';
import 'package:olx_prototype/src/controller/dealer_controller.dart';
import 'package:olx_prototype/src/controller/dealer_products_controller.dart';
import 'package:olx_prototype/src/controller/edit_dealer_profile_controller.dart';
import 'package:olx_prototype/src/controller/home_controller.dart';
import 'package:olx_prototype/src/controller/recently_viewed_controller.dart';
import 'package:olx_prototype/src/controller/theme_controller.dart';
import 'package:olx_prototype/src/controller/token_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:olx_prototype/src/services/notification_services/notification_services.dart';
import 'package:olx_prototype/src/services/deep_link_service.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
import 'package:olx_prototype/src/utils/logger.dart';

/// Background FCM handler (do not initialize Firebase here!)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("📩 Background Message Received");
  print("🔔 Title: ${message.notification?.title}");
  print("📦 Data: ${message.data}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not already initialized
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("🔥 Firebase initialized successfully");
    } else {
      print("🔥 Firebase already initialized, using existing app");
    }
  } catch (e) {
    print("⚠️ Firebase initialization error: $e");
    // Continue with app startup even if Firebase fails
  }

  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inject controllers (GetX)
  Get.put(TokenController(), permanent: true);
  Get.put(ChallanController());
  Get.put(DealerProfileController(), permanent: true);
  Get.put(ProductController(), permanent: true);
  Get.put(HomeController(), permanent: true);
  Get.put(EditDealerProfileController(), permanent: true);
  Get.put(DealerProductsController(), permanent: true);
  Get.put(ChatDetailsController(), permanent: true);
  Get.put(ChatController(), permanent: true);
  Get.put(RecentlyViewedController(), permanent: true);
  Get.put(ThemeController(), permanent: true);

  // Initialize notifications
  await _initNotifications();

  // Initialize deep link service
  await _initDeepLinks();

  // If Firebase has an already signed-in user (e.g., Google), mark as logged in
  try {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      final TokenController tc = Get.find<TokenController>();
      await tc.markLoggedInViaExternal();
      print(
        '🔁 Firebase user detected on startup: ${firebaseUser.uid} - marked as logged in',
      );
    }
  } catch (e) {
    print('⚠️ Could not mark Firebase user as logged in: $e');
  }

  runApp(const MyApp());
}

/// Notification initialization
Future<void> _initNotifications() async {
  try {
    NotificationServices notificationServices = NotificationServices();
    await notificationServices.requestNotificationPermission();
    notificationServices.initLocalNotifications();
    notificationServices.firebaseInit();
    await notificationServices.setupInteractMessage();

    String? token = await FirebaseMessaging.instance.getToken();
    print("📲 FCM Token: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("🔄 Refreshed FCM Token: $newToken");
    });
  } catch (e) {
    print("⚠️ Notification init failed: $e");
  }
}

/// Deep link initialization
Future<void> _initDeepLinks() async {
  try {
    final deepLinkService = DeepLinkService();
    await deepLinkService.initialize();
    print("🔗 Deep link service initialized successfully");
  } catch (e) {
    print("⚠️ Deep link init failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    // Simple navigator observer to log route transitions for debugging
    final observer = _DebugRouteObserver();

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Obx(
          () => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeController.theme,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.purple,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: Colors.black,
              colorScheme: const ColorScheme.dark(
                primary: AppColors.appGreen,
                surface: Colors.black,
                background: Colors.black,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
            initialRoute: AppRoutes.splash,
            getPages: Getpages,
            navigatorObservers: [observer],
          ),
        );
      },
    );
  }
}

class _DebugRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    Logger.i(
      'RouteObserver',
      'didPush -> ${route.settings.name}, from ${previousRoute?.settings.name}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    Logger.i(
      'RouteObserver',
      'didPop -> ${route.settings.name}, back to ${previousRoute?.settings.name}',
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Logger.i(
      'RouteObserver',
      'didReplace -> ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
    );
  }
}
