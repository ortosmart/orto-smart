import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/protection_context_write_result.dart';
import 'package:orto_app/data/repositories/protection_context_repository.dart';

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

  ProtectionContextRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return ProtectionContextRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  group('ProtectionContextRepository.read', () {
    test('reads active contexts by default', () async {
      bool? receivedFilter;

      final repository = ProtectionContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow()];
      });

      final result = await repository.getProtectionContexts();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.code, 'OPEN_FIELD');
      expect(result.single.name, 'Pieno campo');
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive contexts', () async {
      bool? receivedFilter;

      final repository = ProtectionContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow(active: false)];
      });

      final result = await repository.getProtectionContexts(activeOnly: false);

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = ProtectionContextRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getProtectionContexts(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = contextRow()..remove('code');

      final repository = ProtectionContextRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getProtectionContexts(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ProtectionContextRepository.create', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'protection_context_id': contextId,
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

      final result = await repository.createProtectionContext(
        code: 'OPEN_FIELD',
        name: 'Pieno campo',
        description: 'Descrizione',
      );

      expect(invokedFunction, 'create_protection_context');
      expect(invokedParameters, {
        'context_code': 'OPEN_FIELD',
        'context_name': 'Pieno campo',
        'context_description': 'Descrizione',
      });

      expect(result, isA<ProtectionContextCreated>());
      final created = result as ProtectionContextCreated;
      expect(created.protectionContextId, contextId);
      expect(created.code, 'OPEN_FIELD');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({
        'status': 'forbidden',
      }).createProtectionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProtectionContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({
        'status': 'invalid_input',
      }).createProtectionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProtectionContextInvalidInput>());
    });

    test('maps duplicate_code', () async {
      final result = await repositoryForRpc({
        'status': 'duplicate_code',
      }).createProtectionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProtectionContextDuplicateCode>());
    });

    test('rejects an unknown status', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'unexpected',
        }).createProtectionContext(code: 'X', name: 'X'),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'protection_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }).createProtectionContext(code: 'X', name: 'X'),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });
  });

  group('ProtectionContextRepository.update', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'protection_context_id': contextId,
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

      final result = await repository.updateProtectionContext(
        protectionContextId: contextId,
        expectedRowVersion: 1,
        name: 'Pieno campo aggiornato',
        description: null,
      );

      expect(invokedFunction, 'update_protection_context');
      expect(invokedParameters, {
        'target_protection_context_id': contextId,
        'expected_row_version': 1,
        'context_name': 'Pieno campo aggiornato',
        'context_description': null,
      });

      expect(result, isA<ProtectionContextUpdated>());
      final updated = result as ProtectionContextUpdated;
      expect(updated.protectionContextId, contextId);
      expect(updated.code, 'OPEN_FIELD');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'protection_context_id': contextId,
            'row_version': 1,
          }).updateProtectionContext(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateProtectionContextUnchanged>());
      final unchanged = result as UpdateProtectionContextUnchanged;
      expect(unchanged.protectionContextId, contextId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).updateProtectionContext(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateProtectionContextVersionConflict>());
      expect((result as UpdateProtectionContextVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .updateProtectionContext(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProtectionContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .updateProtectionContext(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProtectionContextInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .updateProtectionContext(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProtectionContextNotFound>());
    });

    test('rejects malformed version_conflict', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'version_conflict',
        }).updateProtectionContext(
          protectionContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).updateProtectionContext(
          protectionContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });
  });

  group('ProtectionContextRepository.setActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'protection_context_id': contextId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setProtectionContextActive(
        protectionContextId: contextId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_protection_context_active');
      expect(invokedParameters, {
        'target_protection_context_id': contextId,
        'expected_row_version': 1,
        'context_is_active': false,
      });

      expect(result, isA<ProtectionContextActiveChanged>());
      final changed = result as ProtectionContextActiveChanged;
      expect(changed.protectionContextId, contextId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'protection_context_id': contextId,
            'is_active': true,
            'row_version': 1,
          }).setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: true,
          );

      expect(result, isA<SetProtectionContextActiveUnchanged>());
      final unchanged = result as SetProtectionContextActiveUnchanged;
      expect(unchanged.protectionContextId, contextId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProtectionContextActiveVersionConflict>());
      expect(
        (result as SetProtectionContextActiveVersionConflict).rowVersion,
        3,
      );
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProtectionContextActiveForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProtectionContextActiveInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProtectionContextActiveNotFound>());
    });

    test('maps active_dependents without invented details', () async {
      final result = await repositoryForRpc({'status': 'active_dependents'})
          .setProtectionContextActive(
            protectionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProtectionContextActiveDependents>());
    });

    test('rejects malformed active_changed payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'active_changed',
          'protection_context_id': contextId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }).setProtectionContextActive(
          protectionContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).setProtectionContextActive(
          protectionContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });
  });

  group('ProtectionContextRepository.protocol', () {
    test('rejects a non-map RPC response', () async {
      await expectLater(
        repositoryForRpc(null).createProtectionContext(code: 'X', name: 'X'),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });

    test('rejects RPC maps with non-string keys', () async {
      await expectLater(
        repositoryForRpc({
          1: 'invalid',
          'status': 'forbidden',
        }).createProtectionContext(code: 'X', name: 'X'),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });

    test('rejects invalid created timestamps', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'protection_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 1,
          'created_at': 'not-a-date',
        }).createProtectionContext(code: 'X', name: 'X'),
        throwsA(isA<ProtectionContextWriteProtocolException>()),
      );
    });
  });
}
