/// Validaciones de los formularios.
///
/// Repiten las reglas del backend (authController) para avisar al usuario
/// antes de enviar la petición. El backend vuelve a validar: una capa
/// informa y la otra asegura.
class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa tu nombre';
    if (text.length < 3) return 'El nombre es muy corto';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingresa tu correo electrónico';
    if (!_emailRegExp.hasMatch(text)) return 'El correo no es válido';
    return null;
  }

  /// Contraseña de registro: mínimo 6 caracteres (misma regla del backend).
  static String? newPassword(String? value) {
    final text = value ?? '';
    if (text.isEmpty) return 'Ingresa una contraseña';
    if (text.length < 6) return 'La contraseña debe tener mínimo 6 caracteres';
    return null;
  }

  /// Contraseña de login: solo se exige que no esté vacía.
  static String? loginPassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    return null;
  }
}
