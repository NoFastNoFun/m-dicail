import 'package:medicail/features/recording/domain/entities/soap_note.dart';

class SoapNoteResult {
  const SoapNoteResult({
    required this.processedText,
    required this.soapNote,
  });

  final String processedText;
  final SoapNote soapNote;
}

abstract class NoteProcessingRepository {
  Future<SoapNoteResult> process({
    required String sessionId,
    required String rawText,
    required String language,
  });
}
