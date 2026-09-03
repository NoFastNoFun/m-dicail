import 'package:flutter_test/flutter_test.dart';
import 'package:medicail/core/deeplink/auth_deeplink_mapper.dart';

void main() {
  group('mapIncomingAuthUri', () {
    test('maps medicail://reset-password with token', () {
      final uri = Uri.parse('medicail://reset-password?token=abc.def');
      expect(
        mapIncomingAuthUri(uri),
        '/reset-password?token=abc.def',
      );
    });

    test('maps medicail://recovery with token', () {
      final uri = Uri.parse('medicail://recovery?token=tok%2B1');
      expect(
        mapIncomingAuthUri(uri),
        '/recovery?token=tok%2B1',
      );
    });

    test('maps https bounce URL', () {
      final uri = Uri.parse(
        'https://medicail.nf2.tech/reset-password?token=token-1.secret',
      );
      expect(
        mapIncomingAuthUri(uri),
        '/reset-password?token=token-1.secret',
      );
    });

    test('maps path-style custom scheme', () {
      final uri = Uri.parse('medicail:///reset-password?token=x');
      expect(mapIncomingAuthUri(uri), '/reset-password?token=x');
    });

    test('returns path without token when missing', () {
      expect(
        mapIncomingAuthUri(Uri.parse('medicail://reset-password')),
        '/reset-password',
      );
    });

    test('ignores unrelated URIs', () {
      expect(mapIncomingAuthUri(Uri.parse('https://example.com/home')), isNull);
      expect(mapIncomingAuthUri(Uri.parse('medicail://settings')), isNull);
    });
  });
}
