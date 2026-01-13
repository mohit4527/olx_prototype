class OfferStatusModel {
  final String id;
  final String productId;
  final String userId;
  final int offerPrice;
  final String status; // 'pending', 'approved', 'rejected'
  final String productTitle;
  final String productImage;
  final double productPrice;
  final String userName;
  final String userPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferStatusModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.offerPrice,
    required this.status,
    required this.productTitle,
    required this.productImage,
    required this.productPrice,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OfferStatusModel.fromJson(Map<String, dynamic> json) {
    return OfferStatusModel(
      id: json['_id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      offerPrice: (json['offerPrice'] is int)
          ? json['offerPrice']
          : int.tryParse(json['offerPrice']?.toString() ?? '0') ?? 0,
      status: json['status']?.toString() ?? 'pending',
      productTitle: json['productTitle']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? '',
      productPrice: (json['productPrice'] is double)
          ? json['productPrice']
          : double.tryParse(json['productPrice']?.toString() ?? '0') ?? 0.0,
      userName: json['userName']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productId': productId,
      'userId': userId,
      'offerPrice': offerPrice,
      'status': status,
      'productTitle': productTitle,
      'productImage': productImage,
      'productPrice': productPrice,
      'userName': userName,
      'userPhone': userPhone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
