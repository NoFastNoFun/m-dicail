import 'package:injectable/injectable.dart';
import 'package:medicail/core/auth/passkey_service.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/features/auth/domain/entities/login_result.dart';
import 'package:medicail/features/auth/domain/entities/passkey_credential.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient, this._tokenStorage, this._passkeyService);

  static const _mockAdmin = User(
    id: '999',
    email: 'admin@local.com',
    fullName: 'Admin Local',
  );

  final ApiClient _apiClient;
  final AuthTokenStorage _tokenStorage;
  final PasskeyService _passkeyService;

  @override
  Future<LoginResult> login({required String email, required String password}) async {
    const enableMockAdmin = bool.fromEnvironment('ENABLE_MOCK_ADMIN', defaultValue: false);
    if (enableMockAdmin && email == 'admin' && password == 'admin') {
      await _tokenStorage.writeToken(AppConfig.mockAdminToken);
      return LoginAuthenticated(_mockAdmin);
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    final data = response.data;
    if (data == null) throw const ServerException('Reponse vide.');

    if (data['status'] == 'mfa_required') {
      return LoginMfaRequired(
        mfaToken: data['mfaToken'] as String,
        methods: (data['methods'] as List<dynamic>).cast<String>(),
        email: email,
      );
    }

    await _persistAuthResponse(data);
    return LoginAuthenticated(await getMe());
  }

  @override
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'email': email, 'password': password, 'fullName': fullName},
    );

    final data = response.data;
    if (data != null) await _persistAuthResponse(data);
    return getMe();
  }

  @override
  Future<User> getMe() async {
    final token = await _tokenStorage.readToken();
    if (token == null) throw const ServerException('Aucun jeton d\'authentification.');
    if (token == AppConfig.mockAdminToken) return _mockAdmin;

    final response = await _apiClient.get<Map<String, dynamic>>('/auth/me');
    final data = response.data;
    if (data == null) throw const ServerException('Aucune donnee utilisateur retournee.');
    return _mapUser(data);
  }

  @override
  Future<void> logout() async {
    final token = await _tokenStorage.readToken();
    if (token != null && token != AppConfig.mockAdminToken) {
      try {
        await _apiClient.post<void>('/auth/logout');
      } catch (_) {}
    }
    await _tokenStorage.clearToken();
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post<void>('/auth/forgot-password', data: {'email': email});
  }

  @override
  Future<void> resetPassword({required String token, required String password}) async {
    await _apiClient.post<void>(
      '/auth/reset-password',
      data: {'token': token, 'password': password},
    );
  }

  @override
  Future<void> requestAccountRecovery({required String email}) async {
    await _apiClient.post<void>('/auth/recovery/request', data: {'email': email});
  }

  @override
  Future<void> confirmAccountRecovery({required String token}) async {
    await _apiClient.post<void>('/auth/recovery/confirm', data: {'token': token});
  }

  @override
  Future<User> verifyMfa({required String mfaToken, required String code}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/mfa/verify',
      data: {'mfaToken': mfaToken, 'code': code},
    );
    final data = response.data;
    if (data != null) await _persistAuthResponse(data);
    return getMe();
  }

  @override
  Future<User> loginWithPasskey({required String email}) async {
    final optionsResponse = await _apiClient.post<Map<String, dynamic>>(
      '/auth/passkeys/authenticate/options',
      data: {'email': email},
    );
    final options = optionsResponse.data;
    if (options == null) throw const ServerException('Options passkey invalides.');

    final credential = await _passkeyService.authenticate(options);
    final verifyResponse = await _apiClient.post<Map<String, dynamic>>(
      '/auth/passkeys/authenticate/verify',
      data: {'email': email, 'response': credential},
    );
    final data = verifyResponse.data;
    if (data != null) await _persistAuthResponse(data);
    return getMe();
  }

  @override
  Future<User> verifyMfaWithPasskey({
    required String mfaToken,
    required String email,
  }) async {
    final optionsResponse = await _apiClient.post<Map<String, dynamic>>(
      '/auth/passkeys/authenticate/options',
      data: {'mfaToken': mfaToken, 'email': email},
    );
    final options = optionsResponse.data;
    if (options == null) throw const ServerException('Options passkey invalides.');

    final credential = await _passkeyService.authenticate(options);
    final verifyResponse = await _apiClient.post<Map<String, dynamic>>(
      '/auth/passkeys/authenticate/verify',
      data: {'mfaToken': mfaToken, 'email': email, 'response': credential},
    );
    final data = verifyResponse.data;
    if (data != null) await _persistAuthResponse(data);
    return getMe();
  }

  @override
  Future<String> enrollMfa() async {
    final response = await _apiClient.post<Map<String, dynamic>>('/auth/mfa/enroll');
    final otpauthUrl = response.data?['otpauthUrl'];
    if (otpauthUrl is! String || otpauthUrl.isEmpty) {
      throw const ServerException('Enrollment MFA impossible.');
    }
    return otpauthUrl;
  }

  @override
  Future<List<String>> confirmMfa({required String code}) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/mfa/confirm',
      data: {'code': code},
    );
    final codes = response.data?['recoveryCodes'];
    if (codes is List) return codes.cast<String>();
    return const [];
  }

  @override
  Future<void> disableMfa({required String code}) async {
    await _apiClient.post<void>('/auth/mfa/disable', data: {'code': code});
  }

  @override
  Future<List<PasskeyCredential>> listPasskeys() async {
    final response = await _apiClient.get<List<dynamic>>('/auth/passkeys');
    final data = response.data ?? const [];
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return PasskeyCredential(
        id: map['id'] as String,
        deviceName: map['deviceName'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
    }).toList();
  }

  @override
  Future<void> registerPasskey({String? deviceName}) async {
    final optionsResponse = await _apiClient.post<Map<String, dynamic>>(
      '/auth/passkeys/register/options',
    );
    final options = optionsResponse.data;
    if (options == null) throw const ServerException('Options passkey invalides.');

    final credential = await _passkeyService.register(options);
    await _apiClient.post<void>(
      '/auth/passkeys/register/verify',
      data: {'response': credential, 'deviceName': deviceName},
    );
  }

  @override
  Future<void> deletePasskey(String id) async {
    await _apiClient.delete<void>('/auth/passkeys/$id');
  }

  @override
  Future<bool> getMedicalWatchDigestOptIn() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/medical-watch/preferences');
    return response.data?['digestOptIn'] == true;
  }

  @override
  Future<void> setMedicalWatchDigestOptIn(bool value) async {
    await _apiClient.patch<void>(
      '/medical-watch/preferences',
      data: {'digestOptIn': value},
    );
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
      id: json['id'].toString(),
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      mfaEnabled: json['mfaEnabled'] == true,
      hasPasskeys: json['hasPasskeys'] == true,
      medicalWatchDigestOptIn: json['medicalWatchDigestOptIn'] == true,
    );
  }
}
