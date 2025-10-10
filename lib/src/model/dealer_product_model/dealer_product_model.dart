// lib/src/models/dealer_product_description_model.dart

import 'dart:convert';

DealerProductDescriptionModel dealerProductDescriptionModelFromJson(String str) => DealerProductDescriptionModel.fromJson(json.decode(str));

String dealerProductDescriptionModelToJson(DealerProductDescriptionModel data) => json.encode(data.toJson());

class DealerProductDescriptionModel {
  final bool? status;
  final String? message;
  final Data? data;

  DealerProductDescriptionModel({
    this.status,
    this.message,
    this.data,
  });

  factory DealerProductDescriptionModel.fromJson(Map<String, dynamic> json) => DealerProductDescriptionModel(
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
  final List<String>? tags;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Data({
    this.id,
    this.title,
    this.description,
    this.price,
    this.sellerType,
    this.dealerId,
    this.dealerName,
    this.phone,
    this.tags,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    price: json["price"],
    sellerType: json["sellerType"],
    dealerId: json["dealerId"],
    dealerName: json["dealerName"],   // optional
    phone: json["phone"],             // 🔹 from JSON
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
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "price": price,
    "sellerType": sellerType,
    "dealerId": dealerId,
    "dealerName": dealerName,
    "phone": phone,
    "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x)),
    "images": images == null
        ? []
        : List<dynamic>.from(images!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}
