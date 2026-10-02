import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/catalog_crop_write_result.dart';
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
      expect(crop.taxonId, _taxonId);
      expect(crop.taxonRank, 'SPECIES');
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
  group('CropRepository.createCrop', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          invokedFunction = functionName;
          invokedParameters = parameters;

          return {
            'status': 'created',
            'catalog_crop_id': _cropId,
            'row_version': 1,
            'created_at': '2026-10-02T08:00:00+00:00',
            'updated_at': '2026-10-02T08:00:00+00:00',
          };
        },
      );

      final result = await repository.createCrop(
        taxonId: _taxonId,
        canonicalName: 'Pomodoro',
        description: 'Coltura di prova',
      );

      expect(invokedFunction, 'create_catalog_crop');
      expect(invokedParameters, {
        'target_taxon_id': _taxonId,
        'crop_canonical_name': 'Pomodoro',
        'crop_description': 'Coltura di prova',
      });

      expect(result, isA<CatalogCropCreated>());

      final created = result as CatalogCropCreated;
      expect(created.catalogCropId, _cropId);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 2, 8));
      expect(created.updatedAt, DateTime.utc(2026, 10, 2, 8));
    });

    test('maps non-success statuses', () async {
      const cases = <String, Type>{
        'forbidden': CreateCatalogCropForbidden,
        'invalid_input': CreateCatalogCropInvalidInput,
        'taxon_not_found': CreateCatalogCropTaxonNotFound,
        'dependency_inactive': CreateCatalogCropDependencyInactive,
        'duplicate_canonical_name': CreateCatalogCropDuplicateCanonicalName,
      };

      for (final entry in cases.entries) {
        final repository = CropRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.createCrop(
          taxonId: _taxonId,
          canonicalName: 'Pomodoro',
        );

        expect(result.runtimeType, entry.value);
      }
    });

    test('rejects an unknown status', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {'status': 'unexpected'},
      );

      await expectLater(
        repository.createCrop(taxonId: _taxonId, canonicalName: 'Pomodoro'),
        throwsA(isA<CatalogCropWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'created',
          'catalog_crop_id': _cropId,
          'row_version': 0,
          'created_at': '2026-10-02T08:00:00+00:00',
          'updated_at': '2026-10-02T08:00:00+00:00',
        },
      );

      await expectLater(
        repository.createCrop(taxonId: _taxonId, canonicalName: 'Pomodoro'),
        throwsA(isA<CatalogCropWriteProtocolException>()),
      );
    });
  });
  group('CropRepository.updateCrop', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          invokedFunction = functionName;
          invokedParameters = parameters;

          return {
            'status': 'updated',
            'catalog_crop_id': _cropId,
            'row_version': 5,
            'updated_at': '2026-10-02T09:00:00+00:00',
          };
        },
      );

      final result = await repository.updateCrop(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        taxonId: _taxonId,
        canonicalName: 'Pomodoro',
        description: 'Descrizione aggiornata',
      );

      expect(invokedFunction, 'update_catalog_crop');
      expect(invokedParameters, {
        'target_catalog_crop_id': _cropId,
        'expected_row_version': 4,
        'target_taxon_id': _taxonId,
        'crop_canonical_name': 'Pomodoro',
        'crop_description': 'Descrizione aggiornata',
      });

      expect(result, isA<CatalogCropUpdated>());

      final updated = result as CatalogCropUpdated;
      expect(updated.catalogCropId, _cropId);
      expect(updated.rowVersion, 5);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps unchanged', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'unchanged',
          'catalog_crop_id': _cropId,
          'row_version': 4,
          'updated_at': '2026-10-02T09:00:00+00:00',
        },
      );

      final result = await repository.updateCrop(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        taxonId: _taxonId,
        canonicalName: 'Pomodoro',
      );

      expect(result, isA<UpdateCatalogCropUnchanged>());

      final unchanged = result as UpdateCatalogCropUnchanged;
      expect(unchanged.catalogCropId, _cropId);
      expect(unchanged.rowVersion, 4);
      expect(unchanged.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps detailed version conflict', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'catalog_crop_id': _cropId,
          'expected_row_version': 4,
          'current_row_version': 5,
          'updated_at': '2026-10-02T09:00:00+00:00',
        },
      );

      final result = await repository.updateCrop(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        taxonId: _taxonId,
        canonicalName: 'Pomodoro',
      );

      expect(result, isA<UpdateCatalogCropVersionConflict>());

      final conflict = result as UpdateCatalogCropVersionConflict;
      expect(conflict.catalogCropId, _cropId);
      expect(conflict.expectedRowVersion, 4);
      expect(conflict.currentRowVersion, 5);
      expect(conflict.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps version conflict without details', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {'status': 'version_conflict'},
      );

      final result = await repository.updateCrop(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        taxonId: _taxonId,
        canonicalName: 'Pomodoro',
      );

      final conflict = result as UpdateCatalogCropVersionConflict;
      expect(conflict.catalogCropId, isNull);
      expect(conflict.expectedRowVersion, isNull);
      expect(conflict.currentRowVersion, isNull);
      expect(conflict.updatedAt, isNull);
    });

    test('rejects a partial version conflict payload', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'catalog_crop_id': _cropId,
        },
      );

      await expectLater(
        repository.updateCrop(
          catalogCropId: _cropId,
          expectedRowVersion: 4,
          taxonId: _taxonId,
          canonicalName: 'Pomodoro',
        ),
        throwsA(isA<CatalogCropWriteProtocolException>()),
      );
    });

    test('maps non-success statuses', () async {
      const cases = <String, Type>{
        'forbidden': UpdateCatalogCropForbidden,
        'invalid_input': UpdateCatalogCropInvalidInput,
        'not_found': UpdateCatalogCropNotFound,
        'taxon_not_found': UpdateCatalogCropTaxonNotFound,
        'dependency_inactive': UpdateCatalogCropDependencyInactive,
        'duplicate_canonical_name': UpdateCatalogCropDuplicateCanonicalName,
      };

      for (final entry in cases.entries) {
        final repository = CropRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.updateCrop(
          catalogCropId: _cropId,
          expectedRowVersion: 4,
          taxonId: _taxonId,
          canonicalName: 'Pomodoro',
        );

        expect(result.runtimeType, entry.value);
      }
    });
  });
  group('CropRepository.setCropActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          invokedFunction = functionName;
          invokedParameters = parameters;

          return {
            'status': 'active_changed',
            'catalog_crop_id': _cropId,
            'is_active': false,
            'row_version': 5,
            'updated_at': '2026-10-02T09:00:00+00:00',
          };
        },
      );

      final result = await repository.setCropActive(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        isActive: false,
      );

      expect(invokedFunction, 'set_catalog_crop_active');
      expect(invokedParameters, {
        'target_catalog_crop_id': _cropId,
        'expected_row_version': 4,
        'crop_is_active': false,
      });

      expect(result, isA<CatalogCropActiveChanged>());

      final changed = result as CatalogCropActiveChanged;
      expect(changed.catalogCropId, _cropId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 5);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps unchanged', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'unchanged',
          'catalog_crop_id': _cropId,
          'is_active': true,
          'row_version': 4,
          'updated_at': '2026-10-02T09:00:00+00:00',
        },
      );

      final result = await repository.setCropActive(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        isActive: true,
      );

      expect(result, isA<SetCatalogCropActiveUnchanged>());

      final unchanged = result as SetCatalogCropActiveUnchanged;
      expect(unchanged.catalogCropId, _cropId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 4);
      expect(unchanged.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps detailed version conflict', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'catalog_crop_id': _cropId,
          'expected_row_version': 4,
          'current_row_version': 5,
          'updated_at': '2026-10-02T09:00:00+00:00',
        },
      );

      final result = await repository.setCropActive(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        isActive: false,
      );

      expect(result, isA<SetCatalogCropActiveVersionConflict>());

      final conflict = result as SetCatalogCropActiveVersionConflict;
      expect(conflict.catalogCropId, _cropId);
      expect(conflict.expectedRowVersion, 4);
      expect(conflict.currentRowVersion, 5);
      expect(conflict.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps version conflict without details', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {'status': 'version_conflict'},
      );

      final result = await repository.setCropActive(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        isActive: false,
      );

      final conflict = result as SetCatalogCropActiveVersionConflict;
      expect(conflict.catalogCropId, isNull);
      expect(conflict.expectedRowVersion, isNull);
      expect(conflict.currentRowVersion, isNull);
      expect(conflict.updatedAt, isNull);
    });

    test('rejects a partial version conflict payload', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'catalog_crop_id': _cropId,
        },
      );

      await expectLater(
        repository.setCropActive(
          catalogCropId: _cropId,
          expectedRowVersion: 4,
          isActive: false,
        ),
        throwsA(isA<CatalogCropWriteProtocolException>()),
      );
    });

    test('maps active_dependents', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'active_dependents',
          'dependent_type': 'crop_cultivars',
          'dependent_count': 3,
        },
      );

      final result = await repository.setCropActive(
        catalogCropId: _cropId,
        expectedRowVersion: 4,
        isActive: false,
      );

      expect(result, isA<SetCatalogCropActiveDependents>());

      final dependents = result as SetCatalogCropActiveDependents;
      expect(dependents.dependentType, 'crop_cultivars');
      expect(dependents.dependentCount, 3);
    });

    test('maps non-success statuses', () async {
      const cases = <String, Type>{
        'forbidden': SetCatalogCropActiveForbidden,
        'invalid_input': SetCatalogCropActiveInvalidInput,
        'not_found': SetCatalogCropActiveNotFound,
        'dependency_inactive': SetCatalogCropActiveDependencyInactive,
      };

      for (final entry in cases.entries) {
        final repository = CropRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.setCropActive(
          catalogCropId: _cropId,
          expectedRowVersion: 4,
          isActive: false,
        );

        expect(result.runtimeType, entry.value);
      }
    });

    test('rejects malformed active_dependents count', () async {
      final repository = CropRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'active_dependents',
          'dependent_type': 'crop_cultivars',
          'dependent_count': -1,
        },
      );

      await expectLater(
        repository.setCropActive(
          catalogCropId: _cropId,
          expectedRowVersion: 4,
          isActive: false,
        ),
        throwsA(isA<CatalogCropWriteProtocolException>()),
      );
    });
  });
}
