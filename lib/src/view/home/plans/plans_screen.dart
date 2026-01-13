import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:olx_prototype/src/constants/app_colors.dart';
import 'package:olx_prototype/src/constants/app_sizer.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({Key? key}) : super(key: key);

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  // Static Plans Data
  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Basic Plan',
      'price': '₹299',
      'duration': '7 Days',
      'color': Colors.blue,
      'features': [
        '✓ List 1 Vehicle',
        '✓ Basic Support',
        '✓ Standard Visibility',
      ],
    },
    {
      'name': 'Premium Plan',
      'price': '₹799',
      'duration': '30 Days',
      'color': Colors.orange,
      'features': [
        '✓ List 5 Vehicles',
        '✓ Priority Support',
        '✓ High Visibility',
        '✓ Featured Listing',
      ],
    },
    {
      'name': 'Elite Plan',
      'price': '₹1,999',
      'duration': '90 Days',
      'color': Colors.purple,
      'features': [
        '✓ List Unlimited Vehicles',
        '✓ 24/7 Support',
        '✓ Premium Visibility',
        '✓ Featured Listings',
        '✓ Analytics Dashboard',
        '✓ Lead Priority',
      ],
    },
  ];

  // Static Offers Data
  final List<Map<String, dynamic>> offers = [
    {
      'title': 'First Time User Offer',
      'description': 'Get 50% OFF on your first plan',
      'code': 'WELCOME50',
      'discount': '50%',
      'color': Colors.green,
    },
    {
      'title': 'Bulk Listing Offer',
      'description': 'List 5+ vehicles and get exclusive benefits',
      'code': 'BULK5',
      'discount': '25%',
      'color': Colors.teal,
    },
    {
      'title': 'Referral Bonus',
      'description': 'Earn ₹500 for each successful referral',
      'code': 'REFER500',
      'discount': '₹500',
      'color': Colors.indigo,
    },
    {
      'title': 'Weekend Special',
      'description': 'Special rates for weekend subscriptions',
      'code': 'WEEKEND20',
      'discount': '20%',
      'color': Colors.pink,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.appGreen,
        elevation: 0,
        title: const Text(
          'Plans & Offers',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ====== PLANS SECTION ======
            Padding(
              padding: EdgeInsets.all(AppSizer().width4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizer().height2),
                  Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: AppSizer().fontSize20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appGreen,
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),
                  // Plans ListView
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return PlanCard(
                        name: plan['name'],
                        price: plan['price'],
                        duration: plan['duration'],
                        color: plan['color'],
                        features: List<String>.from(plan['features']),
                        isPopular: index == 1, // Mark Premium as popular
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizer().height3),
            const Divider(thickness: 2),
            // ====== OFFERS SECTION ======
            Padding(
              padding: EdgeInsets.all(AppSizer().width4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizer().height2),
                  Text(
                    'Exclusive Offers',
                    style: TextStyle(
                      fontSize: AppSizer().fontSize20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.appGreen,
                    ),
                  ),
                  SizedBox(height: AppSizer().height2),
                  // Offers GridView
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: AppSizer().width2,
                      mainAxisSpacing: AppSizer().height2,
                    ),
                    itemCount: offers.length,
                    itemBuilder: (context, index) {
                      final offer = offers[index];
                      return OfferCard(
                        title: offer['title'],
                        description: offer['description'],
                        code: offer['code'],
                        discount: offer['discount'],
                        color: offer['color'],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizer().height3),
          ],
        ),
      ),
    );
  }
}

// ====== PLAN CARD WIDGET ======
class PlanCard extends StatelessWidget {
  final String name;
  final String price;
  final String duration;
  final Color color;
  final List<String> features;
  final bool isPopular;

  const PlanCard({
    required this.name,
    required this.price,
    required this.duration,
    required this.color,
    required this.features,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizer().height2),
      decoration: BoxDecoration(
        border: Border.all(
          color: isPopular ? color : Colors.grey.shade300,
          width: isPopular ? 2.5 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isPopular ? color.withOpacity(0.05) : Colors.white,
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(AppSizer().width4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizer().width2,
                          vertical: AppSizer().height1,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Popular',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizer().fontSize12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: AppSizer().height1),
                // Price & Duration
                Row(
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    SizedBox(width: AppSizer().width2),
                    Text(
                      '/ ${duration}',
                      style: TextStyle(
                        fontSize: AppSizer().fontSize14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSizer().height2),
                // Features
                ...features.map((feature) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: AppSizer().height1),
                    child: Text(
                      feature,
                      style: TextStyle(
                        fontSize: AppSizer().fontSize13,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                SizedBox(height: AppSizer().height2),
                // Buy Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: EdgeInsets.symmetric(
                        vertical: AppSizer().height2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Get.snackbar(
                        'Plan Selected',
                        'You selected $name - ₹${price}',
                        backgroundColor: color,
                        colorText: Colors.white,
                      );
                    },
                    child: Text(
                      'Subscribe Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppSizer().fontSize15,
                        fontWeight: FontWeight.bold,
                      ),
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
}

// ====== OFFER CARD WIDGET ======
class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String code;
  final String discount;
  final Color color;

  const OfferCard({
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSizer().width3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Discount Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSizer().width2,
                vertical: AppSizer().height1,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                discount,
                style: TextStyle(
                  color: color,
                  fontSize: AppSizer().fontSize12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppSizer().height1),
            // Title
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: AppSizer().fontSize13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizer().height1),
            // Description
            Text(
              description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppSizer().fontSize10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizer().height1),
            // Code
            GestureDetector(
              onTap: () {
                // Copy code to clipboard
                Get.snackbar(
                  'Code Copied',
                  code,
                  backgroundColor: color,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizer().width2,
                  vertical: AppSizer().height1,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  code,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppSizer().fontSize10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
