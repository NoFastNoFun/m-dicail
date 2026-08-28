import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/features/pathology/data/datasources/asset_pathology_data_source.dart';
import 'package:medicail/features/pathology/domain/entities/pathology_source.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AssetPathologyDataSource', () {
    late AssetPathologyDataSource dataSource;

    setUp(() {
      dataSource = AssetPathologyDataSource();
    });

    test('loads built-in pathologies from bundled asset', () async {
      final raw = await rootBundle.loadString(AssetPathologyDataSource.assetPath);
      expect(raw.isNotEmpty, isTrue);

      final pathologies = await dataSource.loadBuiltInPathologies();

      expect(pathologies, isNotEmpty);
      expect(pathologies.length, greaterThanOrEqualTo(50));
      expect(pathologies.every((pathology) => pathology.isBuiltIn), isTrue);
      expect(
        pathologies.every((pathology) => pathology.source == PathologySource.builtIn),
        isTrue,
      );
      expect(
        pathologies.any((pathology) => pathology.templateId == 'builtin_low_back_pain'),
        isTrue,
      );
    });
  });
}
