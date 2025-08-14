class CarProductModel {
  final String title;
  final String description;
  final int price;
  final List<String> mediaUrl;
  final String type;
  final String userId;
  final Location location;

  CarProductModel({
    required this.title,
    required this.description,
    required this.price,
    required this.mediaUrl,
    required this.type,
    required this.userId,
    required this.location,
  });

  factory CarProductModel.fromJson(Map<String, dynamic> json) {
    return CarProductModel(
      title: json['title'],
      description: json['description'],
      price: json['price'],
      mediaUrl: List<String>.from(json['mediaUrl'] ?? []),
      type: json['type'],
      userId: json['userId'],
      location: Location.fromJson(json['location']),
    );
  }

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "price": price,
    "mediaUrl": mediaUrl,
    "type": type,
    "userId": userId,
    "location": location.toJson(),
  };
}

class Location {
  final String country;
  final String state;
  final String city;

  Location({required this.country, required this.state, required this.city});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'],
      state: json['state'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() => {
    "country": country,
    "state": state,
    "city": city,
  };
}
