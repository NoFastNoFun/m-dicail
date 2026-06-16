import 'package:medicail/features/recording/domain/entities/note_processing_result.dart';

abstract interface class NoteProcessingRepository {
  Future<NoteProcessingResult> processNote({
    required String sessionId,
    required String rawText,
    String language = 'fr',
  });

  Future<String> summarizeNote({
    required String sessionId,
    required String anonymizedText,
    String language = 'fr',
  });
}
