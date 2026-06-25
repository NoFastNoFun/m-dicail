import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';

abstract class UserPreferencesRepository {
  Future<AppThemeVariant> readThemeVariant();

  Future<void> writeThemeVariant(AppThemeVariant variant);

  Future<AppFontScale> readFontScale();

  Future<void> writeFontScale(AppFontScale scale);
}
