import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/bed.dart';

const _bedId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _geometryMap() {
  return {
    'id': _geometryId,
    'bed_id': _bedId,
    'width_cm': 90,
    'length_cm': 700,
    'valid_from': '2026-03-01',
    'valid_to': null,
    'row_version': 2,
  };
}

Map<String, dynamic> _bedMap() {
  return {
    'id': _bedId,
    'garden_id': _gardenId,
    'number': 1,
    'name': 'Aiuola di prova',
    'notes': 'Note di prova',
    'is_active': true,
    'row_version': 5,
    'bed_geometries': [_geometryMap()],
  };
}

void main() {
  group('Bed.fromMap', () {
    test('reads identity, descriptive data and selected geometry', () {
      final bed = Bed.fromMap(_bedMap());

      expect(bed.id, _bedId);
      expect(bed.gardenId, _gardenId);
      expect(bed.number, 1);
      expect(bed.name, 'Aiuola di prova');
      expect(bed.notes, 'Note di prova');
      expect(bed.isActive, isTrue);
      expect(bed.rowVersion, 5);
      expect(bed.geometry.id, _geometryId);
      expect(bed.geometry.bedId, _bedId);
      expect(bed.geometry.rowVersion, 2);
      expect(bed.geometry.validFrom, DateTime.utc(2026, 3, 1));
      expect(bed.geometry.validTo, isNull);
    });

    test('accepts null optional fields and a disabled bed', () {
      final map = _bedMap()
        ..['name'] = null
        ..['notes'] = null
        ..['is_active'] = false;

      final bed = Bed.fromMap(map);

      expect(bed.name, isNull);
      expect(bed.notes, isNull);
      expect(bed.isActive, isFalse);
    });

    final codeCases = <int, String>{1: 'A01', 9: 'A09', 10: 'A10', 100: 'A100'};

    for (final entry in codeCases.entries) {
      test('derives ${entry.value} from number ${entry.key}', () {
        final map = _bedMap()..['number'] = entry.key;

        expect(Bed.fromMap(map).code, entry.value);
      });
    }

    test('derives code without using the legacy code field', () {
      final map = _bedMap()..['code'] = 'LEGACY';

      expect(Bed.fromMap(map).code, 'A01');
    });

    test('reads dimensions only from the selected geometry', () {
      final geometry = _geometryMap()
        ..['width_cm'] = 120
        ..['length_cm'] = 800;

      final map = _bedMap()
        ..['width_cm'] = 999
        ..['length_cm'] = 999
        ..['bed_geometries'] = [geometry];

      final bed = Bed.fromMap(map);

      expect(bed.widthCm, 120);
      expect(bed.lengthCm, 800);
      expect(bed.widthCm, bed.geometry.widthCm);
      expect(bed.lengthCm, bed.geometry.lengthCm);
    });

    test('accepts an explicitly selected historical geometry', () {
      final geometry = _geometryMap()..['valid_to'] = '2026-06-01';
      final map = _bedMap()..['bed_geometries'] = [geometry];

      final bed = Bed.fromMap(map);

      expect(bed.geometry.validTo, DateTime.utc(2026, 6, 1));
    });

    test('rejects an absent geometry relation', () {
      final map = _bedMap()..remove('bed_geometries');

      expect(() => Bed.fromMap(map), throwsA(isA<FormatException>()));
    });

    final invalidCases = <String, Map<String, dynamic>>{
      'null geometry relation': {'bed_geometries': null},
      'non-list geometry relation': {'bed_geometries': _geometryMap()},
      'empty geometry relation': {'bed_geometries': <dynamic>[]},
      'multiple geometries': {
        'bed_geometries': [_geometryMap(), _geometryMap()],
      },
      'null geometry entry': {
        'bed_geometries': [null],
      },
      'non-map geometry entry': {
        'bed_geometries': ['invalid'],
      },
      'geometry belonging to another bed': {
        'bed_geometries': [
          _geometryMap()..['bed_id'] = '44444444-4444-4444-8444-444444444444',
        ],
      },
      'empty bed id': {'id': ''},
      'blank garden id': {'garden_id': '   '},
      'zero number': {'number': 0},
      'negative number': {'number': -1},
      'zero bed version': {'row_version': 0},
      'negative bed version': {'row_version': -1},
      'invalid geometry dimensions': {
        'bed_geometries': [_geometryMap()..['width_cm'] = 0],
      },
      'invalid geometry version': {
        'bed_geometries': [_geometryMap()..['row_version'] = 0],
      },
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final map = _bedMap()..addAll(entry.value);

        expect(() => Bed.fromMap(map), throwsA(isA<FormatException>()));
      });
    }

    test('rejects a missing active state instead of defaulting to true', () {
      final map = _bedMap()..remove('is_active');

      expect(() => Bed.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}
