import '../models/cart_item.dart';
import 'api_service.dart';

/// Consume las rutas protegidas /api/cart. Todas envían el token JWT.
class CartService {
  /// GET /api/cart
  Future<List<CartItem>> getCart(String token) async {
    final data = await ApiService.get('/cart', token: token);
    return ApiService.asList(data).map(CartItem.fromJson).toList();
  }

  /// POST /api/cart  { product_id, quantity }
  Future<String> addToCart(
    String token, {
    required int productId,
    int quantity = 1,
  }) async {
    final data = await ApiService.post(
      '/cart',
      token: token,
      body: {'product_id': productId, 'quantity': quantity},
    );
    return ApiService.messageOf(data, 'Producto agregado al carrito');
  }

  /// PUT /api/cart/:id  { quantity }
  Future<void> updateQuantity(
    String token, {
    required int itemId,
    required int quantity,
  }) async {
    await ApiService.put(
      '/cart/$itemId',
      token: token,
      body: {'quantity': quantity},
    );
  }

  /// DELETE /api/cart/:id
  Future<void> removeItem(String token, int itemId) async {
    await ApiService.delete('/cart/$itemId', token: token);
  }

  /// DELETE /api/cart
  Future<void> clearCart(String token) async {
    await ApiService.delete('/cart', token: token);
  }
}
