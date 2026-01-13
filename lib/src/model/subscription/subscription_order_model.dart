class SubscriptionOrderModel {
  final bool success;
  final String message;
  final String orderId;
  final double amount;
  final String currency;
  final String key;

  SubscriptionOrderModel({
    required this.success,
    required this.message,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.key,
  });

  factory SubscriptionOrderModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrderModel(
      success: json['status'] ?? false, // API returns 'status' not 'success'
      message: json['message'] ?? '',
      orderId: json['data']?['orderId'] ?? '',
      amount: (json['data']?['amount'] ?? 0).toDouble(),
      currency: json['data']?['currency'] ?? 'INR',
      key: json['data']?['key'] ?? 'rzp_test_RnX4Oatt9zSiqS',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'orderId': orderId,
        'amount': amount,
        'currency': currency,
        'key': key,
      },
    };
  }
}
