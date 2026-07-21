import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

@injectable
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc(
    this._appointmentRepository,
    this._patientRepository,
  ) : super(const AppointmentInitial()) {
    on<AppointmentsDayRequested>(_onDayRequested);
    on<AppointmentSaved>(_onSaved);
    on<AppointmentCancelled>(_onCancelled);
    on<AppointmentDeleted>(_onDeleted);
  }

  final AppointmentRepository _appointmentRepository;
  final PatientRepository _patientRepository;

  DateTime? _currentDay;

  Future<void> _onDayRequested(
    AppointmentsDayRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    _currentDay = _dateOnly(event.day);
    emit(const AppointmentLoading());
    await _loadDay(emit, _currentDay!);
  }

  Future<void> _onSaved(
    AppointmentSaved event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final existing = event.id.isEmpty
          ? null
          : await _appointmentRepository.getById(event.id);

      final appointment = Appointment(
        id: event.id,
        patientId: event.patientId,
        startsAt: event.startsAt,
        endsAt: event.endsAt ?? event.startsAt.add(const Duration(minutes: 30)),
        status: event.status,
        notes: event.notes,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = await _appointmentRepository.save(appointment);
      emit(AppointmentSaveSuccess(saved.id));

      final day = _currentDay ?? _dateOnly(saved.startsAt);
      _currentDay = day;
      await _loadDay(emit, day);
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onCancelled(
    AppointmentCancelled event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      final existing = await _appointmentRepository.getById(event.id);
      if (existing == null) {
        emit(const AppointmentFailure('Rendez-vous introuvable'));
        return;
      }
      await _appointmentRepository.save(
        existing.copyWith(status: AppointmentStatus.cancelled),
      );
      final day = _currentDay ?? _dateOnly(existing.startsAt);
      await _loadDay(emit, day);
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _onDeleted(
    AppointmentDeleted event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      await _appointmentRepository.delete(event.id);
      final day = _currentDay ?? DateTime.now();
      await _loadDay(emit, _dateOnly(day));
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadDay(Emitter<AppointmentState> emit, DateTime day) async {
    try {
      final from = _dateOnly(day);
      final to = from.add(const Duration(days: 1));
      final appointments = await _appointmentRepository.getByRange(
        from: from,
        to: to,
      );

      final items = <AppointmentListItem>[];
      for (final appointment in appointments) {
        final patient =
            await _patientRepository.getById(appointment.patientId);
        items.add(
          AppointmentListItem(appointment: appointment, patient: patient),
        );
      }

      emit(AppointmentDayLoaded(day: from, items: items));
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
