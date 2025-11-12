import 'dart:convert';

DashboardAdsModel dashboardAdsModelFromJson(String str) =>
    DashboardAdsModel.fromJson(json.decode(str));

String dashboardAdsModelToJson(DashboardAdsModel data) =>
    json.encode(data.toJson());

class DashboardAdsModel {
  final bool? status;
  final String? message;
  final List<DashboardAd>? data;

  DashboardAdsModel({this.status, this.message, this.data});

  factory DashboardAdsModel.fromJson(Map<String, dynamic> json) =>
      DashboardAdsModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<DashboardAd>.from(
                json["data"]!.map((x) => DashboardAd.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class DashboardAd {
  final String? id;
  final String? title;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DashboardAd({
    this.id,
    this.title,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory DashboardAd.fromJson(Map<String, dynamic> json) => DashboardAd(
    id: json["_id"],
    title: json["title"],
    images: json["images"] == null
        ? []
        : List<String>.from(json["images"]!.map((x) => x)),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
