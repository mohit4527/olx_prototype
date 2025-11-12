import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import '../utils/app_routes.dart';
import '../controller/token_controller.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize() async {
    _appLinks = AppLinks();

    // Handle app launch from link
    try {
      final Uri? initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        print('🔗 App launched with deep link: $initialLink');
        await _handleDeepLink(initialLink);
      }
    } catch (e) {
      print('❌ Error getting initial link: $e');
    }

    // Handle incoming links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('🔗 Received deep link: $uri');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('❌ Deep link error: $err');
      },
    );
  }

  /// Handle deep link navigation
  Future<void> _handleDeepLink(Uri uri) async {
    try {
      print('🔍 Processing deep link: ${uri.toString()}');
      print('🔍 Host: ${uri.host}, Path: ${uri.path}');

      // Wait a bit to ensure app is ready
      await Future.delayed(const Duration(milliseconds: 500));

      // Check if user is logged in
      final TokenController tokenController = Get.find<TokenController>();

      if (uri.host == 'oldmarket.bhoomi.cloud' || uri.scheme == 'oldmarket') {
        final pathSegments = uri.pathSegments;

        if (pathSegments.length >= 2) {
          final type = pathSegments[0]; // 'app'
          final section = pathSegments[1]; // 'product' or 'dealer'

          if (type == 'app' && pathSegments.length >= 3) {
            final id = pathSegments[2];

            if (section == 'product') {
              // Handle product deep link
              await _handleProductLink(id, tokenController);
            } else if (section == 'dealer') {
              // Handle dealer product deep link
              await _handleDealerProductLink(id, tokenController);
            }
          }
        }
      }

      // Handle legacy direct links
      if (uri.path.startsWith('/product/')) {
        final productId = uri.path.replaceFirst('/product/', '');
        if (productId.isNotEmpty) {
          await _handleProductLink(productId, tokenController);
        }
      } else if (uri.path.startsWith('/dealer/')) {
        final dealerProductId = uri.path.replaceFirst('/dealer/', '');
        if (dealerProductId.isNotEmpty) {
          await _handleDealerProductLink(dealerProductId, tokenController);
        }
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
      // Fallback to home screen
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Handle product deep link
  Future<void> _handleProductLink(
    String productId,
    TokenController tokenController,
  ) async {
    print('📱 Navigating to product: $productId');

    if (tokenController.isLoggedIn) {
      // Navigate to product description
      Get.offAllNamed(AppRoutes.home);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(AppRoutes.description, arguments: productId);
    } else {
      // Show login screen first, then navigate to product
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        '🔗 Product Link',
        'Please login to view this product',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Store the product ID to navigate after login
      Get.find<TokenController>().pendingProductId = productId;
    }
  }

  /// Handle dealer product deep link
  Future<void> _handleDealerProductLink(
    String dealerProductId,
    TokenController tokenController,
  ) async {
    print('🏪 Navigating to dealer product: $dealerProductId');

    if (tokenController.isLoggedIn) {
      // Navigate to dealer product description
      Get.offAllNamed(AppRoutes.home);
      await Future.delayed(const Duration(milliseconds: 300));
      Get.toNamed(
        AppRoutes.dealer_product_description,
        arguments: dealerProductId,
      );
    } else {
      // Show login screen first, then navigate to dealer product
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        '🔗 Dealer Product Link',
        'Please login to view this dealer product',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Store the dealer product ID to navigate after login
      Get.find<TokenController>().pendingDealerProductId = dealerProductId;
    }
  }

  /// Create deep link for sharing
  static String createProductLink(String productId, {bool isDealer = false}) {
    if (isDealer) {
      return 'https://oldmarket.bhoomi.cloud/app/dealer/$productId';
    } else {
      return 'https://oldmarket.bhoomi.cloud/app/product/$productId';
    }
  }

  /// Create custom scheme link (for app-to-app)
  static String createCustomSchemeLink(
    String productId, {
    bool isDealer = false,
  }) {
    if (isDealer) {
      return 'oldmarket://dealer/$productId';
    } else {
      return 'oldmarket://product/$productId';
    }
  }

  /// Dispose resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
