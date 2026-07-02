enum NoteSectionKind {
  subjective,
  objective,
  assessment,
  plan,
  custom,
}

extension NoteSectionKindX on NoteSectionKind {
  String get jsonValue => name;

  static NoteSectionKind fromJson(String? value) {
    return NoteSectionKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => NoteSectionKind.custom,
    );
  }
}
