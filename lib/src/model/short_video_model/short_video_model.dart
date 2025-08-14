class CommentModel {
  final String userId;
  final String text;
  final String userName;
  final String userProfilePic;

  CommentModel({
    required this.userName,
    required this.userProfilePic,
    required this.userId,
    required this.text,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json['userName'] ?? 'Unknown User',
      userProfilePic: json['userProfilePic'] ?? '',
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "text": text,
      "userName": userName,
      "userProfilePic": userProfilePic,
    };
  }
}

class ShortVideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final int? duration;
  final String productId;
  final String createdAt;
  final String updatedAt;
  bool isLiked;
  int likeCount;
  List<String> likedByUsers;
  List<CommentModel> comments;

  ShortVideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.duration,
    this.isLiked = false,
    this.likeCount = 0,
    this.likedByUsers = const [],
    this.comments = const [],
  });

  factory ShortVideoModel.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['videoUrl'] ?? '';
    rawUrl = rawUrl.replaceAll('\\', '/');
    String fullUrl = rawUrl.startsWith("http")
        ? rawUrl
        : "http://oldmarket.bhoomi.cloud/$rawUrl";

    List<String> likedUsers = json['likedByUsers'] != null
        ? List<String>.from(json['likedByUsers'].map((x) => x.toString()))
        : [];

    return ShortVideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      videoUrl: fullUrl,
      productId: json['productId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      duration: json['duration'] != null ? json['duration'] as int : null,
      isLiked: json['isLiked'] ?? false,
      likeCount: likedUsers.length,
      likedByUsers: likedUsers,
      comments: json['comments'] != null
          ? List<CommentModel>.from(
          json['comments'].map((x) => CommentModel.fromJson(x)))
          : [],
    );
  }
}