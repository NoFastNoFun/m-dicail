import 'package:equatable/equatable.dart';
import 'package:medicail/features/medical_watch/domain/entities/medical_watch_specialty.dart';

sealed class MedicalWatchEvent extends Equatable {
  const MedicalWatchEvent();

  @override
  List<Object?> get props => [];
}

final class MedicalWatchRequested extends MedicalWatchEvent {
  const MedicalWatchRequested({
    this.specialty,
    this.limit = 50,
  });

  final MedicalWatchSpecialty? specialty;
  final int limit;

  @override
  List<Object?> get props => [specialty, limit];
}

final class MedicalWatchSpecialtyChanged extends MedicalWatchEvent {
  const MedicalWatchSpecialtyChanged(this.specialty);

  final MedicalWatchSpecialty? specialty;

  @override
  List<Object?> get props => [specialty];
}

final class MedicalWatchRefreshRequested extends MedicalWatchEvent {
  const MedicalWatchRefreshRequested({this.limit = 50});

  final int limit;

  @override
  List<Object?> get props => [limit];
}
