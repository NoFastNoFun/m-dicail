import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:medicail/core/config/app_info.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/layout/main_shell_chrome.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/design_system/app_radius.dart';
import 'package:medicail/core/design_system/app_spacing.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/core/utils/app_haptics.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_event.dart';
import 'package:medicail/features/auth/presentation/bloc/auth_state.dart';
import 'package:medicail/core/design_system/app_custom_theme_palettes.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/domain/entities/custom_theme_colors.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_event.dart';
import 'package:medicail/features/settings/presentation/bloc/settings_state.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/widget/app_scaffold.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/app_text_field.dart';
import 'package:medicail/widget/feedback/app_toast.dart';
import 'package:medicail/widget/settings/app_color_swatch_picker.dart';
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
                  if (state.themeVariant == AppThemeVariant.custom)
                    AppSettingsTile(
                      icon: Icons.color_lens_outlined,
                      title: l10n.settingsThemeCustom,
                      child: _CustomThemeColorsSection(
                        colors: state.customThemeColors,
                        onChanged: (colors) =>
                            context.read<SettingsBloc>().add(
                              SettingsCustomThemeColorsChanged(colors),
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
                  AppSettingsTile(
                    icon: Icons.newspaper_outlined,
                    title: l10n.medicalWatchTitle,
                    subtitle: l10n.settingsComingSoon,
                    enabled: false,
                  ),
                ],
              ),
              AppSettingsGroup(
                title: l10n.settingsSectionAi,
                children: [
                  AppSettingsTile(
                    icon: Icons.auto_awesome_outlined,
                    title: l10n.settingsAiEnhance,
                    subtitle: l10n.settingsAiEnhanceSubtitle,
                    trailing: Switch(
                      value: state.aiEnhanceEnabled,
                      onChanged: (enabled) => context.read<SettingsBloc>().add(
                        SettingsAiEnhanceChanged(enabled),
                      ),
                    ),
                    child: state.aiEnhanceEnabled
                        ? AppText(
                            l10n.settingsAiEnhanceWarning,
                            variant: AppTextVariant.caption,
                            color: Theme.of(context).colorScheme.error,
                          )
                        : null,
                  ),
                ],
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  return AppSettingsGroup(
                    title: l10n.settingsSectionAccount,
                    children: [
                      if (authState is AuthAuthenticated) ...[
                        AppSettingsTile(
                          icon: Icons.person_outline,
                          title: l10n.settingsProfileTitle,
                          subtitle: [
                            if (authState.user.fullName != null &&
                                authState.user.fullName!.isNotEmpty)
                              authState.user.fullName!,
                            authState.user.email,
                          ].join(' · '),
                          showChevron: true,
                          onTap: () =>
                              context.push(AppRoutes.settingsProfile),
                        ),
                      ],
                      AppSettingsTile(
                        icon: Icons.lock_outline,
                        title: l10n.authSecurityTitle,
                        showChevron: true,
                        onTap: () =>
                            context.push(AppRoutes.settingsSecurity),
                      ),
                      AppSettingsTile(
                        icon: Icons.school_outlined,
                        title: l10n.settingsRestartOnboarding,
                        onTap: () {
                          context.read<TutorialBloc>().add(
                            const TutorialStartRequested(),
                          );
                          AppToast.showSuccess(
                            context,
                            l10n.tutorialRestarted,
                          );
                          context.go(AppRoutes.home);
                        },
                      ),
                    ],
                  );
                },
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
              Builder(
                builder: (context) {
                  final appInfo = getIt<AppInfo>();
                  return AppSettingsGroup(
                    title: l10n.settingsSectionAbout,
                    children: [
                      AppSettingsTile(
                        icon: Icons.info_outline,
                        title: appInfo.appName.isNotEmpty
                            ? appInfo.appName
                            : l10n.appTitle,
                        subtitle:
                            '${l10n.settingsAppVersion}: ${appInfo.version}',
                      ),
                      AppSettingsTile(
                        icon: Icons.medical_services_outlined,
                        title: l10n.settingsAboutProductTitle,
                        subtitle: l10n.settingsAboutProductSubtitle,
                      ),
                      AppSettingsTile(
                        icon: Icons.lock_outline,
                        title: l10n.settingsAboutDataTitle,
                        subtitle: l10n.settingsAboutDataSubtitle,
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
        (value: AppThemeVariant.custom, label: l10n.settingsThemeCustom),
      ],
    );
  }
}

class _CustomThemeColorsSection extends StatelessWidget {
  const _CustomThemeColorsSection({
    required this.colors,
    required this.onChanged,
  });

  final CustomThemeColors colors;
  final ValueChanged<CustomThemeColors> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          l10n.settingsThemeBackground,
          variant: AppTextVariant.label,
          color: context.secondaryTextColor,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppColorSwatchPicker(
          colors: AppCustomThemePalettes.backgroundsLight,
          selected: colors.background,
          onChanged: (background) => onChanged(
            colors.copyWith(background: background),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppColorSwatchPicker(
          colors: AppCustomThemePalettes.backgroundsDark,
          selected: colors.background,
          onChanged: (background) => onChanged(
            colors.copyWith(background: background),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          l10n.settingsThemePrimary,
          variant: AppTextVariant.label,
          color: context.secondaryTextColor,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppColorSwatchPicker(
          colors: AppCustomThemePalettes.primaryLight,
          selected: colors.primary,
          onChanged: (primary) => onChanged(
            colors.copyWith(primary: primary),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppColorSwatchPicker(
          colors: AppCustomThemePalettes.primaryDark,
          selected: colors.primary,
          onChanged: (primary) => onChanged(
            colors.copyWith(primary: primary),
          ),
        ),
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

class _SessionLengthSelector extends StatefulWidget {
  const _SessionLengthSelector({
    required this.selected,
    required this.onChanged,
  });

  final AppSessionLength selected;
  final ValueChanged<AppSessionLength> onChanged;

  @override
  State<_SessionLengthSelector> createState() => _SessionLengthSelectorState();
}

class _SessionLengthSelectorState extends State<_SessionLengthSelector> {
  static const double _fieldWidth = 96;

  late bool _customEnabled;
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _customEnabled = !widget.selected.isPreset;
    _hoursController = TextEditingController();
    _minutesController = TextEditingController();
    if (_customEnabled) {
      _syncControllersFrom(widget.selected);
    }
  }

  @override
  void didUpdateWidget(covariant _SessionLengthSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_customEnabled && oldWidget.selected != widget.selected) {
      _syncControllersFrom(widget.selected);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _syncControllersFrom(AppSessionLength length) {
    final hours = length.totalMinutes ~/ 60;
    final minutes = length.totalMinutes % 60;
    final hoursText = '$hours';
    final minutesText = '$minutes';
    if (_hoursController.text != hoursText) {
      _hoursController.value = TextEditingValue(
        text: hoursText,
        selection: TextSelection.collapsed(offset: hoursText.length),
      );
    }
    if (_minutesController.text != minutesText) {
      _minutesController.value = TextEditingValue(
        text: minutesText,
        selection: TextSelection.collapsed(offset: minutesText.length),
      );
    }
  }

  String _formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '$minutes min';
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes';
  }

  void _onPresetSelected(int index) {
    setState(() {
      _customEnabled = false;
      _hoursController.clear();
      _minutesController.clear();
    });
    widget.onChanged(AppSessionLength.presets[index]);
  }

  void _onCustomToggled(bool enabled) {
    AppHaptics.tap();
    if (enabled) {
      setState(() => _customEnabled = true);
      _syncControllersFrom(widget.selected);
      return;
    }

    setState(() {
      _customEnabled = false;
      _hoursController.clear();
      _minutesController.clear();
    });
    final presetIndex =
        widget.selected.presetIndex ?? widget.selected.closestPresetIndex;
    widget.onChanged(AppSessionLength.presets[presetIndex]);
  }

  void _emitCustomFromFields() {
    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;

    if (hours == 0 && minutes == 0) {
      // Keep previous selection; reset fields so UI matches valueLabel.
      _syncControllersFrom(widget.selected);
      return;
    }

    // Normalize minutes > 59 into hours + remainder for consistent fields.
    var normalizedHours = hours;
    var normalizedMinutes = minutes;
    if (normalizedMinutes > 59) {
      normalizedHours += normalizedMinutes ~/ 60;
      normalizedMinutes = normalizedMinutes % 60;
    }

    final length = AppSessionLength.fromHoursAndMinutes(
      hours: normalizedHours,
      minutes: normalizedMinutes,
    );
    widget.onChanged(length);
    _syncControllersFrom(length);
  }

  Widget _compactDurationField({
    required String label,
    required TextEditingController controller,
    required String suffixText,
    required int maxDigits,
  }) {
    return SizedBox(
      width: _fieldWidth,
      child: AppInput(
        variant: AppInputVariant.number,
        label: label,
        controller: controller,
        hint: '0',
        suffixText: suffixText,
        textAlign: TextAlign.center,
        validator: (_) => null,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(maxDigits),
        ],
        onChanged: (_) => _emitCustomFromFields(),
      ),
    );
  }

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

    final sliderIndex =
        widget.selected.presetIndex ?? widget.selected.closestPresetIndex;
    final valueLabel = _customEnabled
        ? _formatDuration(widget.selected.totalMinutes)
        : stepLabels[sliderIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSteppedSlider(
          steps: stepLabels,
          value: sliderIndex,
          valueLabel: valueLabel,
          minLabel: l10n.settingsSessionLength30m,
          maxLabel: l10n.settingsSessionLength2h,
          onChanged: _onPresetSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppText(
                l10n.settingsSessionLengthCustom,
                variant: AppTextVariant.label,
              ),
            ),
            Switch(
              value: _customEnabled,
              onChanged: _onCustomToggled,
            ),
          ],
        ),
        if (_customEnabled) ...[
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _compactDurationField(
                label: l10n.settingsSessionLengthHours,
                controller: _hoursController,
                suffixText: l10n.settingsSessionLengthHoursUnit,
                maxDigits: 2,
              ),
              _compactDurationField(
                label: l10n.settingsSessionLengthMinutes,
                controller: _minutesController,
                suffixText: l10n.settingsSessionLengthMinutesUnit,
                maxDigits: 2,
              ),
            ],
          ),
        ],
      ],
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
