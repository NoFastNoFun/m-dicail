import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/patient/domain/entities/contact.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/patient_event.dart';
import 'package:medicail/features/patient/presentation/patient_state.dart';
import 'package:dio/dio.dart';

@injectable
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc(this._patientRepository) : super(const PatientInitial()) {
    on<PatientsRequested>(
      _onPatientsRequested,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );
    on<PatientCreated>(_onPatientCreated);
    on<PatientUpdated>(_onPatientUpdated);
    on<PatientDeleted>(_onPatientDeleted);
  }

  final PatientRepository _patientRepository;

  Future<void> _onPatientsRequested(
    PatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(const PatientLoading());
    await _loadPatients(emit, query: event.query);
  }

  Future<void> _onPatientCreated(
    PatientCreated event,
    Emitter<PatientState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final patient = Patient(
        id: _generatePatientId(now),
        mrn: event.mrn.trim(),
        firstName: event.firstName.trim(),
        lastName: event.lastName.trim(),
        birthDate: event.birthDate,
        sex: event.sex,
        contact: Contact(
          email: event.email,
          phone: event.phone,
          address: event.address,
        ),
        notes: event.notes,
        createdAt: now,
        updatedAt: now,
      );
      final savedPatient = await _patientRepository.save(patient);
      emit(PatientCreateSuccess(savedPatient.id));
      await _loadPatients(emit);
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        emit(const PatientMrnConflict());
      } else {
        emit(PatientFailure(Failure.fromException(error).message));
      }
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

  Future<void> _onPatientUpdated(
    PatientUpdated event,
    Emitter<PatientState> emit,
  ) async {
    try {
      final savedPatient = await _patientRepository.save(event.patient);
      emit(PatientUpdateSuccess(savedPatient.id));
      await _loadPatients(emit);
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        emit(const PatientMrnConflict());
      } else {
        emit(PatientFailure(Failure.fromException(error).message));
      }
    } catch (error) {
      emit(PatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadPatients(
    Emitter<PatientState> emit, {
    String? query,
  }) async {
    try {
      final patients = await _patientRepository.getAll(query: query);
      emit(PatientLoaded(patients));
    } catch (error) {
      emit(PatientFailure(Failure.fromException(error).message));
    }
  }

  String _generatePatientId(DateTime createdAt) {
    return 'patient_${createdAt.toUtc().microsecondsSinceEpoch}';
  }
}
