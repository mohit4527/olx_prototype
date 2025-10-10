class UserOffer {
  final String id;
  final int offerPrice;
  final String userId;
  final String? productId;
  late final String? status;
  final DateTime? createdAt;
  final String username;
  final DateTime? updatedAt;

  UserOffer({
    required this.id,
    required this.offerPrice,
    required this.userId,
    this.productId,
    this.status,
    required this.username,
    this.createdAt,
    this.updatedAt,
  });

  factory UserOffer.fromJson(Map<String, dynamic> json) {
    return UserOffer(
      id: json['_id']?.toString() ?? '',
      offerPrice: (json['offerPrice'] is int)
          ? json['offerPrice']
          : int.tryParse(json['offerPrice']?.toString() ?? '0') ?? 0,
      userId: json['userId']?.toString() ?? '',
      productId: json['productId']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null, username: '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'offerPrice': offerPrice,
      'userId': userId,
      'productId': productId,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
