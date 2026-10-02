import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/crop_cultivar_write_result.dart';
import 'package:orto_app/data/repositories/crop_cultivar_repository.dart';

const _cropId = '33333333-3333-4333-8333-333333333333';
const _cultivarId = '44444444-4444-4444-8444-444444444444';

Map<String, dynamic> _cultivarMap({bool isActive = true}) => {
  'cultivar_id': _cultivarId,
  'crop_id': _cropId,
  'crop_canonical_name': 'Pomodoro',
  'canonical_name': 'San Marzano',
  'verification_status': 'VERIFIED',
  'description': 'Cultivar di prova',
  'is_active': isActive,
  'row_version': 2,
  'created_at': '2026-09-11T08:30:00+00:00',
  'updated_at': '2026-09-11T09:45:00+00:00',
};

void main() {
  group('CropCultivarRepository', () {
    test('maps the canonical Cultivar read model', () async {
      final repository = CropCultivarRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [_cultivarMap()],
      );

      final cultivar = (await repository.getAllCultivars()).single;
      expect(cultivar.id, _cultivarId);
      expect(cultivar.cropId, _cropId);
      expect(cultivar.cropName, 'Pomodoro');
      expect(cultivar.name, 'San Marzano');
      expect(cultivar.verificationStatus, 'VERIFIED');
      expect(cultivar.isActive, isTrue);
      expect(cultivar.rowVersion, 2);
    });

    test('passes crop and active filters to the loader', () async {
      String? requestedCrop;
      bool? requestedActive;
      final repository = CropCultivarRepository.withLoader(({
        String? cropId,
        bool activeOnly = true,
      }) async {
        requestedCrop = cropId;
        requestedActive = activeOnly;
        return [];
      });

      await repository.getCultivarsByCrop(_cropId, activeOnly: false);
      expect(requestedCrop, _cropId);
      expect(requestedActive, isFalse);
    });

    test('rejects a malformed canonical response', () async {
      final map = _cultivarMap()..remove('cultivar_id');
      final repository = CropCultivarRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [map],
      );

      await expectLater(repository.getAllCultivars(), throwsFormatException);
    });
    group('createCultivar', () {
      test('invokes create_crop_cultivar with the canonical payload', () async {
        String? invokedFunction;
        Map<String, dynamic>? invokedParams;

        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async {
            invokedFunction = functionName;
            invokedParams = params;

            return {
              'status': 'created',
              'crop_cultivar_id': _cultivarId,
              'row_version': 1,
              'created_at': '2026-09-23T10:00:00+00:00',
              'updated_at': '2026-09-23T10:00:00+00:00',
            };
          },
        );

        await repository.createCultivar(
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
          description: 'Cultivar di prova',
        );

        expect(invokedFunction, 'create_crop_cultivar');
        expect(invokedParams, {
          'target_crop_id': _cropId,
          'cultivar_canonical_name': 'San Marzano',
          'cultivar_verification_status': 'VERIFIED',
          'cultivar_description': 'Cultivar di prova',
        });
      });

      test('maps a created response', () async {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => {
            'status': 'created',
            'crop_cultivar_id': _cultivarId,
            'row_version': 1,
            'created_at': '2026-09-23T10:00:00+00:00',
            'updated_at': '2026-09-23T10:01:00+00:00',
          },
        );

        final result = await repository.createCultivar(
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        );

        expect(result, isA<CropCultivarCreated>());

        final created = result as CropCultivarCreated;
        expect(created.cropCultivarId, _cultivarId);
        expect(created.rowVersion, 1);
        expect(created.createdAt, DateTime.parse('2026-09-23T10:00:00+00:00'));
        expect(created.updatedAt, DateTime.parse('2026-09-23T10:01:00+00:00'));
      });

      test('maps the documented non-success statuses', () async {
        final expectedTypes = <String, Type>{
          'forbidden': CreateCropCultivarForbidden,
          'invalid_input': CreateCropCultivarInvalidInput,
          'crop_not_found': CreateCropCultivarCropNotFound,
          'dependency_inactive': CreateCropCultivarDependencyInactive,
          'duplicate_canonical_name': CreateCropCultivarDuplicateCanonicalName,
        };

        for (final entry in expectedTypes.entries) {
          final repository = CropCultivarRepository.withProviders(
            loadCultivars: ({String? cropId, bool activeOnly = true}) async =>
                [],
            invokeRpc: (functionName, params) async => {'status': entry.key},
          );

          final result = await repository.createCultivar(
            cropId: _cropId,
            canonicalName: 'San Marzano',
            verificationStatus: 'VERIFIED',
          );

          expect(result.runtimeType, entry.value, reason: entry.key);
        }
      });

      test('rejects malformed or unknown RPC responses', () async {
        Future<void> expectProtocolFailure(dynamic response) async {
          final repository = CropCultivarRepository.withProviders(
            loadCultivars: ({String? cropId, bool activeOnly = true}) async =>
                [],
            invokeRpc: (functionName, params) async => response,
          );

          await expectLater(
            repository.createCultivar(
              cropId: _cropId,
              canonicalName: 'San Marzano',
              verificationStatus: 'VERIFIED',
            ),
            throwsA(isA<CropCultivarWriteProtocolException>()),
          );
        }

        await expectProtocolFailure(null);
        await expectProtocolFailure({'status': 'unexpected_status'});
        await expectProtocolFailure({
          'status': 'created',
          'crop_cultivar_id': _cultivarId,
          'row_version': 0,
          'created_at': '2026-09-23T10:00:00+00:00',
          'updated_at': '2026-09-23T10:00:00+00:00',
        });
      });
    });
  });
  group('updateCultivar', () {
    test('invokes update_crop_cultivar with the canonical payload', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParams;

      final repository = CropCultivarRepository.withProviders(
        loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
        invokeRpc: (functionName, params) async {
          invokedFunction = functionName;
          invokedParams = params;

          return {
            'status': 'updated',
            'crop_cultivar_id': _cultivarId,
            'row_version': 3,
            'updated_at': '2026-09-23T11:00:00+00:00',
          };
        },
      );

      await repository.updateCultivar(
        cropCultivarId: _cultivarId,
        expectedRowVersion: 2,
        cropId: _cropId,
        canonicalName: 'San Marzano 2',
        verificationStatus: 'PROVISIONAL',
        description: 'Descrizione aggiornata',
      );

      expect(invokedFunction, 'update_crop_cultivar');
      expect(invokedParams, {
        'target_crop_cultivar_id': _cultivarId,
        'expected_row_version': 2,
        'target_crop_id': _cropId,
        'cultivar_canonical_name': 'San Marzano 2',
        'cultivar_verification_status': 'PROVISIONAL',
        'cultivar_description': 'Descrizione aggiornata',
      });
    });

    test('maps updated and unchanged responses', () async {
      Future<UpdateCropCultivarResult> invoke(Map<String, dynamic> response) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => response,
        );

        return repository.updateCultivar(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        );
      }

      final updated = await invoke({
        'status': 'updated',
        'crop_cultivar_id': _cultivarId,
        'row_version': 3,
        'updated_at': '2026-09-23T11:00:00+00:00',
      });

      expect(updated, isA<CropCultivarUpdated>());
      expect((updated as CropCultivarUpdated).rowVersion, 3);

      final unchanged = await invoke({
        'status': 'unchanged',
        'crop_cultivar_id': _cultivarId,
        'row_version': 2,
        'updated_at': '2026-09-23T10:00:00+00:00',
      });

      expect(unchanged, isA<UpdateCropCultivarUnchanged>());
      expect((unchanged as UpdateCropCultivarUnchanged).rowVersion, 2);
    });

    test('maps both documented version_conflict forms', () async {
      Future<UpdateCropCultivarResult> invoke(Map<String, dynamic> response) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => response,
        );

        return repository.updateCultivar(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        );
      }

      final detailed = await invoke({
        'status': 'version_conflict',
        'crop_cultivar_id': _cultivarId,
        'expected_row_version': 2,
        'current_row_version': 3,
        'updated_at': '2026-09-23T11:00:00+00:00',
      });

      expect(detailed, isA<UpdateCropCultivarVersionConflict>());

      final detailedConflict = detailed as UpdateCropCultivarVersionConflict;
      expect(detailedConflict.cropCultivarId, _cultivarId);
      expect(detailedConflict.expectedRowVersion, 2);
      expect(detailedConflict.currentRowVersion, 3);
      expect(
        detailedConflict.updatedAt,
        DateTime.parse('2026-09-23T11:00:00+00:00'),
      );

      final race = await invoke({'status': 'version_conflict'});

      expect(race, isA<UpdateCropCultivarVersionConflict>());

      final raceConflict = race as UpdateCropCultivarVersionConflict;
      expect(raceConflict.cropCultivarId, isNull);
      expect(raceConflict.expectedRowVersion, isNull);
      expect(raceConflict.currentRowVersion, isNull);
      expect(raceConflict.updatedAt, isNull);
    });

    test('maps the documented non-success statuses', () async {
      final expectedTypes = <String, Type>{
        'forbidden': UpdateCropCultivarForbidden,
        'invalid_input': UpdateCropCultivarInvalidInput,
        'not_found': UpdateCropCultivarNotFound,
        'crop_not_found': UpdateCropCultivarCropNotFound,
        'dependency_inactive': UpdateCropCultivarDependencyInactive,
        'duplicate_canonical_name': UpdateCropCultivarDuplicateCanonicalName,
        'identity_in_use': UpdateCropCultivarIdentityInUse,
      };

      for (final entry in expectedTypes.entries) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => {'status': entry.key},
        );

        final result = await repository.updateCultivar(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        );

        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects partial version_conflict details', () async {
      final repository = CropCultivarRepository.withProviders(
        loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
        invokeRpc: (functionName, params) async => {
          'status': 'version_conflict',
          'crop_cultivar_id': _cultivarId,
          'expected_row_version': 2,
        },
      );

      await expectLater(
        repository.updateCultivar(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        ),
        throwsA(isA<CropCultivarWriteProtocolException>()),
      );
    });

    test('rejects an unknown update status', () async {
      final repository = CropCultivarRepository.withProviders(
        loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
        invokeRpc: (functionName, params) async => {
          'status': 'unexpected_status',
        },
      );

      await expectLater(
        repository.updateCultivar(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          cropId: _cropId,
          canonicalName: 'San Marzano',
          verificationStatus: 'VERIFIED',
        ),
        throwsA(isA<CropCultivarWriteProtocolException>()),
      );
    });
  });
  group('setCultivarActive', () {
    test(
      'invokes set_crop_cultivar_active with the canonical payload',
      () async {
        String? invokedFunction;
        Map<String, dynamic>? invokedParams;

        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async {
            invokedFunction = functionName;
            invokedParams = params;

            return {
              'status': 'active_changed',
              'crop_cultivar_id': _cultivarId,
              'is_active': false,
              'row_version': 3,
              'updated_at': '2026-09-23T12:00:00+00:00',
            };
          },
        );

        await repository.setCultivarActive(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          isActive: false,
        );

        expect(invokedFunction, 'set_crop_cultivar_active');
        expect(invokedParams, {
          'target_crop_cultivar_id': _cultivarId,
          'expected_row_version': 2,
          'cultivar_is_active': false,
        });
      },
    );

    test('maps active_changed and unchanged responses', () async {
      Future<SetCropCultivarActiveResult> invoke(
        Map<String, dynamic> response,
      ) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => response,
        );

        return repository.setCultivarActive(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          isActive: false,
        );
      }

      final changed = await invoke({
        'status': 'active_changed',
        'crop_cultivar_id': _cultivarId,
        'is_active': false,
        'row_version': 3,
        'updated_at': '2026-09-23T12:00:00+00:00',
      });

      expect(changed, isA<CropCultivarActiveChanged>());

      final activeChanged = changed as CropCultivarActiveChanged;
      expect(activeChanged.cropCultivarId, _cultivarId);
      expect(activeChanged.isActive, isFalse);
      expect(activeChanged.rowVersion, 3);

      final unchanged = await invoke({
        'status': 'unchanged',
        'crop_cultivar_id': _cultivarId,
        'is_active': false,
        'row_version': 2,
        'updated_at': '2026-09-23T11:00:00+00:00',
      });

      expect(unchanged, isA<SetCropCultivarActiveUnchanged>());

      final activeUnchanged = unchanged as SetCropCultivarActiveUnchanged;
      expect(activeUnchanged.cropCultivarId, _cultivarId);
      expect(activeUnchanged.isActive, isFalse);
      expect(activeUnchanged.rowVersion, 2);
    });

    test('maps both documented version_conflict forms', () async {
      Future<SetCropCultivarActiveResult> invoke(
        Map<String, dynamic> response,
      ) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => response,
        );

        return repository.setCultivarActive(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          isActive: false,
        );
      }

      final detailed = await invoke({
        'status': 'version_conflict',
        'crop_cultivar_id': _cultivarId,
        'expected_row_version': 2,
        'current_row_version': 3,
        'updated_at': '2026-09-23T12:00:00+00:00',
      });

      expect(detailed, isA<SetCropCultivarActiveVersionConflict>());

      final detailedConflict = detailed as SetCropCultivarActiveVersionConflict;
      expect(detailedConflict.cropCultivarId, _cultivarId);
      expect(detailedConflict.expectedRowVersion, 2);
      expect(detailedConflict.currentRowVersion, 3);

      final race = await invoke({'status': 'version_conflict'});

      expect(race, isA<SetCropCultivarActiveVersionConflict>());

      final raceConflict = race as SetCropCultivarActiveVersionConflict;
      expect(raceConflict.cropCultivarId, isNull);
      expect(raceConflict.expectedRowVersion, isNull);
      expect(raceConflict.currentRowVersion, isNull);
      expect(raceConflict.updatedAt, isNull);
    });

    test('maps the documented non-success statuses', () async {
      final expectedTypes = <String, Type>{
        'forbidden': SetCropCultivarActiveForbidden,
        'invalid_input': SetCropCultivarActiveInvalidInput,
        'not_found': SetCropCultivarActiveNotFound,
        'dependency_inactive': SetCropCultivarActiveDependencyInactive,
      };

      for (final entry in expectedTypes.entries) {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => {'status': entry.key},
        );

        final result = await repository.setCultivarActive(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          isActive: true,
        );

        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects partial version_conflict details', () async {
      final repository = CropCultivarRepository.withProviders(
        loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
        invokeRpc: (functionName, params) async => {
          'status': 'version_conflict',
          'crop_cultivar_id': _cultivarId,
          'expected_row_version': 2,
        },
      );

      await expectLater(
        repository.setCultivarActive(
          cropCultivarId: _cultivarId,
          expectedRowVersion: 2,
          isActive: false,
        ),
        throwsA(isA<CropCultivarWriteProtocolException>()),
      );
    });

    test('rejects malformed or unknown set-active responses', () async {
      Future<void> expectProtocolFailure(dynamic response) async {
        final repository = CropCultivarRepository.withProviders(
          loadCultivars: ({String? cropId, bool activeOnly = true}) async => [],
          invokeRpc: (functionName, params) async => response,
        );

        await expectLater(
          repository.setCultivarActive(
            cropCultivarId: _cultivarId,
            expectedRowVersion: 2,
            isActive: false,
          ),
          throwsA(isA<CropCultivarWriteProtocolException>()),
        );
      }

      await expectProtocolFailure({'status': 'unexpected_status'});

      await expectProtocolFailure({
        'status': 'active_changed',
        'crop_cultivar_id': _cultivarId,
        'is_active': 'false',
        'row_version': 3,
        'updated_at': '2026-09-23T12:00:00+00:00',
      });
    });
  });
}
