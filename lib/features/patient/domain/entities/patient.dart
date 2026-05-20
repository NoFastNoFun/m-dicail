import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.updatedAt,
    this.birthDate,
  });

  final String id;
  final String firstName;
  final String lastName;
  final DateTime? birthDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayName => '$firstName $lastName'.trim();

  Patient copyWith({
    String? id,
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearBirthDate = false,
  }) {
    return Patient(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: clearBirthDate ? null : birthDate ?? this.birthDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        birthDate,
        createdAt,
        updatedAt,
      ];
}
