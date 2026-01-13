import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/subscription_controller.dart';

/// Simple test screen to demonstrate subscription system functionality
class SubscriptionTestScreenSimple extends StatelessWidget {
  const SubscriptionTestScreenSimple({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController subscriptionController =
        Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription System Test'),
        backgroundColor: Colors.green,
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subscription Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subscription Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Subscription Active: ${subscriptionController.subscriptionActive.value}',
                        style: TextStyle(
                          color: subscriptionController.subscriptionActive.value
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Is Loading: ${subscriptionController.isLoading.value}',
                      ),
                      Text(
                        'Price: ₹${subscriptionController.price.value.toStringAsFixed(0)}',
                      ),
                      Text(
                        'Currency: ${subscriptionController.currency.value}',
                      ),
                      Text(
                        'Validity: ${subscriptionController.validityDays.value} days',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              const Text(
                'Test Actions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  subscriptionController.loadSubscriptionPrice();
                },
                child: const Text('Load Subscription Price'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  // Test canUploadProduct with different counts
                  bool can1 = subscriptionController.canUploadProduct(1);
                  bool can3 = subscriptionController.canUploadProduct(3);
                  bool can5 = subscriptionController.canUploadProduct(5);

                  Get.snackbar(
                    'Upload Test',
                    'Can upload with 1 products: $can1\n'
                        'Can upload with 3 products: $can3\n'
                        'Can upload with 5 products: $can5',
                    backgroundColor: Colors.blue.shade100,
                    colorText: Colors.blue.shade800,
                    duration: Duration(seconds: 5),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Test Upload Limits'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Get.snackbar(
                    'Info',
                    'Subscription popup would be shown here. This is a simplified test version.',
                    backgroundColor: Colors.orange.shade100,
                    colorText: Colors.orange.shade800,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Show Subscription Info'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  subscriptionController.startRazorpayPayment();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Start Payment Flow'),
              ),
              const SizedBox(height: 20),

              // Manual Controls
              const Text(
                'Manual Controls (for testing):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      subscriptionController.subscriptionActive.value = true;
                      subscriptionController.isSubscribed.value = true;
                      Get.snackbar(
                        'Premium Activated',
                        'You now have premium subscription!',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                    ),
                    child: const Text('Enable Premium'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      subscriptionController.subscriptionActive.value = false;
                      subscriptionController.isSubscribed.value = false;
                      Get.snackbar(
                        'Premium Disabled',
                        'Premium subscription removed',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                    child: const Text('Disable Premium'),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      subscriptionController.price.value = 99.0;
                      Get.snackbar('Price Updated', 'Price set to ₹99');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                    ),
                    child: const Text('Set Price ₹99'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      subscriptionController.price.value = 199.0;
                      Get.snackbar('Price Updated', 'Price set to ₹199');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade300,
                    ),
                    child: const Text('Set Price ₹199'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
