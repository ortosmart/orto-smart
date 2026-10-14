import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/production_context_write_result.dart';
import 'package:orto_app/data/repositories/production_context_repository.dart';

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

  ProductionContextRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return ProductionContextRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  group('ProductionContextRepository.read', () {
    test('reads active contexts by default', () async {
      bool? receivedFilter;

      final repository = ProductionContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow()];
      });

      final result = await repository.getProductionContexts();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.code, 'OPEN_FIELD');
      expect(result.single.name, 'Pieno campo');
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive contexts', () async {
      bool? receivedFilter;

      final repository = ProductionContextRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [contextRow(active: false)];
      });

      final result = await repository.getProductionContexts(activeOnly: false);

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = ProductionContextRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getProductionContexts(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = contextRow()..remove('code');

      final repository = ProductionContextRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getProductionContexts(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('ProductionContextRepository.create', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'production_context_id': contextId,
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

      final result = await repository.createProductionContext(
        code: 'OPEN_FIELD',
        name: 'Pieno campo',
        description: 'Descrizione',
      );

      expect(invokedFunction, 'create_production_context');
      expect(invokedParameters, {
        'context_code': 'OPEN_FIELD',
        'context_name': 'Pieno campo',
        'context_description': 'Descrizione',
      });

      expect(result, isA<ProductionContextCreated>());
      final created = result as ProductionContextCreated;
      expect(created.productionContextId, contextId);
      expect(created.code, 'OPEN_FIELD');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({
        'status': 'forbidden',
      }).createProductionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProductionContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({
        'status': 'invalid_input',
      }).createProductionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProductionContextInvalidInput>());
    });

    test('maps duplicate_code', () async {
      final result = await repositoryForRpc({
        'status': 'duplicate_code',
      }).createProductionContext(code: 'X', name: 'X');

      expect(result, isA<CreateProductionContextDuplicateCode>());
    });

    test('rejects an unknown status', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'unexpected',
        }).createProductionContext(code: 'X', name: 'X'),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });

    test('rejects a malformed created payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'production_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }).createProductionContext(code: 'X', name: 'X'),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });
  });

  group('ProductionContextRepository.update', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'production_context_id': contextId,
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

      final result = await repository.updateProductionContext(
        productionContextId: contextId,
        expectedRowVersion: 1,
        name: 'Pieno campo aggiornato',
        description: null,
      );

      expect(invokedFunction, 'update_production_context');
      expect(invokedParameters, {
        'target_production_context_id': contextId,
        'expected_row_version': 1,
        'context_name': 'Pieno campo aggiornato',
        'context_description': null,
      });

      expect(result, isA<ProductionContextUpdated>());
      final updated = result as ProductionContextUpdated;
      expect(updated.productionContextId, contextId);
      expect(updated.code, 'OPEN_FIELD');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'production_context_id': contextId,
            'row_version': 1,
          }).updateProductionContext(
            productionContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateProductionContextUnchanged>());
      final unchanged = result as UpdateProductionContextUnchanged;
      expect(unchanged.productionContextId, contextId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).updateProductionContext(
            productionContextId: contextId,
            expectedRowVersion: 1,
            name: 'Pieno campo',
          );

      expect(result, isA<UpdateProductionContextVersionConflict>());
      expect((result as UpdateProductionContextVersionConflict).rowVersion, 3);
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .updateProductionContext(
            productionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProductionContextForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .updateProductionContext(
            productionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProductionContextInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .updateProductionContext(
            productionContextId: contextId,
            expectedRowVersion: 1,
            name: 'X',
          );

      expect(result, isA<UpdateProductionContextNotFound>());
    });

    test('rejects malformed version_conflict', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'version_conflict',
        }).updateProductionContext(
          productionContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).updateProductionContext(
          productionContextId: contextId,
          expectedRowVersion: 1,
          name: 'X',
        ),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });
  });

  group('ProductionContextRepository.setActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'production_context_id': contextId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setProductionContextActive(
        productionContextId: contextId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_production_context_active');
      expect(invokedParameters, {
        'target_production_context_id': contextId,
        'expected_row_version': 1,
        'context_is_active': false,
      });

      expect(result, isA<ProductionContextActiveChanged>());
      final changed = result as ProductionContextActiveChanged;
      expect(changed.productionContextId, contextId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result =
          await repositoryForRpc({
            'status': 'unchanged',
            'production_context_id': contextId,
            'is_active': true,
            'row_version': 1,
          }).setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: true,
          );

      expect(result, isA<SetProductionContextActiveUnchanged>());
      final unchanged = result as SetProductionContextActiveUnchanged;
      expect(unchanged.productionContextId, contextId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result =
          await repositoryForRpc({
            'status': 'version_conflict',
            'row_version': 3,
          }).setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProductionContextActiveVersionConflict>());
      expect(
        (result as SetProductionContextActiveVersionConflict).rowVersion,
        3,
      );
    });

    test('maps forbidden', () async {
      final result = await repositoryForRpc({'status': 'forbidden'})
          .setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProductionContextActiveForbidden>());
    });

    test('maps invalid_input', () async {
      final result = await repositoryForRpc({'status': 'invalid_input'})
          .setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProductionContextActiveInvalidInput>());
    });

    test('maps not_found', () async {
      final result = await repositoryForRpc({'status': 'not_found'})
          .setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProductionContextActiveNotFound>());
    });

    test('maps active_dependents without invented details', () async {
      final result = await repositoryForRpc({'status': 'active_dependents'})
          .setProductionContextActive(
            productionContextId: contextId,
            expectedRowVersion: 1,
            isActive: false,
          );

      expect(result, isA<SetProductionContextActiveDependents>());
    });

    test('rejects malformed active_changed payload', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'active_changed',
          'production_context_id': contextId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }).setProductionContextActive(
          productionContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });

    test('rejects unknown status', () async {
      await expectLater(
        repositoryForRpc({'status': 'unexpected'}).setProductionContextActive(
          productionContextId: contextId,
          expectedRowVersion: 1,
          isActive: false,
        ),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });
  });

  group('ProductionContextRepository.protocol', () {
    test('rejects a non-map RPC response', () async {
      await expectLater(
        repositoryForRpc(null).createProductionContext(code: 'X', name: 'X'),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });

    test('rejects RPC maps with non-string keys', () async {
      await expectLater(
        repositoryForRpc({
          1: 'invalid',
          'status': 'forbidden',
        }).createProductionContext(code: 'X', name: 'X'),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });

    test('rejects invalid created timestamps', () async {
      await expectLater(
        repositoryForRpc({
          'status': 'created',
          'production_context_id': contextId,
          'code': 'OPEN_FIELD',
          'is_active': true,
          'row_version': 1,
          'created_at': 'not-a-date',
        }).createProductionContext(code: 'X', name: 'X'),
        throwsA(isA<ProductionContextWriteProtocolException>()),
      );
    });
  });
}
