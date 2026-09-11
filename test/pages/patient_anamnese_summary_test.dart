import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/i18n/app_localizations_fr.dart';
import 'package:medicail/core/router/app_router.dart';
import 'package:medicail/features/auth/presentation/notifier/auth_notifier.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/detail/patient_detail_bloc.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/recording/domain/repositories/recording_session_repository.dart';
import 'package:medicail/features/settings/presentation/notifier/settings_notifier.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_summary_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';

class _Patients extends Mock implements PatientRepository {}

class _Sessions extends Mock implements RecordingSessionRepository {}

class _Tutorial extends MockBloc<TutorialEvent, TutorialState>
    implements TutorialBloc {}

void main() {
  final l10n = AppLocalizationsFr();
  late _Patients patients;
  late _Tutorial tutorial;

  setUp(() {
    ShowcaseView.register();
    patients = _Patients();
    final sessions = _Sessions();
    tutorial = _Tutorial();
    when(() => tutorial.state).thenReturn(const TutorialCompleted());
    when(
      () => sessions.getByPatientId('patient-1'),
    ).thenAnswer((_) async => []);
    getIt.registerSingleton<SettingsNotifier>(SettingsNotifier());
    getIt.registerSingleton<PatientRepository>(patients);
    getIt.registerSingleton<RecordingSessionRepository>(sessions);
    getIt.registerFactory<PatientDetailBloc>(
      () => PatientDetailBloc(patients, sessions),
    );
    getIt.registerFactory<PatientBloc>(() => PatientBloc(patients));
  });

  tearDown(() async {
    await tutorial.close();
    await getIt.reset();
    ShowcaseView.get().unregister();
  });

  Future<void> mount(WidgetTester tester, Anamnese data) async {
    final patient = Patient(
      id: 'patient-1',
      mrn: 'TEST',
      firstName: 'Patient',
      lastName: 'Test',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      metadata: <String, dynamic>{}.withAnamnese(data),
    );
    when(() => patients.getById(patient.id)).thenAnswer((_) async => patient);
    await tester.binding.setSurfaceSize(const Size(1000, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final auth = AuthNotifier()
      ..setHasCompletedOnboarding(true)
      ..setGuest(true);
    final appRouter = AppRouter(auth);
    appRouter.router.go('/patients/patient-1');
    addTearDown(appRouter.router.dispose);
    addTearDown(auth.dispose);
    await tester.pumpWidget(
      BlocProvider<TutorialBloc>.value(
        value: tutorial,
        child: MaterialApp.router(
          routerConfig: appRouter.router,
          locale: const Locale('fr'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty history only offers completion', (tester) async {
    await mount(tester, const Anamnese());
    expect(find.text(l10n.anamneseCardComplete), findsOneWidget);
    expect(find.text(l10n.anamneseCardViewSummary), findsNothing);
  });

  testWidgets('an explicit absence enables the read-only summary', (
    tester,
  ) async {
    await mount(
      tester,
      const Anamnese(
        stylesDeVie: StylesDeVie(
          allergies: AllergiesEntry(status: PresenceStatus.absent),
        ),
      ),
    );
    expect(find.text(l10n.anamneseCardEdit), findsOneWidget);
    await tester.ensureVisible(find.text(l10n.anamneseCardViewSummary));
    await tester.tap(find.text(l10n.anamneseCardViewSummary));
    await tester.pumpAndSettle();
    expect(find.byType(AnamneseSummaryPage), findsOneWidget);
    expect(
      find.text(
        l10n.anamneseSummaryLabelValue(
          l10n.anamneseAllergies,
          l10n.anamneseSummaryAbsent,
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip(l10n.anamneseSummaryClose));
    await tester.pumpAndSettle();
    expect(find.text(l10n.anamneseCardViewSummary), findsOneWidget);
    verify(() => patients.getById('patient-1')).called(1);
    verifyNoMoreInteractions(patients);
  });
}
