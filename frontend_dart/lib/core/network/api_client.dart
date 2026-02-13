import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/cart/domain/cart_item.dart';
import '../../features/orders/domain/order_summary.dart';
import '../../features/products/domain/product.dart';
import '../config/app_config.dart';

class ApiClient {
  ApiClient({this.token});

  final String? token;

  String get baseUrl => AppConfig.apiBaseUrl;

  ApiClient withToken(String value) => ApiClient(token: value);

  Map<String, String> _headers({bool auth = false}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<String> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final json = _decode(res);
    if (res.statusCode != 200 || json['success'] != true) {
      throw Exception(_extractError(json, fallback: 'Echec de connexion.'));
    }
    return json['data']['token'] as String;
  }

  Future<List<Product>> fetchProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/products'),
      headers: _headers(auth: token != null),
    );
    final json = _decode(res);
    if (res.statusCode != 200 || json['success'] != true) {
      throw Exception(_extractError(json, fallback: 'Impossible de charger les produits.'));
    }
    final items = (json['data'] as List<dynamic>).cast<Map<String, dynamic>>();
    return items.map(Product.fromJson).toList();
  }

  Future<OrderSummary> createOrder(List<CartItem> cart) async {
    final body = {
      'items': cart
          .map((item) => {'productId': item.product.id, 'quantity': item.quantity})
          .toList(),
      'shippingAddress': {
        'street': 'Ouagadougou',
        'city': 'Ouagadougou',
        'country': 'Burkina Faso',
        'phone': '+22670000000',
      }
    };

    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: _headers(auth: true),
      body: jsonEncode(body),
    );
    final json = _decode(res);
    if (res.statusCode != 201 || json['success'] != true) {
      throw Exception(_extractError(json, fallback: 'Creation commande echouee.'));
    }
    final order = json['data']['order'] as Map<String, dynamic>;
    return OrderSummary(id: order['_id'] as String, total: (order['total'] as num).toDouble());
  }

  Future<void> payOrder({
    required String orderId,
    required double amount,
    required String method,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: _headers(auth: true),
      body: jsonEncode({'orderId': orderId, 'method': method, 'amount': amount}),
    );
    final json = _decode(res);
    if (res.statusCode != 201 || json['success'] != true) {
      throw Exception(_extractError(json, fallback: 'Paiement echoue.'));
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'error': {'message': 'Reponse serveur invalide.'}};
    }
  }

  String _extractError(Map<String, dynamic> json, {required String fallback}) {
    final error = json['error'];
    if (error is Map<String, dynamic> && error['message'] is String) {
      return error['message'] as String;
    }
    return fallback;
  }
}
