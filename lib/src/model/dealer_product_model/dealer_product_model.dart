// lib/src/models/dealer_product_description_model.dart

import 'dart:convert';

DealerProductDescriptionModel dealerProductDescriptionModelFromJson(
  String str,
) => DealerProductDescriptionModel.fromJson(json.decode(str));

String dealerProductDescriptionModelToJson(
  DealerProductDescriptionModel data,
) => json.encode(data.toJson());

class DealerProductDescriptionModel {
  final bool? status;
  final String? message;
  final Data? data;

  DealerProductDescriptionModel({this.status, this.message, this.data});

  factory DealerProductDescriptionModel.fromJson(Map<String, dynamic> json) =>
      DealerProductDescriptionModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  final String? id;
  final String? title;
  final String? description;
  final int? price;
  final String? sellerType;
  final String? dealerId;
  final String? dealerName;
  final String? phone;
  final String? dealerPhone;
  final String? dealerBusinessName;
  final String? dealerEmail;
  final List<String>? tags;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final bool isBoosted;

  Data({
    this.id,
    this.title,
    this.description,
    this.price,
    this.sellerType,
    this.dealerId,
    this.dealerName,
    this.phone,
    this.dealerPhone,
    this.dealerBusinessName,
    this.dealerEmail,
    this.tags,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.isBoosted = false,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    sellerType: json["sellerType"],
    // Handle dealerId as both object and string
    dealerId: json["dealerId"] is Map
        ? json["dealerId"]["_id"]?.toString()
        : json["dealerId"]?.toString(),
    dealerName: json["dealerName"], // optional
    dealerPhone: json["dealerPhone"]?.toString(),
    dealerBusinessName: json["dealerBusinessName"]?.toString(),
    dealerEmail: json["dealerEmail"]?.toString(),
    // Enhanced phone extraction with comprehensive fallback hierarchy
    phone: _extractPhoneNumber(json),
    tags: json["tags"] == null
        ? []
        : List<String>.from(json["tags"]!.map((x) => x)),
    images: json["images"] == null
        ? []
        : List<String>.from(json["images"]!.map((x) => x)),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    isBoosted: json["isBoosted"] ?? false,
  );

  /// Enhanced phone extraction with comprehensive fallback hierarchy
  static String? _extractPhoneNumber(Map<String, dynamic> json) {
    // Priority 1: dealerPhone field (most reliable for dealer products)
    if (json["dealerPhone"] != null &&
        json["dealerPhone"].toString().trim().isNotEmpty) {
      return json["dealerPhone"].toString().trim();
    }

    // Priority 2: dealerId object with phone (from some dealer APIs)
    if (json["dealerId"] is Map && json["dealerId"]["phone"] != null) {
      final phone = json["dealerId"]["phone"].toString().trim();
      if (phone.isNotEmpty) return phone;
    }

    // Priority 3: Direct phone field (fallback)
    if (json["phone"] != null && json["phone"].toString().trim().isNotEmpty) {
      return json["phone"].toString().trim();
    }

    // Priority 4: number field (for compatibility with user products)
    if (json["number"] != null && json["number"].toString().trim().isNotEmpty) {
      return json["number"].toString().trim();
    }

    return null;
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "price": price,
    "sellerType": sellerType,
    "dealerId": dealerId,
    "dealerName": dealerName,
    "phone": phone,
    "dealerPhone": dealerPhone,
    "dealerBusinessName": dealerBusinessName,
    "dealerEmail": dealerEmail,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "isBoosted": isBoosted,
  };
}
