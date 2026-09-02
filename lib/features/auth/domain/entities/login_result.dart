import 'package:equatable/equatable.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';

sealed class LoginResult extends Equatable {
  const LoginResult();
}

class LoginAuthenticated extends LoginResult {
  const LoginAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class LoginMfaRequired extends LoginResult {
  const LoginMfaRequired({
    required this.mfaToken,
    required this.methods,
    required this.email,
  });

  final String mfaToken;
  final List<String> methods;
  final String email;

  @override
  List<Object?> get props => [mfaToken, methods, email];
}
