class ProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final List<String> mediaUrl;
  final String type;
  final String whatsapp;
  final String city;
  final String state;
  final String country;
  final String? createdAt;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.mediaUrl,
    required this.type,
    required this.whatsapp,
    required this.city,
    required this.state,
    required this.country,
    required this.createdAt,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> media = List<String>.from(json['mediaUrl'] ?? []);

    return ProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      mediaUrl: media,
      type: json['type'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      city: json['location']?['city'] ?? '',
      state: json['location']?['state'] ?? '',
      country: json['location']?['country'] ?? '',
      createdAt: json['createdAt'] ?? '',
      imageUrl: media.isNotEmpty ? media.first : '', // For easy access to thumbnail
    );
  }
}
