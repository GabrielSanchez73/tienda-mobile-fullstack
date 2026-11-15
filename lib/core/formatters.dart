/// Da formato de moneda a un precio: 1999.9 -> "$1,999.90".
String formatPrice(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final integerPart = parts[0];
  final buffer = StringBuffer();

  for (var i = 0; i < integerPart.length; i++) {
    final remaining = integerPart.length - i;
    buffer.write(integerPart[i]);
    // Separador de miles cada tres cifras
    if (remaining > 1 && remaining % 3 == 1) {
      buffer.write(',');
    }
  }

  return '\$${buffer.toString()}.${parts[1]}';
}
