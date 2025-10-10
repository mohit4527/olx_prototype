class FuelModel {
  final String fuel;
  final String date;
  final String price;
  final String change;
  final String trend;

  FuelModel({
    required this.fuel,
    required this.date,
    required this.price,
    required this.change,
    required this.trend,
  });

  factory FuelModel.fromJson(Map<String, dynamic> json) {
    return FuelModel(
      fuel: json['fuel'],
      date: json['date'],
      price: json['price'],
      change: json['change'],
      trend: json['trend'],
    );
  }
}
