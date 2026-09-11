import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/i18n/app_localizations.dart';
import 'package:medicail/features/patient/domain/entities/anamnese.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_form_data.dart';
import 'package:medicail/widget/consultation/anamnese/anamnese_pages.dart';

void main() {
  testWidgets('alcool toggle expands and collapses detail chips', (tester) async {
    final data = AnamneseFormData();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr')],
        home: Scaffold(
          body: AnamneseStylesDeViePage(
            data: data,
            onChanged: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(AnamneseStylesDeViePage)),
    );

    expect(find.text(l10n.anamneseFreqHebdo), findsNothing);

    final alcoolSwitch = find.descendant(
      of: find.widgetWithText(SwitchListTile, l10n.anamneseAlcool),
      matching: find.byType(Switch),
    );
    await tester.tap(alcoolSwitch);
    await tester.pumpAndSettle();

    expect(data.anamnese.stylesDeVie.alcool.status, PresenceStatus.present);
    expect(find.text(l10n.anamneseFreqHebdo), findsOneWidget);
    expect(find.text(l10n.anamneseVerresSemaine), findsOneWidget);

    await tester.tap(alcoolSwitch);
    await tester.pumpAndSettle();

    expect(data.anamnese.stylesDeVie.alcool.status, PresenceStatus.absent);
    expect(find.text(l10n.anamneseFreqHebdo), findsNothing);
  });
}
