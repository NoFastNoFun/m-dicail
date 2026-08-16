import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_platform.dart';

@lazySingleton
class AppConfig {
  static const String _debugDefaultBaseUrl = 'http://10.10.161.239//api/v1';
  static const String _releaseBaseUrl = 'https://medicail.nf2.dev/api/v1';
  static const String mockAdminToken = 'mock_admin_token';

  String? _debugBackendUrlOverride;

  static bool isOfflineMode(String? token) =>
      token == null || token == mockAdminToken;

  bool get supportsDebugBackendUrl => isDesktopDebugBackendUrlEnabled;

  String? get debugBackendUrlOverride =>
      supportsDebugBackendUrl ? _debugBackendUrlOverride : null;

  void applyDebugBackendUrlOverride(String? url) {
    if (!supportsDebugBackendUrl) return;
    final trimmed = url?.trim();
    _debugBackendUrlOverride =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  String get resolvedDefaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (kReleaseMode) {
      return _releaseBaseUrl;
    }
    return _debugDefaultBaseUrl;
  }

  String get baseUrl {
    final override = debugBackendUrlOverride;
    if (override != null) {
      return override;
    }
    return resolvedDefaultBaseUrl;
  }

  Duration get connectTimeout => const Duration(seconds: 15);

  Duration get receiveTimeout => const Duration(seconds: 30);

  Duration get enhanceUploadTimeout => const Duration(minutes: 2);

  Duration get enhanceReceiveTimeout => const Duration(minutes: 10);

  /// AI service base URL (`…/ai/v1`), derived from [baseUrl] (`…/api/v1`).
  String get aiBaseUrl {
    final api = baseUrl;
    if (api.contains('/api/v1')) {
      return api.replaceFirst('/api/v1', '/ai/v1');
    }
    return api.replaceFirst('/api/', '/ai/');
  }
}
