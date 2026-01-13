import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizer.dart';
import '../../../controller/dealer_details_controller.dart';

class AllDealersScreen extends StatelessWidget {
  const AllDealersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dController = Get.find<DealerController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        foregroundColor: Colors.white,
        title: const Text(
          'All Dealers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (dController.isDealerListLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.appGreen),
          );
        }

        if (dController.dealers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
                SizedBox(height: AppSizer().height2),
                Text(
                  'No dealers found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await dController.fetchAllDealers();
          },
          color: AppColors.appGreen,
          child: GridView.builder(
            padding: EdgeInsets.all(AppSizer().height2),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizer().width2,
              mainAxisSpacing: AppSizer().height2,
              childAspectRatio: 0.75,
            ),
            itemCount: dController.dealers.length,
            itemBuilder: (context, index) {
              final dealer = dController.dealers[index];
              final businessName = dealer.businessName ?? 'Unknown Business';

              // Build image URL
              String imageUrl = '';
              if (dealer.businessLogo != null &&
                  dealer.businessLogo!.isNotEmpty) {
                final logo = dealer.businessLogo!;
                if (logo.startsWith('http')) {
                  imageUrl = logo;
                } else {
                  imageUrl =
                      'https://oldmarket.bhoomi.cloud${logo.startsWith('/') ? logo : '/$logo'}';
                }
              }

              return GestureDetector(
                onTap: () {
                  Get.toNamed(
                    '/dealer_detail_screen',
                    arguments: dealer.dealerId,
                  );
                },
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Dealer Image
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.appGreen.withOpacity(
                                        0.1,
                                      ),
                                      child: const Icon(
                                        Icons.store,
                                        size: 50,
                                        color: AppColors.appGreen,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                              color: AppColors.appGreen,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  color: AppColors.appGreen.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.store,
                                    size: 50,
                                    color: AppColors.appGreen,
                                  ),
                                ),
                        ),
                      ),

                      // Dealer Info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.all(AppSizer().height1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Business Name
                              Text(
                                businessName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.appGreen,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 4),

                              // Phone Number
                              if (dealer.phone != null &&
                                  dealer.phone!.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      size: 12,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      dealer.phone!,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),

                              SizedBox(height: 2),

                              // City & Dealer Type
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (dealer.city != null &&
                                      dealer.city!.isNotEmpty) ...[
                                    Icon(
                                      Icons.location_on,
                                      size: 11,
                                      color: Colors.grey[600],
                                    ),
                                    SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        dealer.city!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                  if (dealer.city != null &&
                                      dealer.city!.isNotEmpty &&
                                      dealer.dealerType != null &&
                                      dealer.dealerType!.isNotEmpty)
                                    Text(
                                      ' • ',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  if (dealer.dealerType != null &&
                                      dealer.dealerType!.isNotEmpty)
                                    Text(
                                      dealer.dealerType!.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.appGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
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
    );
  }
}
