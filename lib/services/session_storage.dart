import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../models/user.dart';

/// Sesión guardada en el teléfono.
class StoredSession {
  const StoredSession({required this.token, required this.user});

  final String token;
  final User user;
}

/// Guarda en el dispositivo (SharedPreferences) el token JWT, los datos del
/// usuario y la URL del servidor, para no pedir login cada vez que se abre
/// la app.
class SessionStorage {
  Future<void> saveSession(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.tokenKey, token);
    await prefs.setString(Constants.userKey, jsonEncode(user.toJson()));
  }

  Future<StoredSession?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Constants.tokenKey);
    final userJson = prefs.getString(Constants.userKey);
    if (token == null || userJson == null) return null;

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) return null;
      return StoredSession(token: token, user: User.fromJson(decoded));
    } on FormatException {
      return null;
    }
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
  }

  Future<String?> readApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.apiUrlKey);
  }

  /// Guarda la URL del servidor. Con null se vuelve a la URL por defecto.
  Future<void> saveApiUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null) {
      await prefs.remove(Constants.apiUrlKey);
    } else {
      await prefs.setString(Constants.apiUrlKey, url);
    }
  }

  /// Revisa la fecha de expiración ("exp") que viene dentro del JWT.
  /// El token va codificado en Base64 (no cifrado), por eso se puede leer.
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final data = jsonDecode(payload);
      if (data is! Map<String, dynamic>) return true;
      final exp = data['exp'];
      if (exp is! num) return false; // sin fecha de expiración
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return true;
    }
  }
}
