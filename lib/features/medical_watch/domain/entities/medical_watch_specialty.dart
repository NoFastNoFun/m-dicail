enum MedicalWatchSpecialty {
  rehabilitation,
  musculoskeletal,
  exerciseTherapy,
  manualTherapy,
}

extension MedicalWatchSpecialtyApiValue on MedicalWatchSpecialty {
  String get apiValue {
    return switch (this) {
      MedicalWatchSpecialty.rehabilitation => 'rehabilitation',
      MedicalWatchSpecialty.musculoskeletal => 'musculoskeletal',
      MedicalWatchSpecialty.exerciseTherapy => 'exercise_therapy',
      MedicalWatchSpecialty.manualTherapy => 'manual_therapy',
    };
  }
}

MedicalWatchSpecialty medicalWatchSpecialtyFromApiValue(String value) {
  return switch (value) {
    'rehabilitation' => MedicalWatchSpecialty.rehabilitation,
    'musculoskeletal' => MedicalWatchSpecialty.musculoskeletal,
    'exercise_therapy' => MedicalWatchSpecialty.exerciseTherapy,
    'manual_therapy' => MedicalWatchSpecialty.manualTherapy,
    _ => MedicalWatchSpecialty.rehabilitation,
  };
}
