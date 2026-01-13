class SubscriptionVerifyModel {
  final bool success;
  final String message;
  final bool subscriptionActive;
  final String subscriptionId;
  final DateTime? expiryDate;

  SubscriptionVerifyModel({
    required this.success,
    required this.message,
    required this.subscriptionActive,
    required this.subscriptionId,
    this.expiryDate,
  });

  factory SubscriptionVerifyModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionVerifyModel(
      success: json['status'] ?? false, // API returns 'status' not 'success'
      message: json['message'] ?? '',
      subscriptionActive:
          json['status'] ?? false, // Status true means subscription is active
      subscriptionId:
          json['data']?['subscriptionId'] ?? json['data']?['paymentId'] ?? '',
      expiryDate: json['data']?['subscriptionExpires'] != null
          ? DateTime.parse(json['data']['subscriptionExpires'])
          : (json['data']?['expiryDate'] != null
                ? DateTime.parse(json['data']['expiryDate'])
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'subscriptionActive': subscriptionActive,
        'subscriptionId': subscriptionId,
        'expiryDate': expiryDate?.toIso8601String(),
      },
    };
  }
}
