import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/auth/passkey_service.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/core/storage/app_session_storage.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_checkbox.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/inputs/input_validation_l10n.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _sessionStorage = getIt<AppSessionStorage>();
  final _passkeyService = getIt<PasskeyService>();

  bool _rememberEmail = false;

  /// Prefer silent Conditional UI; only show a discreet control when false.
  bool _conditionalPasskeyAvailable = false;
  bool _passkeysSupported = false;
  bool _capabilitiesReady = false;

  /// Email last used to start a conditional ceremony (avoids duplicate starts).
  String? _conditionalEmailStarted;
  Timer? _conditionalDebounce;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChanged);
    _emailController.addListener(_onEmailTextChanged);
    _restoreRememberedEmail();
    unawaited(_probePasskeyCapabilities());
  }

  Future<void> _probePasskeyCapabilities() async {
    try {
      final supported = await _passkeyService.isSupported();
      final conditional = supported
          ? await _passkeyService.isConditionalMediationAvailable()
          : false;
      if (!mounted) return;
      setState(() {
        _passkeysSupported = supported;
        _conditionalPasskeyAvailable = conditional;
        _capabilitiesReady = true;
      });
      _maybeStartConditionalPasskey();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _passkeysSupported = false;
        _conditionalPasskeyAvailable = false;
        _capabilitiesReady = true;
      });
    }
  }

  Future<void> _restoreRememberedEmail() async {
    try {
      final email = await _sessionStorage.readRememberedEmail();
      if (!mounted || email == null) {
        return;
      }
      setState(() {
        _emailController.text = email;
        _rememberEmail = true;
      });
      _maybeStartConditionalPasskey();
    } catch (_) {
      // Ignore restore failures; login must still work.
    }
  }

  void _onEmailFocusChanged() {
    if (_emailFocusNode.hasFocus) {
      // Re-arm on focus so a dismissed autofill sheet can be tried again.
      _conditionalEmailStarted = null;
      _maybeStartConditionalPasskey();
    }
  }

  void _onEmailTextChanged() {
    _conditionalDebounce?.cancel();
    _conditionalDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _maybeStartConditionalPasskey();
    });
  }

  /// Starts Conditional WebAuthn once a plausible email is known.
  /// Prefer focus-driven starts; also runs after remembered-email restore so
  /// autofill can prime before the user taps the field.
  void _maybeStartConditionalPasskey() {
    if (!_capabilitiesReady || !_conditionalPasskeyAvailable) return;
    if (!mounted) return;
    final email = _emailController.text.trim();
    if (!_isPlausibleEmail(email)) return;
    if (_conditionalEmailStarted == email) return;

    if (_conditionalEmailStarted != null) {
      unawaited(_passkeyService.cancelCurrentOperation());
    }
    _conditionalEmailStarted = email;
    context.read<AuthBloc>().add(
      AuthPasskeyLoginRequested(email: email, conditional: true),
    );
  }

  bool _isPlausibleEmail(String email) {
    return email.contains('@') && email.contains('.');
  }

  /// Discreet modal fallback when Conditional Mediation is unavailable
  /// (notably Android today: passkeys_android does not plumb
  /// `mediation: conditional`). Documented here so we do not reintroduce a
  /// large primary passkey CTA on platforms that support autofill.
  void _submitPasskeyFallback() {
    final email = _emailController.text.trim();
    if (!_isPlausibleEmail(email)) {
      _formKey.currentState?.validate();
      return;
    }
    context.read<AuthBloc>().add(AuthPasskeyLoginRequested(email: email));
    unawaited(_persistRememberedEmail());
  }

  bool get _showDiscreetPasskeyFallback =>
      _capabilitiesReady && _passkeysSupported && !_conditionalPasskeyAvailable;

  @override
  void dispose() {
    _conditionalDebounce?.cancel();
    _emailFocusNode.removeListener(_onEmailFocusChanged);
    _emailController.removeListener(_onEmailTextChanged);
    unawaited(_passkeyService.cancelCurrentOperation());
    _emailFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  static const _enableMockAdmin = bool.fromEnvironment(
    'ENABLE_MOCK_ADMIN',
    defaultValue: false,
  );

  String? _messageResolver(String key) {
    final l10n = AppLocalizations.of(context);
    return resolveInputValidationMessage(l10n, key);
  }

  Future<void> _persistRememberedEmail() async {
    try {
      if (_rememberEmail) {
        await _sessionStorage.writeRememberedEmail(
          _emailController.text.trim(),
        );
      } else {
        await _sessionStorage.writeRememberedEmail(null);
      }
    } catch (_) {
      // Remember-email is best-effort; never block sign-in.
    }
  }

  void _submit() {
    if (_enableMockAdmin || (_formKey.currentState?.validate() ?? false)) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      unawaited(_persistRememberedEmail());
    }
  }

  /// Web requires the `webauthn` token in autocomplete for Conditional UI.
  /// See Flutter autofillHints docs — only the first hint is used on web.
  Iterable<String> get _emailAutofillHints {
    if (kIsWeb) {
      return const ['username webauthn'];
    }
    return const [AutofillHints.username, AutofillHints.email];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: Theme.of(context).authSurface,
      child: AppScaffold(
        hideAppBar: true,
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              AppToast.showError(context, state.message);
              // Allow retrying conditional mediation after a soft failure.
              _conditionalEmailStarted = null;
            } else if (state is AuthMfaRequired) {
              context.push(AppRoutes.loginMfa, extra: state);
            } else if (state is AuthGuest || state is AuthAuthenticated) {
              TextInput.finishAutofillContext();
              context.go(AppRoutes.home);
            } else if (state is AuthUnauthenticated) {
              _conditionalEmailStarted = null;
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              const padding = EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xl,
              );
              return SingleChildScrollView(
                padding: padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - padding.vertical,
                  ),
                  child: AppFormConstraint(
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppText(
                              l10n.loginWelcomeTitle,
                              variant: AppTextVariant.display,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppText(
                              l10n.loginWelcomeSubtitle,
                              variant: AppTextVariant.body,
                              color: context.secondaryTextColor,
                            ),
                            const SizedBox(
                              height: AppSpacing.xxl + AppSpacing.sm,
                            ),
                            Hero(
                              tag: 'auth-email-field',
                              child: Material(
                                type: MaterialType.transparency,
                                child: AppInput(
                                  variant: AppInputVariant.email,
                                  label: l10n.loginEmailLabel,
                                  controller: _emailController,
                                  focusNode: _emailFocusNode,
                                  messageResolver: _messageResolver,
                                  autofillHints: _emailAutofillHints,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            AppCheckbox(
                              label: l10n.loginRememberEmail,
                              value: _rememberEmail,
                              onChanged: (value) {
                                setState(() {
                                  _rememberEmail = value ?? false;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            AppInput(
                              variant: AppInputVariant.password,
                              label: l10n.loginPasswordLabel,
                              controller: _passwordController,
                              messageResolver: _messageResolver,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push(
                                  AppRoutes.forgotPassword,
                                  extra: _emailController.text,
                                ),
                                child: AppText(
                                  l10n.authForgotPasswordLink,
                                  variant: AppTextVariant.label,
                                  color: context.colorScheme.primary,
                                ),
                              ),
                            ),
                            // Fallback only when Conditional UI cannot run.
                            // Keep this a text-style control — never a large
                            // primary "Login with passkey" button when
                            // mediation: conditional is available.
                            if (_showDiscreetPasskeyFallback)
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _submitPasskeyFallback,
                                  child: AppText(
                                    l10n.authPasskeyLogin,
                                    variant: AppTextVariant.label,
                                    color: context.colorScheme.primary,
                                  ),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.xl),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final loading = state is AuthLoading;
                                return AppButton(
                                  label: l10n.homeSignIn,
                                  onPressed: loading ? null : _submit,
                                  isLoading: loading,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: l10n.loginCreateAccountButton,
                              style: AppButtonStyle.tertiary,
                              onPressed: () => context.push(AppRoutes.register),
                            ),
                            AppButton(
                              label: l10n.loginContinueWithoutAccount,
                              style: AppButtonStyle.tertiary,
                              onPressed: () {
                                context.read<AuthBloc>().add(
                                  const AuthGuestContinueRequested(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
