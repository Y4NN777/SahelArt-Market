import '../models/user_model.dart';
import 'api_service.dart';

class AuthResponse {
  AuthResponse({
    required this.user,
    required this.token,
  });

  final UserModel user;
  final String token;
}

class AuthService {
  AuthService(this._apiService);
  final ApiService _apiService;

  Future<AuthResponse> login(String email, String password) async {
    final json = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}
