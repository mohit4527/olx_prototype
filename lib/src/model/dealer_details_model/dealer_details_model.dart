class DealerStats {
  final String dealerId;
  final String businessName;
  final String? imageUrl;
  final String? businessLogo;
  final String? phone;
  final int totalVehicles;
  final int totalSold;
  final int totalStock;

  DealerStats({
    required this.dealerId,
    required this.businessName,
    this.imageUrl,
    this.businessLogo,
    this.phone,
    required this.totalVehicles,
    required this.totalSold,
    required this.totalStock,
  });

  factory DealerStats.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl'] ?? json['image'] ?? json['avatar'];
    final businessLogo = json['businessLogo'] ?? json['logo'] ?? json['photo'];

    print("📦 DealerStats JSON: $json");
    print("🔍 DealerStats imageUrl=$imageUrl, businessLogo=$businessLogo");

    return DealerStats(
      dealerId: json['dealerId']?.toString() ?? json['_id']?.toString() ?? '',
      businessName: json['businessName']?.toString() ?? 'Unknown',
      imageUrl: imageUrl?.toString(),
      businessLogo: businessLogo?.toString(),
      phone: json['phone']?.toString() ?? json['contact']?.toString(),
      totalVehicles: json['totalVehicles'] ?? 0,
      totalSold: json['totalSold'] ?? 0,
      totalStock: json['totalStock'] ?? 0,
    );
  }
}

class DealerProduct {
  final String id;
  final String title;
  final String description;
  final int price;
  final List images;
  final List<Offer> offers;

  DealerProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.images,
    required this.offers,
  });

  factory DealerProduct.fromJson(Map<String, dynamic> json) {
    print("🚗 DealerProduct JSON: $json");

    return DealerProduct(
      id: json["_id"]?.toString() ?? "",
      title: json["title"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      price: json["price"] ?? 0,
      images: json["images"] ?? [],
      offers: (json["offers"] ?? []).map<Offer>((e) => Offer.fromJson(e)).toList(),
    );
  }
}

class Offer {
  final String status;

  Offer({required this.status});

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(status: json["status"]?.toString() ?? "");
  }
}

class DealerModel {
  final String dealerId;
  final String businessName;
  final String? image;
  final String? phone;

  DealerModel({
    required this.dealerId,
    required this.businessName,
    this.image,
    this.phone,
  });

  factory DealerModel.fromJson(Map<String, dynamic> json) {
    final image = json['image'] ?? json['avatar'] ?? json['photo'] ?? json['businessLogo'] ?? json['logo'];

    print("📦 DealerModel JSON: $json");
    print("🔍 DealerModel image=$image");

    return DealerModel(
      dealerId: (json['_id'] ?? json['dealerId'] ?? json['id'] ?? '').toString(),
      businessName: (json['businessName'] ?? json['business_name'] ?? json['name'] ?? 'Unknown').toString(),
      image: image?.toString(),
      phone: (json['phone'] ?? json['contact'])?.toString(),
    );
  }
}
