import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'core/constants.dart';
import 'models/category.dart';
import 'models/product.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/catalog_provider.dart';
import 'screens/cart_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/products_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

/// Raíz de la aplicación: registra los providers (estado) y las rutas.
class TiendaApp extends StatelessWidget {
  const TiendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
        // El carrito depende de la sesión: cada vez que cambia el token,
        // el CartProvider lo recibe para usarlo en las rutas protegidas.
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) =>
              (cart ?? CartProvider())..updateToken(auth.token),
        ),
      ],
      child: MaterialApp(
        title: Constants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Navegación: cada nombre de ruta se convierte en su pantalla.
  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget page = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.login => const LoginScreen(),
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.products =>
        ProductsScreen(category: args is Category ? args : null),
      AppRoutes.productDetail when args is Product =>
        ProductDetailScreen(product: args),
      AppRoutes.cart => const CartScreen(),
      _ => const HomeScreen(),
    };
    return MaterialPageRoute<dynamic>(builder: (_) => page, settings: settings);
  }
}
