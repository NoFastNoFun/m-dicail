import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:medicail/core/design_system/app_custom_theme_palettes.dart';

final class CustomThemeColors extends Equatable {
  const CustomThemeColors({
    required this.primary,
    required this.background,
  });

  factory CustomThemeColors.defaults() {
    return CustomThemeColors(
      primary: AppCustomThemePalettes.defaultPrimary,
      background: AppCustomThemePalettes.defaultBackground,
    );
  }

  factory CustomThemeColors.fromStorage({
    required String? primaryHex,
    required String? backgroundHex,
  }) {
    return CustomThemeColors(
      primary: AppCustomThemePalettes.resolvePrimary(_parseHex(primaryHex)),
      background: AppCustomThemePalettes.resolveBackground(
        _parseHex(backgroundHex),
      ),
    );
  }

  final Color primary;
  final Color background;

  String get primaryStorageKey => _toHex(primary);

  String get backgroundStorageKey => _toHex(background);

  CustomThemeColors copyWith({
    Color? primary,
    Color? background,
  }) {
    return CustomThemeColors(
      primary: primary ?? this.primary,
      background: background ?? this.background,
    );
  }

  static Color? _parseHex(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final normalized = value.startsWith('#') ? value.substring(1) : value;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) {
      return null;
    }
    if (normalized.length == 6) {
      return Color(0xFF000000 | parsed);
    }
    if (normalized.length == 8) {
      return Color(parsed);
    }
    return null;
  }

  static String _toHex(Color color) {
    return color.toARGB32().toRadixString(16).padLeft(8, '0');
  }

  @override
  List<Object?> get props => [primary.toARGB32(), background.toARGB32()];
}
