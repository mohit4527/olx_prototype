// lib/src/model/dealer_product_model.dart


class DealerProductModel {
  final bool status;
  final String message;
  final List<DealerProduct> data;

  DealerProductModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DealerProductModel.fromJson(Map<String, dynamic> json) {
    return DealerProductModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((item) => DealerProduct.fromJson(item))
          .toList(),
    );
  }
}

// lib/src/model/dealer_product_model.dart

class DealerProduct {
  final String id;
  final String title;
  final String description;
  final int price;
  final String sellerType;
  final String? dealerId;
  final String? dealerName;
  final String? phone; // 🔹 Add phone here
  final List<String> tags;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;

  DealerProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerType,
    this.dealerId,
    this.dealerName,
    this.phone, // 🔹 Constructor me add
    required this.tags,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.location,
  });

  factory DealerProduct.fromJson(Map<String, dynamic> json) {
    return DealerProduct(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      sellerType: json['sellerType'] as String? ?? '',
      dealerId: json['dealerId'] as String?,
      dealerName: json['dealerName'] as String?,
      phone: json['phone'] as String?, // 🔹 Parse JSON
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
      location: json['location'] as String?,
    );
  }
}
