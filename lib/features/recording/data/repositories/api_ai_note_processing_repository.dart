import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/utils/anonymization_helper.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/exceptions/invalid_soap_note_exception.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';

@injectable
class ApiAiNoteProcessingRepository implements NoteProcessingRepository {
  ApiAiNoteProcessingRepository(this._apiClient, this._config);

  final ApiClient _apiClient;
  final AppConfig _config;

  @override
  Future<SoapNoteResult> process({
    required String sessionId,
    required String rawText,
    required String language,
  }) async {
    final text = AnonymizationHelper.anonymize(rawText);
    final base = _config.aiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$base/notes/process',
      data: {'session_id': sessionId, 'raw_text': text, 'language': language},
      options: Options(receiveTimeout: _config.soapReceiveTimeout),
    );
    final data = response.data;
    final soap = data?['soap_note'];
    if (soap is! Map<String, dynamic> ||
        [
          'subjective',
          'objective',
          'assessment',
          'plan',
        ].any((section) => soap[section] is! String)) {
      throw const InvalidSoapNoteException();
    }
    return SoapNoteResult(
      processedText: data?['processed_text'] as String? ?? text,
      soapNote: SoapNote.fromJson(soap),
      isAiGenerated: true,
    );
  }
}
