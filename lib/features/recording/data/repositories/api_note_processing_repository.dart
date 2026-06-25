import 'package:injectable/injectable.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/recording/domain/entities/note_processing_result.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';

@LazySingleton(as: NoteProcessingRepository)
class ApiNoteProcessingRepository implements NoteProcessingRepository {
  ApiNoteProcessingRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<NoteProcessingResult> processNote({
    required String sessionId,
    required String rawText,
    String language = 'fr',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/notes/process',
      data: {
        'session_id': sessionId,
        'raw_text': rawText,
        'language': language,
      },
    );

    return NoteProcessingResult.fromJson(
      response.data ?? const <String, dynamic>{},
    );
  }

  @override
  Future<String> summarizeNote({
    required String sessionId,
    required String processedText,
    String language = 'fr',
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/notes/summarize',
      data: {
        'session_id': sessionId,
        'processed_text': processedText,
        'language': language,
      },
    );

    return response.data?['summary'] as String? ?? '';
  }
}
