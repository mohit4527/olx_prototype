import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/product_boost_service.dart';
import '../controller/token_controller.dart';

class ProductBoostController extends GetxController {
  final TokenController tokenController = Get.find<TokenController>();

  // Razorpay Keys
  static const String _razorpayKeyId = 'rzp_test_RnX4Oatt9zSiqS';

  // Observable variables
  RxString currentProductId = ''.obs;
  RxString orderId = ''.obs;
  RxString paymentId = ''.obs;
  RxString signature = ''.obs;
  RxBool isProcessing = false.obs;
  RxInt boostAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    print('✅ Product Boost Controller initialized');
  }

  // Start boost payment for a product
  Future<void> startBoostPayment(String productId) async {
    try {
      final userId = tokenController.userUid.value;
      if (userId.isEmpty) {
        Get.snackbar('❌ Error', 'Please login first');
        return;
      }

      currentProductId.value = productId;
      isProcessing.value = true;

      print('🚀 Starting boost payment for product: $productId, user: $userId');

      // Create boost order
      final orderResponse = await ProductBoostService.createBoostOrder(
        productId: productId,
        userId: userId,
      );

      if (orderResponse == null || orderResponse['status'] != true) {
        isProcessing.value = false;

        // Extract error message from response
        String errorMessage = 'Failed to create boost order';
        if (orderResponse != null) {
          errorMessage = orderResponse['message'] ?? errorMessage;

          // Check for specific error details
          if (orderResponse['error'] != null) {
            final error = orderResponse['error'];
            if (error['error'] != null &&
                error['error']['description'] != null) {
              errorMessage = error['error']['description'];
            }
          }
        }

        Get.snackbar(
          '❌ Boost Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          duration: Duration(seconds: 5),
        );
        return;
      }

      // Extract order details from response
      final data = orderResponse['data'];
      orderId.value = data['orderId'] ?? '';
      boostAmount.value = data['amount'] ?? 4900;

      print('🎯 Opening Razorpay checkout with order: ${orderId.value}');
      _openRazorpayCheckout();
    } catch (e) {
      print('❌ Boost Payment Start Error: $e');
      isProcessing.value = false;
      Get.snackbar(
        '❌ Error',
        'Failed to start boost payment. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _openRazorpayCheckout() {
    try {
      print('🎯 Opening Razorpay Boost Payment Page');

      Get.to(
        () => BoostPaymentPage(
          orderId: orderId.value,
          amount: boostAmount.value,
          keyId: _razorpayKeyId,
          name: 'Product Boost',
          description: 'Boost your product for better visibility',
          prefillContact: tokenController.phoneNumber.value,
          prefillEmail: tokenController.email.value,
          onPaymentSuccess: (paymentId, razorpayOrderId, signature) {
            print('✅ Boost Payment Success: $paymentId');
            this.paymentId.value = paymentId;
            this.signature.value = signature;
            _verifyBoostPayment();
          },
          onPaymentError: (code, message) {
            print('❌ Boost Payment Error: $code - $message');
            Get.back();
            isProcessing.value = false;
            Get.snackbar(
              '❌ Payment Failed',
              message,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
            );
          },
        ),
      );
    } catch (e) {
      print('❌ Razorpay open error: $e');
      isProcessing.value = false;
      Get.snackbar('❌ Error', 'Failed to open payment: $e');
    }
  }

  Future<void> _verifyBoostPayment() async {
    try {
      print(
        '🔍 Verifying boost payment for product: ${currentProductId.value}',
      );

      final verifyResponse = await ProductBoostService.verifyBoostPayment(
        productId: currentProductId.value,
        paymentId: paymentId.value,
        orderId: orderId.value,
        signature: signature.value,
      );

      if (verifyResponse != null && verifyResponse['status'] == true) {
        isProcessing.value = false;

        Get.snackbar(
          '🎉 Boost Activated!',
          verifyResponse['message'] ?? 'Product boosted successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          duration: Duration(seconds: 5),
        );

        print('✅ Product boosted successfully');
      } else {
        throw Exception(
          verifyResponse?['message'] ?? 'Boost verification failed',
        );
      }
    } catch (e) {
      print('❌ Boost Payment Verification Error: $e');
      isProcessing.value = false;
      Get.snackbar(
        '❌ Verification Failed',
        'Payment could not be verified. Please contact support.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
      );
    }
  }
}

// Razorpay Boost Payment Page using WebView
class BoostPaymentPage extends StatefulWidget {
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

  const BoostPaymentPage({
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
  State<BoostPaymentPage> createState() => _BoostPaymentPageState();
}

class _BoostPaymentPageState extends State<BoostPaymentPage> {
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
          background: linear-gradient(135deg, #ff6b35 0%, #f7931e 100%);
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
          color: #ff6b35;
          font-size: 18px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h2>🚀 Product Boost</h2>
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
            "color": "#ff6b35"
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
      if (message.contains('"type":"success"')) {
        final paymentId = _extractValue(message, 'payment_id');
        final orderId = _extractValue(message, 'order_id');
        final signature = _extractValue(message, 'signature');

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        widget.onPaymentSuccess(paymentId, orderId, signature);
      } else if (message.contains('"type":"error"')) {
        final code = _extractValue(message, 'code');
        final errorMessage = _extractValue(message, 'message');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Boost Payment'),
        backgroundColor: Color(0xFFff6b35),
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
