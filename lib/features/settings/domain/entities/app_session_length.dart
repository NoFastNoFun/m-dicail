import 'package:equatable/equatable.dart';

class AppSessionLength extends Equatable {
  const AppSessionLength({required this.totalMinutes})
      : assert(totalMinutes > 0);

  final int totalMinutes;

  static const int maxTotalMinutes = 12 * 60;

  static const minutes30 = AppSessionLength(totalMinutes: 30);
  static const minutes45 = AppSessionLength(totalMinutes: 45);
  static const hour1 = AppSessionLength(totalMinutes: 60);
  static const hour1Minutes30 = AppSessionLength(totalMinutes: 90);
  static const hours2 = AppSessionLength(totalMinutes: 120);

  static const List<AppSessionLength> presets = [
    minutes30,
    minutes45,
    hour1,
    hour1Minutes30,
    hours2,
  ];

  static AppSessionLength get defaultLength => hour1;

  Duration get duration => Duration(minutes: totalMinutes);

  bool get isPreset => presets.any((p) => p.totalMinutes == totalMinutes);

  int? get presetIndex {
    final index = presets.indexWhere((p) => p.totalMinutes == totalMinutes);
    return index >= 0 ? index : null;
  }

  int get closestPresetIndex {
    final exact = presetIndex;
    if (exact != null) return exact;

    var bestIndex = 0;
    var bestDelta = (presets[0].totalMinutes - totalMinutes).abs();
    for (var i = 1; i < presets.length; i++) {
      final delta = (presets[i].totalMinutes - totalMinutes).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  factory AppSessionLength.fromHoursAndMinutes({
    required int hours,
    required int minutes,
  }) {
    final total = (hours * 60) + minutes;
    final clamped = total.clamp(1, maxTotalMinutes);
    return AppSessionLength(totalMinutes: clamped);
  }

  String get storageKey => 'minutes_$totalMinutes';

  static AppSessionLength fromStorageKey(String? key) {
    if (key == null || key.isEmpty) return defaultLength;

    switch (key) {
      case 'hour_1':
        return hour1;
      case 'hour_1_30':
        return hour1Minutes30;
      case 'hours_2':
        return hours2;
    }

    if (key.startsWith('minutes_')) {
      final minutes = int.tryParse(key.substring('minutes_'.length));
      if (minutes != null && minutes > 0) {
        return AppSessionLength(
          totalMinutes: minutes.clamp(1, maxTotalMinutes),
        );
      }
    }

    return defaultLength;
  }

  @override
  List<Object?> get props => [totalMinutes];
}
