class SubscriptionPriceModel {
  final bool success;
  final String message;
  final double price;
  final String currency;
  final int validityDays;

  SubscriptionPriceModel({
    required this.success,
    required this.message,
    required this.price,
    required this.currency,
    required this.validityDays,
  });

  factory SubscriptionPriceModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPriceModel(
      success:
          true, // API doesn't return success field, but if we get data it's successful
      message: 'Success',
      price: (json['data']?['price'] ?? 0).toDouble(),
      currency: json['data']?['currency'] ?? 'INR',
      validityDays: json['data']?['durationInDays'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': {
        'price': price,
        'currency': currency,
        'validityDays': validityDays,
      },
    };
  }
}
