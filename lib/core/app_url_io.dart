import 'dart:io';

const String _apiUrlOverride = String.fromEnvironment('API_URL');

String getNativeApiUrl() {
  if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:3000/api';
  }
  return 'http://localhost:3000/api';
}
