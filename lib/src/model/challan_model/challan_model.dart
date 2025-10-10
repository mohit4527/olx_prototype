class ChallanModel {
  final String challanNo;
  final String date;
  final String reason;
  final String amount;

  ChallanModel({
    required this.challanNo,
    required this.date,
    required this.reason,
    required this.amount,
  });

  factory ChallanModel.fromJson(Map<String, dynamic> json) {
    return ChallanModel(
      challanNo: json['challan_no'] ?? 'N/A',
      date: json['date'] ?? 'N/A',
      reason: json['reason'] ?? 'N/A',
      amount: json['amount'] ?? '₹0',
    );
  }
}
