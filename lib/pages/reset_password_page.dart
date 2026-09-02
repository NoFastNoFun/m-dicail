import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
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
import 'package:medicail/widget/inputs/input_validation_l10n.dart';
import 'package:medicail/widget/inputs/input_validators.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.token});

  final String token;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  String? _messageResolver(String key) {
    return resolveInputValidationMessage(AppLocalizations.of(context), key);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      await getIt<AuthRepository>().resetPassword(
        token: widget.token,
        password: _passwordController.text,
      );
      if (mounted) {
        AppToast.showSuccess(context, AppLocalizations.of(context).authResetPasswordSuccess);
        context.go(AppRoutes.login);
      }
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
      title: l10n.authResetPasswordTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppFormConstraint(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(l10n.authResetPasswordHint, variant: AppTextVariant.body),
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    variant: AppInputVariant.password,
                    label: l10n.loginPasswordLabel,
                    controller: _passwordController,
                    messageResolver: _messageResolver,
                    validator: InputValidators.validatePassword,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.authResetPasswordSubmit,
                    onPressed: _submit,
                    isLoading: _loading,
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
