import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';

const _familyId = '22222222-2222-4222-8222-222222222222';
const _taxonId = '22222222-2222-4222-8222-222222222223';
const _cropId = '33333333-3333-4333-8333-333333333333';

Map<String, dynamic> _cropMap({
  bool isActive = true,
  String? familyName = 'Solanaceae',
}) => {
  'crop_id': _cropId,
  'canonical_name': 'Pomodoro',
  'description': 'Coltura di prova',
  'is_active': isActive,
  'row_version': 4,
  'created_at': '2026-09-11T08:30:00+00:00',
  'updated_at': '2026-09-11T09:45:00+00:00',
  'taxon_id': _taxonId,
  'taxon_rank': 'SPECIES',
  'taxon_scientific_name': 'Solanum lycopersicum',
  'family_taxon_id': _familyId,
  'family_scientific_name': familyName,
};

void main() {
  group('CropRepository.getCrops', () {
    test('returns an empty list when the global catalog is empty', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );
      expect(await repository.getCrops(), isEmpty);
    });

    test('maps the canonical Crop read model', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [_cropMap()],
      );

      final crop = (await repository.getCrops()).single;
      expect(crop.id, _cropId);
      expect(crop.profileId, isNull);
      expect(crop.botanicalFamilyId, _familyId);
      expect(crop.name, 'Pomodoro');
      expect(crop.scientificName, 'Solanum lycopersicum');
      expect(crop.description, 'Coltura di prova');
      expect(crop.botanicalFamilyName, 'Solanaceae');
      expect(crop.botanicalFamily, 'Solanaceae');
      expect(crop.isActive, isTrue);
      expect(crop.rowVersion, 4);
      expect(crop.createdAt, DateTime.utc(2026, 9, 11, 8, 30));
      expect(crop.updatedAt, DateTime.utc(2026, 9, 11, 9, 45));
    });

    test('preserves inactive Crops when requested', () async {
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [_cropMap(isActive: false)],
      );
      expect(
        (await repository.getCrops(activeOnly: false)).single.isActive,
        isFalse,
      );
    });

    test('passes activeOnly to the loader', () async {
      final requested = <bool>[];
      final repository = CropRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        requested.add(activeOnly);
        return [];
      });

      await repository.getCrops();
      await repository.getCrops(activeOnly: false);
      expect(requested, [true, false]);
    });

    test('accepts a Crop without a resolved family', () async {
      final map = _cropMap(familyName: null)..['family_taxon_id'] = null;
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [map],
      );

      final crop = (await repository.getCrops()).single;
      expect(crop.botanicalFamilyId, isNull);
      expect(crop.botanicalFamilyName, isNull);
    });

    test('rejects a malformed canonical response', () async {
      final map = _cropMap()..remove('crop_id');
      final repository = CropRepository.withLoader(
        ({bool activeOnly = true}) async => [map],
      );
      await expectLater(repository.getCrops(), throwsFormatException);
    });
  });
}
