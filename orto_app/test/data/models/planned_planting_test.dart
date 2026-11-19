import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/planned_planting.dart';

const _plannedPlantingId = '11111111-1111-4111-8111-111111111111';
const _seasonPlanId = '22222222-2222-4222-8222-222222222222';
const _profileId = '33333333-3333-4333-8333-333333333333';
const _gardenId = '44444444-4444-4444-8444-444444444444';
const _seasonId = '55555555-5555-4555-8555-555555555555';
const _bedId = '66666666-6666-4666-8666-666666666666';
const _cropId = '77777777-7777-4777-8777-777777777777';
const _cultivarId = '88888888-8888-4888-8888-888888888888';
const _executedPlantingId = '99999999-9999-4999-8999-999999999999';

Map<String, dynamic> _plannedPlantingMap() {
  return {
    'id': _plannedPlantingId,
    'season_plan_id': _seasonPlanId,
    'profile_id': _profileId,
    'garden_id': _gardenId,
    'season_id': _seasonId,
    'bed_id': _bedId,
    'crop_id': _cropId,
    'cultivar_id': _cultivarId,
    'start_method': 'direct_rows',
    'planned_start_date': '2026-11-20',
    'planned_end_date': '2026-12-20',
    'start_position_cm': 100,
    'length_cm': 250,
    'occupied_width_cm': 40,
    'plant_spacing_cm': 30,
    'row_spacing_cm': 40,
    'rows_count': 2,
    'plants_count': 8,
    'seed_quantity_g': 12.5,
    'status': 'draft',
    'executed_planting_id': null,
    'notes': 'Pianificazione di test',
    'created_at': '2026-11-19T10:00:00+00:00',
    'updated_at': '2026-11-19T10:30:00+00:00',
    'row_version': 3,
  };
}

void main() {
  group('PlannedPlanting.fromMap', () {
    test('reads the complete authoritative planned planting record', () {
      final planting = PlannedPlanting.fromMap(_plannedPlantingMap());

      expect(planting.id, _plannedPlantingId);
      expect(planting.seasonPlanId, _seasonPlanId);
      expect(planting.profileId, _profileId);
      expect(planting.gardenId, _gardenId);
      expect(planting.seasonId, _seasonId);
      expect(planting.bedId, _bedId);
      expect(planting.cropId, _cropId);
      expect(planting.cultivarId, _cultivarId);

      expect(planting.startMethod, 'direct_rows');
      expect(planting.plannedStartDate, DateTime.utc(2026, 11, 20));
      expect(planting.plannedEndDate, DateTime.utc(2026, 12, 20));

      expect(planting.startPositionCm, 100);
      expect(planting.lengthCm, 250);
      expect(planting.occupiedWidthCm, 40);
      expect(planting.plantSpacingCm, 30);
      expect(planting.rowSpacingCm, 40);
      expect(planting.rowsCount, 2);
      expect(planting.plantsCount, 8);
      expect(planting.seedQuantityG, 12.5);

      expect(planting.status, 'draft');
      expect(planting.executedPlantingId, isNull);
      expect(planting.notes, 'Pianificazione di test');
      expect(planting.createdAt, DateTime.utc(2026, 11, 19, 10));
      expect(planting.updatedAt, DateTime.utc(2026, 11, 19, 10, 30));
      expect(planting.rowVersion, 3);
    });

    test('accepts nullable optional fields', () {
      final map = _plannedPlantingMap()
        ..['cultivar_id'] = null
        ..['planned_end_date'] = null
        ..['plant_spacing_cm'] = null
        ..['row_spacing_cm'] = null
        ..['rows_count'] = null
        ..['plants_count'] = null
        ..['seed_quantity_g'] = null
        ..['notes'] = null;

      final planting = PlannedPlanting.fromMap(map);

      expect(planting.cultivarId, isNull);
      expect(planting.plannedEndDate, isNull);
      expect(planting.plantSpacingCm, isNull);
      expect(planting.rowSpacingCm, isNull);
      expect(planting.rowsCount, isNull);
      expect(planting.plantsCount, isNull);
      expect(planting.seedQuantityG, isNull);
      expect(planting.notes, isNull);
    });

    test('converts integer seed quantity to double', () {
      final map = _plannedPlantingMap()..['seed_quantity_g'] = 12;

      expect(PlannedPlanting.fromMap(map).seedQuantityG, 12.0);
    });

    for (final status in PlannedPlanting.allowedStatuses) {
      test('accepts valid status $status', () {
        final map = _plannedPlantingMap()..['status'] = status;
        if (status == 'executed') {
          map['executed_planting_id'] = _executedPlantingId;
        }

        final planting = PlannedPlanting.fromMap(map);

        expect(planting.status, status);
        expect(
          planting.executedPlantingId,
          status == 'executed' ? _executedPlantingId : null,
        );
      });
    }

    for (final method in PlannedPlanting.allowedStartMethods) {
      test('accepts valid start method $method', () {
        final map = _plannedPlantingMap()..['start_method'] = method;

        expect(PlannedPlanting.fromMap(map).startMethod, method);
      });
    }

    test('accepts planned end date equal to start date', () {
      final map = _plannedPlantingMap()..['planned_end_date'] = '2026-11-20';

      expect(
        PlannedPlanting.fromMap(map).plannedEndDate,
        DateTime.utc(2026, 11, 20),
      );
    });

    final invalidCases = <String, Map<String, dynamic>>{
      'empty id': {'id': ''},
      'empty season plan id': {'season_plan_id': ''},
      'blank profile id': {'profile_id': '   '},
      'empty garden id': {'garden_id': ''},
      'empty season id': {'season_id': ''},
      'empty bed id': {'bed_id': ''},
      'empty crop id': {'crop_id': ''},
      'empty cultivar id': {'cultivar_id': ''},
      'empty notes': {'notes': ''},
      'invalid start method': {'start_method': 'manual'},
      'invalid status': {'status': 'finished'},
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
      'invalid start date format': {'planned_start_date': '20/11/2026'},
      'invalid calendar start date': {'planned_start_date': '2026-02-30'},
      'invalid calendar end date': {'planned_end_date': '2026-02-30'},
      'end date before start': {'planned_end_date': '2026-11-19'},
      'invalid created timestamp': {'created_at': 'invalid'},
      'invalid updated timestamp': {'updated_at': 'invalid'},
      'executed without planting id': {'status': 'executed'},
      'draft with executed planting id': {
        'executed_planting_id': _executedPlantingId,
      },
    };

    for (final entry in invalidCases.entries) {
      test('rejects ${entry.key}', () {
        final map = _plannedPlantingMap()..addAll(entry.value);

        expect(
          () => PlannedPlanting.fromMap(map),
          throwsA(isA<FormatException>()),
        );
      });
    }

    test('rejects missing planned_end_date field', () {
      final map = _plannedPlantingMap()..remove('planned_end_date');

      expect(
        () => PlannedPlanting.fromMap(map),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing executed_planting_id field', () {
      final map = _plannedPlantingMap()..remove('executed_planting_id');

      expect(
        () => PlannedPlanting.fromMap(map),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects missing optional numeric field', () {
      final map = _plannedPlantingMap()..remove('plants_count');

      expect(
        () => PlannedPlanting.fromMap(map),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
