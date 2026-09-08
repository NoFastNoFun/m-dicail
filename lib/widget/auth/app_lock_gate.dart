import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/auth/app_lock_controller.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';

class AppLockGate extends StatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate>
    with WidgetsBindingObserver {
  final _lockController = getIt<AppLockController>();
  final _authNotifier = getIt<AuthNotifier>();
  final _router = getIt<GoRouter>();

  VoidCallback? _authListener;
  VoidCallback? _lockListener;
  VoidCallback? _routerListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authListener = () {
      _lockController.onAuthAccessChanged();
      if (_authNotifier.canAccessApp && _lockController.shouldShowLock) {
        unawaited(_tryUnlock());
      }
      if (mounted) setState(() {});
    };
    _authNotifier.addListener(_authListener!);
    _lockListener = () {
      if (mounted) setState(() {});
    };
    _lockController.addListener(_lockListener!);
    _routerListener = () {
      if (mounted) setState(() {});
    };
    _router.routerDelegate.addListener(_routerListener!);
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!_lockController.isHydrated) {
      await _lockController.hydrate();
    }
    if (!mounted) return;
    // Wait until auth check restores guest/session before prompting.
    if (_authNotifier.canAccessApp && _lockController.shouldShowLock) {
      unawaited(_tryUnlock());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_authListener != null) {
      _authNotifier.removeListener(_authListener!);
    }
    if (_lockListener != null) {
      _lockController.removeListener(_lockListener!);
    }
    if (_routerListener != null) {
      _router.routerDelegate.removeListener(_routerListener!);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _lockController.lockIfNeeded();
      case AppLifecycleState.resumed:
        if (_lockController.shouldShowLock && !_isPublicAuthRoute()) {
          unawaited(_tryUnlock());
        }
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  bool _isPublicAuthRoute() {
    final location = _router.state.uri.toString();
    return location == AppRoutes.login ||
        location == AppRoutes.register ||
        location.startsWith(AppRoutes.forgotPassword) ||
        location.startsWith(AppRoutes.resetPassword) ||
        location.startsWith(AppRoutes.recovery) ||
        location.startsWith(AppRoutes.loginMfa);
  }

  Future<void> _tryUnlock() async {
    if (_isPublicAuthRoute()) return;
    final l10n = AppLocalizations.of(context);
    await _lockController.unlock(reason: l10n.authBiometricUnlockReason);
  }

  @override
  Widget build(BuildContext context) {
    final showLock =
        _lockController.shouldShowLock && !_isPublicAuthRoute();
    if (!showLock) return widget.child;

    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        ColoredBox(
          color: colorScheme.surface,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 56,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.authBiometricLockTitle,
                    variant: AppTextVariant.title,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    l10n.authBiometricLockSubtitle,
                    variant: AppTextVariant.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.authBiometricUnlock,
                    isLoading: _lockController.isAuthenticating,
                    onPressed: _lockController.isAuthenticating
                        ? null
                        : _tryUnlock,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
