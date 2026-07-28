import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/auth/auth_session_coordinator.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/core/storage/app_session_storage.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/core/error/failure.dart';
import 'auth_event.dart';
import 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authRepository,
    this._authNotifier,
    this._sessionStorage,
    this._tokenStorage,
    this._sessionCoordinator,
  ) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthGuestContinueRequested>(_onAuthGuestContinueRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);

    _sessionExpiredSubscription =
        _sessionCoordinator.onSessionExpired.listen((_) {
      add(const AuthSessionExpired());
    });
  }

  final AuthRepository _authRepository;
  final AuthNotifier _authNotifier;
  final AppSessionStorage _sessionStorage;
  final AuthTokenStorage _tokenStorage;
  final AuthSessionCoordinator _sessionCoordinator;
  late final StreamSubscription<void> _sessionExpiredSubscription;

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final hasCompletedOnboarding =
        await _sessionStorage.hasCompletedOnboarding();
    _authNotifier.setHasCompletedOnboarding(hasCompletedOnboarding);

    if (!hasCompletedOnboarding) {
      _authNotifier.setAuthenticated(false);
      _authNotifier.setGuest(false);
      emit(const AuthUnauthenticated());
      return;
    }

    final token = await _tokenStorage.readToken();
    if (token == null) {
      _authNotifier.setGuest(true);
      emit(const AuthGuest());
      return;
    }

    try {
      final user = await _authRepository.getMe();
      _authNotifier.setAuthenticated(true);
      emit(AuthAuthenticated(user));
    } catch (error) {
      if (error is ServerException && error.statusCode == 401) {
        await _tokenStorage.clearToken();
        _authNotifier.setAuthenticated(false);
        _authNotifier.setGuest(false);
        emit(const AuthUnauthenticated());
        return;
      }

      _authNotifier.setGuest(true);
      emit(const AuthGuest());
    }
  }

  Future<void> _onAuthGuestContinueRequested(
    AuthGuestContinueRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _sessionStorage.markOnboardingCompleted();
    _authNotifier.setHasCompletedOnboarding(true);
    _authNotifier.setGuest(true);
    emit(const AuthGuest());
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      await _sessionStorage.markOnboardingCompleted();
      _authNotifier.setHasCompletedOnboarding(true);
      _authNotifier.setAuthenticated(true);
      emit(AuthAuthenticated(user));
    } catch (e) {
      _authNotifier.setAuthenticated(false);
      emit(AuthError(Failure.fromException(e).message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
      );
      await _sessionStorage.markOnboardingCompleted();
      _authNotifier.setHasCompletedOnboarding(true);
      _authNotifier.setAuthenticated(true);
      emit(AuthAuthenticated(user));
    } catch (e) {
      _authNotifier.setAuthenticated(false);
      emit(AuthError(Failure.fromException(e).message));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    _authNotifier.setGuest(true);
    emit(const AuthGuest());
  }

  Future<void> _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSessionExpiredState());
    emit(const AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _sessionExpiredSubscription.cancel();
    return super.close();
  }
}
