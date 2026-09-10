import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_event.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_state.dart';

@injectable
class PatientDetailBloc extends Bloc<PatientDetailEvent, PatientDetailState> {
  PatientDetailBloc(
    this._patientRepository,
    this._recordingRepository,
  ) : super(const PatientDetailInitial()) {
    on<PatientDetailRequested>(_onPatientDetailRequested);
    on<PatientDetailSessionDeleted>(_onSessionDeleted);
    on<PatientDetailArchived>(_onArchived);
    on<PatientDetailUnarchived>(_onUnarchived);
    on<PatientDetailDeleted>(_onDeleted);
  }

  final PatientRepository _patientRepository;
  final RecordingSessionRepository _recordingRepository;

  Future<void> _onPatientDetailRequested(
    PatientDetailRequested event,
    Emitter<PatientDetailState> emit,
  ) async {
    emit(const PatientDetailLoading());
    try {
      final patient = await _patientRepository.getById(event.patientId);
      final sessions = await _recordingRepository.getByPatientId(event.patientId);
      emit(PatientDetailLoaded(patient: patient, sessions: sessions));
    } catch (e) {
      emit(PatientDetailFailure(Failure.fromException(e).message));
    }
  }

  Future<void> _onSessionDeleted(
    PatientDetailSessionDeleted event,
    Emitter<PatientDetailState> emit,
  ) async {
    try {
      await _recordingRepository.delete(event.sessionId);
      final patient = await _patientRepository.getById(event.patientId);
      final sessions = await _recordingRepository.getByPatientId(event.patientId);
      emit(PatientDetailLoaded(patient: patient, sessions: sessions));
    } catch (e) {
      emit(PatientDetailFailure(Failure.fromException(e).message));
    }
  }

  Future<void> _onArchived(
    PatientDetailArchived event,
    Emitter<PatientDetailState> emit,
  ) async {
    try {
      final patient = await _patientRepository.archive(event.patientId);
      final sessions = await _recordingRepository.getByPatientId(event.patientId);
      emit(PatientDetailLoaded(patient: patient, sessions: sessions));
    } catch (e) {
      emit(PatientDetailFailure(Failure.fromException(e).message));
    }
  }

  Future<void> _onUnarchived(
    PatientDetailUnarchived event,
    Emitter<PatientDetailState> emit,
  ) async {
    try {
      final patient = await _patientRepository.unarchive(event.patientId);
      final sessions = await _recordingRepository.getByPatientId(event.patientId);
      emit(PatientDetailLoaded(patient: patient, sessions: sessions));
    } catch (e) {
      emit(PatientDetailFailure(Failure.fromException(e).message));
    }
  }

  Future<void> _onDeleted(
    PatientDetailDeleted event,
    Emitter<PatientDetailState> emit,
  ) async {
    try {
      await _patientRepository.delete(event.patientId);
      emit(const PatientDetailDeletedSuccess());
    } catch (e) {
      emit(PatientDetailFailure(Failure.fromException(e).message));
    }
  }
}
