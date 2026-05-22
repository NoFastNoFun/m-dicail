import 'package:medicail/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  
  Future<User> register({
    required String email,
    required String password,
    String? fullName,
  });
  
  Future<User> getMe();
  
  Future<void> logout();
}
