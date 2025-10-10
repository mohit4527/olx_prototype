class DealerCarModel {
  final String title;
  final String description;
  final int price;
  final String sellerType;
  final String dealerId;
  final String userId;
  final List<String> tags;
  final String category;

  DealerCarModel({
    required this.title,
    required this.description,
    required this.price,
    required this.userId,
    required this.sellerType,
    required this.dealerId,
    required this.category,
    this.tags = const [],
  });
}
