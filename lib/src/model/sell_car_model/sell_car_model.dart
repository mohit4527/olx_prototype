class CarModel {
  final String title;
  final String description;
  final String price;
  final String userId;
  final Map<String, String> location;
  final List<String> imageUrls; // URLs after upload

  CarModel({
    required this.title,
    required this.description,
    required this.price,
    required this.userId,
    required this.location,
    required this.imageUrls,
  });

  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      title: json['title'],
      description: json['description'],
      price: json['price'].toString(),
      userId: json['userId'],
      location: Map<String, String>.from(json['location']),
      imageUrls: List<String>.from(json['mediaUrl']),

    );
  }
}
