import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/date/civil_date.dart';

void main() {
  group('CivilDate.parseItalian', () {
    test('parses a valid italian civil date', () {
      final date = CivilDate.parseItalian('30/08/2026');

      expect(date, DateTime.utc(2026, 8, 30));
    });

    test('trims surrounding whitespace', () {
      final date = CivilDate.parseItalian('  30/08/2026  ');

      expect(date, DateTime.utc(2026, 8, 30));
    });

    test('rejects iso format', () {
      expect(CivilDate.parseItalian('2026-08-30'), isNull);
    });

    test('rejects impossible date', () {
      expect(CivilDate.parseItalian('30/02/2026'), isNull);
    });

    test('accepts leap day in a leap year', () {
      final date = CivilDate.parseItalian('29/02/2024');

      expect(date, DateTime.utc(2024, 2, 29));
    });

    test('rejects leap day in a non-leap year', () {
      expect(CivilDate.parseItalian('29/02/2025'), isNull);
    });
  });

  group('CivilDate.formatItalian', () {
    test('formats date as GG/MM/AAAA', () {
      final text = CivilDate.formatItalian(DateTime.utc(2026, 8, 30));

      expect(text, '30/08/2026');
    });
  });
}
