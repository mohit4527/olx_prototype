class AllProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String userId;
  final List<String> mediaUrl;
  final bool isBoosted;
  final String whatsapp;
  final String? phone; // 🔹 Added phone field
  final Location location;
  final String? createdAt;
  bool? status;

  AllProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.userId,
    required this.mediaUrl,
    required this.isBoosted,
    required this.whatsapp,
    this.phone, // 🔹 Phone is optional
    required this.location,
    required this.createdAt, // ✅ Add this
    this.status,
  });

  // 🔥 Getters for easy access to location properties
  String? get country => location.country.isNotEmpty ? location.country : null;
  String? get state => location.state.isNotEmpty ? location.state : null;
  String? get city => location.city.isNotEmpty ? location.city : null;

  factory AllProductModel.fromJson(Map<String, dynamic> json) {
    // Robust extraction of userId from various backend schemas
    String extractUserId(Map<String, dynamic> j) {
      if (j['userId'] != null) return j['userId'].toString();
      if (j['user_id'] != null) return j['user_id'].toString();
      if (j['sellerId'] != null) return j['sellerId'].toString();
      if (j['createdBy'] != null) return j['createdBy'].toString();
      final userObj = j['user'];
      if (userObj is Map) {
        return (userObj['_id'] ?? userObj['id'] ?? userObj['uid'] ?? '')
            .toString();
      }
      // some APIs nest author info under 'postedBy' or 'owner'
      final postedBy = j['postedBy'];
      if (postedBy is Map) {
        return (postedBy['_id'] ?? postedBy['id'] ?? '').toString();
      }
      final owner = j['owner'];
      if (owner is Map) {
        return (owner['_id'] ?? owner['id'] ?? '').toString();
      }
      return '';
    }

    // Robust extraction of media list
    List<String> extractMedia(Map<String, dynamic> j) {
      try {
        if (j['mediaUrl'] is List) return List<String>.from(j['mediaUrl']);
        if (j['images'] is List) return List<String>.from(j['images']);
        if (j['media'] is List) return List<String>.from(j['media']);
        // Sometimes media is a comma-separated string
        if (j['mediaUrl'] is String && j['mediaUrl'].isNotEmpty) {
          return (j['mediaUrl'] as String)
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      } catch (e) {
        // ignore and fallback to empty
      }
      return <String>[];
    }

    final uid = extractUserId(json);
    final media = extractMedia(json);

    return AllProductModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      userId: uid,
      mediaUrl: media,
      isBoosted: json['isBoosted'] ?? false,
      whatsapp: json['whatsapp'] ?? '',
      phone:
          json['number']?.toString() ?? // 🔥 PRIMARY: API sends as "number"
          json['phone']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['userPhone']?.toString(), // 🔹 Extract phone from API
      location: json['location'] != null
          ? Location.fromJson(json['location'] as Map<String, dynamic>, json)
          : Location(
              country: json['country']?.toString() ?? '',
              state: json['state']?.toString() ?? '',
              city: json['city']?.toString() ?? '',
            ),
      createdAt: json['createdAt'] ?? '', // keep as-is
      status: json['status'] as bool?,
    );
  }
}

class Location {
  final String country;
  final String state;
  final String city;

  Location({required this.country, required this.state, required this.city});

  factory Location.fromJson(
    Map<String, dynamic> json, [
    Map<String, dynamic>? rootJson,
  ]) {
    // First try to get from location object itself
    String city = json['city']?.toString() ?? '';
    String state = json['state']?.toString() ?? '';
    String country = json['country']?.toString() ?? '';

    // If location object is empty (like {type: Point}), check root level
    if (city.isEmpty && state.isEmpty && country.isEmpty && rootJson != null) {
      city = rootJson['city']?.toString() ?? '';
      state = rootJson['state']?.toString() ?? '';
      country = rootJson['country']?.toString() ?? '';
    }

    return Location(country: country, state: state, city: city);
  }
}
