import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/planting.dart';

const _plantingId = '11111111-1111-4111-8111-111111111111';
const _profileId = '22222222-2222-4222-8222-222222222222';
const _gardenId = '33333333-3333-4333-8333-333333333333';
const _seasonId = '44444444-4444-4444-8444-444444444444';
const _bedId = '55555555-5555-4555-8555-555555555555';
const _cropId = '66666666-6666-4666-8666-666666666666';
const _varietyId = '77777777-7777-4777-8777-777777777777';

Map<String, dynamic> _plantingMap() {
  return {
    'id': _plantingId,
    'profile_id': _profileId,
    'garden_id': _gardenId,
    'season_id': _seasonId,
    'bed_id': _bedId,
    'crop_id': _cropId,
    'variety_id': _varietyId,
    'start_method': 'direct_rows',
    'start_date': '2026-09-16',
    'end_date': null,
    'start_position_cm': 100,
    'length_cm': 250,
    'plant_spacing_cm': 30,
    'row_spacing_cm': 40,
    'rows_count': 2,
    'occupied_width_cm': 40,
    'plants_count': 8,
    'seed_quantity_g': 12.5,
    'status': 'sown',
    'notes': 'Semina di prova',
    'created_at': '2026-09-16T10:00:00+00:00',
    'updated_at': '2026-09-16T10:30:00+00:00',
    'row_version': 3,
  };
}

void main() {
  group('Planting.fromMap', () {
    test('reads the complete authoritative planting record', () {
      final planting = Planting.fromMap(_plantingMap());

      expect(planting.id, _plantingId);
      expect(planting.profileId, _profileId);
      expect(planting.gardenId, _gardenId);
      expect(planting.seasonId, _seasonId);
      expect(planting.bedId, _bedId);
      expect(planting.cropId, _cropId);
      expect(planting.varietyId, _varietyId);

      expect(planting.startMethod, 'direct_rows');
      expect(planting.startDate, DateTime.utc(2026, 9, 16));
      expect(planting.endDate, isNull);

      expect(planting.startPositionCm, 100);
      expect(planting.lengthCm, 250);
      expect(planting.plantSpacingCm, 30);
      expect(planting.rowSpacingCm, 40);
      expect(planting.rowsCount, 2);
      expect(planting.occupiedWidthCm, 40);
      expect(planting.plantsCount, 8);
      expect(planting.seedQuantityG, 12.5);

      expect(planting.status, 'sown');
      expect(planting.notes, 'Semina di prova');

      expect(planting.createdAt, DateTime.utc(2026, 9, 16, 10));
      expect(planting.updatedAt, DateTime.utc(2026, 9, 16, 10, 30));
      expect(planting.rowVersion, 3);
    });

    test('accepts null optional fields', () {
      final map = _plantingMap()
        ..['variety_id'] = null
        ..['plant_spacing_cm'] = null
        ..['row_spacing_cm'] = null
        ..['rows_count'] = null
        ..['plants_count'] = null
        ..['seed_quantity_g'] = null
        ..['notes'] = null;

      final planting = Planting.fromMap(map);

      expect(planting.varietyId, isNull);
      expect(planting.plantSpacingCm, isNull);
      expect(planting.rowSpacingCm, isNull);
      expect(planting.rowsCount, isNull);
      expect(planting.plantsCount, isNull);
      expect(planting.seedQuantityG, isNull);
      expect(planting.notes, isNull);
    });

    test('converts integer seed quantity to double', () {
      final map = _plantingMap()..['seed_quantity_g'] = 12;

      expect(Planting.fromMap(map).seedQuantityG, 12.0);
    });

    test('accepts finished with end date', () {
      final map = _plantingMap()
        ..['status'] = 'finished'
        ..['end_date'] = '2026-10-20';

      final planting = Planting.fromMap(map);

      expect(planting.status, 'finished');
      expect(planting.endDate, DateTime.utc(2026, 10, 20));
    });

    test('accepts removed with end date equal to start date', () {
      final map = _plantingMap()
        ..['status'] = 'removed'
        ..['end_date'] = '2026-09-16';

      final planting = Planting.fromMap(map);

      expect(planting.status, 'removed');
      expect(planting.endDate, DateTime.utc(2026, 9, 16));
    });

    final invalidCases = <String, Map<String, dynamic>>{
      'empty id': {'id': ''},
      'blank profile id': {'profile_id': '   '},
      'empty garden id': {'garden_id': ''},
      'empty season id': {'season_id': ''},
      'empty bed id': {'bed_id': ''},
      'empty crop id': {'crop_id': ''},
      'empty variety id': {'variety_id': ''},
      'empty notes': {'notes': ''},
      'invalid start method': {'start_method': 'manual'},
      'invalid status': {'status': 'completed'},
      'negative start position': {'start_position_cm': -1},
      'zero length': {'length_cm': 0},
      'negative length': {'length_cm': -1},
      'zero occupied width': {'occupied_width_cm': 0},
      'negative occupied width': {'occupied_width_cm': -1},
      'zero row version': {'row_version': 0},
      'negative row version': {'row_version': -1},
      'zero plant spacing': {'plant_spacing_cm': 0},
      'negative plant spacing': {'plant_spacing_cm': -1},
      'zero row spacing': {'row_spacing_cm': 0},
      'negative row spacing': {'row_spacing_cm': -1},
      'zero rows count': {'rows_count': 0},
      'negative rows count': {'rows_count': -1},
      'zero plants count': {'plants_count': 0},
      'negative plants count': {'plants_count': -1},
      'zero seed quantity': {'seed_quantity_g': 0},
      'negative seed quantity': {'seed_quantity_g': -1},
      'non numeric seed quantity': {'seed_quantity_g': '12.5'},
      'invalid start date format': {'start_date': '16/09/2026'},
      'invalid calendar start date': {'start_date': '2026-02-30'},
      'invalid created timestamp': {'created_at': 'invalid'},
      'invalid updated timestamp': {'updated_at': 'invalid'},
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final map = _plantingMap()..addAll(entry.value);

        expect(() => Planting.fromMap(map), throwsA(isA<FormatException>()));
      });
    }

    test('rejects missing end_date field', () {
      final map = _plantingMap()..remove('end_date');

      expect(() => Planting.fromMap(map), throwsA(isA<FormatException>()));
    });

    test('rejects terminal status without end date', () {
      final map = _plantingMap()..['status'] = 'finished';

      expect(() => Planting.fromMap(map), throwsA(isA<FormatException>()));
    });

    test('rejects active status with end date', () {
      final map = _plantingMap()..['end_date'] = '2026-10-20';

      expect(() => Planting.fromMap(map), throwsA(isA<FormatException>()));
    });

    test('rejects end date before start date', () {
      final map = _plantingMap()
        ..['status'] = 'removed'
        ..['end_date'] = '2026-09-15';

      expect(() => Planting.fromMap(map), throwsA(isA<FormatException>()));
    });
  });
}
