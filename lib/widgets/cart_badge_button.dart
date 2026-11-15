import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_routes.dart';
import '../providers/cart_provider.dart';

/// Ícono del carrito con el número de unidades. Se actualiza solo cuando
/// cambia el total gracias a context.select.
class CartBadgeButton extends StatelessWidget {
  const CartBadgeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select<CartProvider, int>((c) => c.totalQuantity);
    return IconButton(
      tooltip: 'Carrito',
      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
