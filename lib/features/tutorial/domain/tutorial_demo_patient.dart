import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/tutorial/domain/tutorial_flow.dart';

class TutorialDemoPatient {
  TutorialDemoPatient._();

  static Patient get patient {
    final now = DateTime.now();
    return Patient(
      id: TutorialFlow.demoPatientId,
      mrn: 'DEMO-001',
      firstName: 'Marie',
      lastName: 'Dupont',
      createdAt: now,
      updatedAt: now,
    );
  }
}
