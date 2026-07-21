import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppContentConstraint pattern gives non-zero width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              const SizedBox(width: 88, child: ColoredBox(color: Colors.grey)),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 880),
                        child: SizedBox(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Text('Prochains rendez-vous'),
                                    ),
                                    TextButton(onPressed: () {}, child: const Text('Voir tout')),
                                  ],
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(onPressed: () {}, child: const Text('Nouveau')),
                                ),
                                const Expanded(child: ColoredBox(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final title = tester.getSize(find.text('Prochains rendez-vous'));
    final row = tester.getSize(find.byType(Row).first);
    debugPrint('title size: $title');
    debugPrint('row size: $row');
    expect(title.width, greaterThan(50));
  });

  testWidgets('nested scaffold body with Align', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1280, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(width: 88),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Scaffold(
                      appBar: AppBar(title: const Text('Accueil')),
                      body: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 880),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: const [
                                Text('Prochains rendez-vous'),
                                Expanded(child: Placeholder()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final title = tester.getSize(find.text('Prochains rendez-vous'));
    debugPrint('nested title size: $title');
    expect(title.width, greaterThan(50));
  });
}
