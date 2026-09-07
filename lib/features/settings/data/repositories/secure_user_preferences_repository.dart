import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/features/settings/domain/entities/app_font_scale.dart';
import 'package:medicail/features/settings/domain/entities/app_session_length.dart';
import 'package:medicail/features/settings/domain/entities/app_theme_variant.dart';
import 'package:medicail/features/settings/domain/entities/custom_theme_colors.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';

@LazySingleton(as: UserPreferencesRepository)
class SecureUserPreferencesRepository implements UserPreferencesRepository {
  SecureUserPreferencesRepository(this._storage);

  static const String _themeKey = 'theme_variant';
  static const String _customPrimaryKey = 'custom_theme_primary';
  static const String _customBackgroundKey = 'custom_theme_background';
  static const String _fontScaleKey = 'font_scale';
  static const String _sessionLengthKey = 'default_session_length';

  final FlutterSecureStorage _storage;

  @override
  Future<AppThemeVariant> readThemeVariant() async {
    final value = await _storage.read(key: _themeKey);
    return AppThemeVariantStorage.fromStorageKey(value);
  }

  @override
  Future<void> writeThemeVariant(AppThemeVariant variant) async {
    await _storage.write(key: _themeKey, value: variant.storageKey);
  }

  @override
  Future<CustomThemeColors> readCustomThemeColors() async {
    final primaryHex = await _storage.read(key: _customPrimaryKey);
    final backgroundHex = await _storage.read(key: _customBackgroundKey);
    return CustomThemeColors.fromStorage(
      primaryHex: primaryHex,
      backgroundHex: backgroundHex,
    );
  }

  @override
  Future<void> writeCustomThemeColors(CustomThemeColors colors) async {
    await _storage.write(
      key: _customPrimaryKey,
      value: colors.primaryStorageKey,
    );
    await _storage.write(
      key: _customBackgroundKey,
      value: colors.backgroundStorageKey,
    );
  }

  @override
  Future<AppFontScale> readFontScale() async {
    final value = await _storage.read(key: _fontScaleKey);
    return AppFontScaleStorage.fromStorageKey(value);
  }

  @override
  Future<void> writeFontScale(AppFontScale scale) async {
    await _storage.write(key: _fontScaleKey, value: scale.storageKey);
  }

  @override
  Future<AppSessionLength> readDefaultSessionLength() async {
    final value = await _storage.read(key: _sessionLengthKey);
    return AppSessionLengthStorage.fromStorageKey(value);
  }

  @override
  Future<void> writeDefaultSessionLength(AppSessionLength length) async {
    await _storage.write(key: _sessionLengthKey, value: length.storageKey);
  }
}
