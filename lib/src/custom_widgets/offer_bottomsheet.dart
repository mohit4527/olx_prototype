import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizer.dart';
import '../controller/history_controller.dart';
import '../controller/dealer_history_controller.dart';
import '../model/user_offermodel/user_offermodel.dart';

class OffersBottomSheet extends StatelessWidget {
  final String productId;
  final String productTitle;
  final dynamic controller;

  const OffersBottomSheet({
    super.key,
    required this.productId,
    required this.productTitle,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;
    if (ctrl == null) {
      return const Center(child: Text("Controller not initialized"));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl is UserHistoryController) {
        ctrl.getUserOffers(productId);
      } else if (ctrl is DealerHistoryController) {
        ctrl.getDealerOffers(productId);
      }
    });

    return Obx(() {
      bool loading = false;
      if (ctrl is UserHistoryController) {
        loading = ctrl.isLoading.value;
      } else if (ctrl is DealerHistoryController) {
        loading = ctrl.isLoadingOffers.value;
      }

      if (loading) {
        return const Center(child: CircularProgressIndicator());
      }

      final offers = ctrl.offers as List<UserOffer>;

      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(AppSizer().height2),
            decoration: BoxDecoration(
              color: AppColors.appWhite,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Offers for $productTitle",
                  style: TextStyle(
                    fontSize: AppSizer().fontSize18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.appBlack,
                  ),
                ),
                Divider(color: AppColors.appGreen),
                SizedBox(height: AppSizer().height2),

                if (offers.isEmpty)
                  Center(
                    child: Text(
                      "No offers yet",
                      style: TextStyle(color: AppColors.appGrey),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              // User Icon and Title
                              SizedBox(
                                width: 60,
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        color: AppColors.appGreen,
                                        size: AppSizer().fontSize18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "User",
                                        style: TextStyle(
                                          fontSize: AppSizer().fontSize16,
                                          fontWeight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  "₹ ${offer.offerPrice}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.appRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppSizer().fontSize16,
                                  ),
                                ),
                              ),

                              SizedBox(width: AppSizer().width2),
                              Wrap(
                                spacing: AppSizer().width3,
                                children: [
                                  if (offer.status == "accepted") ...[
                                    Text(
                                      "Offer Accepted",
                                      style: TextStyle(
                                        color: AppColors.appGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSizer().fontSize16,
                                      ),
                                    ),
                                  ] else if (offer.status == "rejected") ...[
                                    Text(
                                      "Offer Rejected",
                                      style: TextStyle(
                                        color: AppColors.appRed,
                                        fontWeight: FontWeight.bold,
                                        fontSize: AppSizer().fontSize16,
                                      ),
                                    ),
                                  ] else ...[
                                    GestureDetector(
                                      onTap: () {
                                        if (ctrl is UserHistoryController) {
                                          ctrl.acceptOffer(productId, offer.id);
                                        } else if (ctrl is DealerHistoryController) {
                                          ctrl.acceptOffer(productId, offer.id);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppColors.appGreen,
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          color: AppColors.appWhite,
                                          size: AppSizer().fontSize18,
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        if (ctrl is UserHistoryController) {
                                          ctrl.rejectOffer(productId, offer.id);
                                        } else if (ctrl is DealerHistoryController) {
                                          ctrl.rejectOffer(productId, offer.id);
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          color: AppColors.appRed,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: AppColors.appWhite,
                                          size: AppSizer().fontSize18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              )


                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    });
  }
}
