import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/layout/app_content_constraint.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

class MfaLoginPage extends StatefulWidget {
  const MfaLoginPage({
    super.key,
    required this.mfaToken,
    required this.methods,
    required this.email,
  });

  final String mfaToken;
  final List<String> methods;
  final String email;

  @override
  State<MfaLoginPage> createState() => _MfaLoginPageState();
}

class _MfaLoginPageState extends State<MfaLoginPage> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() {
    context.read<AuthBloc>().add(
      AuthMfaVerifyRequested(
        mfaToken: widget.mfaToken,
        code: _codeController.text.trim(),
      ),
    );
  }

  void _submitPasskey() {
    context.read<AuthBloc>().add(
      AuthMfaPasskeyRequested(
        mfaToken: widget.mfaToken,
        email: widget.email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final canUsePasskey = widget.methods.contains('passkey');

    return AppScaffold(
      title: l10n.authMfaTitle,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppToast.showError(context, state.message);
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: AppFormConstraint(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(l10n.authMfaHint, variant: AppTextVariant.body),
                  const SizedBox(height: AppSpacing.lg),
                  AppInput(
                    variant: AppInputVariant.text,
                    label: l10n.authMfaCodeLabel,
                    controller: _codeController,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        label: l10n.authMfaVerify,
                        onPressed: _submitCode,
                        isLoading: state is AuthLoading,
                      );
                    },
                  ),
                  if (canUsePasskey) ...[
                    const SizedBox(height: AppSpacing.md),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          label: l10n.authPasskeyLogin,
                          style: AppButtonStyle.secondary,
                          onPressed: _submitPasskey,
                          isLoading: state is AuthLoading,
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
