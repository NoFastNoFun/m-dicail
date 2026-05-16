import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/auth_token_storage.dart';

@LazySingleton(as: AuthTokenStorage)
class SecureStorageAuthToken implements AuthTokenStorage {
  SecureStorageAuthToken(this._storage);

  static const String _tokenKey = 'auth_access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
