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
    this.transcript = '',
    this.soapNote,
    this.summary,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String transcript;
  final SoapNote? soapNote;
  final String? summary;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RecordingSessionStatus status;

  RecordingSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? transcript,
    SoapNote? soapNote,
    String? summary,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    RecordingSessionStatus? status,
    bool clearPatientId = false,
    bool clearEndedAt = false,
    bool clearSoapNote = false,
    bool clearSummary = false,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      patientId: clearPatientId ? null : patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      transcript: transcript ?? this.transcript,
      soapNote: clearSoapNote ? null : soapNote ?? this.soapNote,
      summary: clearSummary ? null : summary ?? this.summary,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        startedAt,
        endedAt,
        transcript,
        soapNote,
        summary,
        userId,
        createdAt,
        updatedAt,
        status,
      ];
}
