import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';

class ApiService {
  ApiService();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await http.get(Uri.parse('${ApiConstants.baseUrl}$path'), headers: _headers());
    return _decodeOrThrow(res);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: _headers(),
      body: jsonEncode(data),
    );
    return _decodeOrThrow(res);
  }

  Map<String, dynamic> _decodeOrThrow(http.Response response) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok || json['success'] != true) {
      final message = (json['error'] as Map<String, dynamic>?)?['message'] as String? ??
          'Erreur API';
      throw ApiException(message);
    }
    return json;
  }
}
