import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  final _sessionStorage = getIt<AppSessionStorage>();

  bool _rememberEmail = false;

  @override
  void initState() {
    super.initState();
    _restoreRememberedEmail();
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
    } catch (_) {
      // Ignore restore failures; login must still work.
    }
  }

  @override
  void dispose() {
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
            } else if (state is AuthMfaRequired) {
              context.push(AppRoutes.loginMfa, extra: state);
            } else if (state is AuthGuest || state is AuthAuthenticated) {
              TextInput.finishAutofillContext();
              context.go(AppRoutes.home);
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
                                  messageResolver: _messageResolver,
                                  autofillHints: const [
                                    AutofillHints.username,
                                    AutofillHints.email,
                                  ],
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
                            const SizedBox(height: AppSpacing.xl),
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                return AppButton(
                                  label: l10n.homeSignIn,
                                  onPressed: _submit,
                                  isLoading: state is AuthLoading,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppButton(
                              label: l10n.loginCreateAccountButton,
                              style: AppButtonStyle.tertiary,
                              onPressed: () =>
                                  context.push(AppRoutes.register),
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
