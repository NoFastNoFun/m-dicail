abstract class EnhancedTranscriptionRepository {
  Future<String> transcribeFile({
    required String filePath,
    required String sessionId,
    String language = 'fr',
  });
}
