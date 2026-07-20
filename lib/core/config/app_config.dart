import 'package:injectable/injectable.dart';

@lazySingleton
class AppConfig {
  static const String _defaultBaseUrl = 'http://localhost:8000/api/v1';
  static const String mockAdminToken = 'mock_admin_token';

  static bool isOfflineMode(String? token) =>
      token == null || token == mockAdminToken;

  String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return _defaultBaseUrl;
  }

  Duration get connectTimeout => const Duration(seconds: 15);

  Duration get receiveTimeout => const Duration(seconds: 30);
}
