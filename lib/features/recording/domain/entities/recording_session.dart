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
    this.templateId,
    this.templateName,
  });

  final String id;
  final String? patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String transcript;
  final SoapNote? soapNote;
  final RecordingSessionStatus status;
  final String? templateId;
  final String? templateName;

  RecordingSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? transcript,
    SoapNote? soapNote,
    RecordingSessionStatus? status,
    String? templateId,
    String? templateName,
    bool clearPatientId = false,
    bool clearEndedAt = false,
    bool clearSoapNote = false,
    bool clearTemplateId = false,
    bool clearTemplateName = false,
  }) {
    return RecordingSession(
      id: id ?? this.id,
      patientId: clearPatientId ? null : patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: clearEndedAt ? null : endedAt ?? this.endedAt,
      transcript: transcript ?? this.transcript,
      soapNote: clearSoapNote ? null : soapNote ?? this.soapNote,
      status: status ?? this.status,
      templateId: clearTemplateId ? null : templateId ?? this.templateId,
      templateName:
          clearTemplateName ? null : templateName ?? this.templateName,
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
        status,
        templateId,
        templateName,
      ];
}
