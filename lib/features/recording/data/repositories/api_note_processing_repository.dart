import 'package:injectable/injectable.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';

@LazySingleton(as: NoteProcessingRepository)
class ApiNoteProcessingRepository implements NoteProcessingRepository {
  ApiNoteProcessingRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<SoapNoteResult> process({
    required String sessionId,
    required String rawText,
    required String language,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/notes/process',
      data: {
        'session_id': sessionId,
        'raw_text': rawText,
        'language': language,
      },
    );

    final data = response.data;
    if (data == null) {
      throw const ServerException('Erreur lors du traitement de la note.');
    }

    final processedText = data['processed_text'] as String? ?? rawText;
    final soapNoteJson = data['soap_note'] as Map<String, dynamic>?;
    final soapNote = soapNoteJson != null
        ? SoapNote.fromJson(soapNoteJson)
        : const SoapNote();

    return SoapNoteResult(
      processedText: processedText,
      soapNote: soapNote,
    );
  }
}
