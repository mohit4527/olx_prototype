import 'package:intl/intl.dart';

class BookTestDriveScreenModel {
  String? id;
  String? name;
  String? phone;
  String? date;
  String? time;
  String? status;
  String? carId;

  BookTestDriveScreenModel({
    this.id,
    this.name,
    this.phone,
    this.date,
    this.time,
    this.status,
    this.carId,
  });

  factory BookTestDriveScreenModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawCarId = json['carId'];
    final String? mappedCarId = (rawCarId is Map)
        ? rawCarId['_id']?.toString()
        : rawCarId?.toString();

    return BookTestDriveScreenModel(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      date: json['date']?.toString(),
      time: json['time']?.toString(),
      status: json['status']?.toString(),
      carId: mappedCarId,
    );
  }

  String get formattedDate {
    if (date == null || date!.isEmpty) return "No Date";
    try {
      final parsedDate = DateTime.parse(date!);
      return DateFormat('dd MMM yyyy').format(parsedDate);
    } catch (e) {
      print("⚠️ Date parsing failed: $date → $e");
      return "Invalid Date";
    }
  }

  String get formattedTime {
    if (time == null || time!.isEmpty) return "No Time";
    try {
      final parsedTime = DateFormat("HH:mm").parseLoose(time!);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      print("⚠️ Time parsing failed: $time → $e");
      return time!;
    }
  }
}
