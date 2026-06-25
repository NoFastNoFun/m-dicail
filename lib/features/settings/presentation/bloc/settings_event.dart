import 'package:equatable/equatable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

final class SettingsLoadRequested extends SettingsEvent {
  const SettingsLoadRequested();
}

final class SettingsThemeChanged extends SettingsEvent {
  const SettingsThemeChanged(this.variant);

  final AppThemeVariant variant;

  @override
  List<Object?> get props => [variant];
}

final class SettingsFontScaleChanged extends SettingsEvent {
  const SettingsFontScaleChanged(this.scale);

  final AppFontScale scale;

  @override
  List<Object?> get props => [scale];
}
