import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import '../../../controller/dealer_product_description_controller.dart';
import '../../../controller/dealer_wishlist_controller.dart';
import '../../../controller/recently_viewed_controller.dart';
import '../../../controller/chat_controller.dart';
import '../../../custom_widgets/share_products_bottomsheet.dart';
import '../../../model/recently_product_model/recently_product_model.dart';
import '../../../services/auth_service/auth_service.dart';

class DealerDescriptionScreen extends StatelessWidget {
  final String productId;

  DealerDescriptionScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(
      DealerDescriptionController(productId: productId),
    );
    final chatController = Get.put(ChatController());
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
      body: Container(
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
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
                  child: Text(
                    "User Id: ${product.dealerId}",
                    style: TextStyle(
                      fontSize: AppSizer().fontSize16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: AppSizer().height2),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                                color: isInWishlist ? Colors.red : Colors.grey,
                              ),
                            );
                          }),

                          IconButton(
                            onPressed: () {
                              Get.bottomSheet(
                                ShareBottomSheet(
                                  productId: product.id!,
                                  isDealer: true,
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                      minimumSize: Size(AppSizer().width40, AppSizer().height5),
                      backgroundColor: AppColors.appGreen,
                      foregroundColor: AppColors.appWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizer().height1),
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
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                // CALL & WHATSAPP BUTTONS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                          icon: Icon(Icons.message, color: AppColors.appWhite),
                          label: Text("WhatsApp"),
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
                ),
                SizedBox(height: AppSizer().height2),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizer().width1),
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
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                                  bookController.bookTestDrive(
                                                    bookController.productId,
                                                  );
                                                },

                                          icon: const Icon(Icons.check_circle),
                                          label: bookController.isBooking.value
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
                                            backgroundColor: AppColors.appGreen,
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
                          Icon(Icons.directions_car, color: AppColors.appWhite),
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
    );
  }
}
