// Conversores tolerantes para leer el JSON del backend.
// mysql2 puede devolver números como texto (por ejemplo DECIMAL "49.99"),
// así que no se asume el tipo exacto de cada campo.

int asInt(Object? value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}

double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

String asString(Object? value, {String fallback = ''}) {
  return value?.toString() ?? fallback;
}

String? asNullableString(Object? value) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return null;
  return text;
}
