import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _familyId = '22222222-2222-4222-8222-222222222222';
const _cropId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _cropMap({
  bool isActive = true,
  String? botanicalFamilyName = 'Solanaceae',
}) {
  return {
    'id': _cropId,
    'profile_id': _profileId,
    'botanical_family_id': _familyId,
    'name': 'Pomodoro',
    'scientific_name': 'Solanum lycopersicum',
    'description': 'Coltura di prova',
    'default_start_method': 'nursery_then_transplant',
    'row_spacing_cm': 80,
    'plant_spacing_cm': 40,
    'sowing_depth_cm': 1.5,
    'germination_days': 8,
    'harvest_days': 90,
    'min_temperature': 10,
    'optimal_temperature': 24,
    'rotation_seasons': 3,
    'water_requirement': 'Regolare',
    'water_requirement_value': 2.5,
    'water_requirement_basis': 'per_plant',
    'water_interval_days': 2,
    'productivity': 'Alta',
    'expected_yield_min': 3,
    'expected_yield_avg': 4.5,
    'expected_yield_max': 6,
    'expected_yield_unit': 'kg_per_plant',
    'yield_source_name': 'Fonte di prova',
    'yield_source_url': 'https://example.test/pomodoro',
    'yield_source_year': 2026,
    'yield_notes': 'Dati di prova',
    'is_active': isActive,
    'row_version': 4,
    'created_at': '2026-09-11T08:30:00+00:00',
    'updated_at': '2026-09-11T09:45:00+00:00',
    'botanical_family_name': botanicalFamilyName,
  };
}

void main() {
  group('CropRepository.getCrops', () {
    test('returns an empty list when no Crops are available', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      final crops = await repository.getCrops();

      expect(crops, isEmpty);
    });

    test('maps the complete Catalog V1 Crop', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [_cropMap()],
      );

      final crops = await repository.getCrops();

      expect(crops, hasLength(1));

      final crop = crops.single;

      expect(crop.id, _cropId);
      expect(crop.profileId, _profileId);
      expect(crop.botanicalFamilyId, _familyId);
      expect(crop.name, 'Pomodoro');
      expect(crop.scientificName, 'Solanum lycopersicum');
      expect(crop.description, 'Coltura di prova');

      expect(crop.defaultStartMethod, 'nursery_then_transplant');

      expect(crop.rowSpacingCm, 80);
      expect(crop.plantSpacingCm, 40);
      expect(crop.sowingDepthCm, 1.5);
      expect(crop.germinationDays, 8);
      expect(crop.harvestDays, 90);

      expect(crop.minTemperature, 10);
      expect(crop.optimalTemperature, 24);
      expect(crop.rotationSeasons, 3);

      expect(crop.waterRequirement, 'Regolare');
      expect(crop.waterRequirementValue, 2.5);
      expect(crop.waterRequirementBasis, 'per_plant');
      expect(crop.waterIntervalDays, 2);

      expect(crop.productivity, 'Alta');

      expect(crop.expectedYieldMin, 3);
      expect(crop.expectedYieldAvg, 4.5);
      expect(crop.expectedYieldMax, 6);
      expect(crop.expectedYieldUnit, 'kg_per_plant');

      expect(crop.yieldSourceName, 'Fonte di prova');
      expect(crop.yieldSourceUrl, 'https://example.test/pomodoro');
      expect(crop.yieldSourceYear, 2026);
      expect(crop.yieldNotes, 'Dati di prova');

      expect(crop.isActive, isTrue);
      expect(crop.rowVersion, 4);

      expect(crop.createdAt, DateTime.parse('2026-09-11T08:30:00+00:00'));
      expect(crop.updatedAt, DateTime.parse('2026-09-11T09:45:00+00:00'));

      expect(crop.botanicalFamilyName, 'Solanaceae');
      expect(crop.botanicalFamily, 'Solanaceae');
    });

    test('preserves numeric values returned as integers', () async {
      final map = _cropMap()
        ..['water_requirement_value'] = 2
        ..['expected_yield_min'] = 3
        ..['expected_yield_avg'] = 4
        ..['expected_yield_max'] = 6;

      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [map],
      );

      final crop = (await repository.getCrops()).single;

      expect(crop.waterRequirementValue, 2.0);
      expect(crop.expectedYieldMin, 3.0);
      expect(crop.expectedYieldAvg, 4.0);
      expect(crop.expectedYieldMax, 6.0);
    });

    test('preserves an inactive Crop when requested by loader', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [_cropMap(isActive: false)],
      );

      final crop = (await repository.getCrops(activeOnly: false)).single;

      expect(crop.isActive, isFalse);
    });

    test('passes activeOnly to the loader', () async {
      final requestedValues = <bool>[];

      final repository = CropRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        requestedValues.add(activeOnly);
        return [];
      });

      await repository.getCrops();
      await repository.getCrops(activeOnly: false);

      expect(requestedValues, [true, false]);
    });

    test('preserves a missing botanical family name', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [
          _cropMap(botanicalFamilyName: null),
        ],
      );

      final crop = (await repository.getCrops()).single;

      expect(crop.botanicalFamilyName, isNull);
      expect(crop.botanicalFamily, isNull);
      expect(crop.botanicalFamilyId, _familyId);
    });

    test('propagates loader failure without retrying', () async {
      var calls = 0;
      final failure = StateError('Synthetic loader failure');

      final repository = CropRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        calls += 1;
        throw failure;
      });

      await expectLater(repository.getCrops(), throwsA(same(failure)));

      expect(calls, 1);
    });
  });
}
