import 'package:equatable/equatable.dart';

enum RecordingSessionStatus {
  draft,
  recording,
  completed,
  failed,
}

final class RecordingSession extends Equatable {
  const RecordingSession({
    required this.id,
    required this.startedAt,
    required this.status,
    this.patientId,
    this.endedAt,
    this.rawAudioPath,
    this.transcript = '',
  });

  final String id;
  final String? patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? rawAudioPath;
  final String transcript;
  final RecordingSessionStatus status;

  RecordingSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? rawAudioPath,
    String? transcript,
    RecordingSessionStatus? status,
    bool clearPatientId = false,
    bool clearEndedAt = false,
    bool clearRawAudioPath = false,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      patientId: clearPatientId ? null : patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      rawAudioPath:
          clearRawAudioPath ? null : rawAudioPath ?? this.rawAudioPath,
      transcript: transcript ?? this.transcript,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        startedAt,
        endedAt,
        rawAudioPath,
        transcript,
        status,
      ];
}
