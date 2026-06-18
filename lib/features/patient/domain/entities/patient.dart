import 'package:equatable/equatable.dart';
import 'package:medicail/features/patient/domain/entities/contact.dart';

class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.mrn,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.userId,
    this.birthDate,
    this.sex,
    this.contact,
    this.notes,
    this.metadata,
  });

  final String id;
  final String mrn;
  final String firstName;
  final String lastName;
  final int? userId;
  final DateTime? birthDate;
  final String? sex;
  final Contact? contact;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => '$firstName $lastName'.trim();

  Patient copyWith({
    String? id,
    String? mrn,
    String? firstName,
    String? lastName,
    int? userId,
    DateTime? birthDate,
    String? sex,
    Contact? contact,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBirthDate = false,
    bool clearSex = false,
    bool clearUserId = false,
    bool clearContact = false,
    bool clearNotes = false,
    bool clearMetadata = false,
  }) {
    return Patient(
      id: id ?? this.id,
      mrn: mrn ?? this.mrn,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userId: clearUserId ? null : userId ?? this.userId,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      sex: clearSex ? null : sex ?? this.sex,
      contact: clearContact ? null : contact ?? this.contact,
      notes: clearNotes ? null : notes ?? this.notes,
      metadata: clearMetadata ? null : metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        mrn,
        firstName,
        lastName,
        userId,
        birthDate,
        sex,
        contact,
        notes,
        metadata,
        createdAt,
        updatedAt,
      ];
}
