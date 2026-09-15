import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_cubit.dart';
import 'package:medicail/features/voice_capture/presentation/ai_transcription_job_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockEnhancedTranscriptionRepository extends Mock
    implements EnhancedTranscriptionRepository {}

class _MockOfflineAudioTranscriptionService extends Mock
    implements OfflineAudioTranscriptionService {}

class _MockRecordingNotificationService extends Mock
    implements RecordingNotificationService {}

void main() {
  late _MockEnhancedTranscriptionRepository enhanced;
  late _MockOfflineAudioTranscriptionService offline;
  late _MockRecordingNotificationService notifications;
  late Directory tempDir;
  late File audioFile;

  setUp(() async {
    enhanced = _MockEnhancedTranscriptionRepository();
    offline = _MockOfflineAudioTranscriptionService();
    notifications = _MockRecordingNotificationService();
    tempDir = await Directory.systemTemp.createTemp('ai_job_test_');
    audioFile = File('${tempDir.path}/session.wav');
    await audioFile.writeAsString('fake-wav');

    when(
      () => notifications.start(
        title: any(named: 'title'),
        body: any(named: 'body'),
        serviceTypes: any(named: 'serviceTypes'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => notifications.update(
        title: any(named: 'title'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {});
    when(() => notifications.stop()).thenAnswer((_) async {});
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  AiTranscriptionJobCubit buildCubit() {
    return AiTranscriptionJobCubit(enhanced, offline, notifications);
  }

  test('estimateDuration clamps between 20s and 3min', () {
    expect(
      AiTranscriptionJobCubit.estimateDuration(const Duration(seconds: 10)),
      const Duration(seconds: 20),
    );
    expect(
      AiTranscriptionJobCubit.estimateDuration(const Duration(seconds: 100)),
      const Duration(seconds: 30),
    );
    expect(
      AiTranscriptionJobCubit.estimateDuration(const Duration(minutes: 30)),
      const Duration(minutes: 3),
    );
  });

  blocTest<AiTranscriptionJobCubit, AiTranscriptionJobState>(
    'emits ready when cloud and local both succeed',
    build: buildCubit,
    setUp: () {
      when(
        () => enhanced.transcribeFile(
          filePath: any(named: 'filePath'),
          sessionId: any(named: 'sessionId'),
          language: any(named: 'language'),
        ),
      ).thenAnswer((_) async => 'texte IA');
      when(
        () => offline.transcribeFile(any(), language: any(named: 'language')),
      ).thenAnswer((_) async => 'texte local');
    },
    act: (cubit) => cubit.start(
      sessionId: 's1',
      audioPath: audioFile.path,
      language: 'fr',
      roughTranscript: 'brouillon',
      audioDuration: const Duration(seconds: 60),
    ),
    expect: () => [
      isA<AiTranscriptionJobRunning>(),
      isA<AiTranscriptionJobReady>()
          .having((s) => s.aiTranscript, 'ai', 'texte IA')
          .having((s) => s.localTranscript, 'local', 'texte local'),
    ],
    verify: (_) {
      verify(
        () => notifications.update(
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(1);
    },
  );

  blocTest<AiTranscriptionJobCubit, AiTranscriptionJobState>(
    'falls back to local-only when cloud fails',
    build: buildCubit,
    setUp: () {
      when(
        () => enhanced.transcribeFile(
          filePath: any(named: 'filePath'),
          sessionId: any(named: 'sessionId'),
          language: any(named: 'language'),
        ),
      ).thenThrow(Exception('network'));
      when(
        () => offline.transcribeFile(any(), language: any(named: 'language')),
      ).thenAnswer((_) async => 'bonjour patient');
    },
    act: (cubit) => cubit.start(
      sessionId: 's1',
      audioPath: audioFile.path,
      language: 'fr',
      roughTranscript: '',
      audioDuration: const Duration(seconds: 40),
    ),
    expect: () => [
      isA<AiTranscriptionJobRunning>(),
      isA<AiTranscriptionJobCompletedWithoutCompare>().having(
        (s) => s.transcript,
        'transcript',
        'bonjour patient',
      ),
    ],
    verify: (_) {
      verify(() => notifications.stop()).called(1);
    },
  );

  blocTest<AiTranscriptionJobCubit, AiTranscriptionJobState>(
    'fails when both cloud and local produce nothing',
    build: buildCubit,
    setUp: () {
      when(
        () => enhanced.transcribeFile(
          filePath: any(named: 'filePath'),
          sessionId: any(named: 'sessionId'),
          language: any(named: 'language'),
        ),
      ).thenThrow(Exception('network'));
      when(
        () => offline.transcribeFile(any(), language: any(named: 'language')),
      ).thenAnswer((_) async => '');
    },
    act: (cubit) => cubit.start(
      sessionId: 's1',
      audioPath: audioFile.path,
      language: 'fr',
      roughTranscript: '',
      audioDuration: const Duration(seconds: 40),
    ),
    expect: () => [
      isA<AiTranscriptionJobRunning>(),
      isA<AiTranscriptionJobFailed>(),
    ],
  );
}
