const String _apiUrlOverride = String.fromEnvironment('API_URL');

String getNativeApiUrl() =>
    _apiUrlOverride.isNotEmpty ? _apiUrlOverride : 'http://localhost:3000/api';
