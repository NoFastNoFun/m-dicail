import 'package:equatable/equatable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/domain/entities/custom_theme_colors.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.themeVariant,
    required this.customThemeColors,
    required this.fontScale,
    required this.defaultSessionLength,
    this.aiEnhanceEnabled = false,
  });

  final AppThemeVariant themeVariant;
  final CustomThemeColors customThemeColors;
  final AppFontScale fontScale;
  final AppSessionLength defaultSessionLength;
  final bool aiEnhanceEnabled;

  @override
  List<Object?> get props => [
        themeVariant,
        customThemeColors,
        fontScale,
        defaultSessionLength,
        aiEnhanceEnabled,
      ];

  SettingsLoaded copyWith({
    AppThemeVariant? themeVariant,
    CustomThemeColors? customThemeColors,
    AppFontScale? fontScale,
    AppSessionLength? defaultSessionLength,
    bool? aiEnhanceEnabled,
  }) {
    return SettingsLoaded(
      themeVariant: themeVariant ?? this.themeVariant,
      customThemeColors: customThemeColors ?? this.customThemeColors,
      fontScale: fontScale ?? this.fontScale,
      defaultSessionLength: defaultSessionLength ?? this.defaultSessionLength,
      aiEnhanceEnabled: aiEnhanceEnabled ?? this.aiEnhanceEnabled,
    );
  }
}
