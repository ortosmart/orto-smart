import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/bed_geometry.dart';

Map<String, dynamic> _validMap() {
  return {
    'id': '11111111-1111-4111-8111-111111111111',
    'bed_id': '22222222-2222-4222-8222-222222222222',
    'width_cm': 90,
    'length_cm': 700,
    'valid_from': '2026-03-01',
    'valid_to': null,
    'row_version': 1,
  };
}

void main() {
  group('BedGeometry.fromMap', () {
    test('reads a geometry with an open interval', () {
      final geometry = BedGeometry.fromMap(_validMap());

      expect(geometry.id, '11111111-1111-4111-8111-111111111111');
      expect(geometry.bedId, '22222222-2222-4222-8222-222222222222');
      expect(geometry.widthCm, 90);
      expect(geometry.lengthCm, 700);
      expect(geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(geometry.validFrom.isUtc, isTrue);
      expect(geometry.validTo, isNull);
      expect(geometry.rowVersion, 1);
    });

    test('reads a geometry with a closed interval', () {
      final map = _validMap()
        ..['valid_to'] = '2026-06-01'
        ..['row_version'] = 3;

      final geometry = BedGeometry.fromMap(map);

      expect(geometry.validTo, DateTime.utc(2026, 6, 1));
      expect(geometry.validTo!.isUtc, isTrue);
      expect(geometry.rowVersion, 3);
    });

    test('accepts a valid leap day', () {
      final map = _validMap()..['valid_from'] = '2024-02-29';

      final geometry = BedGeometry.fromMap(map);

      expect(geometry.validFrom, DateTime.utc(2024, 2, 29));
    });
    final invalidCases = <String, Map<String, dynamic>>{
      'empty geometry id': {'id': ''},
      'blank bed id': {'bed_id': '   '},
      'zero width': {'width_cm': 0},
      'negative width': {'width_cm': -1},
      'zero length': {'length_cm': 0},
      'negative length': {'length_cm': -1},
      'zero row version': {'row_version': 0},
      'negative row version': {'row_version': -1},
      'missing start date': {'valid_from': null},
      'non-string start date': {'valid_from': 20260301},
      'empty start date': {'valid_from': ''},
      'non-padded date': {'valid_from': '2026-3-01'},
      'timestamp instead of date': {'valid_from': '2026-03-01T00:00:00Z'},
      'impossible leap day': {'valid_from': '2026-02-29'},
      'impossible day of month': {'valid_from': '2026-04-31'},
      'invalid month': {'valid_from': '2026-13-01'},
      'year zero': {'valid_from': '0000-03-01'},
      'invalid end date': {'valid_to': '2026-06-31'},
      'empty interval': {'valid_to': '2026-03-01'},
      'inverted interval': {'valid_to': '2026-02-28'},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final map = _validMap()..addAll(entry.value);

        expect(() => BedGeometry.fromMap(map), throwsA(isA<FormatException>()));
      });
    }
  });
}
