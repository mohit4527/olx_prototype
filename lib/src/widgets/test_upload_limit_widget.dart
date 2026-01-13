import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/sell_user_car_controller.dart';
import '../controller/all_products_controller.dart';
import '../controller/subscription_controller.dart';

class TestUploadLimitWidget extends StatelessWidget {
  const TestUploadLimitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Text(
            'Upload Limit Tester',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          SizedBox(height: 12),

          ElevatedButton(
            onPressed: () async {
              print('🧪 Manual subscription test started...');

              final productController = Get.isRegistered<ProductController>()
                  ? Get.find<ProductController>()
                  : Get.put(ProductController());

              final subscriptionController =
                  Get.isRegistered<SubscriptionController>()
                  ? Get.find<SubscriptionController>()
                  : Get.put(SubscriptionController());

              print(
                '📊 Subscription active: ${subscriptionController.isSubscribed.value}',
              );

              final canUpload = await productController
                  .checkSubscriptionLimit();
              print('🧪 Test result: canUpload = $canUpload');

              Get.snackbar(
                'Test Result',
                'Can upload: $canUpload\nSubscribed: ${subscriptionController.isSubscribed.value}\nProducts: ${productController.myProducts.length}',
                duration: Duration(seconds: 5),
                backgroundColor: canUpload
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                colorText: canUpload
                    ? Colors.green.shade800
                    : Colors.red.shade800,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('🧪 Test Subscription Check'),
          ),

          SizedBox(height: 8),

          ElevatedButton(
            onPressed: () async {
              final productController = Get.isRegistered<ProductController>()
                  ? Get.find<ProductController>()
                  : Get.put(ProductController());

              await productController.fetchMyProducts();

              Get.snackbar(
                'Products Count',
                'You have ${productController.myProducts.length} products uploaded',
                duration: Duration(seconds: 3),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text('📊 Check Product Count'),
          ),

          SizedBox(height: 8),

          ElevatedButton(
            onPressed: () {
              final productController = Get.find<ProductController>();
              productController.showSubscriptionPopup();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text('🎯 Show Popup Directly'),
          ),
        ],
      ),
    );
  }
}
