import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/audio/audio_capture_service.dart';
import 'package:medicail/core/audio/background_audio_recorder.dart';
import 'package:medicail/core/audio/offline_audio_transcription_service.dart';
import 'package:medicail/core/audio/recording_notification_service.dart';
import 'package:medicail/core/medical_terms/medical_term_correction_service.dart';
import 'package:medicail/features/note_template/domain/entities/note_section.dart';
import 'package:medicail/features/note_template/domain/entities/note_section_kind.dart';
import 'package:medicail/features/note_template/domain/entities/note_template.dart';
import 'package:medicail/features/note_template/domain/entities/note_template_source.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/enhanced_transcription_repository.dart';
import 'package:medicail/features/recording/domain/repositories/note_processing_repository.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/settings/domain/repositories/user_preferences_repository.dart';
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

class _MockMedicalTermCorrectionService extends Mock
    implements MedicalTermCorrectionService {}

class _MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

void _fallbackOnResult(String text, {bool isFinal = false}) {}

void _fallbackOnListeningEnded() {}

void main() {
  late _MockAudioCaptureService audioCapture;
  late _MockRecordingSessionRepository sessionRepository;
  late _MockNoteProcessingRepository noteProcessing;
  late _MockEnhancedTranscriptionRepository enhancedTranscription;
  late _MockRecordingNotificationService notificationService;
  late _MockBackgroundAudioRecorder backgroundRecorder;
  late _MockOfflineAudioTranscriptionService offlineTranscription;
  late _MockMedicalTermCorrectionService medicalTermCorrection;
  late _MockUserPreferencesRepository userPreferences;

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
    medicalTermCorrection = _MockMedicalTermCorrectionService();
    userPreferences = _MockUserPreferencesRepository();

    when(
      () => userPreferences.readAiEnhanceEnabled(),
    ).thenAnswer((_) async => false);
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
    when(
      () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
    ).thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(true);
    });
    when(() => backgroundRecorder.stop()).thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(false);
      return null;
    });
    when(() => backgroundRecorder.cancel()).thenAnswer((_) async {
      when(() => backgroundRecorder.isRecording).thenReturn(false);
    });
    when(() => backgroundRecorder.pause()).thenAnswer((_) async {});

    when(
      () => offlineTranscription.transcribeFile(
        any(),
        language: any(named: 'language'),
      ),
    ).thenAnswer((_) async => '');

    when(() => medicalTermCorrection.warmUp()).thenAnswer((_) async {});
    when(() => medicalTermCorrection.correct(any())).thenAnswer(
      (invocation) async => invocation.positionalArguments.first as String,
    );

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
      medicalTermCorrection,
      userPreferences,
    );
  }

  Future<void> seedListening(VoiceCaptureBloc bloc) async {
    bloc.add(const VoiceCaptureInitializeRequested());
    await bloc.stream.firstWhere((state) => state is VoiceCaptureReady);
    bloc.add(const VoiceCaptureStartRecording());
    await bloc.stream.firstWhere((state) => state is RecordingInProgress);
  }

  group('VoiceCaptureBloc dual capture', () {
    test(
      'keeps generated AI SOAP with a preselected local template and local transcription',
      () async {
        const aiSoap = SoapNote(
          subjective: 'Douleur au dos et au genou',
          objective: 'Mesures dictées',
          assessment: 'Évaluation dictée',
          plan: 'Plan dicté',
        );
        when(
          () => noteProcessing.process(
            sessionId: any(named: 'sessionId'),
            rawText: any(named: 'rawText'),
            language: any(named: 'language'),
          ),
        ).thenAnswer(
          (_) async => const SoapNoteResult(
            processedText: 'Transcription locale',
            soapNote: aiSoap,
            isAiGenerated: true,
          ),
        );
        final bloc = buildBloc();
        addTearDown(bloc.close);
        bloc.add(
          const VoiceCaptureTemplateSelected(
            NoteTemplate(
              id: 'knee',
              pathologyKey: 'knee',
              name: 'Genou',
              source: NoteTemplateSource.builtIn,
              sections: [
                NoteSection(
                  id: 'objective',
                  kind: NoteSectionKind.objective,
                  title: 'O',
                  prompt: 'Trame locale',
                  order: 0,
                ),
              ],
            ),
          ),
        );
        await seedListening(bloc);
        bloc.add(const VoiceCaptureFinishConsultation());
        final finished =
            await bloc.stream.firstWhere(
                  (s) => s is VoiceCaptureConsultationFinished,
                )
                as VoiceCaptureConsultationFinished;
        expect(finished.soapGeneratedByAi, isTrue);
        final saved = verify(
          () => sessionRepository.save(captureAny()),
        ).captured.cast<RecordingSession>();
        final completed = saved.lastWhere(
          (s) => s.status == RecordingSessionStatus.completed,
        );
        expect(completed.soapNote, aiSoap);
        expect(completed.transcriptIsAi, isFalse);
        expect(completed.pathologyNames, ['Genou']);
      },
    );

    group('AI recording preference', () {
      setUp(() {
        when(
          () => userPreferences.readAiEnhanceEnabled(),
        ).thenAnswer((_) async => true);
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/session.wav';
        });
      });

      test(
        'keeps audio without starting the competing live microphone',
        () async {
          final bloc = buildBloc();
          addTearDown(bloc.close);
          await seedListening(bloc);
          expect(backgroundRecorder.isRecording, isTrue);
          expect((bloc.state as RecordingInProgress).isAiCapture, isTrue);
          verifyNever(() => backgroundRecorder.cancel());
          verifyNever(() => audioCapture.initialize());
          verifyNever(
            () => audioCapture.startListening(
              onResult: any(named: 'onResult'),
              onListeningEnded: any(named: 'onListeningEnded'),
            ),
          );
          bloc.add(const VoiceCaptureListeningSessionEnded());
          await Future<void>.delayed(const Duration(milliseconds: 20));
          expect(backgroundRecorder.isRecording, isTrue);
          verifyNever(() => backgroundRecorder.cancel());
        },
      );

      for (final resume in [false, true]) {
        test('uploads retained audio after pause, resume=$resume', () async {
          final bloc = buildBloc();
          addTearDown(bloc.close);
          await seedListening(bloc);
          bloc.add(const VoiceCaptureStopRecording());
          await bloc.stream.firstWhere((s) => s is ListeningPaused);
          verify(() => backgroundRecorder.pause()).called(1);
          verifyNever(() => backgroundRecorder.cancel());
          verifyNever(() => backgroundRecorder.stop());
          if (resume) {
            bloc.add(const VoiceCaptureStartRecording());
            await bloc.stream.firstWhere((s) => s is RecordingInProgress);
          }
          bloc.add(const VoiceCaptureFinishConsultation());
          await bloc.stream.firstWhere(
            (s) => s is VoiceCaptureTranscriptCompare,
          );
          verify(
            () => enhancedTranscription.transcribeFile(
              filePath: '/tmp/session.wav',
              sessionId: any(named: 'sessionId'),
              language: 'fr',
            ),
          ).called(1);
        });
      }

      test('retains the same audio across background and foreground', () async {
        final bloc = buildBloc();
        addTearDown(bloc.close);
        await seedListening(bloc);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (s) => s is RecordingInProgress && s.isBackgroundCapture,
        );
        bloc.add(const VoiceCaptureAppForegrounded());
        await bloc.stream.firstWhere(
          (s) => s is RecordingInProgress && !s.isBackgroundCapture,
        );
        verifyNever(() => backgroundRecorder.stop());
        verifyNever(() => backgroundRecorder.cancel());
        verify(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        ).called(1);
        bloc.add(const VoiceCaptureFinishConsultation());
        await bloc.stream.firstWhere((s) => s is VoiceCaptureTranscriptCompare);
        verify(
          () => enhancedTranscription.transcribeFile(
            filePath: '/tmp/session.wav',
            sessionId: any(named: 'sessionId'),
            language: 'fr',
          ),
        ).called(1);
      });

      test('does not upload if AI is disabled before finishing', () async {
        final bloc = buildBloc();
        addTearDown(bloc.close);
        await seedListening(bloc);
        when(
          () => userPreferences.readAiEnhanceEnabled(),
        ).thenAnswer((_) async => false);
        when(
          () => offlineTranscription.transcribeFile(
            any(),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => 'transcription locale');
        bloc.add(const VoiceCaptureFinishConsultation());
        await bloc.stream.firstWhere(
          (s) => s is VoiceCaptureConsultationFinished,
        );
        verifyNever(
          () => enhancedTranscription.transcribeFile(
            filePath: any(named: 'filePath'),
            sessionId: any(named: 'sessionId'),
            language: any(named: 'language'),
          ),
        );
      });

      test(
        'reports failed transcriptions instead of saving an empty note',
        () async {
          final bloc = buildBloc();
          addTearDown(bloc.close);
          when(
            () => enhancedTranscription.transcribeFile(
              filePath: any(named: 'filePath'),
              sessionId: any(named: 'sessionId'),
              language: any(named: 'language'),
            ),
          ).thenThrow(Exception('unreachable'));
          await seedListening(bloc);
          bloc.add(const VoiceCaptureFinishConsultation());
          await bloc.stream.firstWhere((s) => s is VoiceCaptureFailure);
          verifyNever(
            () => noteProcessing.process(
              sessionId: any(named: 'sessionId'),
              rawText: any(named: 'rawText'),
              language: any(named: 'language'),
            ),
          );
        },
      );

      test('discards audio without uploading', () async {
        final bloc = buildBloc();
        addTearDown(bloc.close);
        await seedListening(bloc);
        bloc.add(const VoiceCaptureDiscardConsultation());
        await bloc.stream.firstWhere((s) => s is VoiceCaptureReady);
        verify(() => backgroundRecorder.cancel()).called(1);
        verifyNever(
          () => enhancedTranscription.transcribeFile(
            filePath: any(named: 'filePath'),
            sessionId: any(named: 'sessionId'),
            language: any(named: 'language'),
          ),
        );
      });
    });

    test('does not call Groq when the preference is disabled', () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);
      await seedListening(bloc);
      bloc.add(const VoiceCaptureFinishConsultation());
      await bloc.stream.firstWhere(
        (s) => s is VoiceCaptureConsultationFinished,
      );
      verifyNever(
        () => enhancedTranscription.transcribeFile(
          filePath: any(named: 'filePath'),
          sessionId: any(named: 'sessionId'),
          language: any(named: 'language'),
        ),
      );
    });

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'starts only live STT when AI is disabled',
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
        verifyNever(
          () => backgroundRecorder.start(sessionId: any(named: 'sessionId')),
        );
        verify(
          () => audioCapture.startListening(
            onResult: any(named: 'onResult'),
            onListeningEnded: any(named: 'onListeningEnded'),
          ),
        ).called(1);
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'stops STT and starts session WAV when app backgrounds',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        clearInteractions(backgroundRecorder);
        clearInteractions(audioCapture);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) => state is RecordingInProgress && state.isBackgroundCapture,
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
        verifyNever(() => backgroundRecorder.stop());
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'merges offline whisper then resumes STT on foreground',
      build: buildBloc,
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
        ).thenAnswer((_) async => 'texte hors ligne');
      },
      act: (bloc) async {
        await seedListening(bloc);
        bloc.add(const VoiceCaptureAppBackgrounded());
        await bloc.stream.firstWhere(
          (state) => state is RecordingInProgress && state.isBackgroundCapture,
        );
        when(() => backgroundRecorder.isRecording).thenReturn(true);
        clearInteractions(audioCapture);
        clearInteractions(offlineTranscription);
        clearInteractions(backgroundRecorder);
        bloc.add(const VoiceCaptureAppForegrounded());
        await bloc.stream.firstWhere(
          (state) => state is RecordingInProgress && !state.isBackgroundCapture,
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
              (s) => s.transcript,
              'transcript',
              contains('texte hors ligne'),
            ),
      ],
      verify: (_) {
        verify(() => backgroundRecorder.stop()).called(1);
        verify(
          () => offlineTranscription.transcribeFile(
            '/tmp/bg.wav',
            language: any(named: 'language'),
          ),
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
      'enhances from session audio then waits for transcript choice',
      build: buildBloc,
      setUp: () {
        when(
          () => userPreferences.readAiEnhanceEnabled(),
        ).thenAnswer((_) async => true);
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/session.wav';
        });
      },
      act: (bloc) async {
        await seedListening(bloc);
        bloc.add(const VoiceCaptureFinishConsultation(language: 'fr'));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureTranscriptCompare,
        );
        bloc.add(const VoiceCaptureTranscriptChoiceSelected(useAi: true));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureConsultationFinished,
        );
      },
      expect: () => [
        const VoiceCaptureReady(),
        isA<RecordingInProgress>(),
        isA<VoiceCaptureEnhancing>(),
        isA<VoiceCaptureTranscriptCompare>().having(
          (s) => s.aiTranscript,
          'aiTranscript',
          'texte ameliore',
        ),
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
      'choosing local transcript skips AI text',
      build: buildBloc,
      setUp: () {
        when(
          () => userPreferences.readAiEnhanceEnabled(),
        ).thenAnswer((_) async => true);
        when(
          () => offlineTranscription.transcribeFile(
            any(),
            language: any(named: 'language'),
          ),
        ).thenAnswer((_) async => 'bonjour patient');
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return '/tmp/session.wav';
        });
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
        bloc.add(const VoiceCaptureFinishConsultation(language: 'fr'));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureTranscriptCompare,
        );
        bloc.add(const VoiceCaptureTranscriptChoiceSelected(useAi: false));
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
      'falls back to offline transcript when enhance fails',
      build: buildBloc,
      setUp: () {
        when(
          () => userPreferences.readAiEnhanceEnabled(),
        ).thenAnswer((_) async => true);
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
        ).thenAnswer((_) async => 'bonjour patient');
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
      'applies selected pathology template to SOAP on finish',
      build: buildBloc,
      setUp: () {
        when(() => backgroundRecorder.stop()).thenAnswer((_) async {
          when(() => backgroundRecorder.isRecording).thenReturn(false);
          return null;
        });
        when(
          () => noteProcessing.process(
            sessionId: any(named: 'sessionId'),
            rawText: any(named: 'rawText'),
            language: any(named: 'language'),
          ),
        ).thenAnswer(
          (_) async => const SoapNoteResult(
            processedText: 'douleur a la cheville',
            soapNote: SoapNote(),
          ),
        );
      },
      act: (bloc) async {
        const template = NoteTemplate(
          id: 'builtin_ankle_sprain',
          pathologyKey: 'ankle_sprain',
          name: 'Entorse de cheville',
          source: NoteTemplateSource.builtIn,
          sections: [
            NoteSection(
              id: 'subjective',
              kind: NoteSectionKind.subjective,
              title: 'Subjectif',
              prompt: '- Motif de consultation :',
              order: 0,
            ),
            NoteSection(
              id: 'objective',
              kind: NoteSectionKind.objective,
              title: 'Objectif',
              prompt: '- Inspection :',
              order: 1,
            ),
            NoteSection(
              id: 'assessment',
              kind: NoteSectionKind.assessment,
              title: 'Evaluation',
              prompt: '- Grade :',
              order: 2,
            ),
            NoteSection(
              id: 'plan',
              kind: NoteSectionKind.plan,
              title: 'Plan',
              prompt: '- Traitement :',
              order: 3,
            ),
          ],
        );
        bloc.add(const VoiceCaptureTemplateSelected(template));
        await seedListening(bloc);
        bloc.add(const VoiceCaptureTranscriptUpdated('douleur'));
        await bloc.stream.firstWhere(
          (state) =>
              state is RecordingInProgress && state.transcript.isNotEmpty,
        );
        bloc.add(const VoiceCaptureFinishConsultation(language: 'fr'));
        await bloc.stream.firstWhere(
          (state) => state is VoiceCaptureConsultationFinished,
        );
      },
      verify: (_) {
        final savedSessions = verify(
          () => sessionRepository.save(captureAny()),
        ).captured.cast<RecordingSession>();
        final completed = savedSessions.lastWhere(
          (session) => session.status == RecordingSessionStatus.completed,
        );
        expect(completed.templateId, 'builtin_ankle_sprain');
        expect(
          completed.soapNote?.subjective,
          contains('douleur a la cheville'),
        );
        expect(
          completed.soapNote?.subjective,
          contains('Motif de consultation'),
        );
        expect(completed.soapNote?.objective, contains('Inspection'));
        expect(completed.soapNote?.assessment, contains('Grade'));
        expect(completed.soapNote?.plan, contains('Traitement'));
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cleans up notification and session audio on pause',
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
        verify(() => backgroundRecorder.cancel()).called(greaterThan(0));
      },
    );

    blocTest<VoiceCaptureBloc, VoiceCaptureState>(
      'cancels session audio on discard',
      build: buildBloc,
      act: (bloc) async {
        await seedListening(bloc);
        bloc.add(const VoiceCaptureDiscardConsultation());
        await bloc.stream.firstWhere(
          (state) =>
              state is VoiceCaptureReady && bloc.state is VoiceCaptureReady,
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

    test(
      'ignores STT session end while background capture is active',
      () async {
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
      },
    );
  });
}
