import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/domain/entities/custom_theme_colors.dart';

abstract class UserPreferencesRepository {
  Future<AppThemeVariant> readThemeVariant();

  Future<void> writeThemeVariant(AppThemeVariant variant);

  Future<CustomThemeColors> readCustomThemeColors();

  Future<void> writeCustomThemeColors(CustomThemeColors colors);

  Future<AppFontScale> readFontScale();

  Future<void> writeFontScale(AppFontScale scale);

  Future<AppSessionLength> readDefaultSessionLength();

  Future<void> writeDefaultSessionLength(AppSessionLength length);

  Future<bool> readAiEnhanceEnabled();

  Future<void> writeAiEnhanceEnabled(bool enabled);
}
