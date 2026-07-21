import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/appointment/domain/entities/appointment.dart';
import 'package:medicail/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:medicail/features/appointment/presentation/appointment_bloc.dart';
import 'package:medicail/features/appointment/presentation/appointment_event.dart';
import 'package:medicail/features/appointment/presentation/appointment_state.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';

class _FakeAppointmentRepository implements AppointmentRepository {
  final Map<String, Appointment> store = {};

  @override
  Future<void> clear() async => store.clear();

  @override
  Future<void> delete(String id) async {
    store.remove(id);
  }

  @override
  Future<Appointment?> getById(String id) async => store[id];

  @override
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  }) async {
    return store.values
        .where((a) => !a.startsAt.isBefore(from) && a.startsAt.isBefore(to))
        .toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  }

  @override
  Future<Appointment> save(Appointment appointment) async {
    final saved = appointment.id.isEmpty
        ? appointment.copyWith(id: 'appointment_1')
        : appointment;
    store[saved.id] = saved;
    return saved;
  }
}

class _FakePatientRepository implements PatientRepository {
  @override
  Future<void> clear() async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<List<Patient>> getAll({String? query}) async => [];

  @override
  Future<Patient?> getById(String id) async {
    if (id != 'patient_1') return null;
    final now = DateTime(2026, 7, 21);
    return Patient(
      id: 'patient_1',
      mrn: 'MRN1',
      firstName: 'Jean',
      lastName: 'Dupont',
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Patient> save(Patient patient) async => patient;
}

void main() {
  late _FakeAppointmentRepository appointmentRepository;
  late AppointmentBloc bloc;

  setUp(() {
    appointmentRepository = _FakeAppointmentRepository();
    bloc = AppointmentBloc(appointmentRepository, _FakePatientRepository());
  });

  tearDown(() => bloc.close());

  blocTest<AppointmentBloc, AppointmentState>(
    'loads day appointments with patient names',
    build: () {
      final startsAt = DateTime(2026, 7, 21, 10);
      appointmentRepository.store['a1'] = Appointment(
        id: 'a1',
        patientId: 'patient_1',
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(minutes: 30)),
        createdAt: startsAt,
        updatedAt: startsAt,
      );
      return bloc;
    },
    act: (bloc) =>
        bloc.add(AppointmentsDayRequested(DateTime(2026, 7, 21))),
    expect: () => [
      const AppointmentLoading(),
      isA<AppointmentDayLoaded>()
          .having((s) => s.items.length, 'items', 1)
          .having(
            (s) => s.items.first.patientDisplayName,
            'name',
            'Jean Dupont',
          ),
    ],
  );

  blocTest<AppointmentBloc, AppointmentState>(
    'creates then reloads day',
    build: () => bloc,
    act: (bloc) async {
      bloc.add(AppointmentsDayRequested(DateTime(2026, 7, 21)));
      await bloc.stream.firstWhere((s) => s is AppointmentDayLoaded);
      bloc.add(
        AppointmentSaved(
          patientId: 'patient_1',
          startsAt: DateTime(2026, 7, 21, 11),
        ),
      );
    },
    skip: 2,
    expect: () => [
      isA<AppointmentSaveSuccess>(),
      isA<AppointmentDayLoaded>().having((s) => s.items.length, 'items', 1),
    ],
  );

  blocTest<AppointmentBloc, AppointmentState>(
    'cancels appointment',
    build: () {
      final startsAt = DateTime(2026, 7, 21, 10);
      appointmentRepository.store['a1'] = Appointment(
        id: 'a1',
        patientId: 'patient_1',
        startsAt: startsAt,
        endsAt: startsAt.add(const Duration(minutes: 30)),
        createdAt: startsAt,
        updatedAt: startsAt,
      );
      return bloc;
    },
    act: (bloc) async {
      bloc.add(AppointmentsDayRequested(DateTime(2026, 7, 21)));
      await bloc.stream.firstWhere((s) => s is AppointmentDayLoaded);
      bloc.add(const AppointmentCancelled('a1'));
    },
    skip: 2,
    expect: () => [
      isA<AppointmentDayLoaded>().having(
        (s) => s.items.first.appointment.status,
        'status',
        AppointmentStatus.cancelled,
      ),
    ],
  );
}
