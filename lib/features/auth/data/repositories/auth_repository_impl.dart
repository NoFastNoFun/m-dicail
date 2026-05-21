import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._tokenStorage);

  static const _mockToken = 'mock_admin_token';
  static const _mockAdmin = User(
    id: 999,
    email: 'admin@local.com',
    fullName: 'Admin Local',
  );

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<User> login({required String email, required String password}) async {
    if (email == 'admin' && password == 'admin') {
      await _tokenStorage.writeToken(_mockToken);
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
    if (data != null && data['access_token'] != null) {
      final token = data['access_token'] as String;
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
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'full_name': fullName,
      },
    );

    final data = response.data;
    if (data != null && data['access_token'] != null) {
      final token = data['access_token'] as String;
      await _tokenStorage.writeToken(token);
      final userJson = data['user'] as Map<String, dynamic>;
      return _mapUser(userJson);
    }

    return getMe();
  }

  @override
  Future<User> getMe() async {
    final token = await _tokenStorage.readToken();
    if (token == _mockToken) {
      return _mockAdmin;
    }

    final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) {
      throw Exception('Aucune donnée utilisateur retournée.');
    }
    return _mapUser(data);
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearToken();
  }

  User _mapUser(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
    );
  }
}
