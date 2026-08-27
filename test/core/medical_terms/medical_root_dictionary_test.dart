import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/medical_terms/medical_root_dictionary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MedicalRootDictionary', () {
    test('loads roots and known terms from the asset', () async {
      final data = await MedicalRootDictionary().load();

      expect(data.prefixesAnatomiques, isNotEmpty);
      expect(data.prefixesRegions, isNotEmpty);
      expect(data.prefixesDirection, isNotEmpty);
      expect(data.suffixesPathologiques, isNotEmpty);
      expect(data.knownTerms, contains('tendinite'));
      expect(data.knownTerms, contains('épicondylite'));
    });

    test('caches the parsed result across calls', () async {
      final dictionary = MedicalRootDictionary();
      final first = await dictionary.load();
      final second = await dictionary.load();

      expect(identical(first, second), isTrue);
    });
  });
}
