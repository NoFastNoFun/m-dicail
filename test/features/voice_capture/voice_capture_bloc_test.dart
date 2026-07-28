import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
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
        .thenAnswer((_) async {});
    when(() => backgroundRecorder.stop()).thenAnswer((_) async => null);
    when(() => backgroundRecorder.cancel()).thenAnswer((_) async {});

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
  });

  VoiceCaptureBloc buildBloc() {
    return VoiceCaptureBloc(
      audioCapture,
      sessionRepository,
      noteProcessing,
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

  group('VoiceCaptureBloc background handoff', () {
    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'switches from STT to file capture when app backgrounds',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
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
        verify(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        ).called(1);
        verify(
          () => notificationService.update(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'transcribes offline segment and merges on foreground',
      build: buildBloc,
      setUp: () {
        when(() => backgroundRecorder.stop())
            .thenAnswer((_) async => '/tmp/bg.wav');
        when(() => offlineTranscription.transcribeFile(any()))
            .thenAnswer((_) async => 'texte hors ligne');
        when(
          () => offlineTranscription.transcribeFile(
            any(),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => 'texte hors ligne');
      },
      act: (bloc) async {
        await seedListening(bloc);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress && state.isBackgroundCapture,
        );
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
        isA<VoiceCaptureTranscribingBackground>(),
        isA<RecordingInProgress>()
            .having((s) => s.isBackgroundCapture, 'isBackgroundCapture', false)
            .having(
              (s) => s.transcript.contains('texte hors ligne'),
              'merged transcript',
              true,
            ),
      ],
      verify: (_) {
        verify(() => backgroundRecorder.stop()).called(1);
        verify(() => offlineTranscription.transcribeFile(any())).called(1);
        verify(
          () => audioCapture.startListening(
            onResult: any(named: 'onResult'),
            onListeningEnded: any(named: 'onListeningEnded'),
          ),
        ).called(greaterThanOrEqualTo(2));
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cleans up notification and recorder on stop',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
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
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cleans up infrastructure on discard',
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
