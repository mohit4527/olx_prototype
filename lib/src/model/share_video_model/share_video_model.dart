class ShareVideoResponse {
  final bool status;
  final String message;
  final List<SharedWith> sharedWith;
  final String videoUrl;

  ShareVideoResponse({
    required this.status,
    required this.message,
    required this.sharedWith,
    required this.videoUrl,
  });

  factory ShareVideoResponse.fromJson(Map<String, dynamic> json) {
    return ShareVideoResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      sharedWith: (json['sharedWith'] as List? ?? [])
          .map((e) => SharedWith.fromJson(e))
          .toList(),
      videoUrl: json['videoUrl'] ?? '',
    );
  }
}

class SharedWith {
  final String user;
  final String sharedBy;
  final String sharedAt;
  final String id;

  SharedWith({
    required this.user,
    required this.sharedBy,
    required this.sharedAt,
    required this.id,
  });

  factory SharedWith.fromJson(Map<String, dynamic> json) {
    return SharedWith(
      user: json['user'] ?? '',
      sharedBy: json['sharedBy'] ?? '',
      sharedAt: json['sharedAt'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
