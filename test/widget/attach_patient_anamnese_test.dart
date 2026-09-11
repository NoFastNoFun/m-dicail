import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/di/injection.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/features/patient/domain/repositories/patient_repository.dart';
import 'package:medicail/features/patient/presentation/patient_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_bloc.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_event.dart';
import 'package:medicail/features/tutorial/presentation/tutorial_state.dart';
import 'package:medicail/widget/consultation/attach_patient_dialog.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/consultation/new_patient_anamnese_carousel.dart';
import 'package:mocktail/mocktail.dart';
import 'package:showcaseview/showcaseview.dart';

class _Patients extends Mock implements PatientRepository {}

class _TutorialBloc extends MockBloc<TutorialEvent, TutorialState>
    implements TutorialBloc {}

void main() {
  late _Patients patients;
  late _TutorialBloc tutorial;
  final patient = Patient(
    id: 'patient-1',
    mrn: 'MRN1',
    firstName: 'Alice',
    lastName: 'Martin',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUp(() {
    ShowcaseView.register();
    patients = _Patients();
    tutorial = _TutorialBloc();
    when(() => tutorial.state).thenReturn(const TutorialCompleted());
    registerFallbackValue(patient);
    when(() => patients.getAll(query: any(named: 'query'), archived: any(named: 'archived')))
        .thenAnswer((_) async => [patient]);
    when(() => patients.save(any())).thenAnswer((invocation) async {
      final p = invocation.positionalArguments.first as Patient;
      if (p.id.isEmpty) {
        return p.copyWith(id: 'created-1');
      }
      return p;
    });
    if (getIt.isRegistered<PatientRepository>()) {
      getIt.unregister<PatientRepository>();
    }
    if (getIt.isRegistered<PatientBloc>()) {
      getIt.unregister<PatientBloc>();
    }
    getIt.registerSingleton<PatientRepository>(patients);
    getIt.registerFactory<PatientBloc>(() => PatientBloc(patients));
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget wrap(Widget child) {
    return BlocProvider<TutorialBloc>.value(
      value: tutorial,
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr')],
        home: child,
      ),
    );
  }

  testWidgets('selecting an existing patient returns its id', (tester) async {
    String? result;
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await AttachPatientDialog.show(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AttachPatientDialog), findsOneWidget);

    await tester.tap(find.text(patient.displayName));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AttachPatientDialog)),
    );
    await tester.tap(find.text(l10n.attachPatientConfirm));
    await tester.pumpAndSettle();

    expect(result, patient.id);
    expect(find.byType(AttachPatientDialog), findsNothing);
  });

  testWidgets('closing the dialog cancels without a patient id', (tester) async {
    String? result = 'sentinel';
    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await AttachPatientDialog.show(context);
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('identity page blocks next without required fields', (tester) async {
    await tester.pumpWidget(
      wrap(
        BlocProvider(
          create: (_) => PatientBloc(patients),
          child: const Scaffold(
            body: NewPatientAnamneseCarousel(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(NewPatientAnamneseCarousel)),
    );
    await tester.tap(find.text(l10n.anamneseNext));
    await tester.pumpAndSettle();

    // Still on identity page (toast may not render without AppToastHost).
    expect(find.text(l10n.anamneseIdentityTitle), findsWidgets);
    expect(find.text(l10n.anamneseHubSubtitle), findsNothing);
    expect(find.text(l10n.anamneseNaissanceEnfanceTitle), findsNothing);
    verifyNever(() => patients.save(any()));
  });

  testWidgets('finish after identity creates a patient', (tester) async {
    String? createdId;
    await tester.pumpWidget(
      wrap(
        BlocProvider(
          create: (_) => PatientBloc(patients),
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () async {
                    createdId = await showDialog<String>(
                      context: context,
                      builder: (_) => BlocProvider(
                        create: (_) => PatientBloc(patients),
                        child: const Dialog.fullscreen(
                          child: SafeArea(
                            child: NewPatientAnamneseCarousel(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('open'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(NewPatientAnamneseCarousel)),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Jean');
    await tester.enterText(find.byType(TextFormField).at(1), 'Dupont');
    await tester.enterText(find.byType(TextFormField).at(2), '01/01/1990');
    await tester.pumpAndSettle();

    expect(find.text(l10n.anamneseFinish), findsOneWidget);
    await tester.tap(find.text(l10n.anamneseFinish));
    await tester.pumpAndSettle();

    expect(createdId, 'created-1');
    verify(() => patients.save(any())).called(1);
  });

  test('AnamneseFormData.generateMrn starts with P', () {
    expect(AnamneseFormData.generateMrn(), startsWith('P'));
  });
}
