import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_bottom_sheet.dart';
import 'package:medicail/widget/feedback/app_dialog.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/inputs/input_validation_l10n.dart';
import 'package:medicail/widget/layout/app_scaffold.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController(text: 'invalid');
  final _passwordController = TextEditingController(text: 'short');
  final _textareaController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _textareaController.dispose();
    super.dispose();
  }

  String? _messageResolver(String key) {
    final l10n = AppLocalizations.of(context);
    return resolveInputValidationMessage(l10n, key);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.debugPageTitle,
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            _sectionTitle(l10n.debugSectionButtons),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonPrimary,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonSecondary,
              style: AppButtonStyle.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonWarning,
              style: AppButtonStyle.warning,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonError,
              style: AppButtonStyle.error,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonLoading,
              isLoading: true,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonDisabled,
              enabled: false,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              layout: AppButtonLayout.icon,
              icon: Icons.favorite_outline,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugButtonTextIcon,
              layout: AppButtonLayout.textWithIcon,
              icon: Icons.add,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(l10n.debugSectionInputs),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              variant: AppInputVariant.text,
              label: l10n.debugInputText,
              controller: _textController,
              autovalidateMode: AutovalidateMode.always,
              messageResolver: _messageResolver,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              variant: AppInputVariant.number,
              label: l10n.debugInputNumber,
              controller: _numberController,
              autovalidateMode: AutovalidateMode.always,
              messageResolver: _messageResolver,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              variant: AppInputVariant.email,
              label: l10n.debugInputEmail,
              controller: _emailController,
              autovalidateMode: AutovalidateMode.always,
              messageResolver: _messageResolver,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              variant: AppInputVariant.password,
              label: l10n.debugInputPassword,
              controller: _passwordController,
              autovalidateMode: AutovalidateMode.always,
              messageResolver: _messageResolver,
            ),
            const SizedBox(height: AppSpacing.md),
            AppInput(
              variant: AppInputVariant.textarea,
              label: l10n.debugInputTextarea,
              controller: _textareaController,
              autovalidateMode: AutovalidateMode.always,
              messageResolver: _messageResolver,
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(l10n.debugSectionBottomSheet),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugOpenBottomSheet,
              onPressed: () => AppBottomSheet.show(
                context,
                title: l10n.debugBottomSheetTitle,
                child: AppText(
                  l10n.debugBottomSheetBody,
                  variant: AppTextVariant.body,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(l10n.debugSectionDialog),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugOpenFullscreenDialog,
              onPressed: () => AppDialog.show(
                context,
                variant: AppDialogVariant.fullscreen,
                title: l10n.debugFullscreenTitle,
                body: AppText(
                  l10n.debugFullscreenBody,
                  variant: AppTextVariant.body,
                ),
                actions: [
                  AppButton(
                    label: l10n.debugClose,
                    expanded: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugOpenLockDialog,
              onPressed: () => AppDialog.show(
                context,
                variant: AppDialogVariant.lockScreen,
                title: l10n.debugLockTitle,
                body: AppText(
                  l10n.debugLockBody,
                  variant: AppTextVariant.body,
                ),
                actions: [
                  AppButton(
                    label: l10n.debugLockDismiss,
                    expanded: false,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _sectionTitle(l10n.debugSectionToast),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugShowToastSuccess,
              style: AppButtonStyle.secondary,
              onPressed: () => AppToast.show(
                context,
                message: l10n.debugToastSuccess,
                type: AppToastType.success,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugShowToastWarning,
              style: AppButtonStyle.warning,
              onPressed: () => AppToast.show(
                context,
                message: l10n.debugToastWarning,
                type: AppToastType.warning,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugShowToastError,
              style: AppButtonStyle.error,
              onPressed: () => AppToast.show(
                context,
                message: l10n.debugToastError,
                type: AppToastType.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.debugShowToastInfo,
              style: AppButtonStyle.info,
              onPressed: () => AppToast.show(
                context,
                message: l10n.debugToastInfo,
                type: AppToastType.info,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return AppText(title, variant: AppTextVariant.headline);
  }
}
