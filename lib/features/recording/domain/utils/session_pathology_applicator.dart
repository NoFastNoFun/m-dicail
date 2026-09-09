import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/utils/note_template_applicator.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/session_pathology.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';

abstract final class SessionPathologyApplicator {
  /// Tagging preserves the note unless local template prefilling is requested.
  static RecordingSession apply({
    required RecordingSession session,
    required List<SessionPathology> pathologies,
    NoteTemplate? primaryTemplate,
    bool prefillLocalSoap = false,
  }) {
    if (pathologies.isEmpty) return session;
    final primary = pathologies.first;
    var soap = session.soapNote;
    if (prefillLocalSoap) {
      final transcript = session.transcript.isNotEmpty
          ? session.transcript
          : (soap ?? const SoapNote()).subjective;
      soap = NoteTemplateApplicator.apply(
        template: primaryTemplate,
        transcript: transcript,
      );
    }
    return session.copyWith(
      templateId: primaryTemplate?.id ?? primary.id,
      templateName: primary.name,
      pathologies: pathologies,
      soapNote: soap,
    );
  }
}
