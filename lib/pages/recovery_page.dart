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

class RecoveryPage extends StatefulWidget {
  const RecoveryPage({super.key, required this.token});

  final String token;

  @override
  State<RecoveryPage> createState() => _RecoveryPageState();
}

class _RecoveryPageState extends State<RecoveryPage> {
  bool _loading = false;
  bool _done = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await getIt<AuthRepository>().confirmAccountRecovery(token: widget.token);
      setState(() => _done = true);
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
      title: l10n.authRecoveryTitle,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: AppFormConstraint(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  _done ? l10n.authRecoverySuccess : l10n.authRecoveryHint,
                  variant: AppTextVariant.body,
                ),
                if (!_done) ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.authRecoveryConfirm,
                    onPressed: _confirm,
                    isLoading: _loading,
                  ),
                ] else ...[
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: l10n.authBackToLogin,
                    onPressed: () => context.go(AppRoutes.login),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
