import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise.dart';
import 'package:medicail/features/exo_patient/domain/entities/patient_exercise_status.dart';
import 'package:medicail/features/exo_patient/domain/repositories/exercise_repository.dart';
import 'package:medicail/features/exo_patient/domain/repositories/patient_exercise_repository.dart';
import 'package:medicail/features/exo_patient/presentation/exo_patient_event.dart';
import 'package:medicail/features/exo_patient/presentation/exo_patient_state.dart';

@injectable
class ExoPatientBloc extends Bloc<ExoPatientEvent, ExoPatientState> {
  ExoPatientBloc(
    this._exerciseRepository,
    this._patientExerciseRepository,
  ) : super(const ExoPatientInitial()) {
    on<ExoPatientDataRequested>(_onDataRequested);
    on<ExoPatientAssignRequested>(_onAssign);
    on<ExoPatientStatusUpdateRequested>(_onStatusUpdate);
    on<ExoPatientUnassignRequested>(_onUnassign);
  }

  final ExerciseRepository _exerciseRepository;
  final PatientExerciseRepository _patientExerciseRepository;

  Future<void> _onDataRequested(
    ExoPatientDataRequested event,
    Emitter<ExoPatientState> emit,
  ) async {
    emit(const ExoPatientLoading());
    await _loadData(event.patientId, emit);
  }

  Future<void> _onAssign(
    ExoPatientAssignRequested event,
    Emitter<ExoPatientState> emit,
  ) async {
    try {
      final assignment = await _patientExerciseRepository.assign(
        PatientExercise(
          id: '',
          patientId: event.patientId,
          exerciseId: event.exerciseId,
          assignedAt: DateTime.now(),
          status: PatientExerciseStatus.assigned,
          frequency: event.frequency,
          notes: event.notes,
        ),
      );
      await _emitActionSuccess(
        patientId: event.patientId,
        message: 'assigned',
        affectedAssignmentId: assignment.id,
        emit: emit,
      );
    } catch (error) {
      emit(ExoPatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onStatusUpdate(
    ExoPatientStatusUpdateRequested event,
    Emitter<ExoPatientState> emit,
  ) async {
    try {
      final assignment = await _patientExerciseRepository.updateStatus(
        id: event.assignmentId,
        status: event.status,
      );
      await _emitActionSuccess(
        patientId: event.patientId,
        message: 'status_updated',
        affectedAssignmentId: assignment.id,
        emit: emit,
      );
    } catch (error) {
      emit(ExoPatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onUnassign(
    ExoPatientUnassignRequested event,
    Emitter<ExoPatientState> emit,
  ) async {
    try {
      await _patientExerciseRepository.unassign(event.assignmentId);
      await _emitActionSuccess(
        patientId: event.patientId,
        message: 'unassigned',
        affectedAssignmentId: event.assignmentId,
        emit: emit,
      );
    } catch (error) {
      emit(ExoPatientFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _emitActionSuccess({
    required String patientId,
    required String message,
    required String? affectedAssignmentId,
    required Emitter<ExoPatientState> emit,
  }) async {
    final catalog = await _exerciseRepository.getAll();
    final assignments = await _patientExerciseRepository.getForPatient(
      patientId,
    );

    if (emit.isDone) {
      return;
    }

    emit(
      ExoPatientActionSuccess(
        catalog: catalog,
        assignments: assignments,
        message: message,
        affectedAssignmentId: affectedAssignmentId,
      ),
    );
  }

  Future<void> _loadData(String patientId, Emitter<ExoPatientState> emit) async {
    try {
      final catalog = await _exerciseRepository.getAll();
      final assignments = await _patientExerciseRepository.getForPatient(
        patientId,
      );

      if (emit.isDone) {
        return;
      }

      emit(ExoPatientLoaded(catalog: catalog, assignments: assignments));
    } catch (error) {
      if (emit.isDone) {
        return;
      }
      emit(ExoPatientFailure(Failure.fromException(error).message));
    }
  }
}
