import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/config/app_config.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  static const _mockAdmin = User(
    id: 999,
    email: 'admin@local.com',
    fullName: 'Admin Local',
  );

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    const enableMockAdmin = bool.fromEnvironment('ENABLE_MOCK_ADMIN', defaultValue: false);
    if (enableMockAdmin && email == 'admin' && password == 'admin') {
      await _tokenStorage.writeToken(AppConfig.mockAdminToken);
      return _mockAdmin;
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data;
    if (data != null) {
      await _persistAuthResponse(data);
    }

    return getMe();
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );

    final data = response.data;
    if (data != null) {
      await _persistAuthResponse(data);
    }

    return getMe();
  }

  @override
  Future<User> getMe() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      throw const ServerException('Aucun jeton d\'authentification.');
    }
    if (token == AppConfig.mockAdminToken) {
      return _mockAdmin;
    }

    final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) {
      throw const ServerException('Aucune donnée utilisateur retournée.');
    }
    return _mapUser(data);
  }

  @override
  Future<void> logout() async {
    final token = await _tokenStorage.readToken();
    if (token != null && token != AppConfig.mockAdminToken) {
      try {
        await _apiClient.post<void>('/auth/logout');
      } catch (_) {
        // Best-effort server logout; always clear local tokens.
      }
    }
    await _tokenStorage.clearToken();
  }

  Future<void> _persistAuthResponse(Map<String, dynamic> data) async {
    final accessToken = data['accessToken'];
    final refreshToken = data['refreshToken'];
    if (accessToken is String &&
        refreshToken is String &&
        accessToken.isNotEmpty &&
        refreshToken.isNotEmpty) {
      await _tokenStorage.writeTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json['id'].toString()) ?? 0,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
    );
  }
}
