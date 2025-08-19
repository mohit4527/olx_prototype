class VerifyOtpResponse {
  final String message;
  final String token;
  final User user;

  VerifyOtpResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String phone;
  final String name;
  final String profileImage;

  User({
    required this.id,
    required this.phone,
    required this.name,
    required this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }
}
