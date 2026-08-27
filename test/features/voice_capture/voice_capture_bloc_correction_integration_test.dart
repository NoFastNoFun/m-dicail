import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/core/medical_terms/medical_root_dictionary.dart';
import 'package:medicail/core/medical_terms/medical_term_correction_service.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:mocktail/mocktail.dart';

// This suite wires the REAL MedicalTermCorrectionService + MedicalRootDictionary
// (real asset load, real Levenshtein matching) into VoiceCaptureBloc, only
// mocking the hardware-facing dependencies (mic, notifications, storage).
// It exists to prove the correction pipeline works end-to-end through the
// actual production code path, not just against a mocked correction service.

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

void _fallbackOnResult(String text, {bool isFinal = false}) {}

void _fallbackOnListeningEnded() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockAudioCaptureService audioCapture;
  late _MockRecordingSessionRepository sessionRepository;
  late _MockNoteProcessingRepository noteProcessing;
  late _MockEnhancedTranscriptionRepository enhancedTranscription;
  late _MockRecordingNotificationService notificationService;
  late _MockBackgroundAudioRecorder backgroundRecorder;
  late _MockOfflineAudioTranscriptionService offlineTranscription;

  setUpAll(() {
    registerFallbackValue(_fallbackOnResult);
    registerFallbackValue(_fallbackOnListeningEnded);
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

    when(
      () => notificationService.ensureInitialized(),
    ).thenAnswer((_) async {});
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
  });

  VoiceCaptureBloc buildRealBloc() {
    return VoiceCaptureBloc(
      audioCapture,
      sessionRepository,
      noteProcessing,
      enhancedTranscription,
      notificationService,
      backgroundRecorder,
      offlineTranscription,
      MedicalTermCorrectionService(MedicalRootDictionary()),
    );
  }

  group('VoiceCaptureBloc + real MedicalTermCorrectionService', () {
    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'corrects a misheard medical term during live dictation',
      build: buildRealBloc,
      act: (bloc) async {
        bloc.add(const VoiceCaptureInitializeRequested());
        await bloc.stream.firstWhere((state) => state is VoiceCaptureReady);
        bloc.add(const VoiceCaptureStartRecording());
        await bloc.stream.firstWhere((state) => state is RecordingInProgress);

        const simulatedAsrOutput =
            'le patient a une tendinnite au coude depuis 3 semaines';
        bloc.add(const VoiceCaptureTranscriptUpdated(simulatedAsrOutput));
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress &&
              state.transcript.contains('tendin'),
        );
      },
      verify: (bloc) {
        expect(bloc.state, isA<RecordingInProgress>());
        final transcript = (bloc.state as RecordingInProgress).transcript;
        expect(transcript, contains('tendinite'));
        expect(transcript, isNot(contains('tendinnite')));
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'restores accents on a misheard term from the background Whisper path',
      build: buildRealBloc,
      setUp: () {
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/bg.wav';
        });
        when(
          () => offlineTranscription.transcribeFile(
            any(),
            language: any(named: 'language'),
          ),
        ).thenAnswer(
          (_) async => 'le patient presente une epicondylite du coude',
        );
      },
      act: (bloc) async {
        bloc.add(const VoiceCaptureInitializeRequested());
        await bloc.stream.firstWhere((state) => state is VoiceCaptureReady);
        bloc.add(const VoiceCaptureStartRecording());
        await bloc.stream.firstWhere((state) => state is RecordingInProgress);

        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) => state is RecordingInProgress && state.isBackgroundCapture,
        );
        bloc.add(const VoiceCaptureAppForegrounded());
        await bloc.stream.firstWhere(
          (state) => state is RecordingInProgress && !state.isBackgroundCapture,
        );
      },
      verify: (bloc) {
        final transcript = (bloc.state as RecordingInProgress).transcript;
        expect(transcript, contains('épicondylite'));
      },
    );
  });
}
