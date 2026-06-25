import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_colors.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  String? _messageResolver(String key) {
    final l10n = AppLocalizations.of(context);
    return resolveInputValidationMessage(l10n, key);
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim().isNotEmpty
              ? _fullNameController.text.trim()
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppToast.showError(context, state.message);
          } else if (state is AuthGuest) {
            context.go(AppRoutes.home);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    l10n.registerTitle,
                    variant: AppTextVariant.headline,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    l10n.registerSubtitle,
                    variant: AppTextVariant.body,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.registerFullNameLabel,
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    variant: AppInputVariant.email,
                    label: l10n.registerEmailLabel,
                    controller: _emailController,
                    messageResolver: _messageResolver,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    variant: AppInputVariant.password,
                    label: l10n.registerPasswordLabel,
                    controller: _passwordController,
                    messageResolver: _messageResolver,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: l10n.registerSubmit,
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.loginContinueWithoutAccount,
                    style: AppButtonStyle.secondary,
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
  }
}
