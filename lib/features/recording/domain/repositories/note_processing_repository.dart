import 'package:medicail/features/recording/domain/entities/soap_note.dart';

class SoapNoteResult {
  const SoapNoteResult({
    required this.processedText,
    required this.soapNote,
    this.isAiGenerated = false,
  });

  final String processedText;
  final SoapNote soapNote;

  /// Describes the SOAP generator, independently of the transcription source.
  final bool isAiGenerated;
}

abstract class NoteProcessingRepository {
  Future<SoapNoteResult> process({
    required String sessionId,
    required String rawText,
    required String language,
  });
}
