class UserModel {
  UserModel({
    required this.id,
    required this.email,
    required this.role,
  });

  final String id;
  final String email;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
    );
  }
}
