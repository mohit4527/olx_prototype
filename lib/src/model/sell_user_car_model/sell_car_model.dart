class SellUserCarModel {
  final String title;
  final String description;
  final int price;
  final String type;
  final String userId;
  final String country;
  final String state;
  final String city;
  final String category;
  final String? dealerType;
  final String phoneNumber; // 📞 Phone number field added

  SellUserCarModel({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    required this.userId,
    required this.country,
    required this.state,
    required this.city,
    required this.phoneNumber, // 📞 Required phone number
    this.dealerType,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'type': type,
      'userId': userId,
      'country': country,
      'state': state,
      'city': city,
      'dealerType': dealerType,
      'phoneNumber': phoneNumber, // 📞 Phone number in API call
    };
  }
}
