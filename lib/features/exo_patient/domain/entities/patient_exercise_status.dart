enum PatientExerciseStatus {
  assigned,
  inProgress,
  completed,
  discontinued,
}

extension PatientExerciseStatusX on PatientExerciseStatus {
  String get jsonValue => name;

  static PatientExerciseStatus fromJson(String? value) {
    return PatientExerciseStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PatientExerciseStatus.assigned,
    );
  }
}
