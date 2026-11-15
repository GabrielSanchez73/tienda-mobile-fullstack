import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/formatters.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/feedback.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadCategories();
      context.read<ProductProvider>().loadProducts();
      context.read<CartProvider>().loadCart();
    });
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    context.read<CartProvider>().clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${auth.user?.name ?? 'Usuario'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Explora el catálogo',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Carrito',
            icon: Badge(
              label: Text('${cartProvider.totalQuantity}'),
              isLabelVisible: cartProvider.totalQuantity > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.loadCategories();
          await productProvider.loadProducts(
            categoryId: productProvider.selectedCategoryId,
          );
          await cartProvider.loadCart();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Categorías',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (productProvider.categories.isNotEmpty)
              SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Todas'),
                        selected: productProvider.selectedCategoryId == null,
                        onSelected: (_) {
                          productProvider.loadProducts();
                        },
                      ),
                    ),
                    ...productProvider.categories.map(
                      (category) => CategoryChip(
                        category: category,
                        isSelected:
                            productProvider.selectedCategoryId == category.id,
                        onTap: () {
                          productProvider.loadProducts(categoryId: category.id);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _buildProductList(context, productProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(BuildContext context, ProductProvider provider) {
    if (provider.isLoading && provider.products.isEmpty) {
      return const LoadingView(message: 'Cargando productos...');
    }

    if (provider.error != null && provider.products.isEmpty) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => provider.loadProducts(
          categoryId: provider.selectedCategoryId,
        ),
      );
    }

    if (provider.products.isEmpty) {
      return const MessageView(
        icon: Icons.inventory_2_outlined,
        title: 'Sin productos',
        message: 'No hay productos disponibles en este momento.',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.products.length,
      itemBuilder: (context, index) {
        final product = provider.products[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
          onAdd: () async {
            final cart = context.read<CartProvider>();
            final success = await cart.addToCart(product.id);
            if (!context.mounted) return;
            showAppSnackBar(
              context,
              success
                  ? '${product.name}: agregado al carrito (${formatPrice(product.price)})'
                  : (cart.error ?? 'Error al agregar al carrito'),
              isError: !success,
            );
          },
        );
      },
    );
  }
}
