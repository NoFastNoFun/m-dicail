import 'package:flutter/material.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/debug/desktop_debug_backend_url_store.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/buttons/app_button.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';

/// Desktop debug-only control to override the API base URL at runtime.
class DesktopDebugBackendUrlSection extends StatefulWidget {
  const DesktopDebugBackendUrlSection({super.key});

  @override
  State<DesktopDebugBackendUrlSection> createState() =>
      _DesktopDebugBackendUrlSectionState();
}

class _DesktopDebugBackendUrlSectionState
    extends State<DesktopDebugBackendUrlSection> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _saving = false;

  AppConfig get _config => getIt<AppConfig>();
  DesktopDebugBackendUrlStore get _store =>
      getIt<DesktopDebugBackendUrlStore>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _config.debugBackendUrlOverride ?? _config.resolvedDefaultBaseUrl,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    if (!DesktopDebugBackendUrlStore.isValidBackendUrl(value)) {
      setState(() {
        _errorText = AppLocalizations.of(context).debugBackendUrlInvalid;
      });
      return;
    }

    setState(() {
      _errorText = null;
      _saving = true;
    });

    try {
      await _store.save(value);
      if (!mounted) return;
      AppToast.showSuccess(
        context,
        AppLocalizations.of(context).debugBackendUrlSaved,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _reset() async {
    setState(() {
      _errorText = null;
      _saving = true;
    });

    try {
      await _store.reset();
      if (!mounted) return;
      setState(() {
        _controller.text = _config.resolvedDefaultBaseUrl;
      });
      AppToast.showSuccess(
        context,
        AppLocalizations.of(context).debugBackendUrlSaved,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(l10n.debugSectionBackend, variant: AppTextVariant.headline),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          l10n.debugBackendUrlSubtitle,
          variant: AppTextVariant.body,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppInput(
          variant: AppInputVariant.text,
          label: l10n.debugBackendUrlLabel,
          hint: l10n.debugBackendUrlHint,
          controller: _controller,
          errorText: _errorText,
          enabled: !_saving,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: l10n.debugBackendUrlSave,
                isLoading: _saving,
                onPressed: _save,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: l10n.debugBackendUrlReset,
                style: AppButtonStyle.secondary,
                enabled: !_saving,
                onPressed: _reset,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
