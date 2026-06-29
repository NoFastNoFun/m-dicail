import 'package:medicail/features/recording/domain/entities/recording_session.dart';

abstract class RecordingSessionRepository {
  Future<RecordingSession> create(RecordingSession session);

  Future<List<RecordingSession>> getAll();

  Future<RecordingSession?> getById(String id);

  Future<List<RecordingSession>> getByPatientId(String patientId);

  Future<RecordingSession> save(RecordingSession session);

  Future<RecordingSession> associatePatient(String sessionId, String patientId);

  Future<void> delete(String id);

  Future<void> clear();
}
