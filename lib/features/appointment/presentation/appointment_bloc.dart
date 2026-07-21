import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/failure.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medicail/features/appointment/presentation/appointment_change_notifier.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

enum _AppointmentLoadMode { day, upcoming }

@injectable
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  AppointmentBloc(
    this._appointmentRepository,
    this._patientRepository,
  ) : super(const AppointmentInitial()) {
    on<AppointmentsDayRequested>(_onDayRequested);
    on<AppointmentsUpcomingRequested>(_onUpcomingRequested);
    on<AppointmentSaved>(_onSaved);
    on<AppointmentCancelled>(_onCancelled);
    on<AppointmentDeleted>(_onDeleted);
  }

  final AppointmentRepository _appointmentRepository;
  final PatientRepository _patientRepository;

  _AppointmentLoadMode _mode = _AppointmentLoadMode.day;
  DateTime? _currentDay;
  int _upcomingLimit = 5;
  int _upcomingHorizonDays = 30;

  Future<void> _onDayRequested(
    AppointmentsDayRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    _mode = _AppointmentLoadMode.day;
    _currentDay = _dateOnly(event.day);
    emit(const AppointmentLoading());
    await _loadDay(emit, _currentDay!);
  }

  Future<void> _onUpcomingRequested(
    AppointmentsUpcomingRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    _mode = _AppointmentLoadMode.upcoming;
    _upcomingLimit = event.limit;
    _upcomingHorizonDays = event.horizonDays;
    if (event.showLoading) {
      emit(const AppointmentLoading());
    }
    await _loadUpcoming(emit);
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
        endsAt: event.endsAt ?? event.startsAt.add(const Duration(hours: 1)),
        status: event.status,
        notes: event.notes,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = await _appointmentRepository.save(appointment);
      await _reload(emit, fallbackDay: _dateOnly(saved.startsAt));
      appointmentChangeNotifier.notifyChanged();
      emit(AppointmentSaveSuccess(saved.id));
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
      appointmentChangeNotifier.notifyChanged();
      await _reload(emit, fallbackDay: _dateOnly(existing.startsAt));
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
      appointmentChangeNotifier.notifyChanged();
      await _reload(emit, fallbackDay: _dateOnly(DateTime.now()));
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _reload(
    Emitter<AppointmentState> emit, {
    required DateTime fallbackDay,
  }) async {
    if (_mode == _AppointmentLoadMode.upcoming) {
      await _loadUpcoming(emit);
      return;
    }
    final day = _currentDay ?? fallbackDay;
    _currentDay = day;
    await _loadDay(emit, day);
  }

  Future<void> _loadDay(Emitter<AppointmentState> emit, DateTime day) async {
    try {
      final from = _dateOnly(day);
      final to = from.add(const Duration(days: 1));
      final appointments = await _appointmentRepository.getByRange(
        from: from,
        to: to,
      );
      emit(
        AppointmentDayLoaded(
          day: from,
          items: await _toItems(appointments),
        ),
      );
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  Future<void> _loadUpcoming(Emitter<AppointmentState> emit) async {
    try {
      final now = DateTime.now();
      // Truncate to the minute so appointments whose start was picked as
      // TimeOfDay.now() are not excluded by second-level clock skew.
      final from = DateTime(now.year, now.month, now.day, now.hour, now.minute);
      final endOfToday = _dateOnly(now).add(const Duration(days: 1));

      var appointments = await _appointmentRepository.getByRange(
        from: from,
        to: endOfToday,
      );
      var upcoming = _filterUpcoming(appointments);

      if (upcoming.isEmpty) {
        final to = endOfToday.add(Duration(days: _upcomingHorizonDays));
        appointments = await _appointmentRepository.getByRange(
          from: endOfToday,
          to: to,
        );
        upcoming = _filterUpcoming(appointments).take(_upcomingLimit).toList();
      } else {
        upcoming = upcoming.take(_upcomingLimit).toList();
      }

      emit(
        AppointmentDayLoaded(
          day: _dateOnly(now),
          items: await _toItems(upcoming),
        ),
      );
    } catch (error) {
      emit(AppointmentFailure(Failure.fromException(error).message));
    }
  }

  List<Appointment> _filterUpcoming(List<Appointment> appointments) {
    return appointments
        .where((a) => a.status != AppointmentStatus.cancelled)
        .toList();
  }

  Future<List<AppointmentListItem>> _toItems(
    List<Appointment> appointments,
  ) async {
    final items = <AppointmentListItem>[];
    for (final appointment in appointments) {
      final patient = await _patientRepository.getById(appointment.patientId);
      items.add(
        AppointmentListItem(appointment: appointment, patient: patient),
      );
    }
    return items;
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
