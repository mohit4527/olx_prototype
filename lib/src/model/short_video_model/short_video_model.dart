class CommentModel {
  final String id;
  final String userId;
  final String userName;
  final String userImage;
  final String text;

  CommentModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userImage = '',
    required this.text,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Normalize several possible server shapes for comment -> user data
    String id = json['id']?.toString() ?? json['_id']?.toString() ?? '';
    String userId = '';
    String userName = '';
    String userImage = '';
    try {
      // If server returns a nested user object
      if (json['user'] is Map) {
        final u = json['user'] as Map<String, dynamic>;
        userId = (u['_id'] ?? u['id'] ?? u['user_id'] ?? '').toString();
        userName = (u['name'] ?? u['displayName'] ?? u['username'] ?? '')
            .toString();
        userImage =
            (u['photo'] ??
                    u['profileImage'] ??
                    u['profile_image'] ??
                    u['image'] ??
                    '')
                .toString();
      }

      // Older server shapes where fields are at top-level
      userId = userId.isNotEmpty
          ? userId
          : (json['user_id']?.toString() ?? json['userId']?.toString() ?? '');
      userName = userName.isNotEmpty
          ? userName
          : (json['user_name']?.toString() ??
                json['userName']?.toString() ??
                '');
      userImage = userImage.isNotEmpty
          ? userImage
          : (() {
              try {
                if (json['user_image'] != null)
                  return json['user_image'].toString();
                if (json['userImage'] != null)
                  return json['userImage'].toString();
                if (json['uploader'] is Map &&
                    json['uploader']['profileImage'] != null)
                  return json['uploader']['profileImage'].toString();
              } catch (_) {}
              return '';
            })();
    } catch (_) {}

    return CommentModel(
      id: id,
      userId: userId,
      userName: userName,
      userImage: userImage,
      text: json['text']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_image': userImage,
      'text': text,
    };
  }
}

// APIs differ in how they return uploader info. Handle common possibilities:
// - json['user'] { 'name', 'photo' }
// - json['uploader'] { 'name', 'image' }
// - json['user_name'] and json['user_image']
String _extractUploaderName(Map<String, dynamic> json) {
  try {
    if (json['user'] is Map && json['user']['name'] != null) {
      return json['user']['name'].toString();
    }
    if (json['uploader'] is Map && json['uploader']['name'] != null) {
      return json['uploader']['name'].toString();
    }
    if (json['user_name'] != null) return json['user_name'].toString();
    if (json['uploaderName'] != null) return json['uploaderName'].toString();
  } catch (_) {}
  return 'Unknown user';
}

String _extractUploaderImage(Map<String, dynamic> json) {
  try {
    if (json['user'] is Map && json['user']['photo'] != null) {
      return json['user']['photo'].toString();
    }
    // prefer 'profileImage' which your API uses
    if (json['uploader'] is Map) {
      final up = json['uploader'] as Map<String, dynamic>;
      if (up['profileImage'] != null) return up['profileImage'].toString();
      if (up['profile_image'] != null) return up['profile_image'].toString();
      if (up['image'] != null) return up['image'].toString();
    }
    if (json['user_image'] != null) return json['user_image'].toString();
    if (json['uploaderImage'] != null) return json['uploaderImage'].toString();
  } catch (_) {}
  return '';
}

class VideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final String thumbnailUrl; // <-- added for suggested videos
  final String uploaderName;
  final String uploaderImage;
  final String uploaderId;
  final int duration;
  final String productId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<String> likes;
  List<CommentModel> comments;
  List<String> sharedWith;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl, // <-- added
    required this.duration,
    required this.productId,
    this.createdAt,
    this.updatedAt,
    List<String>? likes,
    List<CommentModel>? comments,
    List<String>? sharedWith,
    String? uploaderName,
    String? uploaderImage,
    String? uploaderId,
  }) : likes = likes ?? [],
       comments = comments ?? [],
       sharedWith = sharedWith ?? [],
       uploaderName = uploaderName ?? 'Unknown user',
       uploaderImage = uploaderImage ?? '',
       uploaderId = uploaderId ?? '';

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    final commentsJson = json['comments'] as List<dynamic>? ?? [];
    return VideoModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '', // <-- added
      duration: (json['duration'] is int)
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      productId: json['productId']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      likes:
          (json['likes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      comments: commentsJson
          .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      sharedWith:
          (json['sharedWith'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      uploaderName: _extractUploaderName(json),
      uploaderImage: _extractUploaderImage(json),
      uploaderId: (() {
        try {
          if (json['uploadedBy'] is String)
            return json['uploadedBy'].toString();
          if (json['uploadedBy'] is Map && json['uploadedBy']['_id'] != null)
            return json['uploadedBy']['_id'].toString();
          if (json['uploader'] is Map && json['uploader']['_id'] != null)
            return json['uploader']['_id'].toString();
          if (json['uploader'] is String) return json['uploader'].toString();
          if (json['user'] is Map && json['user']['_id'] != null)
            return json['user']['_id'].toString();
        } catch (_) {}
        return '';
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl, // <-- added
      'duration': duration,
      'productId': productId,
      'uploadedBy': uploaderId,
      'uploaderName': uploaderName,
      'uploaderImage': uploaderImage,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likes': likes,
      'comments': comments.map((c) => c.toJson()).toList(),
      'sharedWith': sharedWith,
    };
  }

  bool isLikedBy(String userId) => likes.contains(userId);

  void toggleLike(String userId) {
    if (likes.contains(userId)) {
      likes.remove(userId);
    } else {
      likes.add(userId);
    }
  }

  void addComment(CommentModel comment) {
    comments.add(comment);
  }
}

class UploadVideoModel {
  final String videoPath;
  final String title;
  final String productId;
  final int duration;

  UploadVideoModel({
    required this.videoPath,
    required this.title,
    required this.productId,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'videoPath': videoPath,
      'title': title,
      'productId': productId,
      'duration': duration,
    };
  }
}
