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
    super.summary,
    super.userId,
    super.createdAt,
    super.updatedAt,
  });

  factory RecordingSessionModel.fromEntity(RecordingSession session) {
    return RecordingSessionModel(
      id: session.id,
      patientId: session.patientId,
      startedAt: session.startedAt,
      endedAt: session.endedAt,
      transcript: session.transcript,
      soapNote: session.soapNote,
      summary: session.summary,
      userId: session.userId,
      createdAt: session.createdAt,
      updatedAt: session.updatedAt,
      status: session.status,
    );
  }

  factory RecordingSessionModel.fromJson(Map<String, dynamic> json) {
    return RecordingSessionModel(
      id: json['id'] as String? ?? '',
      patientId: json['patient_id'] as String? ?? json['patientId'] as String?,
      startedAt: _parseDate(json['started_at'] ?? json['startedAt']),
      endedAt: _parseNullableDate(json['ended_at'] ?? json['endedAt']),
      transcript: json['transcript'] as String? ?? '',
      soapNote: (json['soap_note'] ?? json['soapNote']) != null
          ? SoapNote.fromJson(
              (json['soap_note'] ?? json['soapNote']) as Map<String, dynamic>,
            )
          : null,
      summary: json['summary'] as String?,
      userId: _parseNullableInt(json['user_id'] ?? json['userId']),
      createdAt: _parseNullableDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _parseNullableDate(json['updated_at'] ?? json['updatedAt']),
      status: _parseStatus(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'transcript': transcript,
      'soapNote': soapNote?.toJson(),
      'summary': summary,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status.name,
    };
  }

  Map<String, dynamic> toCreateApiJson() {
    return {
      'started_at': startedAt.toUtc().toIso8601String(),
      'status': status.name,
      'transcript': transcript,
      'patient_id': patientId,
    };
  }

  Map<String, dynamic> toUpdateApiJson() {
    return {
      'ended_at': endedAt?.toUtc().toIso8601String(),
      'status': status.name,
      'transcript': transcript,
      'soap_note': soapNote?.toJson(),
      'summary': summary,
      'patient_id': patientId,
    };
  }

  static DateTime _parseDate(Object? value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.parse(value);
    }
    return DateTime.now();
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

  static int? _parseNullableInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return int.tryParse(value);
    }
    return null;
  }
}
