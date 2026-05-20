import 'package:medicail/features/recording/domain/entities/recording_session.dart';

abstract class RecordingSessionRepository {
  Future<List<RecordingSession>> getAll();

  Future<RecordingSession?> getById(String id);

  Future<List<RecordingSession>> getByPatientId(String patientId);

  Future<void> save(RecordingSession session);

  Future<void> delete(String id);

  Future<void> clear();
}
