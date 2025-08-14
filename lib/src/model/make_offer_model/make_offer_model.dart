class MakeOfferResponseModel {
  final bool status;
  final String message;

  MakeOfferResponseModel({
    required this.status,
    required this.message,
  });

  factory MakeOfferResponseModel.fromJson(Map<String, dynamic> json) {
    return MakeOfferResponseModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
