class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  final String id;
  final String name;
  final double price;
  final int stock;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'Sans nom',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }
}
