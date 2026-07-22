import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/config/app_platform.dart';
import 'package:medicail/core/di/injection.dart';

@lazySingleton
class DesktopDebugBackendUrlStore {
  DesktopDebugBackendUrlStore(this._storage, this._config);

  static const String _storageKey = 'debug_backend_url';

  final FlutterSecureStorage _storage;
  final AppConfig _config;

  Future<void> hydrate() async {
    if (!isDesktopDebugBackendUrlEnabled) return;

    final stored = await _storage.read(key: _storageKey);
    _config.applyDebugBackendUrlOverride(stored);
  }

  Future<void> save(String? url) async {
    if (!isDesktopDebugBackendUrlEnabled) return;

    final trimmed = url?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await _storage.delete(key: _storageKey);
      _config.applyDebugBackendUrlOverride(null);
    } else {
      await _storage.write(key: _storageKey, value: trimmed);
      _config.applyDebugBackendUrlOverride(trimmed);
    }
    _syncDioBaseUrl();
  }

  Future<void> reset() => save(null);

  void _syncDioBaseUrl() {
    if (!getIt.isRegistered<Dio>()) return;
    getIt<Dio>().options.baseUrl = _config.baseUrl;
  }

  static bool isValidBackendUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
