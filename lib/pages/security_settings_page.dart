import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medicail/core/auth/passkey_service.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/features/auth/domain/entities/passkey_credential.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/settings/app_settings_tile.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final _authRepository = getIt<AuthRepository>();
  final _passkeyService = getIt<PasskeyService>();
  final _mfaCodeController = TextEditingController();
  final _disableCodeController = TextEditingController();
  final _recoveryEmailController = TextEditingController();

  bool _loading = true;
  bool _passkeysSupported = false;
  bool _mfaEnabled = false;
  bool _digestOptIn = false;
  String? _otpauthUrl;
  List<String> _recoveryCodes = const [];
  List<PasskeyCredential> _passkeys = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _mfaCodeController.dispose();
    _disableCodeController.dispose();
    _recoveryEmailController.dispose();
    super.dispose();
  }

  String? get _totpSecret {
    final url = _otpauthUrl;
    if (url == null) return null;
    return Uri.tryParse(url)?.queryParameters['secret'];
  }

  Future<void> _copyText(String text, String successMessage) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) AppToast.showSuccess(context, successMessage);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _passkeysSupported = await _passkeyService.isSupported();
      final user = await _authRepository.getMe();
      _mfaEnabled = user.mfaEnabled;
      _digestOptIn = user.medicalWatchDigestOptIn;
      _recoveryEmailController.text = user.email;
      _passkeys = await _authRepository.listPasskeys();
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startMfaEnroll() async {
    try {
      final url = await _authRepository.enrollMfa();
      setState(() => _otpauthUrl = url);
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _confirmMfa() async {
    try {
      final codes = await _authRepository.confirmMfa(
        code: _mfaCodeController.text.trim(),
      );
      setState(() {
        _recoveryCodes = codes;
        _mfaEnabled = true;
        _otpauthUrl = null;
      });
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _disableMfa() async {
    try {
      await _authRepository.disableMfa(code: _disableCodeController.text.trim());
      setState(() => _mfaEnabled = false);
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _addPasskey() async {
    try {
      await _authRepository.registerPasskey();
      _passkeys = await _authRepository.listPasskeys();
      setState(() {});
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _deletePasskey(String id) async {
    try {
      await _authRepository.deletePasskey(id);
      _passkeys = await _authRepository.listPasskeys();
      setState(() {});
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _requestRecovery() async {
    try {
      await _authRepository.requestAccountRecovery(
        email: _recoveryEmailController.text.trim(),
      );
      if (mounted) {
        AppToast.showSuccess(
          context,
          AppLocalizations.of(context).authRecoveryRequestSent,
        );
      }
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  Future<void> _toggleDigest(bool value) async {
    try {
      await _authRepository.setMedicalWatchDigestOptIn(value);
      setState(() => _digestOptIn = value);
    } catch (e) {
      if (mounted) AppToast.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final secret = _totpSecret;

    return AppScaffold(
      title: l10n.authSecurityTitle,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: MainShellScope.scrollPaddingOf(context),
              children: [
                AppSettingsTile(
                  title: l10n.authMfaTitle,
                  subtitle:
                      _mfaEnabled ? l10n.authMfaEnabled : l10n.authMfaDisabled,
                  child: _mfaEnabled
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppInput(
                              variant: AppInputVariant.text,
                              label: l10n.authMfaCodeLabel,
                              controller: _disableCodeController,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppButton(
                              label: l10n.authMfaDisable,
                              style: AppButtonStyle.secondary,
                              onPressed: _disableMfa,
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_otpauthUrl != null) ...[
                              AppText(
                                l10n.authMfaManualHint,
                                variant: AppTextVariant.body,
                                color: context.secondaryTextColor,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              if (secret != null) ...[
                                AppText(
                                  l10n.authMfaSecretLabel,
                                  variant: AppTextVariant.label,
                                  color: context.secondaryTextColor,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                SelectableText(
                                  secret,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        letterSpacing: 1.2,
                                      ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                AppButton(
                                  label: l10n.authMfaCopySecret,
                                  style: AppButtonStyle.secondary,
                                  onPressed: () => _copyText(
                                    secret,
                                    l10n.authMfaSecretCopied,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              AppButton(
                                label: l10n.authMfaCopyUri,
                                style: AppButtonStyle.tertiary,
                                onPressed: () => _copyText(
                                  _otpauthUrl!,
                                  l10n.authMfaUriCopied,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: QrImageView(
                                  data: _otpauthUrl!,
                                  size: 180,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              AppInput(
                                variant: AppInputVariant.text,
                                label: l10n.authMfaCodeLabel,
                                controller: _mfaCodeController,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppButton(
                                label: l10n.authMfaConfirm,
                                onPressed: _confirmMfa,
                              ),
                            ] else
                              AppButton(
                                label: l10n.authMfaEnroll,
                                onPressed: _startMfaEnroll,
                              ),
                          ],
                        ),
                ),
                if (_recoveryCodes.isNotEmpty) ...[
                  const Divider(),
                  AppSettingsTile(
                    title: l10n.authRecoveryCodesTitle,
                    child: AppText(
                      _recoveryCodes.join('\n'),
                      variant: AppTextVariant.body,
                    ),
                  ),
                ],
                const Divider(),
                AppSettingsTile(
                  title: l10n.authPasskeysTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final passkey in _passkeys)
                        ListTile(
                          title: Text(passkey.deviceName ?? passkey.id),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _deletePasskey(passkey.id),
                          ),
                        ),
                      if (_passkeysSupported)
                        AppButton(
                          label: l10n.authPasskeyAdd,
                          onPressed: _addPasskey,
                        )
                      else
                        AppText(
                          l10n.authPasskeyUnsupported,
                          variant: AppTextVariant.body,
                        ),
                    ],
                  ),
                ),
                const Divider(),
                AppSettingsTile(
                  title: l10n.authRecoveryTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppInput(
                        variant: AppInputVariant.email,
                        label: l10n.loginEmailLabel,
                        controller: _recoveryEmailController,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.authRecoveryRequest,
                        style: AppButtonStyle.secondary,
                        onPressed: _requestRecovery,
                      ),
                    ],
                  ),
                ),
                const Divider(),
                AppSettingsTile(
                  title: l10n.authDigestTitle,
                  subtitle: l10n.authDigestHint,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: AppText(
                      l10n.authDigestOptIn,
                      variant: AppTextVariant.body,
                    ),
                    value: _digestOptIn,
                    onChanged: _toggleDigest,
                  ),
                ),
              ],
            ),
    );
  }
}
