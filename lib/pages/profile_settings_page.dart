import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medicail/core/auth/passkey_service.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/features/auth/domain/entities/user.dart';
import 'package:medicail/features/auth/domain/repositories/auth_repository.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/inputs/app_input.dart';
import 'package:medicail/widget/inputs/input_validation_l10n.dart';
import 'package:medicail/widget/inputs/input_validators.dart';
import 'package:medicail/widget/settings/app_settings_tile.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _authRepository = getIt<AuthRepository>();
  final _passkeyService = getIt<PasskeyService>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _totpController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _savingName = false;
  bool _savingEmail = false;
  bool _savingPassword = false;
  bool _usePasskeyForEmail = false;
  bool _passkeysSupported = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _totpController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _messageResolver(String key) {
    return resolveInputValidationMessage(AppLocalizations.of(context), key);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _passkeysSupported = await _passkeyService.isSupported();
      final user = await _authRepository.getMe();
      _user = user;
      _nameController.text = user.fullName ?? '';
      _emailController.text = user.email;
      _usePasskeyForEmail = false;
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(e).message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _notifyUserUpdated(User user) {
    _user = user;
    context.read<AuthBloc>().add(AuthUserUpdated(user));
  }

  Future<void> _saveName() async {
    if (!(_nameFormKey.currentState?.validate() ?? false)) return;
    setState(() => _savingName = true);
    try {
      final trimmed = _nameController.text.trim();
      final user = await _authRepository.updateProfile(
        fullName: trimmed.isEmpty ? null : trimmed,
      );
      _notifyUserUpdated(user);
      if (mounted) {
        AppToast.showSuccess(
          context,
          AppLocalizations.of(context).settingsProfileNameSaved,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(e).message);
      }
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _saveEmail() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;
    final user = _user;
    if (user == null) return;

    final canUsePasskey = _passkeysSupported && user.hasPasskeys;
    final usePasskey = _usePasskeyForEmail && canUsePasskey;

    if (user.mfaEnabled && _totpController.text.trim().isEmpty) {
      AppToast.showError(
        context,
        AppLocalizations.of(context).settingsProfileTotpRequired,
      );
      return;
    }

    setState(() => _savingEmail = true);
    try {
      final updated = await _authRepository.changeEmail(
        newEmail: _emailController.text.trim(),
        password: usePasskey ? null : _emailPasswordController.text,
        totpCode: user.mfaEnabled ? _totpController.text.trim() : null,
        usePasskey: usePasskey,
      );
      _notifyUserUpdated(updated);
      _emailController.text = updated.email;
      _emailPasswordController.clear();
      _totpController.clear();
      if (mounted) {
        AppToast.showSuccess(
          context,
          AppLocalizations.of(context).settingsProfileEmailSaved,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(e).message);
      }
    } finally {
      if (mounted) setState(() => _savingEmail = false);
    }
  }

  Future<void> _savePassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    setState(() => _savingPassword = true);
    try {
      final user = await _authRepository.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );
      _notifyUserUpdated(user);
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      if (mounted) {
        AppToast.showSuccess(
          context,
          AppLocalizations.of(context).settingsProfilePasswordSaved,
        );
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, Failure.fromException(e).message);
      }
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  String? _confirmPasswordValidator(String? value) {
    final key = InputValidators.validatePassword(value);
    if (key != null) return _messageResolver(key);
    if (value != _newPasswordController.text) {
      return AppLocalizations.of(context).settingsProfilePasswordMismatch;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = _user;
    final canUsePasskey = _passkeysSupported && (user?.hasPasskeys ?? false);
    final usePasskey = _usePasskeyForEmail && canUsePasskey;

    return AppScaffold(
      title: l10n.settingsProfileTitle,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: MainShellScope.scrollPaddingOf(context),
              children: [
                AppSettingsTile(
                  title: l10n.settingsProfileName,
                  child: Form(
                    key: _nameFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppInput(
                          variant: AppInputVariant.text,
                          label: l10n.settingsProfileNameHint,
                          controller: _nameController,
                          validator: (_) => null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.settingsProfileSaveName,
                          onPressed: _saveName,
                          isLoading: _savingName,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                AppSettingsTile(
                  title: l10n.settingsProfileEmail,
                  subtitle: user?.email,
                  child: Form(
                    key: _emailFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppInput(
                          variant: AppInputVariant.email,
                          label: l10n.settingsProfileEmailHint,
                          controller: _emailController,
                          messageResolver: _messageResolver,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (canUsePasskey) ...[
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                value: false,
                                label: Text(l10n.settingsProfileUsePassword),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text(l10n.settingsProfileUsePasskey),
                              ),
                            ],
                            selected: {_usePasskeyForEmail},
                            onSelectionChanged: (selection) {
                              setState(() {
                                _usePasskeyForEmail = selection.first;
                              });
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (!usePasskey)
                          AppInput(
                            variant: AppInputVariant.password,
                            label: l10n.settingsProfileCurrentPassword,
                            controller: _emailPasswordController,
                            messageResolver: _messageResolver,
                          ),
                        if (user?.mfaEnabled == true) ...[
                          const SizedBox(height: AppSpacing.sm),
                          AppInput(
                            variant: AppInputVariant.text,
                            label: l10n.settingsProfileTotpRequired,
                            controller: _totpController,
                            messageResolver: _messageResolver,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.settingsProfileChangeEmail,
                          onPressed: _saveEmail,
                          isLoading: _savingEmail,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                AppSettingsTile(
                  title: l10n.settingsProfileChangePassword,
                  child: Form(
                    key: _passwordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppInput(
                          variant: AppInputVariant.password,
                          label: l10n.settingsProfileCurrentPassword,
                          controller: _currentPasswordController,
                          messageResolver: _messageResolver,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppInput(
                          variant: AppInputVariant.password,
                          label: l10n.settingsProfileNewPassword,
                          controller: _newPasswordController,
                          messageResolver: _messageResolver,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppInput(
                          variant: AppInputVariant.password,
                          label: l10n.settingsProfileConfirmPassword,
                          controller: _confirmPasswordController,
                          validator: _confirmPasswordValidator,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppButton(
                          label: l10n.settingsProfileChangePassword,
                          onPressed: _savePassword,
                          isLoading: _savingPassword,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
