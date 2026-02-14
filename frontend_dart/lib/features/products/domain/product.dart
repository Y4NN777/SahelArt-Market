class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.imageUrl,
    this.description,
    this.category,
    this.artisan,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.specifications,
  });

  final String id;
  final String name;
  final double price;
  final int stock;
  final String? imageUrl;
  final String? description;
  final String? category;
  final Artisan? artisan;
  final double rating;
  final int reviewsCount;
  final Map<String, String>? specifications;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      name: json['name'] as String? ?? 'Sans nom',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      imageUrl: json['image'] as String?,
      description: json['description'] as String?,
      category: json['category'] as String?,
      artisan: json['vendor'] != null
          ? Artisan.fromJson(json['vendor'] as Map<String, dynamic>)
          : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      specifications: json['specifications'] != null
          ? Map<String, String>.from(json['specifications'] as Map)
          : null,
    );
  }
}

class Artisan {
  Artisan({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.location,
    this.bio,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final String? location;
  final String? bio;

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['_id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar'] as String?,
      location: json['location'] as String?,
      bio: json['bio'] as String?,
    );
  }
}
