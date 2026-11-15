import '../models/category.dart';
import '../models/product.dart';
import 'api_service.dart';

/// Consume las rutas públicas del catálogo: /api/categories y /api/products.
class CatalogService {
  /// GET /api/categories
  Future<List<Category>> getCategories() async {
    final data = await ApiService.get('/categories');
    return ApiService.asList(data).map(Category.fromJson).toList();
  }

  /// GET /api/products
  Future<List<Product>> getProducts() async {
    final data = await ApiService.get('/products');
    return ApiService.asList(data).map(Product.fromJson).toList();
  }

  /// GET /api/products/category/:categoryId
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    final data = await ApiService.get('/products/category/$categoryId');
    return ApiService.asList(data).map(Product.fromJson).toList();
  }

  /// GET /api/products/:id
  Future<Product> getProductById(int id) async {
    final data = await ApiService.get('/products/$id');
    if (data is! Map<String, dynamic>) {
      throw const ApiException('Respuesta inesperada del servidor');
    }
    return Product.fromJson(data);
  }
}
