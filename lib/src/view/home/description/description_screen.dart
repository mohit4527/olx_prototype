import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:olx_prototype/src/controller/chat_controller.dart';
import 'package:olx_prototype/src/controller/description_controller.dart';
// ...existing imports...
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/all_products_controller.dart';
import '../../../controller/book_test_drive_controller.dart';
import '../../../controller/user_make_offer_controller.dart';
import '../../../controller/user_wishlist_controller.dart';
import '../../../custom_widgets/desription_screen_card.dart';
import '../../../custom_widgets/share_products_bottomsheet.dart';
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
  // ChatController is registered in initState; no local field required
  final PageController _pageController = PageController();
  final wishlistController = Get.put(UserWishlistController());

  @override
  void initState() {
    super.initState();
    controller = Get.put(DescriptionController());
    makeOfferController = Get.put(MakeOfferController());
    productcontroller = Get.put(ProductController());
    bookTestDriveController = Get.put(BookTestDriveController());
    Get.put(ChatController());
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
      final cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar('Error', 'Phone number not available');
        return;
      }

      // Normalize: if 10 digits assume India and prefix with +91 for dialing
      String dialNumber = cleaned;
      if (cleaned.length == 10) {
        dialNumber = '+91$cleaned';
      } else if (!cleaned.startsWith('+') &&
          cleaned.length > 10 &&
          !cleaned.startsWith('0')) {
        // if already contains country code e.g. 9198..., add +
        dialNumber = '+$cleaned';
      } else if (cleaned.startsWith('0')) {
        // strip leading zero and prefix +91
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) dialNumber = '+91$stripped';
      }

      final uri = Uri(scheme: 'tel', path: dialNumber);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Unable to open dialer');
      }
    } catch (e) {
      print('[DescriptionScreen] _openDialer error: $e');
      Get.snackbar('Error', 'Unable to open dialer');
    }
  }

  // legacy helper removed — using _shareOnWhatsApp for sharing text to WhatsApp

  /// Share a message on WhatsApp so the user can pick any contact to send to.
  Future<void> _shareOnWhatsApp(String message) async {
    try {
      final encoded = Uri.encodeComponent(message);
      // Try whatsapp:// with text first (some platforms support text param)
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

      // Final fallback: open system share sheet
      Get.snackbar('Error', 'WhatsApp not available');
    } catch (e) {
      print('[DescriptionScreen] _shareOnWhatsApp error: $e');
      Get.snackbar('Error', 'Unable to share on WhatsApp');
    }
  }

  /// Open WhatsApp chat directly with a specific phone number (uploader's number).
  Future<void> _openWhatsAppChat(String rawPhone, String message) async {
    try {
      final cleaned = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleaned.isEmpty) {
        Get.snackbar('Error', 'WhatsApp number not available');
        return;
      }

      // Build international number without '+' for WhatsApp API
      String waNumber = cleaned;
      if (cleaned.length == 10) {
        waNumber = '91$cleaned';
      } else if (cleaned.startsWith('0')) {
        final stripped = cleaned.replaceFirst(RegExp(r'^0+'), '');
        if (stripped.length == 10) waNumber = '91$stripped';
      } else if (cleaned.startsWith('+')) {
        waNumber = cleaned.replaceFirst('+', '');
      }

      final encoded = Uri.encodeComponent(message);
      final uriApp = Uri.parse('whatsapp://send?phone=$waNumber&text=$encoded');
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }

      final uriWeb = Uri.parse(
        'https://api.whatsapp.com/send?phone=$waNumber&text=$encoded',
      );
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        return;
      }

      Get.snackbar('Error', 'WhatsApp not available');
    } catch (e) {
      print('[DescriptionScreen] _openWhatsAppChat error: $e');
      Get.snackbar('Error', 'Unable to open WhatsApp');
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
          onPressed: () => Get.back(),
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
                    return SizedBox(
                      height: AppSizer().height30,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: product.mediaUrl.length,
                        itemBuilder: (context, imageIndex) {
                          final raw = product.mediaUrl[imageIndex];
                          final imagePath = raw.replaceAll('\\', '/');
                          final url =
                              'https://oldmarket.bhoomi.cloud/$imagePath';
                          return ClipRRect(
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
                          );
                        },
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

                  // User id
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    return Text(
                      "User Id: ${product.id}",
                      style: TextStyle(
                        fontSize: AppSizer().fontSize16,
                        fontWeight: FontWeight.w600,
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
                              onPressed: () {
                                Get.bottomSheet(
                                  ShareBottomSheet(productId: product.id),
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                );
                              },
                              icon: Icon(Icons.share),
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
                      return InkWell(
                        onTap: () {
                          makeOfferController.showMakeOfferDialog(
                            productId: product.id,
                            buyerId: product.userId ?? "",
                            sellerId: '',
                          );
                        },
                        child: Container(
                          height: AppSizer().height5,
                          width: AppSizer().width40,
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
                                size: 25,
                              ),
                              SizedBox(width: AppSizer().width3),
                              Text(
                                "Make Offer",
                                style: TextStyle(color: AppColors.appWhite),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],

                  SizedBox(height: AppSizer().height1),

                  // Title
                  Obx(() {
                    if (controller.product.value == null)
                      return const SizedBox();
                    final product = controller.product.value!;
                    return Text(
                      product.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: AppSizer().fontSize17,
                      ),
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
                        Text(
                          '${product.city}, ${product.state}, ${product.country}',
                          style: TextStyle(
                            color: AppColors.appGrey.shade700,
                            fontSize: AppSizer().fontSize16,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.alarm,
                              color: AppColors.appGrey.shade700,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              timeAgo,
                              style: TextStyle(
                                color: AppColors.appGrey.shade700,
                                fontSize: AppSizer().fontSize16,
                              ),
                            ),
                          ],
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
                              await controller.ensureUploaderContact();
                              // Prefer uploader phone resolved by controller, else fallback
                              final phoneNumber =
                                  controller.uploaderPhone.value.isNotEmpty
                                  ? controller.uploaderPhone.value
                                  : (controller.product.value?.phoneNumber ??
                                        controller.product.value?.whatsapp ??
                                        "");
                              await _openDialer(phoneNumber);
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
                                  Text(
                                    "Call",
                                    style: TextStyle(color: AppColors.appWhite),
                                  ),
                                  SizedBox(width: AppSizer().width3),
                                  Icon(Icons.phone, color: AppColors.appWhite),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: AppSizer().width3),

                        // WhatsApp
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await controller.ensureUploaderContact();
                              final prod = controller.product.value;
                              final shareUrl =
                                  "http://oldmarket.bhoomi.cloud/product/${prod?.id ?? widget.productId}";
                              final message =
                                  "Hi, I'm interested in this product: ${prod?.title ?? ''}\n$shareUrl";
                              final phone =
                                  controller.uploaderWhatsApp.value.isNotEmpty
                                  ? controller.uploaderWhatsApp.value
                                  : (prod?.phoneNumber ?? prod?.whatsapp ?? '');
                              // Open direct WhatsApp chat with uploader's number if available,
                              // otherwise fallback to share-to-any-contact.
                              if (phone.isNotEmpty) {
                                await _openWhatsAppChat(phone, message);
                              } else {
                                await _shareOnWhatsApp(message);
                              }
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
                                  Text(
                                    "Go To Whatsapp",
                                    style: TextStyle(color: AppColors.appWhite),
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
                  SizedBox(height: AppSizer().height2),
                  // Book test drive bottom sheet
                  InkWell(
                    onTap: () {
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                          LengthLimitingTextInputFormatter(10),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                  bookController.bookTestDrive(
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
                                              : const Icon(Icons.check_circle),
                                          label: const Text("Book Now"),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.appGreen,
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
                          Icon(Icons.directions_car, color: AppColors.appWhite),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),
                  Obx(() {
                    final product = controller.product.value;
                    if (product == null) return const SizedBox();

                    final prodUserId = product.userId ?? '';
                    final curUserId = controller.currentUserId.value;

                    // If we have the logged-in user id and it's equal to the product owner,
                    // hide the Send Message button (owner shouldn't message themselves).
                    if (curUserId.isNotEmpty && prodUserId == curUserId) {
                      return const SizedBox();
                    }

                    final bool isEnabled = prodUserId.isNotEmpty;

                    return InkWell(
                      onTap: () {
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

                  SizedBox(height: AppSizer().height2),
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
}
