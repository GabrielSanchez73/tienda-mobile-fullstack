import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/catalog_provider.dart';
import '../widgets/cart_badge_button.dart';
import '../widgets/feedback.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';

/// Pantalla 4: listado de productos.
/// - Con categoría: GET /api/products/category/:id
/// - Sin categoría: GET /api/products
/// Incluye un buscador que filtra la lista en el teléfono.
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.category});

  final Category? category;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  /// Evita mostrar por un instante la lista de otra categoría antes de que
  /// arranque la primera carga.
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _started = true;
    _searchController.clear();
    await context
        .read<CatalogProvider>()
        .loadProducts(categoryId: widget.category?.id);
  }

  void _openDetail(Product product) {
    Navigator.of(context)
        .pushNamed(AppRoutes.productDetail, arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final description = widget.category?.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category?.name ?? 'Todos los productos'),
        actions: const [CartBadgeButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) =>
                      context.read<CatalogProvider>().search(text),
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpiar',
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              context.read<CatalogProvider>().search('');
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          Expanded(child: _buildContent(catalog)),
        ],
      ),
    );
  }

  Widget _buildContent(CatalogProvider catalog) {
    if (!_started || catalog.isLoadingProducts) {
      return const LoadingView(message: 'Cargando productos...');
    }

    final error = catalog.productsError;
    if (error != null) {
      return ErrorView(message: error, onRetry: _load);
    }

    final products = catalog.products;
    if (products.isEmpty) {
      final query = catalog.query;
      return MessageView(
        icon: Icons.search_off_rounded,
        title: 'Sin resultados',
        message: query.isNotEmpty
            ? 'No hay productos que coincidan con "$query".'
            : 'Esta categoría todavía no tiene productos.',
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisExtent: 272,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            onTap: () => _openDetail(product),
            onAdd: () => addToCartWithFeedback(context, product),
          );
        },
      ),
    );
  }
}
