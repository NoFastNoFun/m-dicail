import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/core/network/api_client.dart';
import 'package:medicail/core/network/auth_token_storage.dart';
import 'package:medicail/core/network/interceptors/auth_interceptor.dart';
import 'package:medicail/features/recording/data/repositories/api_ai_note_processing_repository.dart';
import 'package:medicail/features/recording/data/repositories/api_note_processing_repository.dart';
import 'package:medicail/features/recording/data/repositories/dynamic_note_processing_repository.dart';
import 'package:medicail/features/recording/domain/exceptions/invalid_soap_note_exception.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:mocktail/mocktail.dart';

class _Tokens extends Mock implements AuthTokenStorage {}

class _Preferences extends Mock implements UserPreferencesRepository {}

class _Config extends AppConfig {
  @override
  String get baseUrl => 'https://medicail.nf2.tech/api/v1';
}

void main() {
  late Dio dio;
  late _Tokens tokens;
  late _Preferences preferences;
  late DynamicNoteProcessingRepository repository;
  late List<RequestOptions> requests;
  late Map<String, dynamic> payload;
  var failRequest = false;

  setUp(() {
    tokens = _Tokens();
    preferences = _Preferences();
    when(() => tokens.readToken()).thenAnswer((_) async => 'test-token');
    when(
      () => preferences.readAiEnhanceEnabled(),
    ).thenAnswer((_) async => true);
    final config = _Config();
    dio = Dio(BaseOptions(baseUrl: config.baseUrl));
    requests = [];
    failRequest = false;
    payload = {
      'processed_text': 'Texte de consultation',
      'soap_note': {
        'subjective': 'Douleur au dos et au genou.',
        'objective': 'Mesures rapportées.',
        'assessment': 'Deux problématiques mentionnées.',
        'plan': 'Suivi décrit dans la transcription.',
      },
    };
    dio.interceptors.add(AuthInterceptor(tokens));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (failRequest) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          } else {
            handler.resolve(
              Response(requestOptions: options, statusCode: 200, data: payload),
            );
          }
        },
      ),
    );
    final client = ApiClient(dio);
    repository = DynamicNoteProcessingRepository(
      ApiNoteProcessingRepository(client),
      tokens,
      ApiAiNoteProcessingRepository(client, config),
      preferences,
    );
  });

  tearDown(() => dio.close(force: true));

  test(
    'AI enabled sends authenticated anonymized JSON to /ai/v1/notes/process',
    () async {
      final result = await repository.process(
        sessionId: 'recording-test',
        rawText: 'Contact test@example.org, douleur au genou.',
        language: 'fr',
      );
      final request = requests.single;
      expect(request.method, 'POST');
      expect(
        request.uri.toString(),
        'https://medicail.nf2.tech/ai/v1/notes/process',
      );
      expect(request.headers['Authorization'], 'Bearer test-token');
      expect(request.receiveTimeout, const Duration(minutes: 3));
      expect(request.data, {
        'session_id': 'recording-test',
        'raw_text': 'Contact [ANONYMIZED], douleur au genou.',
        'language': 'fr',
      });
      expect(result.isAiGenerated, isTrue);
      expect(result.soapNote.toJson(), payload['soap_note']);
    },
  );

  test(
    'AI disabled retains the local API and does not label its SOAP as AI',
    () async {
      when(
        () => preferences.readAiEnhanceEnabled(),
      ).thenAnswer((_) async => false);
      final result = await repository.process(
        sessionId: 'test',
        rawText: 'Douleur',
        language: 'fr',
      );
      expect(requests.single.uri.path, '/api/v1/notes/process');
      expect(result.isAiGenerated, isFalse);
    },
  );

  for (final token in [null, AppConfig.mockAdminToken]) {
    test('offline mode does not contact either API ($token)', () async {
      when(() => tokens.readToken()).thenAnswer((_) async => token);
      final result = await repository.process(
        sessionId: 'test',
        rawText: 'Douleur',
        language: 'fr',
      );
      expect(requests, isEmpty);
      expect(result.isAiGenerated, isFalse);
      expect(result.soapNote.isEmpty, isTrue);
    });
  }

  test('changing the preference changes the next request route', () async {
    await repository.process(
      sessionId: 'first',
      rawText: 'Douleur',
      language: 'fr',
    );
    when(
      () => preferences.readAiEnhanceEnabled(),
    ).thenAnswer((_) async => false);
    await repository.process(
      sessionId: 'second',
      rawText: 'Douleur',
      language: 'fr',
    );
    expect(requests.map((r) => r.uri.path), [
      '/ai/v1/notes/process',
      '/api/v1/notes/process',
    ]);
  });

  test(
    'rejects incomplete AI SOAP instead of saving a partially empty note',
    () async {
      payload['soap_note'] = {'subjective': 'Douleur'};
      await expectLater(
        repository.process(
          sessionId: 'test',
          rawText: 'Douleur',
          language: 'fr',
        ),
        throwsA(isA<InvalidSoapNoteException>()),
      );
      expect(requests, hasLength(1));
    },
  );

  test(
    'AI errors are not silently replaced by local template generation',
    () async {
      failRequest = true;
      await expectLater(
        repository.process(
          sessionId: 'test',
          rawText: 'Douleur',
          language: 'fr',
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(requests, hasLength(1));
      expect(requests.single.uri.path, '/ai/v1/notes/process');
    },
  );
}
