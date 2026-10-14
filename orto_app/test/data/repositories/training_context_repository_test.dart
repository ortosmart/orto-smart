import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/training_context_write_result.dart';
import 'package:orto_app/data/repositories/training_context_repository.dart';

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

  TrainingContextRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return TrainingContextRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  group('TrainingContextRepository.read', () {
    test('reads active contexts by default', () async {
      bool? receivedFilter;

      final repository = TrainingContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow()];
      });

      final result = await repository.getTrainingContexts();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.code, 'OPEN_FIELD');
      expect(result.single.name, 'Pieno campo');
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive contexts', () async {
      bool? receivedFilter;

      final repository = TrainingContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow(active: false)];
      });

      final result = await repository.getTrainingContexts(activeOnly: false);

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = TrainingContextRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getTrainingContexts(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = contextRow()..remove('code');

      final repository = TrainingContextRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getTrainingContexts(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('TrainingContextRepository.create', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'training_context_id': contextId,
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

      final result = await repository.createTrainingContext(
        code: 'OPEN_FIELD',
        name: 'Pieno campo',
        description: 'Descrizione',
      );

      expect(invokedFunction, 'create_training_context');
      expect(invokedParameters, {
        'context_code': 'OPEN_FIELD',
        'context_name': 'Pieno campo',
        'context_description': 'Descrizione',
      });

      expect(result, isA<TrainingContextCreated>());
      final created = result as TrainingContextCreated;
      expect(created.trainingContextId, contextId);
      expect(created.code, 'OPEN_FIELD');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({
        'status': 'forbidden',
      }).createTrainingContext(code: 'X', name: 'X');

      expect(result, isA<CreateTrainingContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({
        'status': 'invalid_input',
      }).createTrainingContext(code: 'X', name: 'X');

      expect(result, isA<CreateTrainingContextInvalidInput>());
    });

    test('maps duplicate_code', () async {
      final result = await repositoryForRpc({
        'status': 'duplicate_code',
      }).createTrainingContext(code: 'X', name: 'X');

      expect(result, isA<CreateTrainingContextDuplicateCode>());
    });

    test('rejects an unknown status', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'unexpected',
        }).createTrainingContext(code: 'X', name: 'X'),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'training_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }).createTrainingContext(code: 'X', name: 'X'),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });
  });

  group('TrainingContextRepository.update', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'training_context_id': contextId,
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

      final result = await repository.updateTrainingContext(
        trainingContextId: contextId,
        expectedRowVersion: 1,
        name: 'Pieno campo aggiornato',
        description: null,
      );

      expect(invokedFunction, 'update_training_context');
      expect(invokedParameters, {
        'target_training_context_id': contextId,
        'expected_row_version': 1,
        'context_name': 'Pieno campo aggiornato',
        'context_description': null,
      });

      expect(result, isA<TrainingContextUpdated>());
      final updated = result as TrainingContextUpdated;
      expect(updated.trainingContextId, contextId);
      expect(updated.code, 'OPEN_FIELD');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'training_context_id': contextId,
            'row_version': 1,
          }).updateTrainingContext(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateTrainingContextUnchanged>());
      final unchanged = result as UpdateTrainingContextUnchanged;
      expect(unchanged.trainingContextId, contextId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).updateTrainingContext(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateTrainingContextVersionConflict>());
      expect((result as UpdateTrainingContextVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .updateTrainingContext(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateTrainingContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .updateTrainingContext(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateTrainingContextInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .updateTrainingContext(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateTrainingContextNotFound>());
    });

    test('rejects malformed version_conflict', () async {
      await expectLater(
        repositoryForRpc({'status': 'version_conflict'}).updateTrainingContext(
          trainingContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).updateTrainingContext(
          trainingContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });
  });

  group('TrainingContextRepository.setActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'training_context_id': contextId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setTrainingContextActive(
        trainingContextId: contextId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_training_context_active');
      expect(invokedParameters, {
        'target_training_context_id': contextId,
        'expected_row_version': 1,
        'context_is_active': false,
      });

      expect(result, isA<TrainingContextActiveChanged>());
      final changed = result as TrainingContextActiveChanged;
      expect(changed.trainingContextId, contextId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'training_context_id': contextId,
            'is_active': true,
            'row_version': 1,
          }).setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: true,
          );

      expect(result, isA<SetTrainingContextActiveUnchanged>());
      final unchanged = result as SetTrainingContextActiveUnchanged;
      expect(unchanged.trainingContextId, contextId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetTrainingContextActiveVersionConflict>());
      expect((result as SetTrainingContextActiveVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetTrainingContextActiveForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetTrainingContextActiveInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetTrainingContextActiveNotFound>());
    });

    test('maps active_dependents without invented details', () async {
      final result = await repositoryForRpc({'status': 'active_dependents'})
          .setTrainingContextActive(
            trainingContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetTrainingContextActiveDependents>());
    });

    test('rejects malformed active_changed payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'active_changed',
          'training_context_id': contextId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }).setTrainingContextActive(
          trainingContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).setTrainingContextActive(
          trainingContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });
  });

  group('TrainingContextRepository.protocol', () {
    test('rejects a non-map RPC response', () async {
      await expectLater(
        repositoryForRpc(null).createTrainingContext(code: 'X', name: 'X'),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });

    test('rejects RPC maps with non-string keys', () async {
      await expectLater(
        repositoryForRpc({
          1: 'invalid',
          'status': 'forbidden',
        }).createTrainingContext(code: 'X', name: 'X'),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });

    test('rejects invalid created timestamps', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'training_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 1,
          'created_at': 'not-a-date',
        }).createTrainingContext(code: 'X', name: 'X'),
        throwsA(isA<TrainingContextWriteProtocolException>()),
      );
    });
  });
}
