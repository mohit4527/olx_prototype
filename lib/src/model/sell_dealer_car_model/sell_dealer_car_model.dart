class DealerCarModel {
  final String title;
  final String description;
  final int price;
  final String sellerType;
  final String dealerId;
  final String userId;
  final List<String> tags;
  final String category;
  final String country;
  final String state;
  final String city;

  DealerCarModel({
    required this.title,
    required this.description,
    required this.price,
    required this.userId,
    required this.sellerType,
    required this.dealerId,
    required this.category,
    required this.country,
    required this.state,
    required this.city,
    this.tags = const [],
  });
}
