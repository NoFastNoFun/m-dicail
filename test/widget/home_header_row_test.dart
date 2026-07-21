import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/design_system/app_theme.dart';
import 'package:medicail/widget/app_text.dart';

void main() {
  testWidgets(
    'TextButton beside Expanded title does not crush title width',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: AppText(
                      'Prochains rendez-vous',
                      variant: AppTextVariant.title,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const AppText(
                      'Voir tout',
                      variant: AppTextVariant.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final title = tester.getRect(find.text('Prochains rendez-vous'));
      final seeAll = tester.getRect(find.text('Voir tout'));

      expect(title.width, greaterThan(120));
      expect(title.height, lessThan(40));
      expect(seeAll.left, greaterThan(title.right));
    },
  );
}
