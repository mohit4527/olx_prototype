class BookTestDriveModel {
  bool? status;
  String? message;
  BookTestDriveData? data;

  BookTestDriveModel({this.status, this.message, this.data});

  factory BookTestDriveModel.fromJson(Map<String, dynamic> json) {
    return BookTestDriveModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? BookTestDriveData.fromJson(json['data']) : null,
    );
  }
}

class BookTestDriveData {
  String? carId;
  String? name;
  String? phone;
  String? date;
  String? time;
  String? status;
  String? id;
  String? createdAt;
  String? updatedAt;
  int? v;

  BookTestDriveData({
    this.carId,
    this.name,
    this.phone,
    this.date,
    this.time,
    this.status,
    this.id,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory BookTestDriveData.fromJson(Map<String, dynamic> json) {
    return BookTestDriveData(
      carId: json['carId'],
      name: json['name'],
      phone: json['phone'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
