class ShortVideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final int? duration;
  final String productId;
  final String createdAt;
  final String updatedAt;

  ShortVideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.duration,
  });

  factory ShortVideoModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['videoUrl'] ?? '';

    // Replace backslashes with slashes (for safety)
    rawUrl = rawUrl.replaceAll('\\', '/');

    // Append base URL if not already present
    String fullUrl = rawUrl.startsWith("http")
        ? rawUrl
        : "http://oldmarket.bhoomi.cloud/$rawUrl";

    return ShortVideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      videoUrl: fullUrl,
      productId: json['productId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      duration: json['duration'] != null ? json['duration'] as int : null,
    );
  }
}
