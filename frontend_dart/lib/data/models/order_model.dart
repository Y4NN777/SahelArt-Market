class OrderModel {
  OrderModel({
    required this.id,
    required this.total,
  });

  final String id;
  final double total;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'] as String,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
