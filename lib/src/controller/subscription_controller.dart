import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/subscription_service.dart';
import '../model/subscription/subscription_price_model.dart';
import '../model/subscription/subscription_order_model.dart';
import '../model/subscription/subscription_verify_model.dart';
import 'token_controller.dart';

class SubscriptionController extends GetxController {
  static SubscriptionController get instance => Get.find();

  final TokenController tokenController = Get.find<TokenController>();

  // Razorpay Keys
  static const String _razorpayKeyId = 'rzp_test_RnX4Oatt9zSiqS';
  static const String _razorpaySecretKey = 'C79lUWsMza7uO849xeo0no5c';

  // Observable variables
  RxBool isSubscribed = false.obs;
  RxBool isLoading = false.obs;
  RxDouble price = 0.0.obs;
  Rx<String?> orderId = Rx<String?>(null);
  Rx<String?> paymentId = Rx<String?>(null);
  Rx<String?> signature = Rx<String?>(null);
  RxString currency = 'INR'.obs;
  RxInt validityDays = 30.obs;

  // Current subscription details
  RxBool subscriptionActive = false.obs;
  Rx<DateTime?> expiryDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSubscriptionStatus();
    loadSubscriptionPrice();
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSubscription = prefs.getBool('subscription_active') ?? false;
      final savedExpiry = prefs.getString('subscription_expiry');

      subscriptionActive.value = savedSubscription;
      isSubscribed.value = savedSubscription;

      if (savedExpiry != null) {
        expiryDate.value = DateTime.parse(savedExpiry);

        // Check if subscription has expired
        if (expiryDate.value != null &&
            expiryDate.value!.isBefore(DateTime.now())) {
          subscriptionActive.value = false;
          isSubscribed.value = false;
          await _clearSubscriptionData();
        }
      }

