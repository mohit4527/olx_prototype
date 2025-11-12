import 'dart:convert';

DealerProfilesModel dealerProfilesModelFromJson(String str) =>
    DealerProfilesModel.fromJson(json.decode(str));

String dealerProfilesModelToJson(DealerProfilesModel data) =>
    json.encode(data.toJson());

class DealerProfilesModel {
  final bool? status;
  final String? message;
  final int? count;
  final List<DealerProfile>? data;

  DealerProfilesModel({this.status, this.message, this.count, this.data});

  factory DealerProfilesModel.fromJson(Map<String, dynamic> json) =>
      DealerProfilesModel(
        status: json["status"],
        message: json["message"],
        count: json["count"],
        data: json["data"] == null
            ? []
            : List<DealerProfile>.from(
                json["data"]!.map((x) => DealerProfile.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "count": count,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class DealerProfile {
  final String? id;
  final String? userId; // 🔥 Added userId to identify profile owner
  final String? businessName;
  final String? registrationNumber; // 🚀 NOW ADDED!
  final String? gstNumber; // 🆕 NEW: Added GST number from API
  final String? village; // 🚀 NOW ADDED!
  final String? city;
  final String? state;
  final String? country;
  final String? phone;
  final String? email;
  final String? businessAddress; // 🔹 Added business address
  final String? dealerType;
  final String? description; // 🚀 NOW ADDED!
  final String? businessLogo;
  final List<String>? businessPhotos; // 🚀 NOW ADDED!
  final String? businessHours; // 🔹 Added business hours
  final List<String>? paymentMethods; // 🚀 NOW ADDED!
  final String? status;
  final DateTime? createdAt;

  DealerProfile({
    this.id,
    this.userId, // 🔥 Added userId to constructor
    this.businessName,
    this.registrationNumber, // 🚀 NOW ADDED!
    this.gstNumber, // 🆕 NEW: Added to constructor
    this.village, // 🚀 NOW ADDED!
    this.city,
    this.state,
    this.country,
    this.phone,
    this.email,
    this.businessAddress, // 🔹 Added to constructor
    this.dealerType,
    this.description, // 🚀 NOW ADDED!
    this.businessLogo,
    this.businessPhotos, // 🚀 NOW ADDED!
    this.businessHours, // 🔹 Added to constructor
    this.paymentMethods, // 🚀 NOW ADDED!
    this.status,
    this.createdAt,
  });

  factory DealerProfile.fromJson(Map<String, dynamic> json) => DealerProfile(
    id: json["_id"],
    userId: json["userId"], // 🔥 Extract userId from API response
    businessName: json["businessName"],
    registrationNumber: json["registrationNumber"], // 🚀 NOW EXTRACTED!
    gstNumber: json["gstNumber"], // 🆕 NEW: Extract GST number from API
    village: json["village"], // 🚀 NOW EXTRACTED!
    city: json["city"],
    state: json["state"],
    country: json["country"],
    phone: json["phone"],
    email: json["email"],
    businessAddress: json["businessAddress"], // 🔹 Extract from JSON
    dealerType: json["dealerType"],
    description: json["description"], // 🚀 NOW EXTRACTED!
    businessLogo: json["businessLogo"],
    businessPhotos: json["businessPhotos"] != null
        ? List<String>.from(json["businessPhotos"])
        : null, // 🚀 NOW EXTRACTED!
    businessHours: json["businessHours"], // 🔹 Extract from JSON
    paymentMethods: json["paymentMethods"] != null
        ? List<String>.from(json["paymentMethods"])
        : null, // 🚀 NOW EXTRACTED!
    status: json["status"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId, // 🔥 Include userId in JSON
    "businessName": businessName,
    "registrationNumber": registrationNumber, // 🚀 NOW INCLUDED!
    "gstNumber": gstNumber, // 🆕 NEW: Include GST number in JSON
    "village": village, // 🚀 NOW INCLUDED!
    "city": city,
    "state": state,
    "country": country,
    "phone": phone,
    "email": email,
    "businessAddress": businessAddress, // 🔹 Include in JSON
    "dealerType": dealerType,
    "description": description, // 🚀 NOW INCLUDED!
    "businessLogo": businessLogo,
    "businessPhotos": businessPhotos, // 🚀 NOW INCLUDED!
    "businessHours": businessHours, // 🔹 Include in JSON
    "paymentMethods": paymentMethods, // 🚀 NOW INCLUDED!
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
  };
}
