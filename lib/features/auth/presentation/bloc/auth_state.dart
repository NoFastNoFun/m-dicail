import 'package:equatable/equatable.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Session restore / bootstrap — not a user-initiated submit.
class AuthChecking extends AuthState {
  const AuthChecking();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthMfaRequired extends AuthState {
  const AuthMfaRequired({
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

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthGuest extends AuthState {
  const AuthGuest();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AuthSessionExpiredState extends AuthState {
  const AuthSessionExpiredState();
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

class AuthPasswordResetComplete extends AuthState {
  const AuthPasswordResetComplete();
}

class AuthRecoveryComplete extends AuthState {
  const AuthRecoveryComplete();
}
