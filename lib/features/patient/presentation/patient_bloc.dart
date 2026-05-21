import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';

@injectable
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc(this._patientRepository) : super(const PatientInitial()) {
    on<PatientsRequested>(_onPatientsRequested);
    on<PatientCreated>(_onPatientCreated);
    on<PatientDeleted>(_onPatientDeleted);
  }

  final PatientRepository _patientRepository;

  Future<void> _onPatientsRequested(
    PatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    await _loadPatients(emit);
  }

  Future<void> _onPatientCreated(
    PatientCreated event,
    Emitter<PatientState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final patient = Patient(
        id: _generatePatientId(now),
        mrn: 'TEMP-MRN-${now.millisecondsSinceEpoch}',
        firstName: event.firstName.trim(),
        lastName: event.lastName.trim(),
        birthDate: event.birthDate,
        createdAt: now,
        updatedAt: now,
      );
      await _patientRepository.save(patient);
      await _loadPatients(emit);
    } catch (error) {
      emit(PatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onPatientDeleted(
    PatientDeleted event,
    Emitter<PatientState> emit,
  ) async {
    try {
      await _patientRepository.delete(event.id);
      await _loadPatients(emit);
    } catch (error) {
      emit(PatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadPatients(Emitter<PatientState> emit) async {
    try {
      final patients = await _patientRepository.getAll();
      emit(PatientLoaded(patients));
    } catch (error) {
      emit(PatientFailure(Failure.fromException(error).message));
    }
  }

  String _generatePatientId(DateTime createdAt) {
    return 'patient_${createdAt.toUtc().microsecondsSinceEpoch}';
  }
}
