import 'package:medicail/features/patient/domain/entities/patient.dart';

final class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
    required super.updatedAt,
    super.birthDate,
  });

  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      firstName: patient.firstName,
      lastName: patient.lastName,
      birthDate: patient.birthDate,
      createdAt: patient.createdAt,
      updatedAt: patient.updatedAt,
    );
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      birthDate: _parseNullableDate(json['birthDate']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }
}
