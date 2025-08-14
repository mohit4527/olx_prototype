class AllProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final List<String> mediaUrl;
  final bool isBoosted;
  final String whatsapp;
  final Location location;
  final String? createdAt; // ✅ Add this

  AllProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.mediaUrl,
    required this.isBoosted,
    required this.whatsapp,
    required this.location,
    required this.createdAt, // ✅ Add this
  });

  factory AllProductModel.fromJson(Map<String, dynamic> json) {
    return AllProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      mediaUrl: List<String>.from(json['mediaUrl'] ?? []),
      isBoosted: json['isBoosted'] ?? false,
      whatsapp: json['whatsapp'] ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : Location(country: '', state: '', city: ''),
      createdAt: json['createdAt'] ?? '', // ✅ Add this
    );
  }
}

class Location {
  final String country;
  final String state;
  final String city;

  Location({required this.country, required this.state, required this.city});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
    );
  }
}
