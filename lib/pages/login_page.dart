import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/auth/passkey_service.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
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
  bool _passkeysSupported = false;

  @override
  void initState() {
    super.initState();
    _checkPasskeys();
  }

  Future<void> _checkPasskeys() async {
    final supported = await getIt<PasskeyService>().isSupported();
    if (mounted) setState(() => _passkeysSupported = supported);
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

  void _submit() {
    if (_enableMockAdmin || (_formKey.currentState?.validate() ?? false)) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Theme(
      data: Theme.of(context).highContrastSurface,
      child: AppScaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              AppToast.showError(context, state.message);
            } else if (state is AuthMfaRequired) {
              context.push(AppRoutes.loginMfa, extra: state);
            } else if (state is AuthGuest || state is AuthAuthenticated) {
              context.go(AppRoutes.home);
            }
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: AppFormConstraint(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        size: 64,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppText(
                        l10n.loginWelcomeTitle,
                        variant: AppTextVariant.headline,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppText(
                        l10n.loginWelcomeSubtitle,
                        variant: AppTextVariant.body,
                        color: context.secondaryTextColor,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AppInput(
                        variant: AppInputVariant.email,
                        label: l10n.loginEmailLabel,
                        controller: _emailController,
                        messageResolver: _messageResolver,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppInput(
                        variant: AppInputVariant.password,
                        label: l10n.loginPasswordLabel,
                        controller: _passwordController,
                        messageResolver: _messageResolver,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => context.push(AppRoutes.forgotPassword),
                          child: AppText(
                            l10n.authForgotPasswordLink,
                            variant: AppTextVariant.body,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return AppButton(
                            label: l10n.homeSignIn,
                            onPressed: _submit,
                            isLoading: state is AuthLoading,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_passkeysSupported)
                        AppButton(
                          label: l10n.authPasskeyLogin,
                          style: AppButtonStyle.secondary,
                          onPressed: () {
                            context.read<AuthBloc>().add(
                              AuthPasskeyLoginRequested(
                                email: _emailController.text.trim(),
                              ),
                            );
                          },
                        ),
                      if (_passkeysSupported) const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.loginContinueWithoutAccount,
                        style: AppButtonStyle.secondary,
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthGuestContinueRequested(),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: l10n.loginCreateAccountButton,
                        style: AppButtonStyle.secondary,
                        onPressed: () => context.push(AppRoutes.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
