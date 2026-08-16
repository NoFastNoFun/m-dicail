import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioCaptureService extends Mock implements AudioCaptureService {}

class _MockRecordingSessionRepository extends Mock
    implements RecordingSessionRepository {}

class _MockNoteProcessingRepository extends Mock
    implements NoteProcessingRepository {}

class _MockEnhancedTranscriptionRepository extends Mock
    implements EnhancedTranscriptionRepository {}

class _MockRecordingNotificationService extends Mock
    implements RecordingNotificationService {}

class _MockBackgroundAudioRecorder extends Mock
    implements BackgroundAudioRecorder {}

class _MockOfflineAudioTranscriptionService extends Mock
    implements OfflineAudioTranscriptionService {}

void main() {
  late _MockAudioCaptureService audioCapture;
  late _MockRecordingSessionRepository sessionRepository;
  late _MockNoteProcessingRepository noteProcessing;
  late _MockEnhancedTranscriptionRepository enhancedTranscription;
  late _MockRecordingNotificationService notificationService;
  late _MockBackgroundAudioRecorder backgroundRecorder;
  late _MockOfflineAudioTranscriptionService offlineTranscription;

  setUpAll(() {
    registerFallbackValue(
      RecordingSession(
        id: 'fallback',
        startedAt: DateTime(2026),
        status: RecordingSessionStatus.draft,
      ),
    );
  });

  setUp(() {
    audioCapture = _MockAudioCaptureService();
    sessionRepository = _MockRecordingSessionRepository();
    noteProcessing = _MockNoteProcessingRepository();
    enhancedTranscription = _MockEnhancedTranscriptionRepository();
    notificationService = _MockRecordingNotificationService();
    backgroundRecorder = _MockBackgroundAudioRecorder();
    offlineTranscription = _MockOfflineAudioTranscriptionService();

    when(() => audioCapture.initialize()).thenAnswer((_) async => true);
    when(() => audioCapture.isListening).thenReturn(false);
    when(
      () => audioCapture.startListening(
        onResult: any(named: 'onResult'),
        onListeningEnded: any(named: 'onListeningEnded'),
      ),
    ).thenAnswer((_) async {});
    when(() => audioCapture.stopListening()).thenAnswer((_) async {});

    when(() => notificationService.ensureInitialized())
        .thenAnswer((_) async {});
    when(
      () => notificationService.start(
        title: any(named: 'title'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.update(
        title: any(named: 'title'),
        body: any(named: 'body'),
      ),
    ).thenAnswer((_) async {});
    when(() => notificationService.stop()).thenAnswer((_) async {});

    when(() => backgroundRecorder.isRecording).thenReturn(false);
    when(() => backgroundRecorder.start(sessionId: any(named: 'sessionId')))
        .thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(true);
    });
    when(() => backgroundRecorder.stop()).thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(false);
      return null;
    });
    when(() => backgroundRecorder.cancel()).thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(false);
    });

    when(
      () => offlineTranscription.transcribeFile(
        any(),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async => '');

    when(() => sessionRepository.save(any())).thenAnswer((invocation) async {
      return invocation.positionalArguments.first as RecordingSession;
    });
    when(() => sessionRepository.delete(any())).thenAnswer((_) async {});

    when(
      () => enhancedTranscription.transcribeFile(
        filePath: any(named: 'filePath'),
        sessionId: any(named: 'sessionId'),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async => 'texte ameliore');

    when(
      () => noteProcessing.process(
        sessionId: any(named: 'sessionId'),
        rawText: any(named: 'rawText'),
        language: any(named: 'language'),
      ),
    ).thenAnswer(
      (_) async => const SoapNoteResult(
        processedText: 'texte ameliore',
        soapNote: SoapNote(),
      ),
    );
  });

  VoiceCaptureBloc buildBloc() {
    return VoiceCaptureBloc(
      audioCapture,
      sessionRepository,
      noteProcessing,
      enhancedTranscription,
      notificationService,
      backgroundRecorder,
      offlineTranscription,
    );
  }

  Future<void> seedListening(VoiceCaptureBloc bloc) async {
    bloc.add(const VoiceCaptureInitializeRequested());
    await bloc.stream.firstWhere((state) => state is VoiceCaptureReady);
    bloc.add(const VoiceCaptureStartRecording());
    await bloc.stream.firstWhere((state) => state is RecordingInProgress);
  }

  group('VoiceCaptureBloc dual capture', () {
    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'starts continuous session audio with STT',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>().having(
          (s) => s.isBackgroundCapture,
          'isBackgroundCapture',
          false,
        ),
      ],
      verify: (_) {
        verify(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        ).called(1);
        verify(
          () => audioCapture.startListening(
            onResult: any(named: 'onResult'),
            onListeningEnded: any(named: 'onListeningEnded'),
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'keeps session audio and only stops STT when app backgrounds',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        clearInteractions(backgroundRecorder);
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress && state.isBackgroundCapture,
        );
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>().having(
          (s) => s.isBackgroundCapture,
          'isBackgroundCapture',
          false,
        ),
        isA<RecordingInProgress>().having(
          (s) => s.isBackgroundCapture,
          'isBackgroundCapture',
          true,
        ),
      ],
      verify: (_) {
        verify(() => audioCapture.stopListening()).called(greaterThan(0));
        verifyNever(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        );
        verifyNever(() => backgroundRecorder.stop());
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'resumes STT on foreground without offline whisper merge',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress && state.isBackgroundCapture,
        );
        clearInteractions(audioCapture);
        clearInteractions(offlineTranscription);
        clearInteractions(backgroundRecorder);
        bloc.add(const VoiceCaptureAppForegrounded());
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress && !state.isBackgroundCapture,
        );
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>(),
        isA<RecordingInProgress>().having(
          (s) => s.isBackgroundCapture,
          'isBackgroundCapture',
          true,
        ),
        isA<RecordingInProgress>().having(
          (s) => s.isBackgroundCapture,
          'isBackgroundCapture',
          false,
        ),
      ],
      verify: (_) {
        verifyNever(() => backgroundRecorder.stop());
        verifyNever(() => offlineTranscription.transcribeFile(any()));
        verify(
          () => audioCapture.startListening(
            onResult: any(named: 'onResult'),
            onListeningEnded: any(named: 'onListeningEnded'),
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'enhances from session audio then processes note on finish',
      build: buildBloc,
      setUp: () {
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/session.wav';
        });
      },
      act: (bloc) async {
        await seedListening(bloc);
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        bloc.add(const VoiceCaptureFinishConsultation(language: 'fr'));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureConsultationFinished,
        );
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>(),
        isA<VoiceCaptureEnhancing>(),
        isA<VoiceCaptureProcessing>(),
        isA<VoiceCaptureConsultationFinished>().having(
          (s) => s.transcript,
          'transcript',
          'texte ameliore',
        ),
      ],
      verify: (_) {
        verify(
          () => enhancedTranscription.transcribeFile(
            filePath: '/tmp/session.wav',
            sessionId: any(named: 'sessionId'),
            language: 'fr',
          ),
        ).called(1);
        verify(
          () => noteProcessing.process(
            sessionId: any(named: 'sessionId'),
            rawText: 'texte ameliore',
            language: 'fr',
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'falls back to rough transcript when enhance fails',
      build: buildBloc,
      setUp: () {
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/session.wav';
        });
        when(
          () => enhancedTranscription.transcribeFile(
            filePath: any(named: 'filePath'),
            sessionId: any(named: 'sessionId'),
            language: any(named: 'language'),
          ),
        ).thenThrow(Exception('whisper down'));
        when(
          () => offlineTranscription.transcribeFile(
            any(),
            language: any(named: 'language'),
          ),
        ).thenThrow(Exception('offline fail'));
        when(
          () => noteProcessing.process(
            sessionId: any(named: 'sessionId'),
            rawText: any(named: 'rawText'),
            language: any(named: 'language'),
          ),
        ).thenAnswer(
          (invocation) async => SoapNoteResult(
            processedText: invocation.namedArguments[#rawText] as String,
            soapNote: const SoapNote(),
          ),
        );
      },
      act: (bloc) async {
        await seedListening(bloc);
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        bloc.add(const VoiceCaptureTranscriptUpdated('bonjour patient'));
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress &&
              state.transcript.contains('bonjour'),
        );
        bloc.add(const VoiceCaptureFinishConsultation(language: 'fr'));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureConsultationFinished,
        );
      },
      verify: (_) {
        verify(
          () => noteProcessing.process(
            sessionId: any(named: 'sessionId'),
            rawText: any(named: 'rawText', that: contains('bonjour')),
            language: 'fr',
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cleans up notification on stop but keeps session audio',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        clearInteractions(backgroundRecorder);
        bloc.add(const VoiceCaptureStopRecording());
        await bloc.stream.firstWhere((state) => state is ListeningPaused);
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>(),
        isA<ListeningPaused>(),
      ],
      verify: (_) {
        verify(() => audioCapture.stopListening()).called(greaterThan(0));
        verify(() => notificationService.stop()).called(greaterThan(0));
        verifyNever(() => backgroundRecorder.stop());
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cancels session audio on discard',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        bloc.add(const VoiceCaptureDiscardConsultation());
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureReady && bloc.state is VoiceCaptureReady,
        );
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>(),
        isA<VoiceCaptureReady>(),
      ],
      verify: (_) {
        verify(() => notificationService.stop()).called(greaterThan(0));
        verify(() => backgroundRecorder.cancel()).called(greaterThan(0));
        verify(() => sessionRepository.delete(any())).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'ignores background event when not recording',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const VoiceCaptureInitializeRequested());
        await bloc.stream.firstWhere((state) => state is VoiceCaptureReady);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await Future<void>.delayed(const Duration(milliseconds: 20));
      },
      expect: () => [const VoiceCaptureReady()],
      verify: (_) {
        verifyNever(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        );
      },
    );

    test('ignores STT session end while background capture is active', () async {
      final bloc = buildBloc();
      await seedListening(bloc);
      when(() => backgroundRecorder.isRecording).thenReturn(true);
      bloc.add(const VoiceCaptureAppBackgrounded());
      await bloc.stream.firstWhere(
        (state) => state is RecordingInProgress && state.isBackgroundCapture,
      );

      clearInteractions(audioCapture);
      bloc.add(const VoiceCaptureListeningSessionEnded());
      await Future<void>.delayed(const Duration(milliseconds: 50));

      verifyNever(
        () => audioCapture.startListening(
          onResult: any(named: 'onResult'),
          onListeningEnded: any(named: 'onListeningEnded'),
        ),
      );
      await bloc.close();
    });
  });
}
