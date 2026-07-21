import 'package:medicail/features/appointment/domain/entities/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getByRange({
    required DateTime from,
    required DateTime to,
  });

  Future<Appointment?> getById(String id);

  Future<Appointment> save(Appointment appointment);

  Future<void> delete(String id);

  Future<void> clear();
}
