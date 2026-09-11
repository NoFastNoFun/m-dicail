import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';

/// Mutable draft used by the new-patient / edit anamnèse carousel.
class AnamneseFormData {
  AnamneseFormData({
    this.firstName = '',
    this.lastName = '',
    this.birthDate,
    this.birthPlace = '',
    this.address = '',
    this.sex,
    Anamnese? anamnese,
  }) : anamnese = anamnese ?? const Anamnese();

  factory AnamneseFormData.fromPatient(Patient patient) {
    return AnamneseFormData(
      firstName: patient.firstName,
      lastName: patient.lastName,
      birthDate: patient.birthDate,
      birthPlace: patient.metadata.birthPlace ?? '',
      address: patient.contact?.address ?? '',
      sex: patient.sex,
      anamnese: patient.metadata.anamnese,
    );
  }

  String firstName;
  String lastName;
  DateTime? birthDate;
  String birthPlace;
  String address;
  String? sex;
  Anamnese anamnese;

  bool get identityValid =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      birthDate != null;

  Map<String, dynamic> buildMetadata({Map<String, dynamic>? base}) {
    return (base ?? <String, dynamic>{})
        .withBirthPlace(birthPlace.trim().isEmpty ? null : birthPlace)
        .withAnamnese(anamnese);
  }

  static String generateMrn() {
    final now = DateTime.now().toUtc();
    return 'P${now.millisecondsSinceEpoch}';
  }
}
