// lib/models/video_upload_response_model.dart

class VideoUploadResponseModel {
  final bool status;
  final String message;
  final VideoData data;

  VideoUploadResponseModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory VideoUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return VideoUploadResponseModel(
      status: json['status'],
      message: json['message'],
      data: VideoData.fromJson(json['data']),
    );
  }
}

class VideoData {
  final String title;
  final String videoUrl;
  final int duration;
  final String productId;
  final String id;

  final String? createdAt;
  final String? updatedAt;

  VideoData({
    required this.title,
    required this.videoUrl,
    required this.duration,
    required this.productId,
    required this.id,
    this.createdAt,
    this.updatedAt,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(
      title: json['title'],
      videoUrl: json['videoUrl'],
      duration: json['duration'],
      productId: json['productId'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}