import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/feedback.dart';
import '../widgets/product_image.dart';
import '../widgets/state_views.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProductDetail(widget.productId);
    });
  }

  Future<void> _addToCart() async {
    final cart = context.read<CartProvider>();
    final product = context.read<ProductProvider>().selectedProduct;
    final success = await cart.addToCart(widget.productId);

    if (!mounted) return;

    showAppSnackBar(
      context,
      success
          ? '${product?.name ?? 'Producto'} agregado al carrito'
          : (cart.error ?? 'Error al agregar'),
      isError: !success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final product = provider.selectedProduct;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del producto')),
      body: provider.isLoading
          ? const LoadingView(message: 'Cargando producto...')
          : provider.error != null
              ? ErrorView(
                  message: provider.error!,
                  onRetry: () => provider.loadProductDetail(widget.productId),
                )
              : product == null
                  ? const MessageView(
                      icon: Icons.search_off_rounded,
                      title: 'Producto no encontrado',
                      message:
                          'No pudimos cargar la información de este producto.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: AspectRatio(
                              aspectRatio: 1.2,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ProductImage(url: product.imageUrl),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (product.categoryName != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Chip(
                                avatar: const Icon(Icons.category_outlined, size: 18),
                                label: Text(product.categoryName!),
                              ),
                            ),
                          Text(
                            product.name,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              formatPrice(product.price),
                              style: textTheme.headlineSmall?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Descripción',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                (product.description == null ||
                                        product.description!.trim().isEmpty)
                                    ? 'Sin descripción disponible para este producto.'
                                    : product.description!,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: product != null
          ? SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: provider.isLoading ? null : _addToCart,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Agregar al carrito'),
                ),
              ),
            )
          : null,
    );
  }
}
