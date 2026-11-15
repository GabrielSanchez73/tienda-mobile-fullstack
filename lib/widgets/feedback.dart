import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

/// Muestra un mensaje en la parte inferior de la pantalla.
void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  SnackBarAction? action,
}) {
  final scheme = Theme.of(context).colorScheme;
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: isError ? TextStyle(color: scheme.onError) : null,
      ),
      backgroundColor: isError ? scheme.error : null,
      action: action,
    ),
  );
}

/// Cierra la sesión y vuelve al login (por ejemplo, si el token expiró).
Future<void> forceLogout(BuildContext context, {String? message}) async {
  final navigator = Navigator.of(context);
  if (message != null) showAppSnackBar(context, message, isError: true);
  await context.read<AuthProvider>().logout();
  navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
}

String _messageOf(Object error) {
  final text = error.toString();
  return text.startsWith('Exception: ')
      ? text.substring('Exception: '.length)
      : text;
}

bool _isUnauthorized(Object error) {
  final msg = _messageOf(error).toLowerCase();
  return msg.contains('401') ||
      msg.contains('no autorizado') ||
      msg.contains('token inválido') ||
      msg.contains('token invalido') ||
      msg.contains('sesión expir') ||
      msg.contains('sesion expir');
}

/// Manejo común de errores de las acciones del usuario.
/// Si el backend responde 401, la sesión venció: se vuelve al login.
Future<void> handleActionError(BuildContext context, Object error) async {
  if (_isUnauthorized(error)) {
    await forceLogout(
      context,
      message: 'Tu sesión expiró. Inicia sesión de nuevo.',
    );
    return;
  }
  if (!context.mounted) return;
  showAppSnackBar(context, _messageOf(error), isError: true);
}

/// Agrega un producto al carrito y muestra el resultado con la opción
/// de ir al carrito.
Future<void> addToCartWithFeedback(
  BuildContext context,
  Product product, {
  int quantity = 1,
}) async {
  final navigator = Navigator.of(context);
  final cart = context.read<CartProvider>();
  final success = await cart.addToCart(product.id, quantity: quantity);
  if (!context.mounted) return;
  if (success) {
    showAppSnackBar(
      context,
      '${product.name}: agregado al carrito',
      action: SnackBarAction(
        label: 'Ver carrito',
        onPressed: () => navigator.pushNamed(AppRoutes.cart),
      ),
    );
    return;
  }
  final error = cart.error ?? 'Ocurrió un error inesperado';
  await handleActionError(context, Exception(error));
}
