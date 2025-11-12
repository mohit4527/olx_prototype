import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/dealer_details_controller.dart';
import '../../../model/dealer_profiles_model/dealer_profiles_model.dart';
import '../../../model/dealer_details_model/dealer_details_model.dart';
import '../dealer_details_product_screen/dealer_product_details_screen.dart';

class DealerDetailScreen extends StatefulWidget {
  final String dealerId;
  const DealerDetailScreen({required this.dealerId});

  @override
  State<DealerDetailScreen> createState() => _DealerDetailScreenState();
}

class _DealerDetailScreenState extends State<DealerDetailScreen> {
  final DealerController controller = Get.find<DealerController>();

  @override
  void initState() {
    super.initState();
    print("🚀 DealerDetailScreen initialized for dealerId: ${widget.dealerId}");
    Future.delayed(Duration.zero, () async {
      // First try to fetch dealer stats
      await controller.fetchDealerStats(widget.dealerId);

      // If dealer stats failed, try multiple fallback methods
      if (controller.dealerStats.value == null) {
        print("⚠️ DealerStats failed for ID: ${widget.dealerId}");

        // Method 1: Try to find dealer in the main dealers list
        await controller.fetchAllDealers();
        final dealerInList = controller.dealers.firstWhereOrNull(
          (d) => d.dealerId == widget.dealerId,
        );

        if (dealerInList != null) {
          print("✅ Found dealer in main list: ${dealerInList.businessName}");
          controller.dealerStats.value = dealerInList;
        } else {
          // Method 2: Create a basic dealer profile from the dealerId
          print("🔧 Creating basic dealer profile for ID: ${widget.dealerId}");
          final basicDealer = DealerStats(
            dealerId: widget.dealerId,
            businessName: _generateDealerName(widget.dealerId),
            imageUrl: null,
            businessLogo: null,
            phone: null,
            totalVehicles: 0,
            totalSold: 0,
            totalStock: 0,
          );
          controller.dealerStats.value = basicDealer;
          print("✅ Created basic dealer profile: ${basicDealer.businessName}");
        }
      } // Also fetch dealer profiles for additional info
      controller.fetchDealerProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    const baseUrl = "http://oldmarket.bhoomi.cloud/";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Dealer Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 4,
      ),
      body: Obx(() {
        if (controller.isDealerStatsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        final dealer = controller.dealerStats.value;
        if (dealer == null) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Create a basic dealer profile with available info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade50, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.store,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Dealer Profile",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "ID: ${widget.dealerId}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Get.to(
                                  () => DealerDetailsProductScreen(
                                    dealerId: widget.dealerId,
                                    showSoldOnly: false,
                                    showStockOnly: false,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.inventory_2),
                              label: const Text("View Products"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Info message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Loading detailed dealer information. You can still view products using the button above.",
                          style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final imagePath = dealer.imageUrl?.isNotEmpty == true
            ? dealer.imageUrl!
            : dealer.businessLogo?.isNotEmpty == true
            ? dealer.businessLogo!
            : "";

        final imageUrl = imagePath.isNotEmpty
            ? "$baseUrl${imagePath.replaceFirst(RegExp(r'^/+'), '')}"
            : "";

        print("📸 Dealer Detail => Final imageUrl used: $imageUrl");

        return SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppSizer().height2),
              Container(
                width: double.infinity,
                height: AppSizer().height28,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl.isEmpty
                    ? const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),

              // Business Info
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Business Name:",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dealer.businessName,
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Phone:",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dealer.phone ?? "Not available",
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showCompleteDetailsDialog(widget.dealerId),
                          icon: const Icon(Icons.info_outline),
                          label: const Text("More Details"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Stats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _statBox(
                    "Total Vehicles",
                    dealer.totalVehicles,
                    showSold: false,
                    showStock: false,
                  ),
                  _statBox(
                    "Total Sold",
                    dealer.totalSold,
                    showSold: true,
                    showStock: false,
                  ),
                  _statBox(
                    "Total Stock",
                    dealer.totalStock,
                    showSold: false,
                    showStock: true,
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _statBox(
    String title,
    int count, {
    bool showSold = false,
    bool showStock = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Get.to(
            () => DealerDetailsProductScreen(
              dealerId: widget.dealerId,
              showSoldOnly: showSold,
              showStockOnly: showStock,
            ),
          );
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.green.shade50,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 NEW: Show complete dealer details from profiles API
  void _showCompleteDetailsDialog(String dealerId) {
    // Check if profiles are loaded
    if (controller.dealerProfiles.isEmpty) {
      Get.snackbar(
        "Loading...",
        "Please wait while we fetch complete details",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
      );
      return;
    }

    // Find the dealer profile by ID
    final dealerProfile = controller.getDealerProfileById(dealerId);
    if (dealerProfile == null) {
      Get.snackbar(
        "Not Found",
        "Complete details not available for this dealer",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 700, maxWidth: 400),
            padding: const EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "📋 Complete Dealer Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.green),
                  const SizedBox(height: 15),

                  // 🔥 Complete Business Details from API
                  _buildDetailItem(
                    "🏪 Business Name",
                    dealerProfile.businessName ?? "Not available",
                  ),
                  _buildDetailItem(
                    "📞 Phone Number",
                    dealerProfile.phone ?? "Not available",
                  ),
                  _buildDetailItem(
                    "📧 Email Address",
                    dealerProfile.email ?? "Not available",
                  ),
                  _buildDetailItem(
                    "� Business Address",
                    dealerProfile.businessAddress ?? "Not available",
                  ),
                  _buildDetailItem(
                    "�🏙️ City",
                    dealerProfile.city ?? "Not available",
                  ),
                  _buildDetailItem(
                    "🗺️ State",
                    dealerProfile.state ?? "Not available",
                  ),
                  _buildDetailItem(
                    "🌍 Country",
                    dealerProfile.country ?? "Not available",
                  ),
                  _buildDetailItem(
                    "🚗 Dealer Type",
                    dealerProfile.dealerType ?? "Not available",
                  ),
                  _buildDetailItem(
                    "🕐 Business Hours",
                    dealerProfile.businessHours ?? "Not available",
                  ),
                  _buildDetailItem(
                    "✅ Status",
                    dealerProfile.status ?? "Not available",
                  ),
                  _buildDetailItem(
                    "� Registered On",
                    dealerProfile.createdAt != null
                        ? "${dealerProfile.createdAt!.day}-${dealerProfile.createdAt!.month}-${dealerProfile.createdAt!.year}"
                        : "Not available",
                  ),

                  const SizedBox(height: 20),

                  // Business Information Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.business, color: Colors.green, size: 18),
                            SizedBox(width: 8),
                            Text(
                              "Complete Business Address",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (dealerProfile.businessAddress?.isNotEmpty == true)
                          Text(
                            "🏢 ${dealerProfile.businessAddress}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "📍 ${dealerProfile.city ?? 'N/A'}, ${dealerProfile.state ?? 'N/A'}, ${dealerProfile.country ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        if (dealerProfile.businessHours?.isNotEmpty == true)
                          Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                "🕐 Hours: ${dealerProfile.businessHours}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Contact Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.contact_phone,
                              color: Colors.blue,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Contact Information",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (dealerProfile.phone?.isNotEmpty == true)
                          Text(
                            "📞 Call: ${dealerProfile.phone}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              height: 1.3,
                            ),
                          ),
                        if (dealerProfile.email?.isNotEmpty == true)
                          Text(
                            "📧 Email: ${dealerProfile.email}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              height: 1.3,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _makeCallToProfileDealer(dealerProfile),
                          icon: const Icon(Icons.call),
                          label: const Text("Call Dealer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          label: const Text("Close"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100, // Reduced width to prevent overflow
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 12, // Slightly smaller font
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8), // Add spacing
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12, // Slightly smaller font
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 🔥 NEW: Make call using dealer profile data
  Future<void> _makeCallToProfileDealer(DealerProfile dealerProfile) async {
    Navigator.of(context).pop(); // Close dialog first

    String? phoneToCall = dealerProfile.phone;

    print(
      "📞 Call Debug: Dealer ID = '${dealerProfile.id}', Phone = '${dealerProfile.phone}'",
    );

    if (phoneToCall?.isNotEmpty == true) {
      try {
        // Show calling message
        Get.snackbar(
          "📞 Calling ${dealerProfile.businessName ?? 'Dealer'}",
          "Connecting to: $phoneToCall",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );

        final phoneNumber = phoneToCall!.replaceAll(RegExp(r'[^0-9+]'), '');
        final callUrl = Uri.parse('tel:$phoneNumber');

        if (await canLaunchUrl(callUrl)) {
          await launchUrl(callUrl);
        } else {
          Get.snackbar(
            "❌ Call Failed",
            "Cannot make call automatically. Please dial $phoneToCall manually.",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        print("📞 Call Error: $e");
        Get.snackbar(
          "❌ Call Error",
          "Cannot make call. Please dial $phoneToCall manually.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      Get.snackbar(
        "📞 No Phone Number",
        "This dealer's phone number is not available.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Generate a readable dealer name from dealer ID
  String _generateDealerName(String dealerId) {
    if (dealerId.isEmpty) return 'Unknown Dealer';

    // Try to make a readable name from the ID
    if (dealerId.length > 12) {
      return 'Dealer ${dealerId.substring(dealerId.length - 8).toUpperCase()}';
    } else if (dealerId.length > 6) {
      return 'Dealer ${dealerId.substring(0, 6).toUpperCase()}';
    } else {
      return 'Dealer ${dealerId.toUpperCase()}';
    }
  }

  Future<void> _makeCallToDealer(dynamic dealer) async {
    Navigator.of(context).pop(); // Close dialog first

    // Use only the dealer's API phone number (specific to this dealer)
    String? phoneToCall = dealer.phone;

    print(
      "📞 Call Debug: Dealer ID = '${dealer.dealerId}', Phone = '${dealer.phone}'",
    );

    if (phoneToCall?.isNotEmpty == true) {
      try {
        // Show calling message
        Get.snackbar(
          "📞 Calling ${dealer.businessName ?? 'Dealer'}",
          "Connecting to: $phoneToCall",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 2),
        );

        final phoneNumber = phoneToCall!.replaceAll(RegExp(r'[^0-9+]'), '');
        final callUrl = Uri.parse('tel:$phoneNumber');

        if (await canLaunchUrl(callUrl)) {
          await launchUrl(callUrl);
        } else {
          Get.snackbar(
            "❌ Call Failed",
            "Cannot make call automatically. Please dial $phoneToCall manually.",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          );
        }
      } catch (e) {
        print("📞 Call Error: $e");
        Get.snackbar(
          "❌ Call Error",
          "Cannot make call. Please dial $phoneToCall manually.",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        );
      }
    } else {
      Get.snackbar(
        "📞 No Phone Number",
        "This dealer's phone number is not available.",
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade800,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
