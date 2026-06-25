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
    id: '999',
    email: 'admin@local.com',
    fullName: 'Admin Local',
  );

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    if (AppConfig.enableMockAdmin &&
        email == AppConfig.mockAdminEmail &&
        password == AppConfig.mockAdminPassword) {
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
    final token = _readAccessToken(data);
    if (token != null) {
      await _tokenStorage.writeToken(token);
    }

    return getMe();
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    if (AppConfig.enableMockAdmin && email == AppConfig.mockAdminEmail) {
      await _tokenStorage.writeToken(AppConfig.mockAdminToken);
      return _mockAdmin;
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      },
    );

    final data = response.data;
    final token = _readAccessToken(data);
    if (data != null && token != null) {
      await _tokenStorage.writeToken(token);
      final userJson = data['user'] as Map<String, dynamic>;
      return _mapUser(userJson);
    }

    return getMe();
  }

  @override
  Future<User> getMe() async {
    final token = await _tokenStorage.readToken();
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
    await _tokenStorage.clearToken();
  }

  String? _readAccessToken(Map<String, dynamic>? json) {
    return (json?['accessToken'] ?? json?['access_token']) as String?;
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      fullName: (json['fullName'] ?? json['full_name']) as String?,
    );
  }
}
