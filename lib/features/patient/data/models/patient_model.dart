import 'package:medicail/features/patient/domain/entities/contact.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';

final class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.mrn,
    required super.firstName,
    required super.lastName,
    required super.createdAt,
    required super.updatedAt,
    super.userId,
    super.birthDate,
    super.sex,
    super.contact,
    super.notes,
    super.metadata,
  });

  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      mrn: patient.mrn,
      firstName: patient.firstName,
      lastName: patient.lastName,
      userId: patient.userId,
      birthDate: patient.birthDate,
      sex: patient.sex,
      contact: patient.contact,
      notes: patient.notes,
      metadata: patient.metadata,
      createdAt: patient.createdAt,
      updatedAt: patient.updatedAt,
    );
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      mrn: json['mrn'] as String? ?? '',
      firstName:
          json['first_name'] as String? ?? json['firstName'] as String? ?? '',
      lastName:
          json['last_name'] as String? ?? json['lastName'] as String? ?? '',
      userId: _parseNullableInt(json['user_id'] ?? json['userId']),
      birthDate: _parseNullableDate(json['birth_date'] ?? json['birthDate']),
      sex: json['sex'] as String?,
      contact: json['contact'] != null
          ? Contact.fromJson(json['contact'] as Map<String, dynamic>)
          : null,
      notes: _blankToNull(json['notes'] as String?),
      metadata: json['patient_metadata'] as Map<String, dynamic>?,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'mrn': mrn,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate != null
          ? '${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}'
          : null,
      'sex': sex,
      'contact': contact?.toJson(),
      'notes': _blankToNull(notes),
      'patient_metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toApiJson() {
    return {
      'mrn': mrn,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate != null
          ? '${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}'
          : null,
      'sex': sex,
      'contact': contact?.toJson(),
      'notes': _blankToNull(notes),
      'patient_metadata': metadata,
    };
  }

  static DateTime _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }

  static int? _parseNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
