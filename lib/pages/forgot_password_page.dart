import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await getIt<AuthRepository>().forgotPassword(
        email: _emailController.text.trim(),
      );
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.authForgotPasswordTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppFormConstraint(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  _sent ? l10n.authForgotPasswordSent : l10n.authForgotPasswordHint,
                  variant: AppTextVariant.body,
                  color: context.secondaryTextColor,
                ),
                if (!_sent) ...[
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    variant: AppInputVariant.email,
                    label: l10n.loginEmailLabel,
                    controller: _emailController,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.authForgotPasswordSubmit,
                    onPressed: _submit,
                    isLoading: _loading,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.authBackToLogin,
                  style: AppButtonStyle.secondary,
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
