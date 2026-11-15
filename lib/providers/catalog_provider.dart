import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/catalog_service.dart';

/// Estado del catálogo: categorías, productos destacados del home y el
/// listado de productos que se está viendo (todos o de una categoría).
class CatalogProvider extends ChangeNotifier {
  CatalogProvider({CatalogService? service})
      : _service = service ?? CatalogService();

  final CatalogService _service;

  // ─── Home ──────────────────────────────────────────────────────────────
  List<Category> _categories = const [];
  List<Product> _featured = const [];
  bool _isLoadingHome = false;
  String? _homeError;

  List<Category> get categories => _categories;
  List<Product> get featured => _featured;
  bool get isLoadingHome => _isLoadingHome;
  String? get homeError => _homeError;

  // ─── Listado de productos ──────────────────────────────────────────────
  List<Product> _products = const [];
  bool _isLoadingProducts = false;
  String? _productsError;
  String _query = '';
  int _productsRequest = 0;

  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;
  String get query => _query;

  /// Productos filtrados por el texto del buscador.
  List<Product> get products {
    if (_query.isEmpty) return _products;
    final q = _query.toLowerCase();
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(q) ||
              p.description.toLowerCase().contains(q),
        )
        .toList();
  }

  /// Carga categorías y productos en paralelo para el home.
  Future<void> loadHome() async {
    _isLoadingHome = true;
    _homeError = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _service.getCategories(),
        _service.getProducts(),
      ]);
      _categories = results[0] as List<Category>;
      _featured = (results[1] as List<Product>).take(6).toList();
    } on ApiException catch (e) {
      _homeError = e.message;
    } catch (e) {
      _homeError = 'Ocurrió un error inesperado: $e';
    } finally {
      _isLoadingHome = false;
      notifyListeners();
    }
  }

  /// Carga todos los productos ([categoryId] null) o los de una categoría.
  Future<void> loadProducts({int? categoryId}) async {
    final request = ++_productsRequest;
    _isLoadingProducts = true;
    _productsError = null;
    _products = const [];
    _query = '';
    notifyListeners();
    try {
      final result = categoryId == null
          ? await _service.getProducts()
          : await _service.getProductsByCategory(categoryId);
      if (request != _productsRequest) return; // llegó una petición más nueva
      _products = result;
    } on ApiException catch (e) {
      if (request != _productsRequest) return;
      _productsError = e.message;
    } catch (e) {
      if (request != _productsRequest) return;
      _productsError = 'Ocurrió un error inesperado: $e';
    } finally {
      if (request == _productsRequest) {
        _isLoadingProducts = false;
        notifyListeners();
      }
    }
  }

  /// Buscador: filtra la lista que ya está cargada (sin ir al servidor).
  void search(String text) {
    _query = text.trim();
    notifyListeners();
  }

  /// Detalle actualizado de un producto (GET /api/products/:id).
  Future<Product> fetchProduct(int id) => _service.getProductById(id);
}
