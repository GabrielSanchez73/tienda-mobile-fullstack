/// Nombres de las rutas (pantallas) de la aplicación.
/// El mapeo ruta -> pantalla está en app.dart (onGenerateRoute).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String products =
      '/products'; // argumento: Category? (null = todos)
  static const String productDetail = '/product'; // argumento: Product
  static const String cart = '/cart';
}
