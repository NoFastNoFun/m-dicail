import 'package:medicail/features/auth/domain/entities/login_result.dart';
import 'package:medicail/features/auth/domain/entities/passkey_credential.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<LoginResult> login({required String email, required String password});

  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<User> getMe();

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({required String token, required String password});

  Future<void> requestAccountRecovery({required String email});

  Future<void> confirmAccountRecovery({required String token});

  Future<User> verifyMfa({required String mfaToken, required String code});

  Future<User> loginWithPasskey({required String email});

  Future<User> verifyMfaWithPasskey({
    required String mfaToken,
    required String email,
  });

  Future<String> enrollMfa();

  Future<List<String>> confirmMfa({required String code});

  Future<void> disableMfa({required String code});

  Future<List<PasskeyCredential>> listPasskeys();

  Future<void> registerPasskey({String? deviceName});

  Future<void> deletePasskey(String id);

  Future<bool> getMedicalWatchDigestOptIn();

  Future<void> setMedicalWatchDigestOptIn(bool value);
}
