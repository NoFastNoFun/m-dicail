import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/design_system/app_theme.dart';
import 'package:medicail/core/design_system/theme_colors.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/core/i18n/app_localizations_fr.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/features/patient/domain/entities/patient.dart';
import 'package:medicail/widget/app_button.dart';
import 'package:medicail/widget/app_text.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_summary_page.dart';

import '../support/load_test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadTestFonts);
  final l10n = AppLocalizationsFr();
  final longNote = List.filled(
    20,
    'Texte clinique conservé intégralement.',
  ).join(' ');
  final patient = Patient(
    id: 'patient-1',
    mrn: 'TEST',
    firstName: 'Patient',
    lastName: 'Test',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    metadata: <String, dynamic>{}.withAnamnese(
      Anamnese(
        naissanceEnfance: NaissanceEnfance(notes: longNote),
        stylesDeVie: const StylesDeVie(
          allergies: AllergiesEntry(status: PresenceStatus.absent),
        ),
      ),
    ),
  );

  Future<void> mount(
    WidgetTester tester, {
    double scale = 1,
    Brightness brightness = Brightness.light,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: brightness == Brightness.dark ? AppTheme.dark : AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => AppButton(
              label: l10n.anamneseCardViewSummary,
              onPressed: () => showAnamneseSummary(context, patient: patient),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text(l10n.anamneseCardViewSummary));
    await tester.pumpAndSettle();
  }

  testWidgets('summary opens compact and preserves explicit absences', (
    tester,
  ) async {
    await mount(tester);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text(l10n.anamneseSummaryShowDetails), findsOneWidget);
    expect(find.text(l10n.anamneseVieFamilialeTitle), findsNothing);
    expect(
      find.text(
        l10n.anamneseSummaryLabelValue(
          l10n.anamneseAllergies,
          l10n.anamneseSummaryAbsent,
        ),
      ),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNothing);
    final note = tester.widget<Text>(
      find.text(
        l10n.anamneseSummaryLabelValue(
          l10n.anamneseNotesComplementaires,
          longNote,
        ),
      ),
    );
    expect(note.maxLines, 2);
    expect(note.overflow, TextOverflow.ellipsis);
  });

  testWidgets('details show missing fields in grey and restore full text', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.text(l10n.anamneseSummaryShowDetails));
    await tester.pumpAndSettle();
    final missingText = l10n.anamneseSummaryLabelValue(
      l10n.anamnesePoidsNaissance,
      l10n.anamneseSummaryNotFilled,
    );
    final missing = tester.widget<AppText>(
      find.widgetWithText(AppText, missingText),
    );
    expect(
      missing.color,
      tester.element(find.byType(AnamneseSummaryPage)).secondaryTextColor,
    );
    final note = tester.widget<Text>(
      find.text(
        l10n.anamneseSummaryLabelValue(
          l10n.anamneseNotesComplementaires,
          longNote,
        ),
      ),
    );
    expect(note.maxLines, isNull);
    expect(note.overflow, isNull);
    await tester.tap(find.text(l10n.anamneseSummaryShowCompact));
    await tester.pumpAndSettle();
    expect(find.text(missingText), findsNothing);
    expect(patient.metadata.anamnese.naissanceEnfance.notes, longNote);
  });

  testWidgets('both close controls return to the previous screen', (
    tester,
  ) async {
    await mount(tester);
    await tester.tap(find.widgetWithText(AppButton, l10n.anamneseSummaryClose));
    await tester.pumpAndSettle();
    expect(find.byType(AnamneseSummaryPage), findsNothing);
    await tester.tap(find.text(l10n.anamneseCardViewSummary));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l10n.anamneseSummaryClose));
    await tester.pumpAndSettle();
    expect(find.byType(AnamneseSummaryPage), findsNothing);
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'small screen with large text stays scrollable in ${brightness.name}',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 640));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await mount(tester, scale: 2, brightness: brightness);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text(l10n.anamneseSummaryShowDetails));
        await tester.tap(find.text(l10n.anamneseSummaryShowDetails));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text(l10n.anamneseTraumatismesTitle),
          400,
          scrollable: find.byType(Scrollable),
        );
        expect(tester.takeException(), isNull);
        await tester.tap(
          find.widgetWithText(AppButton, l10n.anamneseSummaryClose),
        );
        await tester.pumpAndSettle();
        expect(find.byType(AnamneseSummaryPage), findsNothing);
      },
    );
  }
}
