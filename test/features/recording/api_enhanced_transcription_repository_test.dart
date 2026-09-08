import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_compression_service.dart';
import 'package:medicail/core/config/app_config.dart';
import 'package:medicail/core/error/exceptions.dart';
import 'package:medicail/features/recording/data/repositories/api_enhanced_transcription_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

class _MockCompression extends Mock implements AudioCompressionService {}

void main() {
  late Directory cache;
  late File original;
  late AudioUploadFile upload;
  late _MockDio dio;
  late ApiEnhancedTranscriptionRepository repository;

  setUp(() async {
    cache = await Directory.systemTemp.createTemp('transcription_upload_test_');
    original = await File(
      '${cache.path}/original.wav',
    ).writeAsBytes([1, 2, 3, 4]);
    final directory = await cache.createTemp('copy_');
    final compressed = await File(
      '${directory.path}/audio.m4a',
    ).writeAsBytes([5, 6]);
    upload = AudioUploadFile(
      path: compressed.path,
      mimeType: 'audio/mp4',
      temporaryDirectory: directory,
    );
    final compression = _MockCompression();
    when(
      () => compression.prepareUpload(original.path),
    ).thenAnswer((_) async => upload);
    dio = _MockDio();
    repository = ApiEnhancedTranscriptionRepository(
      dio,
      AppConfig(),
      compression,
    );
  });

  tearDown(() async => cache.delete(recursive: true));

  test('posts the compressed bytes and metadata to the AI route', () async {
    when(
      () => dio.post<Map<String, dynamic>>(
        any(),
        data: any(named: 'data'),
        options: any(named: 'options'),
      ),
    ).thenAnswer((call) async {
      expect(
        call.positionalArguments.single,
        '${AppConfig().aiBaseUrl}/transcriptions',
      );
      final form = call.namedArguments[#data] as FormData;
      expect(Map.fromEntries(form.fields), {
        'language': 'fr',
        'session_id': 'session-test',
      });
      final file = form.files.single;
      expect(file.key, 'file');
      expect(file.value.filename, 'audio.m4a');
      expect(file.value.contentType.toString(), 'audio/mp4');
      expect(await file.value.finalize().expand((bytes) => bytes).toList(), [
        5,
        6,
      ]);
      expect(await File(upload.path).exists(), isTrue);
      return Response(
        data: {'text': ' Bonjour '},
        requestOptions: RequestOptions(),
      );
    });
    expect(
      await repository.transcribeFile(
        filePath: original.path,
        sessionId: 'session-test',
      ),
      'Bonjour',
    );
    expect(await File(upload.path).exists(), isFalse);
    expect(await original.exists(), isTrue);
  });

  test(
    'cleans the upload copy after an HTTP failure and preserves the WAV',
    () async {
      when(
        () => dio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.connectionError,
        ),
      );
      await expectLater(
        repository.transcribeFile(
          filePath: original.path,
          sessionId: 'session-test',
        ),
        throwsA(isA<NetworkException>()),
      );
      expect(await File(upload.path).exists(), isFalse);
      expect(await original.readAsBytes(), [1, 2, 3, 4]);
    },
  );
}
