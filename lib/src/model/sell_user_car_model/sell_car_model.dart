class SellUserCarModel {
  final String title;
  final String description;
  final int price;
  final String type;
  final String userId;
  final Location location;
  final String category;
  final String? dealerType;

  SellUserCarModel({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.type,
    required this.userId,
    required this.location,
    this.dealerType
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'type': type,
      'userId': userId,
      'location': location.toJson(),
      'dealerType': dealerType,
    };
  }
}

class Location {
  final String country;
  final String state;
  final String city;

  Location({
    required this.country,
    required this.state,
    required this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'state': state,
      'city': city,
    };
  }
}