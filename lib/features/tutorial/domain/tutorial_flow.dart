enum TutorialStepId {
  homePatients,
  patientsAdd,
  patientMrn,
  patientFirstName,
  patientLastName,
  patientCreate,
  patientConsultation,
  recordFromPatient,
  recordStopFromPatient,
  recordFinishFromPatient,
  homeQuickRecord,
  quickRecordStart,
}

class TutorialStepDefinition {
  const TutorialStepDefinition({required this.index, required this.id});

  final int index;
  final TutorialStepId id;
}

class TutorialFlow {
  const TutorialFlow._();

  static const steps = <TutorialStepDefinition>[
    TutorialStepDefinition(index: 1, id: TutorialStepId.homePatients),
    TutorialStepDefinition(index: 2, id: TutorialStepId.patientsAdd),
    TutorialStepDefinition(index: 3, id: TutorialStepId.patientMrn),
    TutorialStepDefinition(index: 4, id: TutorialStepId.patientFirstName),
    TutorialStepDefinition(index: 5, id: TutorialStepId.patientLastName),
    TutorialStepDefinition(index: 6, id: TutorialStepId.patientCreate),
    TutorialStepDefinition(index: 7, id: TutorialStepId.patientConsultation),
    TutorialStepDefinition(index: 8, id: TutorialStepId.recordFromPatient),
    TutorialStepDefinition(index: 9, id: TutorialStepId.recordStopFromPatient),
    TutorialStepDefinition(
      index: 10,
      id: TutorialStepId.recordFinishFromPatient,
    ),
    TutorialStepDefinition(index: 11, id: TutorialStepId.homeQuickRecord),
    TutorialStepDefinition(index: 12, id: TutorialStepId.quickRecordStart),
  ];

  static int get firstStep => steps.first.index;

  static int get lastStep => steps.last.index;

  static int indexOf(TutorialStepId id) {
    return steps.firstWhere((step) => step.id == id).index;
  }

  static TutorialStepId? idFromIndex(int index) {
    for (final step in steps) {
      if (step.index == index) return step.id;
    }
    return null;
  }

  static bool isStep(int currentStep, TutorialStepId id) {
    return currentStep == indexOf(id);
  }

  static int? nextStepAfter(int currentStep) {
    for (var index = 0; index < steps.length; index++) {
      if (steps[index].index != currentStep) continue;
      final nextIndex = index + 1;
      if (nextIndex >= steps.length) return null;
      return steps[nextIndex].index;
    }
    return null;
  }
}
