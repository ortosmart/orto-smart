import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/harvest_purpose_write_result.dart';
import 'package:orto_app/data/repositories/harvest_purpose_repository.dart';

void main() {
  const contextId = '11111111-1111-4111-8111-111111111111';
  const createdAt = '2026-10-14T10:00:00Z';
  const updatedAt = '2026-10-14T11:00:00Z';

  Map<String, dynamic> contextRow({bool active = true, int version = 1}) => {
    'id': contextId,
    'code': 'OPEN_FIELD',
    'name': 'Pieno campo',
    'description': 'Coltivazione in pieno campo',
    'is_active': active,
    'row_version': version,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  HarvestPurposeRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return HarvestPurposeRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  group('HarvestPurposeRepository.read', () {
    test('reads active contexts by default', () async {
      bool? receivedFilter;

      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow()];
      });

      final result = await repository.getHarvestPurposes();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.code, 'OPEN_FIELD');
      expect(result.single.name, 'Pieno campo');
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive contexts', () async {
      bool? receivedFilter;

      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow(active: false)];
      });

      final result = await repository.getHarvestPurposes(activeOnly: false);

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = HarvestPurposeRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getHarvestPurposes(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = contextRow()..remove('code');

      final repository = HarvestPurposeRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getHarvestPurposes(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('HarvestPurposeRepository.create', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'harvest_purpose_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 1,
          'created_at': createdAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.createHarvestPurpose(
        code: 'OPEN_FIELD',
        name: 'Pieno campo',
        description: 'Descrizione',
      );

      expect(invokedFunction, 'create_harvest_purpose');
      expect(invokedParameters, {
        'context_code': 'OPEN_FIELD',
        'context_name': 'Pieno campo',
        'context_description': 'Descrizione',
      });

      expect(result, isA<HarvestPurposeCreated>());
      final created = result as HarvestPurposeCreated;
      expect(created.harvestPurposeId, contextId);
      expect(created.code, 'OPEN_FIELD');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({
        'status': 'forbidden',
      }).createHarvestPurpose(code: 'X', name: 'X');

      expect(result, isA<CreateHarvestPurposeForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({
        'status': 'invalid_input',
      }).createHarvestPurpose(code: 'X', name: 'X');

      expect(result, isA<CreateHarvestPurposeInvalidInput>());
    });

    test('maps duplicate_code', () async {
      final result = await repositoryForRpc({
        'status': 'duplicate_code',
      }).createHarvestPurpose(code: 'X', name: 'X');

      expect(result, isA<CreateHarvestPurposeDuplicateCode>());
    });

    test('rejects an unknown status', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'unexpected',
        }).createHarvestPurpose(code: 'X', name: 'X'),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'harvest_purpose_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }).createHarvestPurpose(code: 'X', name: 'X'),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });
  });

  group('HarvestPurposeRepository.update', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'harvest_purpose_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.updateHarvestPurpose(
        harvestPurposeId: contextId,
        expectedRowVersion: 1,
        name: 'Pieno campo aggiornato',
        description: null,
      );

      expect(invokedFunction, 'update_harvest_purpose');
      expect(invokedParameters, {
        'target_harvest_purpose_id': contextId,
        'expected_row_version': 1,
        'context_name': 'Pieno campo aggiornato',
        'context_description': null,
      });

      expect(result, isA<HarvestPurposeUpdated>());
      final updated = result as HarvestPurposeUpdated;
      expect(updated.harvestPurposeId, contextId);
      expect(updated.code, 'OPEN_FIELD');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'harvest_purpose_id': contextId,
            'row_version': 1,
          }).updateHarvestPurpose(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateHarvestPurposeUnchanged>());
      final unchanged = result as UpdateHarvestPurposeUnchanged;
      expect(unchanged.harvestPurposeId, contextId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).updateHarvestPurpose(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateHarvestPurposeVersionConflict>());
      expect((result as UpdateHarvestPurposeVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .updateHarvestPurpose(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateHarvestPurposeForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .updateHarvestPurpose(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateHarvestPurposeInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .updateHarvestPurpose(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateHarvestPurposeNotFound>());
    });

    test('rejects malformed version_conflict', () async {
      await expectLater(
        repositoryForRpc({'status': 'version_conflict'}).updateHarvestPurpose(
          harvestPurposeId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).updateHarvestPurpose(
          harvestPurposeId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });
  });

  group('HarvestPurposeRepository.setActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'harvest_purpose_id': contextId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setHarvestPurposeActive(
        harvestPurposeId: contextId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_harvest_purpose_active');
      expect(invokedParameters, {
        'target_harvest_purpose_id': contextId,
        'expected_row_version': 1,
        'context_is_active': false,
      });

      expect(result, isA<HarvestPurposeActiveChanged>());
      final changed = result as HarvestPurposeActiveChanged;
      expect(changed.harvestPurposeId, contextId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'harvest_purpose_id': contextId,
            'is_active': true,
            'row_version': 1,
          }).setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: true,
          );

      expect(result, isA<SetHarvestPurposeActiveUnchanged>());
      final unchanged = result as SetHarvestPurposeActiveUnchanged;
      expect(unchanged.harvestPurposeId, contextId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetHarvestPurposeActiveVersionConflict>());
      expect((result as SetHarvestPurposeActiveVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetHarvestPurposeActiveForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetHarvestPurposeActiveInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetHarvestPurposeActiveNotFound>());
    });

    test('maps active_dependents without invented details', () async {
      final result = await repositoryForRpc({'status': 'active_dependents'})
          .setHarvestPurposeActive(
            harvestPurposeId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetHarvestPurposeActiveDependents>());
    });

    test('rejects malformed active_changed payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'active_changed',
          'harvest_purpose_id': contextId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }).setHarvestPurposeActive(
          harvestPurposeId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).setHarvestPurposeActive(
          harvestPurposeId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });
  });

  group('HarvestPurposeRepository.protocol', () {
    test('rejects a non-map RPC response', () async {
      await expectLater(
        repositoryForRpc(null).createHarvestPurpose(code: 'X', name: 'X'),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });

    test('rejects RPC maps with non-string keys', () async {
      await expectLater(
        repositoryForRpc({
          1: 'invalid',
          'status': 'forbidden',
        }).createHarvestPurpose(code: 'X', name: 'X'),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });

    test('rejects invalid created timestamps', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'harvest_purpose_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 1,
          'created_at': 'not-a-date',
        }).createHarvestPurpose(code: 'X', name: 'X'),
        throwsA(isA<HarvestPurposeWriteProtocolException>()),
      );
    });
  });
}
