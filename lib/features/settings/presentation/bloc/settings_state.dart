import 'package:equatable/equatable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';

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
    required this.fontScale,
  });

  final AppThemeVariant themeVariant;
  final AppFontScale fontScale;

  @override
  List<Object?> get props => [themeVariant, fontScale];

  SettingsLoaded copyWith({
    AppThemeVariant? themeVariant,
    AppFontScale? fontScale,
  }) {
    return SettingsLoaded(
      themeVariant: themeVariant ?? this.themeVariant,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
