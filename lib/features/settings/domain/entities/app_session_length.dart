enum AppSessionLength {
  minutes30,
  minutes45,
  hour1,
  hour1Minutes30,
  hours2,
}

extension AppSessionLengthStorage on AppSessionLength {
  String get storageKey => switch (this) {
        AppSessionLength.minutes30 => 'minutes_30',
        AppSessionLength.minutes45 => 'minutes_45',
        AppSessionLength.hour1 => 'hour_1',
        AppSessionLength.hour1Minutes30 => 'hour_1_30',
        AppSessionLength.hours2 => 'hours_2',
      };

  Duration get duration => switch (this) {
        AppSessionLength.minutes30 => const Duration(minutes: 30),
        AppSessionLength.minutes45 => const Duration(minutes: 45),
        AppSessionLength.hour1 => const Duration(hours: 1),
        AppSessionLength.hour1Minutes30 => const Duration(hours: 1, minutes: 30),
        AppSessionLength.hours2 => const Duration(hours: 2),
      };

  static AppSessionLength get defaultLength => AppSessionLength.hour1;

  static AppSessionLength fromStorageKey(String? key) {
    return AppSessionLength.values.firstWhere(
      (length) => length.storageKey == key,
      orElse: () => AppSessionLength.hour1,
    );
  }
}
