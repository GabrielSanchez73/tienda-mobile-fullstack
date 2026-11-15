import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../models/cart_item.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};

    if (auth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  String _extractError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] != null) {
        return body['message'].toString();
      }
    } catch (_) {}
    return 'Error en la solicitud (${response.statusCode})';
  }

  Exception _friendlyError(Object e) {
    if (e is TimeoutException) {
      return Exception(
        'Tiempo de espera agotado. Verifica que el servidor esté activo y que la dirección IP sea correcta.',
      );
    }
    if (e is SocketException) {
      return Exception(
        'No se pudo conectar con el servidor. Revisa la red Wi-Fi, la IP/puerto y que el backend esté en ejecución.',
      );
    }
    if (e is http.ClientException) {
      return Exception(
        'No se pudo completar la solicitud. Revisa la conexión con el servidor.',
      );
    }
    if (e is FormatException) {
      return Exception('Respuesta inválida del servidor.');
    }
    return Exception('Error de conexión: $e');
  }

  Future<http.Response> _get(
    String path, {
    bool auth = false,
  }) async {
    try {
      return await http
          .get(Uri.parse('${AppConstants.baseUrl}$path'),
              headers: await _headers(auth: auth))
          .timeout(_timeout);
    } catch (e) {
      throw _friendlyError(e);
    }
  }

  Future<http.Response> _post(
    String path, {
    bool auth = false,
    Object? body,
  }) async {
    try {
      return await http
          .post(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
    } catch (e) {
      throw _friendlyError(e);
    }
  }

  Future<http.Response> _put(
    String path, {
    bool auth = false,
    Object? body,
  }) async {
    try {
      return await http
          .put(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
    } catch (e) {
      throw _friendlyError(e);
    }
  }

  Future<http.Response> _delete(String path, {bool auth = false}) async {
    try {
      return await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout);
    } catch (e) {
      throw _friendlyError(e);
    }
  }

  Future<User> register(String name, String email, String password) async {
    final response = await _post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.saveToken(data['token'] as String);
      await _storage.saveUserName(data['user']['name'] as String);
      return User.fromJson(data['user']);
    }

    throw Exception(_extractError(response));
  }

  Future<User> login(String email, String password) async {
    final response = await _post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.saveToken(data['token'] as String);
      await _storage.saveUserName(data['user']['name'] as String);
      return User.fromJson(data['user']);
    }

    throw Exception(_extractError(response));
  }

  Future<List<Category>> getCategories() async {
    final response = await _get('/categories');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Category.fromJson(e)).toList();
    }

    throw Exception(_extractError(response));
  }

  Future<List<Product>> getProducts() async {
    final response = await _get('/products');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception(_extractError(response));
  }

  Future<Product> getProductById(int id) async {
    final response = await _get('/products/$id');

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    }

    throw Exception(_extractError(response));
  }

  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final response = await _get('/products/category/$categoryId');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception(_extractError(response));
  }

  Future<List<CartItem>> getCart() async {
    final response = await _get('/cart', auth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CartItem.fromJson(e)).toList();
    }

    throw Exception(_extractError(response));
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    final response = await _post(
      '/cart',
      auth: true,
      body: {'product_id': productId, 'quantity': quantity},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> updateCartItem(int id, int quantity) async {
    final response = await _put(
      '/cart/$id',
      auth: true,
      body: {'quantity': quantity},
    );

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }

  Future<void> removeCartItem(int id) async {
    final response = await _delete('/cart/$id', auth: true);

    if (response.statusCode != 200) {
      throw Exception(_extractError(response));
    }
  }
}
