import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/chat_controller.dart';
import 'package:olx_prototype/src/controller/description_controller.dart';
import 'package:olx_prototype/src/utils/app_routes.dart';
// ...existing imports...
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../../../controller/all_products_controller.dart';
import '../../../controller/book_test_drive_controller.dart';
import '../../../controller/user_make_offer_controller.dart';
import '../../../controller/user_wishlist_controller.dart';
import '../../../controller/product_boost_controller.dart';
import '../../../controller/token_controller.dart';
import '../../../controller/comment_controller.dart';
import '../../../custom_widgets/desription_screen_card.dart';
import '../../../custom_widgets/comment_section_widget.dart';
import '../../../services/phone_resolver_service.dart';

// ...existing imports...

class DescriptionScreen extends StatefulWidget {
  final String productId;
  final String sellerId;
  final String sellerName;
  final String carId;
  final bool fromVideo;

  DescriptionScreen({
    super.key,
    required this.productId,
    required this.sellerId,
    required this.sellerName,
    required this.carId,
    this.fromVideo = false,
  });

  @override
  State<DescriptionScreen> createState() => _DescriptionScreenState();
}

class _DescriptionScreenState extends State<DescriptionScreen> {
  late final DescriptionController controller;
  late final MakeOfferController makeOfferController;
  late final ProductController productcontroller;
  late final BookTestDriveController bookTestDriveController;
  late final ProductBoostController boostController;
  late final TokenController tokenController;
  late final CommentController commentController;
  // ChatController is registered in initState; no local field required
  final PageController _pageController = PageController();
  final wishlistController = Get.put(UserWishlistController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(DescriptionController());
    makeOfferController = Get.put(MakeOfferController());
    productcontroller = Get.put(ProductController());
    boostController = Get.put(ProductBoostController());
    tokenController = Get.find<TokenController>();
    commentController = Get.put(CommentController());
    bookTestDriveController = Get.put(BookTestDriveController());
    // Use Get.find if already exists, otherwise create new
    try {
      Get.find<ChatController>();
    } catch (e) {
      Get.put(ChatController());
    }
    // Debug: log that DescriptionScreen initState ran with the carId
    print('[DescriptionScreen] initState called for carId: ${widget.carId}');
    // debug snackbar removed - no visual debug feedback shown now
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch product when screen opens or when the requested carId differs
      // from the already loaded product in the shared controller.
      if (controller.product.value == null ||
          controller.product.value?.id != widget.carId) {
        controller.fetchProductById(widget.carId);
      }
    });
  }

  Future<void> _openDialer(String phoneNumber) async {
    try {
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar('Error', 'Phone number not available');
        return;
      }

      // 🔥 Debug device info
      print('[DescriptionScreen] 🔥 DEVICE CALL DEBUG:');
      print('[DescriptionScreen] Original phone: $phoneNumber');
      print('[DescriptionScreen] Cleaned phone: $cleaned');

      // Normalize phone number for India
      String dialNumber = cleaned;
      if (cleaned.length == 10) {
        dialNumber = '+91$cleaned';
      } else if (!cleaned.startsWith('+') && cleaned.length > 10) {
        dialNumber = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) dialNumber = '+91$stripped';
      }

      // Show connecting message first
      Get.snackbar(
        "📞 Calling...",
        "Connecting to: $dialNumber",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        duration: const Duration(seconds: 2),
      );

      // 🔥 Multiple call attempts with different methods
      print('[DescriptionScreen] Attempting to call: $dialNumber');

      bool callSuccess = false;

      // METHOD 1: Standard tel: URI
      try {
        final uri = Uri(scheme: 'tel', path: dialNumber);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          callSuccess = true;
          print('[DescriptionScreen] ✅ Call launched with tel: URI');
        }
      } catch (e) {
        print('[DescriptionScreen] ❌ Tel URI failed: $e');
      }

      // METHOD 2: Try with different launch modes
      if (!callSuccess) {
        try {
          final uri = Uri.parse('tel:$dialNumber');
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          callSuccess = true;
          print(
            '[DescriptionScreen] ✅ Call launched with platformDefault mode',
          );
        } catch (e) {
          print('[DescriptionScreen] ❌ PlatformDefault mode failed: $e');
        }
      }

      // METHOD 3: Try system call intent
      if (!callSuccess) {
        try {
          final uri = Uri.parse('tel:$dialNumber');
          await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          callSuccess = true;
          print('[DescriptionScreen] ✅ Call launched with external app mode');
        } catch (e) {
          print('[DescriptionScreen] ❌ External app mode failed: $e');
        }
      }

      if (!callSuccess) {
        // Final fallback: Multiple options for user
        await Clipboard.setData(ClipboardData(text: dialNumber));

        Get.defaultDialog(
          title: "📞 Make Call",
          titleStyle: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Phone: $dialNumber",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 16),
              Text(
                "Number copied to clipboard!",
                style: TextStyle(color: Colors.blue.shade600),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      Get.back();
                      try {
                        // Force launch with different method
                        await launchUrl(
                          Uri.parse('tel:$dialNumber'),
                          mode: LaunchMode.platformDefault,
                        );
                      } catch (e) {
                        print('[Call] Force launch failed: $e');
                        Get.snackbar(
                          'Info',
                          'Please open dialer manually and call $dialNumber',
                        );
                      }
                    },
                    icon: Icon(Icons.phone, size: 16),
                    label: Text("Try Call"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        '📋 Copied',
                        'Open your phone dialer and paste: $dialNumber',
                        duration: Duration(seconds: 4),
                      );
                    },
                    icon: Icon(Icons.content_copy, size: 16),
                    label: Text("Copy"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: Text("Cancel")),
          ],
        );
      }
    } catch (e) {
      print('[DescriptionScreen] _openDialer error: $e');
      Get.snackbar(
        "❌ Call Error",
        "Cannot make call. Please dial $phoneNumber manually.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // 📸 Full Screen Image Gallery Method
  void _showFullScreenImages(List<String> imageUrls, int initialIndex) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Get.back(),
          ),
        ),
        body: PageView.builder(
          controller: PageController(initialPage: initialIndex),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final raw = imageUrls[index];
            final imagePath = raw.replaceAll('\\', '/');
            final url = 'https://oldmarket.bhoomi.cloud/$imagePath';

            return Container(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/images/placeholder.jpg',
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      fullscreenDialog: true,
    );
  }

  // legacy helper removed — using _shareOnWhatsApp for sharing text to WhatsApp

  /// Share a message on WhatsApp with product image
  Future<void> _shareOnWhatsApp(String message) async {
    try {
      // Show loading indicator
      Get.snackbar(
        "Sharing...",
        "Preparing product image for WhatsApp",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Try to get product image and share with image
      final imageShared = await _shareWithProductImage(message);

      if (!imageShared) {
        // Fallback to text-only sharing
        await _shareTextOnlyWhatsApp(message);
      }
    } catch (e) {
      print('[DescriptionScreen] _shareOnWhatsApp error: $e');
      await _shareTextOnlyWhatsApp(message);
    }
  }

  /// Share with product image
  Future<bool> _shareWithProductImage(String message) async {
    try {
      final product = controller.product.value;
      if (product?.mediaUrl.isNotEmpty == true) {
        String imageUrl = product!.mediaUrl.first;
        if (!imageUrl.startsWith('http')) {
          imageUrl = 'https://oldmarket.bhoomi.cloud/$imageUrl';
        }

        // Download image
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/product_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          await file.writeAsBytes(response.bodyBytes);

          // Share with image
          await Share.shareXFiles(
            [XFile(file.path)],
            text: message,
            subject: 'Check out this product on Old Market!',
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error sharing with image: $e');
      return false;
    }
  }

  /// Share product via native share dialog (NOT WhatsApp specific)
  Future<void> _shareProductDirectly(dynamic product) async {
    try {
      print(
        '[Share] 📤 Opening native share dialog for product: ${product.title}',
      );

      // Show preparing message
      Get.snackbar(
        "📤 Preparing Share",
        "Getting product details ready for sharing...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Create rich sharing message for general sharing
      String shareMessage = '🛍️ Check out this amazing product!\n\n';
      shareMessage += '📦 *${product.title}*\n';
      shareMessage += '💰 Price: *₹${product.price}*\n';
      if (product.city != null && product.city.isNotEmpty) {
        shareMessage += '📍 Location: *${product.city}*\n';
      }
      if (product.description != null && product.description.isNotEmpty) {
        final shortDesc = product.description.length > 100
            ? '${product.description.substring(0, 100)}...'
            : product.description;
        shareMessage += '📝 ${shortDesc}\n';
      }
      shareMessage +=
          '\n🔗 View details: https://oldmarket.bhoomi.cloud/app/product/${product.id}\n';
      shareMessage +=
          '\n📱 Get the Old Market app for the best shopping experience!';

      // Try to share with product image using native share
      final imageShared = await _shareWithProductImage(shareMessage);

      if (!imageShared) {
        // Fallback to text-only sharing
        await Share.share(
          shareMessage,
          subject: 'Check out this product on Old Market!',
        );
      }
    } catch (e) {
      print('[DescriptionScreen] _shareProductDirectly error: $e');
      // Final fallback
      await Share.share(
        'Check out this product: https://oldmarket.bhoomi.cloud/app/product/${product.id}',
        subject: 'Check out this product on Old Market!',
      );
    }
  }

  /// Text-only WhatsApp sharing fallback
  Future<void> _shareTextOnlyWhatsApp(String message) async {
    try {
      final encoded = Uri.encodeComponent(message);
      // Try whatsapp:// with text first
      final uriApp = Uri.parse('whatsapp://send?text=$encoded');
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }

      // Fallback to WhatsApp web share
      final uriWeb = Uri.parse('https://api.whatsapp.com/send?text=$encoded');
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        return;
      }

      // Final fallback: system share
      await Share.share(message);
    } catch (e) {
      Get.snackbar('Error', 'Unable to share on WhatsApp');
    }
  }

  /// Direct WhatsApp messaging to seller (no image sharing)
  Future<void> _openWhatsAppChat(String rawPhone, String message) async {
    try {
      print('[WhatsApp] � Opening direct seller messaging...');

      final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar(
          '❌ Invalid Number',
          'Seller WhatsApp number not available',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Build international number for WhatsApp
      String waNumber = cleaned;
      if (cleaned.length == 10) {
        waNumber = '91$cleaned';
      } else if (cleaned.startsWith('0')) {
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) waNumber = '91$stripped';
      } else if (cleaned.startsWith('+')) {
        waNumber = cleaned.replaceFirst('+', '');
      }

      print('[WhatsApp] � Messaging seller at: $waNumber');

      // Direct WhatsApp message to seller
      final encoded = Uri.encodeComponent(message);
      final uriApp = Uri.parse('whatsapp://send?phone=$waNumber&text=$encoded');

      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        print('[WhatsApp] ✅ WhatsApp app opened for seller chat');

        Get.snackbar(
          "💬 WhatsApp Opened",
          "Direct messaging with seller: $rawPhone",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // Try WhatsApp web fallback
      final uriWeb = Uri.parse(
        'https://api.whatsapp.com/send?phone=$waNumber&text=$encoded',
      );
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        print('[WhatsApp] ✅ WhatsApp web opened for seller chat');

        Get.snackbar(
          "💬 WhatsApp Web Opened",
          "Direct messaging with seller: $rawPhone",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // If WhatsApp not available
      Get.snackbar(
        '❌ WhatsApp Not Available',
        'WhatsApp is not installed on this device',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('[WhatsApp] Error opening seller chat: $e');
      Get.snackbar(
        '❌ WhatsApp Error',
        'Unable to open WhatsApp for messaging. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Debug: log when build executes
    print(
      '[DescriptionScreen] build start for carId: ${widget.carId}, mounted: ${mounted}',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: Text(
          "Product Description...",
          style: TextStyle(color: AppColors.appWhite),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
          icon: Icon(Icons.arrow_back, color: AppColors.appWhite),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [Colors.black, Colors.grey.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [AppColors.appGreen, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizer().height1),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.product.value == null) {
                      return const Center(child: Text("No products found"));
                    }
                    final product = controller.product.value!;
                    if (product.mediaUrl.isEmpty) {
                      return SizedBox(
                        height: AppSizer().height30,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/placeholder.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                    return GestureDetector(
                      onTap: () => _showFullScreenImages(product.mediaUrl, 0),
                      child: SizedBox(
                        height: AppSizer().height30,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: product.mediaUrl.length,
                          itemBuilder: (context, imageIndex) {
                            final raw = product.mediaUrl[imageIndex];
                            final imagePath = raw.replaceAll('\\', '/');
                            final url =
                                'https://oldmarket.bhoomi.cloud/$imagePath';
                            return GestureDetector(
                              onTap: () => _showFullScreenImages(
                                product.mediaUrl,
                                imageIndex,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/placeholder.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: AppSizer().height2),
                  // Page indicator
                  Center(
                    child: Obx(() {
                      if (controller.isLoading.value ||
                          controller.product.value == null) {
                        return const SizedBox();
                      }

                      final product = controller.product.value!;
                      if (product.mediaUrl.length <= 1) return const SizedBox();

                      return SmoothPageIndicator(
                        controller: _pageController,
                        count: product.mediaUrl.length,
                        effect: SlideEffect(
                          dotHeight: 4,
                          dotWidth: AppSizer().width5,
                          radius: 2,
                          spacing: AppSizer().height1,
                          dotColor: Colors.grey,
                          activeDotColor: AppColors.appGreen,
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: AppSizer().height3),

                  // Enhanced User Profile Section
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    final userId = product.userId ?? '';

                    // 🆕 Use API-fetched uploader profile data
                    String userName = controller.uploaderName.value.isNotEmpty
                        ? controller.uploaderName.value
                        : (widget.sellerName.isNotEmpty
                              ? widget.sellerName
                              : 'Seller');

                    String userAvatar = controller.uploaderImage.value;
                    int productCount = controller.uploaderProductCount.value;
                    int videoCount = controller.uploaderVideoCount.value;

                    // Show loading indicator if profile is still being fetched
                    bool isProfileLoading =
                        controller.uploaderName.value.isEmpty &&
                        controller.isLoading.value;

                    print(
                      '[ProfileCard] 🎯 Profile data: name=$userName, avatar=$userAvatar, products=$productCount, videos=$videoCount',
                    );

                    // Fallback to old logic if API data not loaded yet
                    if (controller.uploaderName.value.isEmpty) {
                      if (widget.sellerName.isEmpty && userId.isNotEmpty) {
                        // Create a readable username from userId
                        if (userId.length > 12) {
                          userName =
                              'User ${userId.substring(userId.length - 8)}';
                        } else if (userId.length > 6) {
                          userName = 'User ${userId.substring(0, 6)}';
                        } else {
                          userName = 'User $userId';
                        }
                      }

                      // If no seller name and no userId, use product title as context
                      if (userName == 'Seller' && product.title.isNotEmpty) {
                        userName = '${product.title} Seller';
                      }
                    }

                    return GestureDetector(
                      onTap: () {
                        if (userId.isNotEmpty) {
                          // Navigate to seller products screen with profile mode
                          Get.toNamed(
                            '/ads_screen',
                            arguments: {
                              'profileUserId': userId,
                              'profileName': userName,
                              'profileAvatar': userAvatar,
                            },
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: AppSizer().height1,
                        ),
                        padding: EdgeInsets.all(AppSizer().height2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.appGreen.withOpacity(0.1),
                              Colors.white,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.appGreen.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.appGreen.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Enhanced Profile Avatar
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.appGreen,
                                    AppColors.appGreen.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.appGreen.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                backgroundImage: userAvatar.isNotEmpty
                                    ? NetworkImage(userAvatar)
                                    : null,
                                child: userAvatar.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            SizedBox(width: AppSizer().width4),
                            // Enhanced User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        color: AppColors.appGreen,
                                        size: 20,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: isProfileLoading
                                            ? Row(
                                                children: [
                                                  SizedBox(
                                                    width: 12,
                                                    height: 12,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 1.5,
                                                          color: AppColors
                                                              .appGreen,
                                                        ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Loading profile...',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppSizer().fontSize14,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Text(
                                                userName,
                                                style: TextStyle(
                                                  fontSize:
                                                      AppSizer().fontSize17,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors
                                                      .appGreen
                                                      .shade800,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),

                                  // Show dealer badge if it's a dealer profile
                                  Obx(() {
                                    final isDealerProfile =
                                        controller.isDealer.value ||
                                        userName.contains('Dealer') ||
                                        userName.contains('Business') ||
                                        userName.contains('Store') ||
                                        userName.contains('Shop') ||
                                        productCount >
                                            5; // If seller has many products, likely a dealer

                                    return isDealerProfile
                                        ? Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: Colors.orange.shade300,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.verified_user,
                                                  size: 12,
                                                  color: Colors.orange.shade700,
                                                ),
                                                SizedBox(width: 3),
                                                Text(
                                                  'Dealer',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppSizer().fontSize12,
                                                    color:
                                                        Colors.orange.shade700,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink();
                                  }),

                                  SizedBox(height: 6),

                                  // Enhanced stats row
                                  if (productCount > 0 || videoCount > 0)
                                    Row(
                                      children: [
                                        if (productCount > 0) ...[
                                          Icon(
                                            Icons.inventory,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            '$productCount products',
                                            style: TextStyle(
                                              fontSize: AppSizer().fontSize12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                        if (productCount > 0 && videoCount > 0)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              '•',
                                              style: TextStyle(
                                                color: Colors.grey.shade400,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        if (videoCount > 0) ...[
                                          Icon(
                                            Icons.videocam,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          SizedBox(width: 3),
                                          Text(
                                            '$videoCount videos',
                                            style: TextStyle(
                                              fontSize: AppSizer().fontSize12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),

                                  SizedBox(height: 4),
                                  Text(
                                    "View full user details",
                                    style: TextStyle(
                                      fontSize: AppSizer()
                                          .fontSize15, // Slightly smaller - reduced to fontSize15
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight
                                          .w500, // Added slight bold weight
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Enhanced arrow with background
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.appGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.appGreen,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: AppSizer().height1),

                  // Price and icons
                  Obx(() {
                    if (controller.product.value == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final product = controller.product.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₹ ${product!.price}",
                          style: TextStyle(
                            fontSize: AppSizer().fontSize19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          children: [
                            Obx(() {
                              final isWishlisted = wishlistController
                                  .isInWishlist(product.id);

                              return IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                  color: isWishlisted
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                                onPressed: () {
                                  wishlistController.toggleWishlist(product.id);
                                },
                              );
                            }),

                            IconButton(
                              onPressed: () async {
                                print(
                                  '[Share] 📤 Share button pressed for product: ${product.title}',
                                );

                                // Show share dialog with multiple options
                                await _shareProductDirectly(product);
                              },
                              icon: Icon(Icons.share),
                            ),

                            // Comment Icon Button
                            IconButton(
                              onPressed: () {
                                _showCommentsBottomSheet(product.id);
                              },
                              icon: Icon(
                                Icons.comment_outlined,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  if (!widget.fromVideo) ...[
                    SizedBox(height: AppSizer().height1),
                    Obx(() {
                      if (controller.product.value == null)
                        return const SizedBox();
                      final product = controller.product.value!;
                      final currentUserId = tokenController.userUid.value;
                      final isOwner = product.userId == currentUserId;
                      final canBoost = isOwner && !product.isBoosted;
                      final isSoldOut = product.status == false;

                      // Hide action buttons if product is sold out
                      if (isSoldOut) {
                        return const SizedBox();
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                // Check if user is logged in
                                if (!tokenController.isLoggedIn) {
                                  Get.snackbar(
                                    "Login Required",
                                    "Please login first",
                                    backgroundColor: AppColors.appRed,
                                    colorText: Colors.white,
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                  Get.toNamed(AppRoutes.login);
                                  return;
                                }

                                // Get logged-in user's ID
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final loggedInUserId =
                                    prefs.getString('userId') ??
                                    prefs.getString('user_uid') ??
                                    '';

                                makeOfferController.showMakeOfferDialog(
                                  productId: product.id,
                                  buyerId: loggedInUserId,
                                  sellerId: product.userId ?? "",
                                );
                              },
                              child: Container(
                                height: AppSizer().height5,
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      color: AppColors.appWhite,
                                      size: 22,
                                    ),
                                    SizedBox(width: AppSizer().width2),
                                    Text(
                                      "Make Offer",
                                      style: TextStyle(
                                        color: AppColors.appWhite,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (canBoost) ...[
                            SizedBox(width: AppSizer().width2),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  // Check if user is logged in
                                  if (!tokenController.isLoggedIn) {
                                    Get.snackbar(
                                      "Login Required",
                                      "Please login first",
                                      backgroundColor: AppColors.appRed,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    Get.toNamed(AppRoutes.login);
                                    return;
                                  }

                                  boostController.startBoostPayment(product.id);
                                },
                                child: Container(
                                  height: AppSizer().height5,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.orange.shade600,
                                        Colors.deepOrange,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.rocket_launch,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      SizedBox(width: AppSizer().width2),
                                      Text(
                                        "Boost",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    }),
                  ],

                  SizedBox(height: AppSizer().height1),

                  // Title with Boosted Badge and Sold Out Badge
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    final isSoldOut = product.status == false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: AppSizer().fontSize17,
                          ),
                        ),
                        SizedBox(height: AppSizer().height1),

                        // Sold Out Badge (if product is sold out)
                        if (isSoldOut) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.block,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'SOLD OUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSizer().height1),
                          // Product Not Available Message
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.red.shade700,
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'This product is not available',
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Boosted Badge (if product is boosted and NOT sold out)
                        if (product.isBoosted && !isSoldOut) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade600,
                                  Colors.deepOrange,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.rocket_launch,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'BOOSTED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  }),

                  SizedBox(height: AppSizer().height1),

                  // Location + time
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    final createdAt =
                        product.createdAt != null &&
                            product.createdAt!.isNotEmpty
                        ? DateTime.tryParse(product.createdAt!)
                        : null;
                    String timeAgo = '';
                    if (createdAt != null)
                      timeAgo = timeago.format(createdAt, locale: 'en');

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${product.city}, ${product.state}, ${product.country}',
                            style: TextStyle(
                              color: AppColors.appGrey.shade700,
                              fontSize: AppSizer().fontSize16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.alarm,
                                color: AppColors.appGrey.shade700,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  timeAgo,
                                  style: TextStyle(
                                    color: AppColors.appGrey.shade700,
                                    fontSize: AppSizer().fontSize16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),

                  SizedBox(height: AppSizer().height2),

                  // Description
                  Text(
                    "Description..",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Divider(color: AppColors.appGreen, thickness: 1.5),
                  SizedBox(height: AppSizer().height2),

                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.description,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize17,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    );
                  }),
                  if (!widget.fromVideo) ...[
                    SizedBox(height: AppSizer().height2),
                    Obx(() {
                      if (controller.product.value == null)
                        return const SizedBox();
                      final product = controller.product.value!;
                      final isSoldOut = product.status == false;

                      // Hide contact section if product is sold out
                      if (isSoldOut) {
                        return const SizedBox();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Contact me - ",
                            style: TextStyle(
                              fontSize: AppSizer().fontSize17,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: AppSizer().height4),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // Check if user is logged in
                                    if (!tokenController.isLoggedIn) {
                                      Get.snackbar(
                                        "Login Required",
                                        "Please login first",
                                        backgroundColor: AppColors.appRed,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      Get.toNamed(AppRoutes.login);
                                      return;
                                    }

                                    print(
                                      '[Call] 🔥 CALL BUTTON PRESSED - Starting process...',
                                    );

                                    // Check if call functionality is available
                                    try {
                                      final testUri = Uri.parse(
                                        'tel:+919999999999',
                                      );
                                      final canCall = await canLaunchUrl(
                                        testUri,
                                      );
                                      print(
                                        '[Call] Device can launch tel: URLs: $canCall',
                                      );
                                    } catch (e) {
                                      print(
                                        '[Call] Call capability check failed: $e',
                                      );
                                    }

                                    // Show loading
                                    Get.snackbar(
                                      '📞 Getting Phone Number...',
                                      'Please wait while we fetch contact details',
                                    );

                                    await controller.ensureUploaderContact();

                                    // Prefer uploader phone resolved by controller, else fallback
                                    String phoneNumber =
                                        controller
                                            .uploaderPhone
                                            .value
                                            .isNotEmpty
                                        ? controller.uploaderPhone.value
                                        : (controller
                                                  .product
                                                  .value
                                                  ?.phoneNumber ??
                                              controller
                                                  .product
                                                  .value
                                                  ?.whatsapp ??
                                              "");

                                    // 🔥 Enhanced debug logging
                                    print(
                                      '[Call] ========== CALL DEBUG INFO ==========',
                                    );
                                    print(
                                      '[Call] Product ID: ${controller.product.value?.id}',
                                    );
                                    print(
                                      '[Call] Product userId: ${controller.product.value?.userId}',
                                    );
                                    print(
                                      '[Call] Product phoneNumber: ${controller.product.value?.phoneNumber}',
                                    );
                                    print(
                                      '[Call] Product whatsapp: ${controller.product.value?.whatsapp}',
                                    );
                                    print(
                                      '[Call] Controller uploaderPhone: ${controller.uploaderPhone.value}',
                                    );
                                    print(
                                      '[Call] Controller uploaderWhatsApp: ${controller.uploaderWhatsApp.value}',
                                    );
                                    print(
                                      '[Call] Initial phone to call: "$phoneNumber"',
                                    );

                                    // 🔥 EMERGENCY FALLBACK: If still no phone, try direct resolution
                                    if (phoneNumber.isEmpty &&
                                        controller.product.value?.userId !=
                                            null) {
                                      print(
                                        '[Call] 🚨 EMERGENCY: No phone found, trying PhoneResolverService...',
                                      );
                                      Get.snackbar(
                                        '🔍 Searching...',
                                        'Trying alternative methods to find contact',
                                      );

                                      final emergencyPhone =
                                          await PhoneResolverService.resolvePhoneForUser(
                                            controller.product.value!.userId!,
                                          );

                                      if (emergencyPhone != null &&
                                          emergencyPhone.isNotEmpty) {
                                        phoneNumber = emergencyPhone;
                                        print(
                                          '[Call] 🎉 EMERGENCY SUCCESS: Found phone: $phoneNumber',
                                        );
                                        Get.snackbar(
                                          '✅ Found!',
                                          'Contact number retrieved successfully',
                                        );
                                      } else {
                                        print(
                                          '[Call] 💥 EMERGENCY FAILED: Still no phone found',
                                        );
                                      }
                                    }

                                    print(
                                      '[Call] Final phone to call: "$phoneNumber"',
                                    );
                                    print(
                                      '[Call] ====================================',
                                    );

                                    if (phoneNumber.isEmpty ||
                                        phoneNumber == "null") {
                                      Get.snackbar(
                                        '❌ No Phone Number',
                                        'Contact number not available for this product.\nTry contacting through WhatsApp instead.',
                                        duration: Duration(seconds: 4),
                                      );
                                      return;
                                    }

                                    await _openDialer(phoneNumber);
                                  },
                                  child: Container(
                                    height: AppSizer().height5,
                                    decoration: BoxDecoration(
                                      color: AppColors.appGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Call",
                                          style: TextStyle(
                                            color: AppColors.appWhite,
                                          ),
                                        ),
                                        SizedBox(width: AppSizer().width3),
                                        Icon(
                                          Icons.phone,
                                          color: AppColors.appWhite,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(width: AppSizer().width3),

                              // WhatsApp - Direct messaging to seller
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    // Check if user is logged in
                                    if (!tokenController.isLoggedIn) {
                                      Get.snackbar(
                                        "Login Required",
                                        "Please login first",
                                        backgroundColor: AppColors.appRed,
                                        colorText: Colors.white,
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                      Get.toNamed(AppRoutes.login);
                                      return;
                                    }

                                    print(
                                      '[WhatsApp] � Direct seller messaging started...',
                                    );

                                    // Show loading
                                    Get.snackbar(
                                      '� Opening WhatsApp',
                                      'Connecting to seller for direct messaging...',
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 2),
                                    );

                                    await controller.ensureUploaderContact();

                                    // Get seller's phone number (same as call button)
                                    String phoneNumber =
                                        controller
                                            .uploaderPhone
                                            .value
                                            .isNotEmpty
                                        ? controller.uploaderPhone.value
                                        : (controller
                                                  .product
                                                  .value
                                                  ?.phoneNumber ??
                                              controller
                                                  .product
                                                  .value
                                                  ?.whatsapp ??
                                              "");

                                    print(
                                      '[WhatsApp] 📞 Seller phone: $phoneNumber',
                                    );

                                    // Emergency fallback
                                    if (phoneNumber.isEmpty &&
                                        controller.product.value?.userId !=
                                            null) {
                                      final emergencyPhone =
                                          await PhoneResolverService.resolvePhoneForUser(
                                            controller.product.value!.userId!,
                                          );

                                      if (emergencyPhone != null &&
                                          emergencyPhone.isNotEmpty) {
                                        phoneNumber = emergencyPhone;
                                        print(
                                          '[WhatsApp] ✅ Emergency contact found: $phoneNumber',
                                        );
                                      }
                                    }

                                    final prod = controller.product.value;

                                    // Create direct messaging text (buyer to seller)
                                    String message =
                                        "Hi! 👋 I'm interested in your product:\n\n";
                                    message +=
                                        "🛍️ *${prod?.title ?? 'Product'}*\n";
                                    if (prod?.price != null) {
                                      message += "💰 Price: ₹${prod!.price}\n";
                                    }
                                    message +=
                                        "\nIs this still available? I'd like to know more details.\n";
                                    message += "Thank you! 😊";

                                    // Direct WhatsApp chat with seller
                                    if (phoneNumber.isNotEmpty &&
                                        phoneNumber != "null") {
                                      print(
                                        '[WhatsApp] 🎯 Opening direct chat with seller: $phoneNumber',
                                      );
                                      await _openWhatsAppChat(
                                        phoneNumber,
                                        message,
                                      );
                                    } else {
                                      print(
                                        '[WhatsApp] ❌ No seller contact available',
                                      );
                                      Get.snackbar(
                                        '❌ No Contact Available',
                                        'Seller contact information not available for direct messaging.',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                        duration: Duration(seconds: 4),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: AppSizer().height5,
                                    decoration: BoxDecoration(
                                      color: AppColors.appGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "WhatsApp Chat",
                                          style: TextStyle(
                                            color: AppColors.appWhite,
                                          ),
                                        ),
                                        SizedBox(width: AppSizer().width3),
                                        Icon(
                                          FontAwesomeIcons.whatsapp,
                                          color: AppColors.appWhite,
                                          size: 25,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                  ],
                  SizedBox(height: AppSizer().height2),
                  // Book test drive bottom sheet
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    final isSoldOut = product.status == false;

                    // Hide book test drive if product is sold out
                    if (isSoldOut) {
                      return const SizedBox();
                    }

                    return InkWell(
                      onTap: () {
                        // Check if user is logged in
                        if (!tokenController.isLoggedIn) {
                          Get.snackbar(
                            "Login Required",
                            "Please login first",
                            backgroundColor: AppColors.appRed,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          Get.toNamed(AppRoutes.login);
                          return;
                        }

                        Get.bottomSheet(
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.appGradient,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 24,
                              ),
                              child: GetBuilder<BookTestDriveController>(
                                builder: (bookController) {
                                  return SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Text(
                                            "Book Test Drive",
                                            style: TextStyle(
                                              fontSize: AppSizer().fontSize18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSizer().height2),

                                        // Name
                                        TextFormField(
                                          controller:
                                              bookController.nameController,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.person,
                                              color: AppColors.appGreen,
                                            ),
                                            labelText: "Your Name",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Phone
                                        TextFormField(
                                          controller:
                                              bookController.phoneController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(
                                              10,
                                            ),
                                          ],
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.phone_android,
                                              color: AppColors.appGreen,
                                            ),
                                            labelText: "Phone Number",
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Date
                                        InkWell(
                                          onTap: () =>
                                              bookController.pickDate(context),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 12,
                                            ),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_month,
                                                  color: AppColors.appGreen,
                                                ),
                                                SizedBox(
                                                  width: AppSizer().width2,
                                                ),
                                                Text(
                                                  bookController.selectedDate !=
                                                          null
                                                      ? bookController
                                                            .formattedDate
                                                      : "Select Date",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Time
                                        InkWell(
                                          onTap: () =>
                                              bookController.pickTime(context),
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14,
                                              horizontal: 12,
                                            ),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                color: Colors.grey,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.alarm,
                                                  color: AppColors.appGreen,
                                                ),
                                                SizedBox(
                                                  width: AppSizer().width2,
                                                ),
                                                Text(
                                                  bookController.selectedTime !=
                                                          null
                                                      ? bookController
                                                            .selectedTime!
                                                            .format(context)
                                                      : "Select Time",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: AppSizer().height3),

                                        // Submit
                                        Obx(
                                          () => ElevatedButton.icon(
                                            onPressed:
                                                bookController.isLoading.value
                                                ? null
                                                : () {
                                                    final productId =
                                                        controller
                                                            .product
                                                            .value
                                                            ?.id ??
                                                        "";
                                                    bookController
                                                        .bookTestDrive(
                                                          productId,
                                                        );
                                                  },
                                            icon: bookController.isLoading.value
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.check_circle,
                                                  ),
                                            label: const Text("Book Now"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.appGreen,
                                              foregroundColor: Colors.white,
                                              minimumSize: const Size(
                                                double.infinity,
                                                48,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 24),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        height: AppSizer().height6,
                        decoration: BoxDecoration(
                          color: AppColors.appGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Book for Test Drive",
                              style: TextStyle(color: AppColors.appWhite),
                            ),
                            SizedBox(width: AppSizer().width3),
                            Icon(
                              Icons.directions_car,
                              color: AppColors.appWhite,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: AppSizer().height2),
                  Obx(() {
                    final product = controller.product.value;
                    if (product == null) return const SizedBox();

                    final prodUserId = product.userId ?? '';
                    final curUserId = controller.currentUserId.value;
                    final isSoldOut = product.status == false;

                    // Hide Send Message button if product is sold out
                    if (isSoldOut) {
                      return const SizedBox();
                    }

                    // If we have the logged-in user id and it's equal to the product owner,
                    // hide the Send Message button (owner shouldn't message themselves).
                    if (curUserId.isNotEmpty && prodUserId == curUserId) {
                      return const SizedBox();
                    }

                    final bool isEnabled = prodUserId.isNotEmpty;

                    return InkWell(
                      onTap: () {
                        // Check if user is logged in
                        if (!tokenController.isLoggedIn) {
                          Get.snackbar(
                            "Login Required",
                            "Please login first",
                            backgroundColor: AppColors.appRed,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          Get.toNamed(AppRoutes.login);
                          return;
                        }

                        if (!isEnabled) {
                          Get.snackbar(
                            "Error",
                            "Seller info unavailable for this product.",
                            backgroundColor: AppColors.appRed,
                            colorText: AppColors.appWhite,
                          );
                          return;
                        }

                        Get.find<ChatController>().startAndNavigateToChat(
                          productId: product.id,
                          productName: product.title,
                          sellerId: prodUserId,
                          productImage: product.mediaUrl.isNotEmpty
                              ? product.mediaUrl[0]
                              : null,
                          initialMessage:
                              "Hi, I'm interested in your ${product.title}. Is it still available?",
                          sellerName: prodUserId,
                        );
                      },
                      child: Container(
                        height: AppSizer().height6,
                        decoration: BoxDecoration(
                          color: isEnabled ? AppColors.appGreen : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Send Message",
                              style: TextStyle(color: AppColors.appWhite),
                            ),
                            SizedBox(width: AppSizer().width3),
                            const Icon(
                              Icons.message,
                              color: AppColors.appWhite,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  SizedBox(height: AppSizer().height3),
                  Text(
                    "More Products...",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),

                  Obx(() {
                    if (productcontroller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productcontroller.productList.isEmpty) {
                      return const Text("No more products found");
                    }

                    return SizedBox(
                      height: AppSizer().height29,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: productcontroller.productList.length,
                        itemBuilder: (context, index) {
                          final product = productcontroller.productList[index];
                          final imagePath = product.mediaUrl.isNotEmpty
                              ? product.mediaUrl[0]
                              : '';
                          final imageUrl = imagePath.isNotEmpty
                              ? "https://oldmarket.bhoomi.cloud/$imagePath"
                              : null;
                          final subtitle = product.location.city.isNotEmpty
                              ? product.location.city
                              : '';

                          return Container(
                            width: AppSizer().width48,
                            margin: EdgeInsets.only(right: AppSizer().width2),
                            decoration: BoxDecoration(
                              color: AppColors.appWhite,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.appBlack.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () async {
                                final targetId = product.id.toString();
                                // quick feedback to confirm the tap is received
                                Get.snackbar(
                                  'Opening',
                                  targetId,
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(milliseconds: 700),
                                );
                                try {
                                  await Future.delayed(
                                    const Duration(milliseconds: 80),
                                  );
                                  await Get.to(
                                    () => DescriptionScreen(
                                      carId: targetId,
                                      productId: '',
                                      sellerId: '',
                                      sellerName: '',
                                    ),
                                    preventDuplicates: false,
                                  );
                                } catch (e, st) {
                                  print(
                                    'Navigation error (description MoreProducts): $e\n$st',
                                  );
                                  Get.snackbar(
                                    'Navigation error',
                                    e.toString(),
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(5),
                                    ),
                                    child: imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            height: AppSizer().height21,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Image.asset(
                                                    "assets/images/placeholder.jpg",
                                                    height: AppSizer().height21,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                  );
                                                },
                                          )
                                        : Image.asset(
                                            "assets/images/placeholder.jpg",
                                            height: AppSizer().height21,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(AppSizer().height1),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: AppSizer().fontSize16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          subtitle,
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  SizedBox(height: AppSizer().height3),

                  Text(
                    "Products related to this item..",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Sponsored",
                    style: TextStyle(
                      color: AppColors.appGrey.shade700,
                      fontSize: AppSizer().fontSize19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),

                  Obx(() {
                    if (productcontroller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (productcontroller.productList.isEmpty) {
                      return const Text("No related products found");
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: productcontroller.productList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.70,
                          ),
                      itemBuilder: (context, index) {
                        final product = productcontroller.productList[index];

                        // ✅ Clean media URL
                        String? imageUrl;
                        if (product.mediaUrl.isNotEmpty &&
                            product.mediaUrl[0].isNotEmpty) {
                          final path = product.mediaUrl[0]
                              .replaceAll('\\', '/')
                              .trim();
                          imageUrl = path.startsWith('http')
                              ? path
                              : 'https://oldmarket.bhoomi.cloud/$path';
                        }

                        final subtitle = product.location.city.isNotEmpty
                            ? product.location.city
                            : '';

                        return CustomProductCard(
                          title: product.title,
                          subtitle: subtitle,
                          imageUrl: imageUrl,
                          onTap: () async {
                            final targetId = product.id.toString();
                            Get.snackbar(
                              'Opening',
                              targetId,
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(milliseconds: 700),
                            );
                            try {
                              await Future.delayed(
                                const Duration(milliseconds: 80),
                              );
                              await Get.to(
                                () => DescriptionScreen(
                                  carId: targetId,
                                  productId: '',
                                  sellerId: '',
                                  sellerName: '',
                                ),
                                preventDuplicates: false,
                              );
                            } catch (e, st) {
                              print(
                                'Navigation error (description related grid): $e\n$st',
                              );
                              Get.snackbar(
                                'Navigation error',
                                e.toString(),
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show Comments Bottom Sheet
  void _showCommentsBottomSheet(String productId) {
    Get.bottomSheet(
      DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizer().height2,
                    vertical: AppSizer().height1,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.comment, color: AppColors.appGreen),
                      SizedBox(width: 8),
                      Text(
                        'Comments',
                        style: TextStyle(
                          fontSize: AppSizer().fontSize18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1),

                // Comment Section
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: CommentSection(
                      targetId: productId,
                      isProduct: true,
                      commentController: commentController,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }
}
