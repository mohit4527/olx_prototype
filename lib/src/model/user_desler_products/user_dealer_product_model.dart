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
    // 🔹 Handle dealerId as both String and Object
    String? parsedDealerId;
    String? parsedPhone;

    final dealerIdField = json['dealerId'];
    if (dealerIdField != null) {
      if (dealerIdField is String) {
        parsedDealerId = dealerIdField;
      } else if (dealerIdField is Map<String, dynamic>) {
        parsedDealerId = dealerIdField['_id'] as String?;
        parsedPhone = dealerIdField['phone'] as String?;
      }
    }

    // Use phone from dealerId object if available, otherwise from direct phone field
    final finalPhone = parsedPhone ?? json['phone'] as String?;

    return DealerProduct(
      id: json['_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      sellerType: json['sellerType'] as String? ?? '',
      dealerId: parsedDealerId,
      dealerName: json['dealerName'] as String?,
      phone: finalPhone, // 🔹 Use extracted phone
      tags: (json['tags'] as List? ?? []).map((e) => e.toString()).toList(),
      images: (json['images'] as List? ?? []).map((e) => e.toString()).toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      location: json['location'] as String?,
    );
  }
}
