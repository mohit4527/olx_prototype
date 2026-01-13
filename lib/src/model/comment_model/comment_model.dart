import 'dart:convert';

// Models for Comment Functionality

// Add Comment Response
AddCommentResponse addCommentResponseFromJson(String str) =>
    AddCommentResponse.fromJson(json.decode(str));

String addCommentResponseToJson(AddCommentResponse data) =>
    json.encode(data.toJson());

class AddCommentResponse {
  bool? success;
  String? message;
  Comment? comment;

  AddCommentResponse({this.success, this.message, this.comment});

  factory AddCommentResponse.fromJson(Map<String, dynamic> json) =>
      AddCommentResponse(
        success: json["success"],
        message: json["message"],
        comment: json["comment"] != null
            ? Comment.fromJson(json["comment"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "comment": comment?.toJson(),
  };
}

// Get Comments Response
CommentsListResponse commentsListResponseFromJson(String str) =>
    CommentsListResponse.fromJson(json.decode(str));

String commentsListResponseToJson(CommentsListResponse data) =>
    json.encode(data.toJson());

class CommentsListResponse {
  bool? success;
  List<Comment>? comments;
  Pagination? pagination;

  CommentsListResponse({this.success, this.comments, this.pagination});

  factory CommentsListResponse.fromJson(Map<String, dynamic> json) =>
      CommentsListResponse(
        success: json["success"],
        comments: json["comments"] != null
            ? List<Comment>.from(
                json["comments"].map((x) => Comment.fromJson(x)),
              )
            : [],
        pagination: json["pagination"] != null
            ? Pagination.fromJson(json["pagination"])
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "comments": comments != null
        ? List<dynamic>.from(comments!.map((x) => x.toJson()))
        : [],
    "pagination": pagination?.toJson(),
  };
}

// Comment Model
class Comment {
  String? id;
  String? userId;
  String? targetType;
  String? targetId;
  String? comment;
  String? parentCommentId;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;
  List<Comment>? replies; // For nested replies

  Comment({
    this.id,
    this.userId,
    this.targetType,
    this.targetId,
    this.comment,
    this.parentCommentId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // userId can be either String or Object
    final userIdValue = json["userId"];
    final String? userIdString = userIdValue is String
        ? userIdValue
        : (userIdValue is Map ? userIdValue["_id"] : null);

    // Parse user object from userId if it's an object
    final User? userObject = userIdValue is Map<String, dynamic>
        ? User.fromJson(userIdValue)
        : (json["user"] != null ? User.fromJson(json["user"]) : null);

    return Comment(
      id: json["_id"],
      userId: userIdString,
      targetType: json["targetType"],
      targetId: json["targetId"],
      comment: json["comment"],
      parentCommentId: json["parentCommentId"],
      createdAt: json["createdAt"] != null
          ? DateTime.parse(json["createdAt"])
          : null,
      updatedAt: json["updatedAt"] != null
          ? DateTime.parse(json["updatedAt"])
          : null,
      user: userObject,
      replies: [], // Initialize empty replies list
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "targetType": targetType,
    "targetId": targetId,
    "comment": comment,
    "parentCommentId": parentCommentId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "user": user?.toJson(),
  };
}

// User Model (for comment author)
class User {
  String? id;
  String? name;
  String? avatar;

  User({this.id, this.name, this.avatar});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    name: json["name"],
    avatar: json["avatar"] ?? json["profileImage"],
  );

  Map<String, dynamic> toJson() => {"_id": id, "name": name, "avatar": avatar};
}

// Pagination Model
class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalComments;
  int? limit;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalComments,
    this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalComments: json["totalComments"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalComments": totalComments,
    "limit": limit,
  };
}

// Delete Comment Response
DeleteCommentResponse deleteCommentResponseFromJson(String str) =>
    DeleteCommentResponse.fromJson(json.decode(str));

String deleteCommentResponseToJson(DeleteCommentResponse data) =>
    json.encode(data.toJson());

class DeleteCommentResponse {
  bool? success;
  String? message;

  DeleteCommentResponse({this.success, this.message});

  factory DeleteCommentResponse.fromJson(Map<String, dynamic> json) =>
      DeleteCommentResponse(success: json["success"], message: json["message"]);

  Map<String, dynamic> toJson() => {"success": success, "message": message};
}
