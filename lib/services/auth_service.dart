import '../core/json_parsers.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Respuesta de registro/login: { message, token, user }.
class AuthResponse {
  const AuthResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  final String message;
  final String token;
  final User user;

  factory AuthResponse.fromJson(dynamic data) {
    if (data is! Map<String, dynamic> ||
        data['user'] is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor');
    }
    return AuthResponse(
      message: asString(data['message']),
      token: asString(data['token']),
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}

/// Consume las rutas /api/auth del backend.
class AuthService {
  /// POST /api/auth/login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthResponse.fromJson(data);
  }

  /// POST /api/auth/register
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await ApiService.post(
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponse.fromJson(data);
  }
}
