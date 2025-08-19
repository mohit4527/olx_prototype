// ==================== share_video_model.dart ====================
class SharedVideo {
  final String user;
  final String sharedBy;
  final String sharedAt;
  final String video;


  SharedVideo({
    required this.user,
    required this.sharedBy,
    required this.sharedAt,
    required this.video,
  });

  factory SharedVideo.fromJson(Map<String, dynamic> json) {
    return SharedVideo(
      user: json["user"] ?? "",
      sharedBy: json["sharedBy"] ?? "",
      sharedAt: json["sharedAt"] ?? "",
      video: json["video"] ?? "",
    );
  }
}
