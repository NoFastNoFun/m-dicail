import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

enum RecordingSessionStatus {
  draft,
  recording,
  completed,
  failed,
}

class RecordingSession extends Equatable {
  const RecordingSession({
    required this.id,
    required this.startedAt,
    required this.status,
    this.patientId,
    this.endedAt,
    this.rawAudioPath,
    this.transcript = '',
    this.soapNote,
  });

  final String id;
  final String? patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? rawAudioPath;
  final String transcript;
  final SoapNote? soapNote;
  final RecordingSessionStatus status;

  RecordingSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? rawAudioPath,
    String? transcript,
    SoapNote? soapNote,
    RecordingSessionStatus? status,
    bool clearPatientId = false,
    bool clearEndedAt = false,
    bool clearRawAudioPath = false,
    bool clearSoapNote = false,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      patientId: clearPatientId ? null : patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      rawAudioPath:
          clearRawAudioPath ? null : rawAudioPath ?? this.rawAudioPath,
      transcript: transcript ?? this.transcript,
      soapNote: clearSoapNote ? null : soapNote ?? this.soapNote,
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
        soapNote,
        status,
      ];
}
