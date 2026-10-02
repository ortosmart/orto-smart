import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/botanical_taxon_write_result.dart';
import 'package:orto_app/data/repositories/botanical_taxon_repository.dart';

const _parentTaxonId = '11111111-1111-4111-8111-111111111111';
const _taxonId = '22222222-2222-4222-8222-222222222222';

Map<String, dynamic> _taxonMap({bool isActive = true}) => {
  'id': _taxonId,
  'parent_taxon_id': _parentTaxonId,
  'rank': 'SPECIES',
  'scientific_name': 'Solanum lycopersicum',
  'authorship': 'L.',
  'is_hybrid': false,
  'description': 'Specie botanica di riferimento per il pomodoro.',
  'is_active': isActive,
  'row_version': 3,
  'created_at': '2026-09-20T08:30:00+00:00',
  'updated_at': '2026-09-20T09:45:00+00:00',
};

Future<dynamic> _unusedRpc(
  String functionName,
  Map<String, dynamic> parameters,
) {
  throw StateError('RPC not expected');
}

void main() {
  group('BotanicalTaxonRepository.getTaxa', () {
    test('returns an empty list when the taxonomy is empty', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        _unusedRpc,
      );

      expect(await repository.getTaxa(), isEmpty);
    });

    test('maps a canonical botanical_taxa row', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [_taxonMap()],
        _unusedRpc,
      );

      final taxon = (await repository.getTaxa()).single;

      expect(taxon.id, _taxonId);
      expect(taxon.parentTaxonId, _parentTaxonId);
      expect(taxon.rank, 'SPECIES');
      expect(taxon.scientificName, 'Solanum lycopersicum');
      expect(taxon.authorship, 'L.');
      expect(taxon.isHybrid, isFalse);
      expect(taxon.isActive, isTrue);
      expect(taxon.rowVersion, 3);
    });

    test('preserves inactive Taxa when requested', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [_taxonMap(isActive: false)],
        _unusedRpc,
      );

      final taxon = (await repository.getTaxa(activeOnly: false)).single;

      expect(taxon.isActive, isFalse);
    });

    test('passes activeOnly to the loader', () async {
      final requested = <bool>[];

      final repository = BotanicalTaxonRepository.withProviders(({
        bool activeOnly = true,
      }) async {
        requested.add(activeOnly);
        return [];
      }, _unusedRpc);

      await repository.getTaxa();
      await repository.getTaxa(activeOnly: false);

      expect(requested, [true, false]);
    });

    test('rejects a malformed taxonomy row', () async {
      final map = _taxonMap()..remove('scientific_name');

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [map],
        _unusedRpc,
      );

      await expectLater(repository.getTaxa(), throwsFormatException);
    });
  });
  group('BotanicalTaxonRepository.createTaxon', () {
    test('invokes create_botanical_taxon and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          invokedFunction = functionName;
          invokedParameters = parameters;

          return {
            'status': 'created',
            'botanical_taxon_id': _taxonId,
            'row_version': 1,
            'created_at': '2026-10-02T09:00:00+00:00',
            'updated_at': '2026-10-02T09:00:00+00:00',
          };
        },
      );

      final result = await repository.createTaxon(
        parentTaxonId: _parentTaxonId,
        rank: 'SPECIES',
        scientificName: 'Solanum lycopersicum',
        authorship: 'L.',
        isHybrid: false,
        description: 'Pomodoro.',
      );

      expect(invokedFunction, 'create_botanical_taxon');
      expect(invokedParameters, {
        'target_parent_taxon_id': _parentTaxonId,
        'taxon_rank': 'SPECIES',
        'taxon_scientific_name': 'Solanum lycopersicum',
        'taxon_authorship': 'L.',
        'taxon_is_hybrid': false,
        'taxon_description': 'Pomodoro.',
      });

      expect(result, isA<BotanicalTaxonCreated>());

      final created = result as BotanicalTaxonCreated;
      expect(created.botanicalTaxonId, _taxonId);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 2, 9));
      expect(created.updatedAt, DateTime.utc(2026, 10, 2, 9));
    });

    test('maps expected non-success statuses', () async {
      final cases = <String, Type>{
        'forbidden': CreateBotanicalTaxonForbidden,
        'invalid_input': CreateBotanicalTaxonInvalidInput,
        'parent_not_found': CreateBotanicalTaxonParentNotFound,
        'dependency_inactive': CreateBotanicalTaxonDependencyInactive,
        'duplicate_identity': CreateBotanicalTaxonDuplicateIdentity,
      };

      for (final entry in cases.entries) {
        final repository = BotanicalTaxonRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.createTaxon(
          rank: 'SPECIES',
          scientificName: 'Solanum lycopersicum',
          isHybrid: false,
        );

        expect(result.runtimeType, entry.value);
      }
    });

    test('rejects an unknown status', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {'status': 'unexpected_status'},
      );

      await expectLater(
        repository.createTaxon(
          rank: 'SPECIES',
          scientificName: 'Solanum lycopersicum',
          isHybrid: false,
        ),
        throwsA(isA<BotanicalTaxonWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'created',
          'botanical_taxon_id': _taxonId,
          'row_version': 0,
          'created_at': '2026-10-02T09:00:00+00:00',
          'updated_at': '2026-10-02T09:00:00+00:00',
        },
      );

      await expectLater(
        repository.createTaxon(
          rank: 'SPECIES',
          scientificName: 'Solanum lycopersicum',
          isHybrid: false,
        ),
        throwsA(isA<BotanicalTaxonWriteProtocolException>()),
      );
    });
  });
  group('BotanicalTaxonRepository.updateTaxon', () {
    test('invokes update_botanical_taxon and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          invokedFunction = functionName;
          invokedParameters = parameters;

          return {
            'status': 'updated',
            'botanical_taxon_id': _taxonId,
            'row_version': 4,
            'updated_at': '2026-10-02T10:00:00+00:00',
          };
        },
      );

      final result = await repository.updateTaxon(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        parentTaxonId: _parentTaxonId,
        rank: 'SPECIES',
        scientificName: 'Solanum lycopersicum',
        authorship: 'L.',
        isHybrid: false,
        description: 'Pomodoro aggiornato.',
      );

      expect(invokedFunction, 'update_botanical_taxon');
      expect(invokedParameters, {
        'target_botanical_taxon_id': _taxonId,
        'expected_row_version': 3,
        'target_parent_taxon_id': _parentTaxonId,
        'taxon_rank': 'SPECIES',
        'taxon_scientific_name': 'Solanum lycopersicum',
        'taxon_authorship': 'L.',
        'taxon_is_hybrid': false,
        'taxon_description': 'Pomodoro aggiornato.',
      });

      expect(result, isA<BotanicalTaxonUpdated>());

      final updated = result as BotanicalTaxonUpdated;
      expect(updated.botanicalTaxonId, _taxonId);
      expect(updated.rowVersion, 4);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 2, 10));
    });

    test('maps unchanged', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'unchanged',
          'botanical_taxon_id': _taxonId,
          'row_version': 3,
          'updated_at': '2026-10-02T09:45:00+00:00',
        },
      );

      final result = await repository.updateTaxon(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        rank: 'SPECIES',
        scientificName: 'Solanum lycopersicum',
        isHybrid: false,
      );

      expect(result, isA<UpdateBotanicalTaxonUnchanged>());

      final unchanged = result as UpdateBotanicalTaxonUnchanged;
      expect(unchanged.botanicalTaxonId, _taxonId);
      expect(unchanged.rowVersion, 3);
    });

    test('maps detailed version conflict', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'botanical_taxon_id': _taxonId,
          'expected_row_version': 3,
          'current_row_version': 4,
          'updated_at': '2026-10-02T10:00:00+00:00',
        },
      );

      final result = await repository.updateTaxon(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        rank: 'SPECIES',
        scientificName: 'Solanum lycopersicum',
        isHybrid: false,
      );

      expect(result, isA<UpdateBotanicalTaxonVersionConflict>());

      final conflict = result as UpdateBotanicalTaxonVersionConflict;
      expect(conflict.botanicalTaxonId, _taxonId);
      expect(conflict.expectedRowVersion, 3);
      expect(conflict.currentRowVersion, 4);
      expect(conflict.updatedAt, DateTime.utc(2026, 10, 2, 10));
    });

    test('maps expected non-success statuses', () async {
      final cases = <String, Type>{
        'forbidden': UpdateBotanicalTaxonForbidden,
        'invalid_input': UpdateBotanicalTaxonInvalidInput,
        'not_found': UpdateBotanicalTaxonNotFound,
        'parent_not_found': UpdateBotanicalTaxonParentNotFound,
        'dependency_inactive': UpdateBotanicalTaxonDependencyInactive,
        'duplicate_identity': UpdateBotanicalTaxonDuplicateIdentity,
      };

      for (final entry in cases.entries) {
        final repository = BotanicalTaxonRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.updateTaxon(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          rank: 'SPECIES',
          scientificName: 'Solanum lycopersicum',
          isHybrid: false,
        );

        expect(result.runtimeType, entry.value);
      }
    });

    test('rejects incomplete version conflict payload', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'botanical_taxon_id': _taxonId,
          'expected_row_version': 3,
        },
      );

      await expectLater(
        repository.updateTaxon(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          rank: 'SPECIES',
          scientificName: 'Solanum lycopersicum',
          isHybrid: false,
        ),
        throwsA(isA<BotanicalTaxonWriteProtocolException>()),
      );
    });
  });
  group('BotanicalTaxonRepository.setTaxonActive', () {
    test(
      'invokes set_botanical_taxon_active and maps active_changed',
      () async {
        String? invokedFunction;
        Map<String, dynamic>? invokedParameters;

        final repository = BotanicalTaxonRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async {
            invokedFunction = functionName;
            invokedParameters = parameters;

            return {
              'status': 'active_changed',
              'botanical_taxon_id': _taxonId,
              'is_active': false,
              'row_version': 4,
              'updated_at': '2026-10-02T10:30:00+00:00',
            };
          },
        );

        final result = await repository.setTaxonActive(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          isActive: false,
        );

        expect(invokedFunction, 'set_botanical_taxon_active');
        expect(invokedParameters, {
          'target_botanical_taxon_id': _taxonId,
          'expected_row_version': 3,
          'taxon_is_active': false,
        });

        expect(result, isA<BotanicalTaxonActiveChanged>());

        final changed = result as BotanicalTaxonActiveChanged;
        expect(changed.botanicalTaxonId, _taxonId);
        expect(changed.isActive, isFalse);
        expect(changed.rowVersion, 4);
        expect(changed.updatedAt, DateTime.utc(2026, 10, 2, 10, 30));
      },
    );

    test('maps unchanged', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'unchanged',
          'botanical_taxon_id': _taxonId,
          'is_active': true,
          'row_version': 3,
          'updated_at': '2026-10-02T09:45:00+00:00',
        },
      );

      final result = await repository.setTaxonActive(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        isActive: true,
      );

      expect(result, isA<SetBotanicalTaxonActiveUnchanged>());

      final unchanged = result as SetBotanicalTaxonActiveUnchanged;
      expect(unchanged.botanicalTaxonId, _taxonId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 3);
    });

    test('maps detailed version conflict', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'botanical_taxon_id': _taxonId,
          'expected_row_version': 3,
          'current_row_version': 4,
          'updated_at': '2026-10-02T10:30:00+00:00',
        },
      );

      final result = await repository.setTaxonActive(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        isActive: false,
      );

      expect(result, isA<SetBotanicalTaxonActiveVersionConflict>());

      final conflict = result as SetBotanicalTaxonActiveVersionConflict;
      expect(conflict.botanicalTaxonId, _taxonId);
      expect(conflict.expectedRowVersion, 3);
      expect(conflict.currentRowVersion, 4);
      expect(conflict.updatedAt, DateTime.utc(2026, 10, 2, 10, 30));
    });

    test('maps version conflict without details', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {'status': 'version_conflict'},
      );

      final result = await repository.setTaxonActive(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        isActive: false,
      );

      expect(result, isA<SetBotanicalTaxonActiveVersionConflict>());

      final conflict = result as SetBotanicalTaxonActiveVersionConflict;
      expect(conflict.botanicalTaxonId, isNull);
      expect(conflict.expectedRowVersion, isNull);
      expect(conflict.currentRowVersion, isNull);
      expect(conflict.updatedAt, isNull);
    });

    test('rejects partial version conflict details', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'version_conflict',
          'botanical_taxon_id': _taxonId,
          'expected_row_version': 3,
        },
      );

      await expectLater(
        repository.setTaxonActive(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          isActive: false,
        ),
        throwsA(isA<BotanicalTaxonWriteProtocolException>()),
      );
    });

    test('maps active dependents including zero counts', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'active_dependents',
          'active_child_taxa_count': 2,
          'active_crops_count': 0,
        },
      );

      final result = await repository.setTaxonActive(
        botanicalTaxonId: _taxonId,
        expectedRowVersion: 3,
        isActive: false,
      );

      expect(result, isA<SetBotanicalTaxonActiveDependents>());

      final dependents = result as SetBotanicalTaxonActiveDependents;
      expect(dependents.activeChildTaxaCount, 2);
      expect(dependents.activeCropsCount, 0);
    });

    test('maps expected non-success statuses', () async {
      final cases = <String, Type>{
        'forbidden': SetBotanicalTaxonActiveForbidden,
        'invalid_input': SetBotanicalTaxonActiveInvalidInput,
        'not_found': SetBotanicalTaxonActiveNotFound,
        'dependency_inactive': SetBotanicalTaxonActiveDependencyInactive,
      };

      for (final entry in cases.entries) {
        final repository = BotanicalTaxonRepository.withProviders(
          ({bool activeOnly = true}) async => [],
          (functionName, parameters) async => {'status': entry.key},
        );

        final result = await repository.setTaxonActive(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          isActive: false,
        );

        expect(result.runtimeType, entry.value);
      }
    });

    test('rejects malformed active_dependents counts', () async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async => {
          'status': 'active_dependents',
          'active_child_taxa_count': -1,
          'active_crops_count': 0,
        },
      );

      await expectLater(
        repository.setTaxonActive(
          botanicalTaxonId: _taxonId,
          expectedRowVersion: 3,
          isActive: false,
        ),
        throwsA(isA<BotanicalTaxonWriteProtocolException>()),
      );
    });
  });
}
