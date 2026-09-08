import 'package:equatable/equatable.dart';
import 'package:medicail/features/recording/domain/entities/session_pathology.dart';
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
    this.transcriptIsAi = false,
    this.soapNote,
    this.templateId,
    this.templateName,
    this.pathologies = const [],
  });

  final String id;
  final String? patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String transcript;
  final bool transcriptIsAi;
  final SoapNote? soapNote;
  final RecordingSessionStatus status;
  final String? templateId;
  final String? templateName;
  final List<SessionPathology> pathologies;

  /// Display names: list first, else legacy [templateName].
  List<String> get pathologyNames {
    if (pathologies.isNotEmpty) {
      return pathologies
          .map((p) => p.name.trim())
          .where((name) => name.isNotEmpty)
          .toList();
    }
    final legacy = templateName?.trim();
    if (legacy == null || legacy.isEmpty) {
      return const [];
    }
    return [legacy];
  }

  bool get hasPathology => pathologyNames.isNotEmpty;

  RecordingSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? transcript,
    bool? transcriptIsAi,
    SoapNote? soapNote,
    RecordingSessionStatus? status,
    String? templateId,
    String? templateName,
    List<SessionPathology>? pathologies,
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
      transcriptIsAi: transcriptIsAi ?? this.transcriptIsAi,
      soapNote: clearSoapNote ? null : soapNote ?? this.soapNote,
      status: status ?? this.status,
      templateId: clearTemplateId ? null : templateId ?? this.templateId,
      templateName:
          clearTemplateName ? null : templateName ?? this.templateName,
      pathologies: pathologies ?? this.pathologies,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        startedAt,
        endedAt,
        transcript,
        transcriptIsAi,
        soapNote,
        status,
        templateId,
        templateName,
        pathologies,
      ];
}
