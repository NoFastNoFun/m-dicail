import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

final class RecordingSessionModel extends RecordingSession {
  const RecordingSessionModel({
    required super.id,
    required super.startedAt,
    required super.status,
    super.patientId,
    super.endedAt,
    super.transcript,
    super.soapNote,
    super.templateId,
    super.templateName,
  });

  factory RecordingSessionModel.fromEntity(RecordingSession session) {
    return RecordingSessionModel(
      id: session.id,
      patientId: session.patientId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      transcript: session.transcript,
      soapNote: session.soapNote,
      status: session.status,
      templateId: session.templateId,
      templateName: session.templateName,
    );
  }

  factory RecordingSessionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSessionModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String? ?? json['patientId'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String? ?? json['startedAt'] as String),
      endedAt: _parseNullableDate(json['ended_at'] ?? json['endedAt']),
      transcript: json['transcript'] as String? ?? '',
      soapNote: (json['soap_note'] != null || json['soapNote'] != null)
          ? SoapNote.fromJson((json['soap_note'] ?? json['soapNote']) as Map<String, dynamic>)
          : null,
      status: _parseStatus(json['status'] as String?),
      templateId: json['templateId'] as String?,
      templateName: json['templateName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'transcript': transcript,
      'soap_note': soapNote?.toJson(),
      'status': status.name,
      'templateId': templateId,
      'templateName': templateName,
    };
  }

  static DateTime? _parseNullableDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.parse(value);
  }

  static RecordingSessionStatus _parseStatus(String? value) {
    return RecordingSessionStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => RecordingSessionStatus.draft,
    );
  }
}
