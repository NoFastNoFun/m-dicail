import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

final class RecordingSessionModel extends RecordingSession {
  const RecordingSessionModel({
    required super.id,
    required super.startedAt,
    required super.status,
    super.patientId,
    super.endedAt,
    super.rawAudioPath,
    super.transcript,
    super.soapNote,
  });

  factory RecordingSessionModel.fromEntity(RecordingSession session) {
    return RecordingSessionModel(
      id: session.id,
      patientId: session.patientId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      rawAudioPath: session.rawAudioPath,
      transcript: session.transcript,
      soapNote: session.soapNote,
      status: session.status,
    );
  }

  factory RecordingSessionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSessionModel(
      id: json['id'] as String,
      patientId: json['patientId'] as String?,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: _parseNullableDate(json['endedAt']),
      rawAudioPath: json['rawAudioPath'] as String?,
      transcript: json['transcript'] as String? ?? '',
      soapNote: json['soapNote'] != null
          ? SoapNote.fromJson(json['soapNote'] as Map<String, dynamic>)
          : null,
      status: _parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'rawAudioPath': rawAudioPath,
      'transcript': transcript,
      'soapNote': soapNote?.toJson(),
      'status': status.name,
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
