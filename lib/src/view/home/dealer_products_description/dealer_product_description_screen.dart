import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../controller/dealer_product_description_controller.dart';
import '../../../controller/dealer_wishlist_controller.dart';
import '../../../controller/recently_viewed_controller.dart';
import '../../../controller/chat_controller.dart';
import '../../../model/recently_product_model/recently_product_model.dart';
import '../../../services/auth_service/auth_service.dart';
import '../dealer_detail/dealer_detail_screen.dart';

class DealerDescriptionScreen extends StatelessWidget {
  final String productId;

  DealerDescriptionScreen({super.key, required this.productId});

  /// Check if product has phone number available for calling/WhatsApp
  bool _hasPhoneNumber(dynamic product) {
    // Check arguments first (passed from dealer products list)
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      final passedPhone = arguments['phoneNumber'];
      if (passedPhone != null && passedPhone.toString().trim().isNotEmpty) {
        return true;
      }
    }

    // Check product data
    if (product?.phone != null && product.phone.toString().trim().isNotEmpty) {
      return true;
    }
    if (product?.dealerPhone != null &&
        product.dealerPhone.toString().trim().isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Handle both old format (String productId) and new format (Map with productId and phone)
    final arguments = Get.arguments;
    String actualProductId;
    String? phoneNumber;
    String? dealerName;
    String? sellerType;

    if (arguments is Map<String, dynamic>) {
      actualProductId = arguments['productId'] ?? productId;
      phoneNumber = arguments['phoneNumber'];
      dealerName = arguments['dealerName'];
      sellerType = arguments['sellerType'];
    } else {
      actualProductId = productId;
    }

    final controller = Get.put(
      DealerDescriptionController(
        productId: actualProductId,
        passedPhoneNumber: phoneNumber,
        passedDealerName: dealerName,
        passedSellerType: sellerType,
      ),
    );
    // Use Get.find if already exists, otherwise create new
    ChatController chatController;
    try {
      chatController = Get.find<ChatController>();
    } catch (e) {
      chatController = Get.put(ChatController());
    }
    final dealerWishlistController = Get.find<DealerWishlistController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        title: const Text(
          "Dealer Product Description",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
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
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final product = controller.productData.value;
            if (product == null) {
              return const Center(
                child: Text("Product details could not be loaded."),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final recentlyViewedController =
                  Get.find<RecentlyViewedController>();
              recentlyViewedController.addProduct(
                RecentlyViewedModel(
                  id: product.id ?? "",
                  title: product.title ?? "",
                  image: product.images?.isNotEmpty == true
                      ? product.images!.first
                      : "",
                  price: product.price?.toString() ?? "0",
                  type: "dealer",
                  createdAt: DateTime.now(),
                ),
              );
            });

            final timeAgo = timeago.format(product.createdAt!);

            return SingleChildScrollView(
              padding: EdgeInsets.all(AppSizer().width1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.images != null && product.images!.isNotEmpty) ...[
                    CarouselSlider(
                      options: CarouselOptions(
                        height: AppSizer().height30,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        viewportFraction: 1.0,
                        onPageChanged: (index, reason) {
                          controller.updateImageIndex(index);
                        },
                      ),
                      items: product.images!.map((imagePath) {
                        final image = imagePath.replaceAll('\\', '/');
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal: AppSizer().width1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.appGrey.shade200,
                            borderRadius: BorderRadius.circular(
                              AppSizer().height1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizer().height1,
                            ),
                            child: Image.network(
                              "https://oldmarket.bhoomi.cloud/$image",
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) => Image.asset(
                                'assets/images/placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSizer().height2),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: product.images!.asMap().entries.map((entry) {
                          return Container(
                            width: AppSizer().width4,
                            height: AppSizer().width1,
                            margin: EdgeInsets.symmetric(
                              horizontal: AppSizer().width1,
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: controller.currentIndex.value == entry.key
                                  ? AppColors.appGreen
                                  : AppColors.appGrey,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ] else ...[
                    Container(
                      width: double.infinity,
                      height: AppSizer().height30,
                      decoration: BoxDecoration(
                        color: AppColors.appGrey.shade200,
                        borderRadius: BorderRadius.circular(AppSizer().height1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizer().height1),
                        child: Image.asset(
                          'assets/images/placeholder.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: AppSizer().height2),
                  // Enhanced Dealer Profile Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: GetBuilder<DealerDescriptionController>(
                      builder: (controller) {
                        if (controller.productData.value == null)
                          return const SizedBox();

                        final dealerId = product.dealerId ?? '';

                        // Enhanced dealer info extraction with better fallbacks
                        String dealerName = 'Dealer';
                        if (dealerId.isNotEmpty) {
                          // Create a readable dealer name from dealerId
                          if (dealerId.length > 12) {
                            dealerName =
                                'Dealer ${dealerId.substring(dealerId.length - 8)}';
                          } else if (dealerId.length > 6) {
                            dealerName = 'Dealer ${dealerId.substring(0, 6)}';
                          } else {
                            dealerName = 'Dealer $dealerId';
                          }
                        }

                        // If no dealerId, use product title as context
                        if (dealerName == 'Dealer' &&
                            product.title!.isNotEmpty) {
                          dealerName = '${product.title} Dealer';
                        }

                        return GestureDetector(
                          onTap: () {
                            if (dealerId.isNotEmpty) {
                              // Navigate to dealer detail screen to show dealer profile and all products
                              Get.to(
                                () => DealerDetailScreen(dealerId: dealerId),
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
                                        color: AppColors.appGreen.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 6,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.transparent,
                                    child: Icon(
                                      Icons.store,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSizer().width4),
                                // Enhanced Dealer Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.business,
                                            color: AppColors.appGreen,
                                            size: 20,
                                          ),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              dealerName,
                                              style: TextStyle(
                                                fontSize: AppSizer().fontSize17,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    AppColors.appGreen.shade800,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.inventory,
                                            color: Colors.grey.shade600,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              "View all products & vehicles",
                                              style: TextStyle(
                                                fontSize: AppSizer().fontSize14,
                                                color: Colors.grey.shade700,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.tap_and_play,
                                            color: Colors.grey.shade500,
                                            size: 14,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            "Tap to view dealer profile",
                                            style: TextStyle(
                                              fontSize: AppSizer().fontSize12,
                                              color: Colors.grey.shade500,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Arrow Icon
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.appGreen.withOpacity(0.7),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "₹ ${product.price}",
                            style: TextStyle(
                              fontSize: AppSizer().fontSize19,
                              fontWeight: FontWeight.w900,
                              color: AppColors.appBlack,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Obx(() {
                              final isInWishlist = dealerWishlistController
                                  .isInWishlist(product.id!);

                              return IconButton(
                                onPressed: () {
                                  dealerWishlistController.toggleWishlist(
                                    product.id!,
                                  );
                                },
                                icon: Icon(
                                  isInWishlist
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isInWishlist
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              );
                            }),

                            IconButton(
                              onPressed: () =>
                                  _shareDealerProductDirectly(product),
                              icon: const Icon(Icons.share),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final currentUserId =
                            await AuthService.getLoggedInUserId();

                        controller.showMakeOfferDialog(
                          productId: product.id ?? "",
                          buyerId: currentUserId ?? "",
                          sellerId: product.dealerId ?? "",
                        );
                      },
                      icon: Icon(Icons.sell, size: AppSizer().fontSize18),
                      label: const Text("Make Offer"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          AppSizer().width40,
                          AppSizer().height5,
                        ),
                        backgroundColor: AppColors.appGreen,
                        foregroundColor: AppColors.appWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizer().height1,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer().width4,
                          vertical: AppSizer().height1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSizer().height1),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: Text(
                      product.title!,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.alarm,
                        color: AppColors.appGrey.shade700,
                        size: AppSizer().fontSize20,
                      ),
                      SizedBox(width: AppSizer().width1),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: AppSizer().fontSize16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.appGrey.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer().height1),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: AppSizer().fontSize19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Divider(color: AppColors.appBlack),
                        Text(
                          product.description!,
                          style: TextStyle(
                            fontSize: AppSizer().fontSize17,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSizer().height2),
                  Column(
                    children: [
                      Text(
                        "Contact me - ",
                        style: TextStyle(
                          fontSize: AppSizer().fontSize17,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 0),
                        height: 1.5,
                        width: 80,
                        color: AppColors.appBlack,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizer().height4),
                  // CALL & WHATSAPP BUTTONS - Conditional rendering based on phone availability
                  Builder(
                    builder: (context) {
                      final hasPhone = _hasPhoneNumber(product);

                      if (!hasPhone) {
                        // Show info message when no phone is available
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSizer().width1,
                          ),
                          child: Container(
                            padding: EdgeInsets.all(AppSizer().height2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              border: Border.all(color: Colors.orange.shade300),
                              borderRadius: BorderRadius.circular(
                                AppSizer().height1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange.shade700,
                                  size: AppSizer().fontSize20,
                                ),
                                SizedBox(width: AppSizer().width2),
                                Expanded(
                                  child: Text(
                                    "Contact information not available for this product",
                                    style: TextStyle(
                                      color: Colors.orange.shade800,
                                      fontSize: AppSizer().fontSize14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Show call and WhatsApp buttons when phone is available
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer().width1,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => controller.callDealer(),
                                icon: const Icon(Icons.phone),
                                label: const Text("Call"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.appGreen,
                                  foregroundColor: AppColors.appWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizer().height1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: AppSizer().width2),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => controller.whatsappDealer(),
                                icon: Icon(
                                  Icons.message,
                                  color: AppColors.appWhite,
                                ),
                                label: const Text("WhatsApp"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.appGreen,
                                  foregroundColor: AppColors.appWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizer().height1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: AppSizer().height2),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizer().width1,
                    ),
                    child: InkWell(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (_) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: MediaQuery.of(
                                  context,
                                ).viewInsets.bottom,
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
                                child: GetBuilder<DealerDescriptionController>(
                                  builder: (bookController) {
                                    return Column(
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

                                        ///  Name
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

                                        ///  Phone
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

                                        ///Date Picker
                                        InkWell(
                                          onTap: () =>
                                              bookController.pickDate(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  bookController
                                                          .formattedDate
                                                          .isNotEmpty
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

                                        ///Time Picker
                                        InkWell(
                                          onTap: () =>
                                              bookController.pickTime(context),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
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
                                                  bookController
                                                          .formattedTime
                                                          .isNotEmpty
                                                      ? bookController
                                                            .formattedTime
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
                                        Obx(
                                          () => ElevatedButton.icon(
                                            onPressed:
                                                bookController.isBooking.value
                                                ? null
                                                : () {
                                                    print(
                                                      "Booking initiated for: ${bookController.productId}",
                                                    );
                                                    bookController
                                                        .bookTestDrive(
                                                          bookController
                                                              .productId,
                                                        );
                                                  },

                                            icon: const Icon(
                                              Icons.check_circle,
                                            ),
                                            label:
                                                bookController.isBooking.value
                                                ? const SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Text("Book Now"),
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
                                        const SizedBox(height: 24),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            );
                          },
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
                    ),
                  ),

                  SizedBox(height: AppSizer().height2),
                  // Send message button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (product.id == null ||
                          product.title == null ||
                          product.dealerId == null) {
                        Get.snackbar(
                          "Error",
                          "Product details are incomplete. Cannot start chat.",
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      chatController.startAndNavigateToChat(
                        productId: product.id!,
                        productName: product.title!,
                        sellerId: product.dealerId!,
                        productImage: product.images?.isNotEmpty == true
                            ? product.images!.first
                            : null,
                        initialMessage:
                            "Hi, I'm interested in your ${product.title}. Is it still available?",
                        sellerName: product.dealerId!,
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text("Send Message"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appGreen,
                      foregroundColor: AppColors.appWhite,
                      minimumSize: Size(double.infinity, AppSizer().height6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizer().height1),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  /// Share dealer product directly with phone's native share dialog
  Future<void> _shareDealerProductDirectly(dynamic product) async {
    try {
      // Show loading message
      Get.snackbar(
        "Preparing Share",
        "Downloading product image...",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      // Create rich sharing message for dealer product
      String shareMessage = '🛍️ *${product.title ?? 'Amazing Product'}*\n';
      if (product.price != null) {
        shareMessage += '💰 Price: *₹${product.price}*\n';
      }
      if (product.dealerName?.isNotEmpty == true) {
        shareMessage += '🏪 Dealer: *${product.dealerName}*\n';
      }
      if (product.description?.isNotEmpty == true) {
        final shortDesc = product.description!.length > 100
            ? '${product.description!.substring(0, 100)}...'
            : product.description!;
        shareMessage += '📝 Description: ${shortDesc}\n';
      }
      shareMessage +=
          '\n🔗 View full details: https://oldmarket.bhoomi.cloud/app/dealer/${product.id}\n';
      shareMessage += '\n📱 Download Old Market app for better experience!';

      // Try to share with product image
      final imageShared = await _shareDealerWithProductImage(
        shareMessage,
        product,
      );

      if (!imageShared) {
        // Fallback to text-only sharing
        await Share.share(
          shareMessage,
          subject: 'Check out this product on Old Market!',
        );
      }
    } catch (e) {
      print('[DealerDescriptionScreen] _shareDealerProductDirectly error: $e');
      // Final fallback
      await Share.share(
        'Check out this product: https://oldmarket.bhoomi.cloud/app/dealer/${product.id}',
        subject: 'Check out this product on Old Market!',
      );
    }
  }

  /// Share dealer product with image
  Future<bool> _shareDealerWithProductImage(
    String message,
    dynamic product,
  ) async {
    try {
      if (product.images?.isNotEmpty == true) {
        String imageUrl = product.images!.first;
        if (!imageUrl.startsWith('http')) {
          imageUrl = 'https://oldmarket.bhoomi.cloud/$imageUrl';
        }

        // Download image
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          // Save to temporary file
          final tempDir = await getTemporaryDirectory();
          final file = File(
            '${tempDir.path}/dealer_product_${DateTime.now().millisecondsSinceEpoch}.jpg',
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
      print('Error sharing dealer product with image: $e');
      return false;
    }
  }
}
