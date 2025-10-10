import 'dart:convert';

class RecentlyViewedModel {
  String id;
  String title;
  String image;
  String price;
  String type;
  DateTime createdAt;

  RecentlyViewedModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.type,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'price': price,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecentlyViewedModel.fromMap(Map<String, dynamic> map) {
    return RecentlyViewedModel(
      id: map['id'],
      title: map['title'],
      image: map['image'],
      price: map['price'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  String toJson() => json.encode(toMap());
  factory RecentlyViewedModel.fromJson(String source) =>
      RecentlyViewedModel.fromMap(json.decode(source));
}
