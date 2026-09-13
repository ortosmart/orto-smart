import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/crop_variety_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _cropId = '22222222-2222-4222-8222-222222222222';
const _varietyId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _varietyMap({
  String cropId = _cropId,
  bool isActive = true,
}) {
  return {
    'id': _varietyId,
    'profile_id': _profileId,
    'crop_id': cropId,
    'name': 'San Marzano',
    'scientific_name': 'Solanum lycopersicum var. San Marzano',
    'description': 'Varietà di prova',
    'default_start_method': 'nursery_then_transplant',
    'row_spacing_cm': 80,
    'plant_spacing_cm': 40,
    'sowing_depth_cm': 1.5,
    'germination_days': 8,
    'harvest_days': 90,
    'min_temperature': 10,
    'optimal_temperature': 24,
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
    'yield_source_url': 'https://example.test/san-marzano',
    'yield_source_year': 2026,
    'yield_notes': 'Dati di prova',
    'is_active': isActive,
    'row_version': 5,
    'created_at': '2026-09-11T08:30:00+00:00',
    'updated_at': '2026-09-11T09:45:00+00:00',
  };
}

void main() {
  group('CropVarietyRepository', () {
    test('returns an empty list when no varieties are available', () async {
      final repository = CropVarietyRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [],
      );

      final varieties = await repository.getAllVarieties();

      expect(varieties, isEmpty);
    });

    test('maps the complete Catalog V1 CropVariety', () async {
      final repository = CropVarietyRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [_varietyMap()],
      );

      final variety = (await repository.getAllVarieties()).single;

      expect(variety.id, _varietyId);
      expect(variety.profileId, _profileId);
      expect(variety.cropId, _cropId);
      expect(variety.name, 'San Marzano');
      expect(variety.scientificName, 'Solanum lycopersicum var. San Marzano');
      expect(variety.description, 'Varietà di prova');

      expect(variety.defaultStartMethod, 'nursery_then_transplant');
      expect(variety.defaultPlantingMethod, 'nursery_then_transplant');

      expect(variety.rowSpacingCm, 80);
      expect(variety.plantSpacingCm, 40);
      expect(variety.sowingDepthCm, 1.5);
      expect(variety.germinationDays, 8);
      expect(variety.harvestDays, 90);

      expect(variety.minTemperature, 10);
      expect(variety.optimalTemperature, 24);

      expect(variety.waterRequirement, 'Regolare');
      expect(variety.waterRequirementValue, 2.5);
      expect(variety.waterRequirementBasis, 'per_plant');
      expect(variety.waterIntervalDays, 2);

      expect(variety.productivity, 'Alta');

      expect(variety.expectedYieldMin, 3);
      expect(variety.expectedYieldAvg, 4.5);
      expect(variety.expectedYieldMax, 6);
      expect(variety.expectedYieldUnit, 'kg_per_plant');

      expect(variety.yieldSourceName, 'Fonte di prova');
      expect(variety.yieldSourceUrl, 'https://example.test/san-marzano');
      expect(variety.yieldSourceYear, 2026);
      expect(variety.yieldNotes, 'Dati di prova');

      expect(variety.isActive, isTrue);
      expect(variety.rowVersion, 5);

      expect(variety.createdAt, DateTime.parse('2026-09-11T08:30:00+00:00'));
      expect(variety.updatedAt, DateTime.parse('2026-09-11T09:45:00+00:00'));
    });

    test('preserves numeric values returned as integers', () async {
      final map = _varietyMap()
        ..['water_requirement_value'] = 2
        ..['expected_yield_min'] = 3
        ..['expected_yield_avg'] = 4
        ..['expected_yield_max'] = 6;

      final repository = CropVarietyRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [map],
      );

      final variety = (await repository.getAllVarieties()).single;

      expect(variety.waterRequirementValue, 2.0);
      expect(variety.expectedYieldMin, 3.0);
      expect(variety.expectedYieldAvg, 4.0);
      expect(variety.expectedYieldMax, 6.0);
    });

    test('passes cropId and activeOnly to the loader', () async {
      final requests = <(String?, bool)>[];

      final repository = CropVarietyRepository.withLoader(({
        String? cropId,
        bool activeOnly = true,
      }) async {
        requests.add((cropId, activeOnly));
        return [];
      });

      await repository.getVarietiesByCrop(_cropId);
      await repository.getVarietiesByCrop(_cropId, activeOnly: false);
      await repository.getAllVarieties();
      await repository.getAllVarieties(activeOnly: false);

      expect(requests, [
        (_cropId, true),
        (_cropId, false),
        (null, true),
        (null, false),
      ]);
    });

    test('preserves an inactive CropVariety when requested', () async {
      final repository = CropVarietyRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [
          _varietyMap(isActive: false),
        ],
      );

      final variety = (await repository.getAllVarieties(
        activeOnly: false,
      )).single;

      expect(variety.isActive, isFalse);
    });

    test('preserves UUID cropId as String', () async {
      const otherCropId = '44444444-4444-4444-8444-444444444444';

      final repository = CropVarietyRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [
          _varietyMap(cropId: otherCropId),
        ],
      );

      final variety = (await repository.getAllVarieties()).single;

      expect(variety.cropId, otherCropId);
    });

    test('propagates loader failure without retrying', () async {
      var calls = 0;
      final failure = StateError('Synthetic loader failure');

      final repository = CropVarietyRepository.withLoader(({
        String? cropId,
        bool activeOnly = true,
      }) async {
        calls += 1;
        throw failure;
      });

      await expectLater(repository.getAllVarieties(), throwsA(same(failure)));

      expect(calls, 1);
    });
  });
}
