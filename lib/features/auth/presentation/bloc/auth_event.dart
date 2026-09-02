import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthPasskeyLoginRequested extends AuthEvent {
  const AuthPasskeyLoginRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class AuthMfaVerifyRequested extends AuthEvent {
  const AuthMfaVerifyRequested({required this.mfaToken, required this.code});

  final String mfaToken;
  final String code;

  @override
  List<Object?> get props => [mfaToken, code];
}

class AuthMfaPasskeyRequested extends AuthEvent {
  const AuthMfaPasskeyRequested({required this.mfaToken, required this.email});

  final String mfaToken;
  final String email;

  @override
  List<Object?> get props => [mfaToken, email];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
  });

  final String email;
  final String password;
  final String? fullName;

  @override
  List<Object?> get props => [email, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthGuestContinueRequested extends AuthEvent {
  const AuthGuestContinueRequested();
}

class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}
