import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/core/router/app_routes.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_event.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/recording/domain/entities/recording_session.dart';
import 'package:medicail/features/recording/domain/entities/soap_note.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_bloc.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_event.dart';
import 'package:medicail/features/voice_capture/presentation/voice_capture_state.dart';
import 'package:medicail/pages/patient_detail_page.dart';
import 'package:medicail/pages/record_page.dart';
import 'package:medicail/widget/assign_patient_sheet.dart';
import 'package:medicail/widget/soap_note_bottom_sheet.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';

class _VoiceBloc extends MockBloc<VoiceCaptureEvent, VoiceCaptureState>
    implements VoiceCaptureBloc {}

class _TutorialBloc extends MockBloc<TutorialEvent, TutorialState>
    implements TutorialBloc {}

class _Patients extends Mock implements PatientRepository {}

class _Sessions extends Mock implements RecordingSessionRepository {}

void main() {
  late _VoiceBloc voice;
  late _TutorialBloc tutorial;
  late _Patients patients;
  late _Sessions sessions;
  late StreamController<VoiceCaptureState> voiceStates;
  late RecordingSession savedSession;
  final patient = Patient(
    id: 'patient-1',
    mrn: 'TEST',
    firstName: 'Patient',
    lastName: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUp(() {
    ShowcaseView.register();
    voice = _VoiceBloc();
    tutorial = _TutorialBloc();
    patients = _Patients();
    sessions = _Sessions();
    voiceStates = StreamController<VoiceCaptureState>.broadcast();
    whenListen(
      voice,
      voiceStates.stream,
      initialState: const ListeningPaused(transcript: 'Transcription test.'),
    );
    when(() => tutorial.state).thenReturn(const TutorialCompleted());
    savedSession = RecordingSession(
      id: 'session-1',
      patientId: patient.id,
      startedAt: DateTime(2026),
      status: RecordingSessionStatus.completed,
      transcript: 'Transcription test.',
      soapNote: const SoapNote(subjective: 'Note de la consultation terminée.'),
      templateId: 'template-1',
      templateName: 'Modèle test',
    );
    registerFallbackValue(savedSession);
    when(() => patients.getById(patient.id)).thenAnswer((_) async => patient);
    when(
      () => patients.getAll(query: any(named: 'query')),
    ).thenAnswer((_) async => [patient]);
    when(
      () => sessions.getById(savedSession.id),
    ).thenAnswer((_) async => savedSession);
    when(() => sessions.getByPatientId(patient.id)).thenAnswer(
      (_) async => [
        savedSession.copyWith(
          id: 'older-session',
          soapNote: const SoapNote(subjective: 'Ancienne note.'),
        ),
        savedSession,
      ],
    );
    when(() => sessions.save(any())).thenAnswer((invocation) async {
      savedSession = invocation.positionalArguments.single as RecordingSession;
      return savedSession;
    });
    getIt.registerFactory<VoiceCaptureBloc>(() => voice);
    getIt.registerSingleton<PatientRepository>(patients);
    getIt.registerSingleton<RecordingSessionRepository>(sessions);
    getIt.registerFactory<PatientDetailBloc>(
      () => PatientDetailBloc(patients, sessions),
    );
    getIt.registerFactory<PatientBloc>(() => PatientBloc(patients));
  });

  tearDown(() async {
    await voiceStates.close();
    await tutorial.close();
    await getIt.reset();
    ShowcaseView.get().unregister();
  });

  Future<AppRouter> mount(WidgetTester tester, String location) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthNotifier()
      ..setHasCompletedOnboarding(true)
      ..setGuest(true);
    final appRouter = AppRouter(auth);
    appRouter.router.go(location);
    addTearDown(appRouter.router.dispose);
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BlocProvider<TutorialBloc>.value(
        value: tutorial,
        child: MaterialApp.router(
          routerConfig: appRouter.router,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();
    return appRouter;
  }

  Future<void> finish(WidgetTester tester) async {
    final l10n = AppLocalizations.of(tester.element(find.byType(RecordPage)));
    await tester.tap(find.text(l10n.buttonFinishConsultation));
    verify(
      () => voice.add(const VoiceCaptureFinishConsultation(language: 'fr')),
    ).called(1);
    voiceStates.add(
      VoiceCaptureConsultationFinished(
        sessionId: savedSession.id,
        transcript: savedSession.transcript,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('finishing opens the exact SOAP note in the patient dossier', (
    tester,
  ) async {
    final appRouter = await mount(
      tester,
      '${AppRoutes.patients}/${patient.id}',
    );
    final l10n = AppLocalizations.of(
      tester.element(find.byType(PatientDetailPage)),
    );
    await tester.tap(find.text(l10n.patientNewConsultationButton));
    await tester.pumpAndSettle();
    expect(find.byType(RecordPage), findsOneWidget);
    await finish(tester);

    expect(find.byType(RecordPage), findsNothing);
    expect(find.byType(PatientDetailPage), findsOneWidget);
    final sheet = tester.widget<SoapNoteBottomSheet>(
      find.byType(SoapNoteBottomSheet),
    );
    expect(sheet.initialNote, savedSession.soapNote);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(SoapNoteBottomSheet), findsNothing);
    expect(find.text(savedSession.soapNote!.subjective), findsOneWidget);

    final context = tester.element(find.text(patient.displayName));
    context.read<PatientDetailBloc>().add(PatientDetailRequested(patient.id));
    await tester.pumpAndSettle();
    expect(find.byType(SoapNoteBottomSheet), findsNothing);
    appRouter.router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(RecordPage), findsNothing);
    expect(find.byType(PatientDetailPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick recording opens its SOAP note after patient assignment', (
    tester,
  ) async {
    savedSession = savedSession.copyWith(clearPatientId: true);
    await mount(tester, AppRoutes.record);
    await finish(tester);
    expect(find.byType(AssignPatientSheet), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    await tester.tap(find.text(patient.displayName));
    await tester.pumpAndSettle();

    expect(savedSession.patientId, patient.id);
    expect(find.byType(AssignPatientSheet), findsNothing);
    expect(find.byType(RecordPage), findsNothing);
    expect(find.byType(PatientDetailPage), findsOneWidget);
    expect(find.byType(SoapNoteBottomSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordinary dossier navigation does not open a SOAP note', (
    tester,
  ) async {
    await mount(tester, '${AppRoutes.patients}/${patient.id}');
    expect(find.byType(PatientDetailPage), findsOneWidget);
    expect(find.byType(SoapNoteBottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
