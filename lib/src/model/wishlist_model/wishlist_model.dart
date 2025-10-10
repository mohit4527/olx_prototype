class WishlistItem {
  final String id;
  final String title;
  final String description;
  final String price;
  final String image;

  WishlistItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'].toString(),
      image: (json['mediaUrl'] != null && json['mediaUrl'].isNotEmpty)
          ? "https://oldmarket.bhoomi.cloud/${json['mediaUrl'][0]}"
          : '',
    );
  }
}
