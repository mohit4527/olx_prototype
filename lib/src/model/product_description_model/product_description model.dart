class ProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final List<String> mediaUrl;
  final String type;
  final String city;
  final String state;
  final String country;
  final String? createdAt;
  final String imageUrl;
  final String? whatsapp;
  final String? challanUrl;
  final String? phoneNumber;
  final String? userId;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.mediaUrl,
    required this.type,
    required this.city,
    required this.state,
    required this.country,
    required this.whatsapp,
    required this.phoneNumber,
    this.challanUrl,
    required this.createdAt,
    required this.imageUrl,
    this.userId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<String> media = [];
    if (json['mediaUrl'] != null) {
      media = (json['mediaUrl'] as List)
          .map((e) => e is String ? e : e['url'].toString())
          .toList();
    }

    return ProductModel(
      challanUrl: json['challanUrl'] as String?,
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: json['price'] is int
          ? json['price']
          : int.tryParse(json['price'].toString()) ?? 0,
      mediaUrl: media,
      type: json['type']?.toString() ?? '',
      city: json['location']?['city']?.toString() ?? '',
      state: json['location']?['state']?.toString() ?? '',
      country: json['location']?['country']?.toString() ?? '',
      createdAt: json['createdAt']?.toString(),
      imageUrl: media.isNotEmpty ? media.first : '',
      userId: json['userId']?.toString(),
      // Product JSON may include phone/whatsapp directly, or nested under
      // an uploader/user object. Try both.
      whatsapp:
          json['whatsapp']?.toString() ??
          (json['user'] is Map ? json['user']['whatsapp']?.toString() : null) ??
          (json['uploader'] is Map
              ? json['uploader']['whatsapp']?.toString()
              : null),
      phoneNumber:
          json['phoneNumber']?.toString() ??
          (json['user'] is Map ? json['user']['phone']?.toString() : null) ??
          (json['uploader'] is Map
              ? json['uploader']['phone']?.toString()
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "description": description,
      "price": price,
      "mediaUrl": mediaUrl,
      "type": type,
      "location": {"city": city, "state": state, "country": country},
      "createdAt": createdAt,
      "imageUrl": imageUrl,
      "userId": userId,
      "whatsapp": whatsapp,
      "challanUrl": challanUrl,
      "phoneNumber": phoneNumber,
    };
  }
}
