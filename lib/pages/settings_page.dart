import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_event.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/settings/app_settings_group.dart';
import 'package:medicail/widget/settings/app_settings_tile.dart';
import 'package:medicail/widget/settings/app_stepped_slider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shellPadding = MainShellScope.scrollPaddingOf(context);

    return AppScaffold(
      title: l10n.settingsTitle,
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: shellPadding.copyWith(
              bottom: shellPadding.bottom +
                  (MainShellChrome.fabHeight + AppSpacing.xxl) / 2,
            ),
            children: [
              AppSettingsGroup(
                title: l10n.settingsSectionDisplay,
                children: [
                  AppSettingsTile(
                    icon: Icons.palette_outlined,
                    title: l10n.settingsTheme,
                    child: _ThemeSelector(
                      selected: state.themeVariant,
                      onChanged: (variant) => context.read<SettingsBloc>().add(
                        SettingsThemeChanged(variant),
                      ),
                    ),
                  ),
                  AppSettingsTile(
                    icon: Icons.format_size,
                    title: l10n.settingsFontSize,
                    child: _FontScaleSelector(
                      selected: state.fontScale,
                      onChanged: (scale) => context.read<SettingsBloc>().add(
                        SettingsFontScaleChanged(scale),
                      ),
                    ),
                  ),
                ],
              ),
              AppSettingsGroup(
                title: l10n.settingsSectionSession,
                children: [
                  AppSettingsTile(
                    icon: Icons.timer_outlined,
                    title: l10n.settingsDefaultSessionLength,
                    child: _SessionLengthSelector(
                      selected: state.defaultSessionLength,
                      onChanged: (length) => context.read<SettingsBloc>().add(
                        SettingsDefaultSessionLengthChanged(length),
                      ),
                    ),
                  ),
                  AppSettingsTile(
                    icon: Icons.medical_information_outlined,
                    title: l10n.settingsTemplates,
                    showChevron: true,
                    onTap: () => context.goTemplates(),
                  ),
                ],
              ),
              AppSettingsGroup(
                title: l10n.settingsSectionAccount,
                children: [
                  AppSettingsTile(
                    icon: Icons.lock_outline,
                    title: l10n.authSecurityTitle,
                    showChevron: true,
                    onTap: () => context.push(AppRoutes.settingsSecurity),
                  ),
                  AppSettingsTile(
                    icon: Icons.school_outlined,
                    title: l10n.settingsRestartOnboarding,
                    onTap: () {
                      context.read<TutorialBloc>().add(
                        const TutorialStartRequested(),
                      );
                      AppToast.showSuccess(context, l10n.tutorialRestarted);
                      context.go(AppRoutes.home);
                    },
                  ),
                ],
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final isAuthenticated = authState is AuthAuthenticated;
                  final colorScheme = Theme.of(context).colorScheme;

                  return AppSettingsGroup(
                    children: [
                      AppSettingsTile(
                        icon: isAuthenticated
                            ? Icons.logout
                            : Icons.login,
                        iconColor: isAuthenticated
                            ? colorScheme.error
                            : colorScheme.primary,
                        titleColor: isAuthenticated
                            ? colorScheme.error
                            : null,
                        title: isAuthenticated
                            ? l10n.settingsLogout
                            : l10n.settingsSignIn,
                        onTap: () {
                          if (isAuthenticated) {
                            context.read<AuthBloc>().add(
                              const AuthLogoutRequested(),
                            );
                          } else {
                            context.push(AppRoutes.login);
                          }
                        },
                      ),
                    ],
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
  const _ThemeSelector({required this.selected, required this.onChanged});

  final AppThemeVariant selected;
  final ValueChanged<AppThemeVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return _SegmentedControl<AppThemeVariant>(
      value: selected,
      onChanged: onChanged,
      options: [
        (value: AppThemeVariant.light, label: l10n.settingsThemeLight),
        (value: AppThemeVariant.dark, label: l10n.settingsThemeDark),
        (value: AppThemeVariant.solarized, label: l10n.settingsThemeSolarized),
      ],
    );
  }
}

class _FontScaleSelector extends StatelessWidget {
  const _FontScaleSelector({required this.selected, required this.onChanged});

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

class _SessionLengthSelector extends StatelessWidget {
  const _SessionLengthSelector({
    required this.selected,
    required this.onChanged,
  });

  final AppSessionLength selected;
  final ValueChanged<AppSessionLength> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final stepLabels = [
      l10n.settingsSessionLength30m,
      l10n.settingsSessionLength45m,
      l10n.settingsSessionLength1h,
      l10n.settingsSessionLength1h30,
      l10n.settingsSessionLength2h,
    ];

    return AppSteppedSlider(
      steps: stepLabels,
      value: selected.index,
      minLabel: l10n.settingsSessionLength30m,
      maxLabel: l10n.settingsSessionLength2h,
      onChanged: (index) => onChanged(AppSessionLength.values[index]),
    );
  }
}

class _SegmentedControl<T> extends StatelessWidget {
  const _SegmentedControl({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<({T value, String label})> options;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: AppRadius.pillBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _SegmentedOption(
                  label: option.label,
                  isSelected: option.value == value,
                  onTap: () => onChanged(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedOption extends StatelessWidget {
  const _SegmentedOption({
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
      color: isSelected ? theme.colorScheme.primary : Colors.transparent,
      borderRadius: AppRadius.pillBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pillBorder,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget - AppSpacing.sm,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: AppText(
                label,
                variant: AppTextVariant.label,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : context.secondaryTextColor,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
