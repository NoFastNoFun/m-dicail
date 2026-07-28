import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';

@LazySingleton(as: AuthTokenStorage)
class SecureStorageAuthToken implements AuthTokenStorage {
  SecureStorageAuthToken(this._storage);

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _accessTokenKey);

  @override
  Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  @override
  Future<void> writeTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  @override
  Future<void> clearToken() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }
}
