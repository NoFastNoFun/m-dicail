import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_event.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_state.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_tbd_pill.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/settings/app_settings_tile.dart';
import 'package:medicail/widget/settings/app_stepped_slider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.settingsTitle,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: [
              AppSettingsTile(
                title: l10n.settingsTheme,
                child: _ThemeSelector(
                  selected: state.themeVariant,
                  onChanged: (variant) => context
                      .read<SettingsBloc>()
                      .add(SettingsThemeChanged(variant)),
                ),
              ),
              const Divider(),
              AppSettingsTile(
                title: l10n.settingsFontSize,
                child: _FontScaleSelector(
                  selected: state.fontScale,
                  onChanged: (scale) => context
                      .read<SettingsBloc>()
                      .add(SettingsFontScaleChanged(scale)),
                ),
              ),
              const Divider(),
              AppSettingsTile(
                title: l10n.settingsTemplates,
                subtitle: l10n.templatesTitle,
                trailing: const Icon(Icons.chevron_right),
                child: AppButton(
                  label: l10n.settingsTemplates,
                  style: AppButtonStyle.secondary,
                  onPressed: () => context.goTemplates(),
                ),
              ),
              const Divider(),
              AppSettingsTile(
                title: l10n.settingsRestartOnboarding,
                enabled: false,
                trailing: AppTbdPill(label: l10n.settingsTbd),
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return AppButton(
                      label: l10n.settingsLogout,
                      style: AppButtonStyle.secondary,
                      layout: AppButtonLayout.textWithIcon,
                      icon: Icons.logout,
                      onPressed: () => context
                          .read<AuthBloc>()
                          .add(const AuthLogoutRequested()),
                    );
                  }
                  return AppButton(
                    label: l10n.settingsSignIn,
                    layout: AppButtonLayout.textWithIcon,
                    icon: Icons.login,
                    onPressed: () => context.push(AppRoutes.login),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selected,
    required this.onChanged,
  });

  final AppThemeVariant selected;
  final ValueChanged<AppThemeVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _ChoiceChip(
          label: l10n.settingsThemeLight,
          isSelected: selected == AppThemeVariant.light,
          onTap: () => onChanged(AppThemeVariant.light),
        ),
        _ChoiceChip(
          label: l10n.settingsThemeDark,
          isSelected: selected == AppThemeVariant.dark,
          onTap: () => onChanged(AppThemeVariant.dark),
        ),
        _ChoiceChip(
          label: l10n.settingsThemeSolarized,
          isSelected: selected == AppThemeVariant.solarized,
          onTap: () => onChanged(AppThemeVariant.solarized),
        ),
      ],
    );
  }
}

class _FontScaleSelector extends StatelessWidget {
  const _FontScaleSelector({
    required this.selected,
    required this.onChanged,
  });

  final AppFontScale selected;
  final ValueChanged<AppFontScale> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final stepLabels = [
      l10n.settingsFontSizeSmall,
      l10n.settingsFontSizeDefault,
      l10n.settingsFontSizeLarge,
      l10n.settingsFontSizeExtraLarge,
    ];

    return AppSteppedSlider(
      steps: stepLabels,
      value: selected.index,
      minLabel: l10n.settingsFontSizeSmall,
      maxLabel: l10n.settingsFontSizeExtraLarge,
      onChanged: (index) => onChanged(AppFontScale.values[index]),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppSpacing.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: AppText(
            label,
            variant: AppTextVariant.label,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