      print('📊 Subscription Status Loaded: ${isSubscribed.value}');
      if (isSubscribed.value && expiryDate.value != null) {
        print('✅ Subscription active until: ${expiryDate.value}');
      }
    } catch (e) {
      print('❌ Error loading subscription status: $e');
    }
  }

  // Public method to reload subscription status
  Future<void> reloadSubscriptionStatus() async {
    await _loadSubscriptionStatus();
  }

  Future<void> _saveSubscriptionStatus(bool active, {DateTime? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('subscription_active', active);

      if (expiry != null) {
        await prefs.setString('subscription_expiry', expiry.toIso8601String());
      }

      subscriptionActive.value = active;
      isSubscribed.value = active;
      expiryDate.value = expiry;

      print('💾 Subscription Status Saved: $active');
    } catch (e) {
      print('❌ Error saving subscription status: $e');
    }
  }

  Future<void> _clearSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('subscription_active');
      await prefs.remove('subscription_expiry');

      subscriptionActive.value = false;
      isSubscribed.value = false;
      expiryDate.value = null;
    } catch (e) {
      print('❌ Error clearing subscription data: $e');
    }
  }

  Future<void> loadSubscriptionPrice() async {
    try {
      isLoading.value = true;
      final priceModel = await SubscriptionService.getPrice();

      if (priceModel.success) {
        price.value = priceModel.price;
        currency.value = priceModel.currency;
        validityDays.value = priceModel.validityDays;
        print('💰 Subscription Price Loaded: ₹${price.value}');
      } else {
        Get.snackbar(
          '❌ Error',
          priceModel.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Load Price Error: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to load subscription price',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createOrder(String userId) async {
    try {
      isLoading.value = true;
      final orderModel = await SubscriptionService.createOrder(userId);

      // Check if order creation was successful
      if (orderModel.success) {
        orderId.value = orderModel.orderId;
        price.value = orderModel.amount;
        currency.value = orderModel.currency;
        print('🛒 Order Created Successfully: ${orderId.value}');
        print('💰 Amount: ${orderModel.amount} ${orderModel.currency}');
      } else {
        print('❌ Order creation failed: ${orderModel.message}');
        throw Exception('Order creation failed: ${orderModel.message}');
      }
    } catch (e) {
      print('❌ Create Order Error: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to create order: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startRazorpayPayment() async {
    try {
      final userId = tokenController.userUid.value;
      if (userId.isEmpty) {
        Get.snackbar('❌ Error', 'Please login first');
        return;
      }

      print('🚀 Starting Razorpay Payment for userId: $userId');

      // // Show loading dialog
      // Get.dialog(
      //   WillPopScope(
      //     onWillPop: () async => false,
      //     child: Center(
      //       child: Container(
      //         padding: EdgeInsets.all(20),
      //         decoration: BoxDecoration(
      //           color: Colors.white,
      //           borderRadius: BorderRadius.circular(12),
      //         ),
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             CircularProgressIndicator(),
      //             SizedBox(height: 16),
      //             Text('Preparing payment...'),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      //   barrierDismissible: false,
      // );

      // First load the subscription price
      await loadSubscriptionPrice();

      // Create order with your API
      await createOrder(userId);

      // Close loading dialog safely
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (orderId.value?.isEmpty ?? true) {
        Get.snackbar('❌ Error', 'Failed to create order');
        return;
      }

      print('🎯 Opening Razorpay checkout with order: ${orderId.value}');
      // Open Razorpay
      _openRazorpayCheckout();
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      print('❌ Payment Start Error: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to start payment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _openRazorpayCheckout() {
    try {
      print('🎯 Opening Razorpay Payment Page');

      // Create payment URL with order details
      final paymentUrl = 'https://api.razorpay.com/v1/checkout/embedded';

      Get.to(
        () => RazorpayPaymentPage(
          orderId: orderId.value ?? '',
          amount: price.value.toInt(),
          keyId: _razorpayKeyId,
          name: 'Old Market Premium',
          description: 'Premium Subscription (${validityDays.value} days)',
          prefillContact: tokenController.phoneNumber.value,
          prefillEmail: tokenController.email.value,
          onPaymentSuccess: (paymentId, razorpayOrderId, signature) {
            print('✅ Payment Success: $paymentId');
            this.paymentId.value = paymentId;
            this.signature.value = signature;
            _verifyPayment();
          },
          onPaymentError: (code, message) {
            print('❌ Payment Error: $code - $message');
            Get.back();
            Get.snackbar(
              '❌ Payment Failed',
              message ?? 'Payment was cancelled or failed',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
            );
          },
        ),
      );
    } catch (e) {
      print('❌ Razorpay open error: $e');
      Get.snackbar('❌ Error', 'Failed to open payment: $e');
    }
  }

  Future<void> _verifyPayment() async {
    try {
      if (paymentId.value == null ||
          orderId.value == null ||
          signature.value == null) {
        throw Exception('Payment verification data missing');
      }

      final userId = tokenController.userUid.value;
      print('🔍 Verifying payment for userId: $userId');

      final verifyModel = await SubscriptionService.verifyPayment(
        userId: userId,
        paymentId: paymentId.value!,
        orderId: orderId.value!,
        signature: signature.value!,
      );

      if (verifyModel.success) {
        // Payment verified successfully
        final expiryDate =
            verifyModel.expiryDate ??
            DateTime.now().add(Duration(days: validityDays.value));
        await _saveSubscriptionStatus(true, expiry: expiryDate);

        // Reload status to ensure it's updated everywhere
        await _loadSubscriptionStatus();

        Get.snackbar(
          '🎉 Success!',
          'Premium subscription activated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          duration: Duration(seconds: 5),
        );

        print('✅ Subscription activated until: $expiryDate');
        print(
          '💎 Subscription status updated: isSubscribed=${isSubscribed.value}',
        );
      } else {
        throw Exception('Payment verification failed: ${verifyModel.message}');
      }
    } catch (e) {
      print('❌ Payment Verification Error: $e');
      Get.snackbar(
        '❌ Verification Failed',
        'Payment could not be verified: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
    }
  }

  // Payment verification with backend
  Future<void> _verifyPaymentWithBackend(
    String userId,
    String paymentId,
    String orderId,
    String signature,
  ) async {
    try {
      final verifyModel = await SubscriptionService.verifyPayment(
        userId: userId,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      if (verifyModel.success && verifyModel.subscriptionActive) {
        // Save subscription status
        await _saveSubscriptionStatus(true, expiry: verifyModel.expiryDate);

        print('🎉 Subscription Activated Successfully!');
      } else {
        throw Exception(verifyModel.message);
      }
    } catch (e) {
      print('❌ Payment verification failed: $e');
      rethrow;
    }
  }

  Future<void> verifyPayment(String userId) async {
    try {
      isLoading.value = true;

      if (paymentId.value == null ||
          orderId.value == null ||
          signature.value == null) {
        throw Exception('Missing payment details');
      }

      final verifyModel = await SubscriptionService.verifyPayment(
        userId: userId,
        paymentId: paymentId.value!,
        orderId: orderId.value!,
        signature: signature.value!,
      );

      if (verifyModel.success && verifyModel.subscriptionActive) {
        // Save subscription status
        await _saveSubscriptionStatus(true, expiry: verifyModel.expiryDate);

        // Close any open dialogs
        if (Get.isDialogOpen!) {
          Get.back();
        }

        Get.snackbar(
          '🎉 Success!',
          'Subscription activated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );

        print('🎉 Subscription Activated Successfully!');
      } else {
        throw Exception(verifyModel.message);
      }
    } catch (e) {
      print('❌ Verify Payment Error: $e');
      Get.snackbar(
        '❌ Verification Failed',
        'Payment verification failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user can upload more products
  bool canUploadProduct(int currentProductCount) {
    if (isSubscribed.value) {
      return true; // Unlimited uploads for subscribed users
    }
    return currentProductCount < 2; // Free users limited to 2 products
  }

  // Create dealer subscription (1 month free)
  Future<void> createDealerSubscription(String userId) async {
    try {
      isLoading.value = true;
      final result = await SubscriptionService.createDealerSubscription(userId);

      if (result.success && result.subscriptionActive) {
        await _saveSubscriptionStatus(true, expiry: result.expiryDate);

        Get.snackbar(
          '🎉 Dealer Account Created!',
          'You get 1 month free subscription!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor,
          colorText: Colors.white,
        );

        print('🎉 Dealer Subscription Created Successfully!');
      } else {
        throw Exception(result.message);
      }
    } catch (e) {
      print('❌ Dealer Subscription Error: $e');
      Get.snackbar(
        '❌ Error',
        'Failed to create dealer subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 🧪 Manual method to show subscription popup for testing
  void showSubscriptionPopup() {
    print('🎯 Showing subscription popup manually...');
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Make it non-dismissible
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.star, color: Colors.orange),
              SizedBox(width: 8),
              Text('Upgrade to Premium'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🚫 You have reached the limit of 3 free products!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Upgrade to premium for:'),
              SizedBox(height: 8),
              Text('✅ Unlimited product uploads'),
              Text('✅ Priority support'),
              Text('✅ Premium features'),
              SizedBox(height: 12),
              Text(
                'Price: ₹${price.value} for ${validityDays.value} days',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.snackbar(
                  '💭 Maybe Later',
                  'You can upgrade anytime from settings',
                  duration: Duration(seconds: 2),
                );
              },
              child: Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                startRazorpayPayment();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Upgrade Now', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}

// Razorpay Payment Page using WebView
class RazorpayPaymentPage extends StatefulWidget {
  final String orderId;
  final int amount;
  final String keyId;
  final String name;
  final String description;
  final String prefillContact;
  final String prefillEmail;
  final Function(String paymentId, String orderId, String signature)
  onPaymentSuccess;
  final Function(String code, String message) onPaymentError;

  const RazorpayPaymentPage({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.keyId,
    required this.name,
    required this.description,
    required this.prefillContact,
    required this.prefillEmail,
    required this.onPaymentSuccess,
    required this.onPaymentError,
  }) : super(key: key);

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🌐 Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('✅ Page finished loading: $url');

            // Check for payment success/failure in URL
            if (url.contains('payment_success')) {
              _handlePaymentSuccess(url);
            } else if (url.contains('payment_error') ||
                url.contains('payment_cancelled')) {
              _handlePaymentError(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Web resource error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'RazorpayHandler',
        onMessageReceived: (JavaScriptMessage message) {
          print('📨 Message from WebView: ${message.message}');
          _handleWebViewMessage(message.message);
        },
      )
      ..loadRequest(Uri.parse('data:text/html;base64,${_getRazorpayHTML()}'));
  }

  String _getRazorpayHTML() {
    final html =
        '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
      <style>
        body {
          margin: 0;
          padding: 20px;
          font-family: Arial, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .container {
          background: white;
          border-radius: 16px;
          padding: 30px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.3);
          text-align: center;
        }
        .loading {
          color: #667eea;
          font-size: 18px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>🔒 Secure Payment</h2>
        <p class="loading">Initializing payment gateway...</p>
      </div>
      
      <script>
        var options = {
          "key": "${widget.keyId}",
          "amount": "${widget.amount}",
          "currency": "INR",
          "name": "${widget.name}",
          "description": "${widget.description}",
          "order_id": "${widget.orderId}",
          "prefill": {
            "contact": "${widget.prefillContact}",
            "email": "${widget.prefillEmail}"
          },
          "theme": {
            "color": "#667eea"
          },
          "handler": function (response) {
            RazorpayHandler.postMessage(JSON.stringify({
              "type": "success",
              "payment_id": response.razorpay_payment_id,
              "order_id": response.razorpay_order_id,
              "signature": response.razorpay_signature
            }));
          },
          "modal": {
            "ondismiss": function() {
              RazorpayHandler.postMessage(JSON.stringify({
                "type": "error",
                "code": "USER_CANCELLED",
                "message": "Payment cancelled by user"
              }));
            }
          }
        };
        
        var rzp = new Razorpay(options);
        
        rzp.on('payment.failed', function (response) {
          RazorpayHandler.postMessage(JSON.stringify({
            "type": "error",
            "code": response.error.code,
            "message": response.error.description
          }));
        });
        
        // Auto-open Razorpay checkout
        setTimeout(function() {
          rzp.open();
        }, 1000);
      </script>
    </body>
    </html>
    ''';

    return base64Encode(utf8.encode(html));
  }

  void _handleWebViewMessage(String message) {
    try {
      print('📱 Processing message: $message');
      // Parse JSON message
      // Note: Simplified parsing - in production use json.decode
      if (message.contains('"type":"success"')) {
        final paymentId = _extractValue(message, 'payment_id');
        final orderId = _extractValue(message, 'order_id');
        final signature = _extractValue(message, 'signature');

        // Close WebView safely
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onPaymentSuccess(paymentId, orderId, signature);
      } else if (message.contains('"type":"error"')) {
        final code = _extractValue(message, 'code');
        final errorMessage = _extractValue(message, 'message');

        // Close WebView safely
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onPaymentError(code, errorMessage);
      }
    } catch (e) {
      print('❌ Error processing message: $e');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      widget.onPaymentError(
        'PROCESSING_ERROR',
        'Failed to process payment response',
      );
    }
  }

  String _extractValue(String json, String key) {
    final pattern = '"$key":"([^"]+)"';
    final match = RegExp(pattern).firstMatch(json);
    return match?.group(1) ?? '';
  }

  void _handlePaymentSuccess(String url) {
    print('✅ Payment successful from URL: $url');
  }

  void _handlePaymentError(String url) {
    print('❌ Payment failed from URL: $url');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Color(0xFF667eea),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Get.back();
            widget.onPaymentError(
              'USER_CANCELLED',
              'Payment cancelled by user',
            );
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
