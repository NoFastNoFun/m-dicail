import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/core/storage/secure_storage_safe.dart';

@LazySingleton(as: AuthTokenStorage)
class SecureStorageAuthToken implements AuthTokenStorage {
  SecureStorageAuthToken(this._storage);

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() =>
      SecureStorageSafe.read(_storage, key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() =>
      SecureStorageSafe.read(_storage, key: _refreshTokenKey);

  @override
  Future<void> writeToken(String token) =>
      SecureStorageSafe.write(_storage, key: _accessTokenKey, value: token);

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      SecureStorageSafe.write(
        _storage,
        key: _accessTokenKey,
        value: accessToken,
      ),
      SecureStorageSafe.write(
        _storage,
        key: _refreshTokenKey,
        value: refreshToken,
      ),
    ]);
  }

  @override
  Future<void> clearToken() async {
    await Future.wait([
      SecureStorageSafe.delete(_storage, key: _accessTokenKey),
      SecureStorageSafe.delete(_storage, key: _refreshTokenKey),
    ]);
  }
}
