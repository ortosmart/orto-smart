
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/agronomic_parameter_write_result.dart';
import 'package:orto_app/data/repositories/agronomic_parameter_repository.dart';

void main() {
  const parameterId = '11111111-1111-4111-8111-111111111111';
  const unitId = '22222222-2222-4222-8222-222222222222';
  const createdAt = '2026-10-14T10:00:00Z';
  const updatedAt = '2026-10-14T11:00:00Z';

  Map<String, dynamic> parameterRow({
    bool active = true,
    int version = 1,
  }) => {
    'id': parameterId,
    'code': 'GERMINATION_DAYS',
    'name': 'Giorni di germinazione',
    'description': 'Durata indicativa della germinazione',
    'value_schema': 'NUMERIC_SCALAR',
    'knowledge_scope': 'INTRINSIC',
    'quantity_kind': 'TIME',
    'canonical_unit_id': unitId,
    'allows_crop': true,
    'allows_cultivar': true,
    'allows_production_context': false,
    'allows_protection_context': false,
    'allows_training_context': false,
    'allows_harvest_purpose': false,
    'is_active': active,
    'row_version': version,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  AgronomicParameterRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return AgronomicParameterRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  Future<CreateAgronomicParameterResult> createWith(
    dynamic response,
  ) {
    return repositoryForRpc(response).createAgronomicParameter(
      code: 'GERMINATION_DAYS',
      name: 'Giorni di germinazione',
      description: 'Durata indicativa della germinazione',
      valueSchema: 'NUMERIC_SCALAR',
      knowledgeScope: 'INTRINSIC',
      quantityKind: 'TIME',
      canonicalUnitId: unitId,
      allowsCrop: true,
      allowsCultivar: true,
      allowsProductionContext: false,
      allowsProtectionContext: false,
      allowsTrainingContext: false,
      allowsHarvestPurpose: false,
    );
  }

  Future<UpdateAgronomicParameterResult> updateWith(
    dynamic response,
  ) {
    return repositoryForRpc(response).updateAgronomicParameter(
      agronomicParameterId: parameterId,
      expectedRowVersion: 1,
      code: 'GERMINATION_DAYS',
      name: 'Giorni di germinazione',
      description: null,
      valueSchema: 'NUMERIC_SCALAR',
      knowledgeScope: 'INTRINSIC',
      quantityKind: 'TIME',
      canonicalUnitId: unitId,
      allowsCrop: true,
      allowsCultivar: true,
      allowsProductionContext: false,
      allowsProtectionContext: false,
      allowsTrainingContext: false,
      allowsHarvestPurpose: false,
    );
  }

  Future<SetAgronomicParameterActiveResult> setActiveWith(
    dynamic response,
  ) {
    return repositoryForRpc(response).setAgronomicParameterActive(
      agronomicParameterId: parameterId,
      expectedRowVersion: 1,
      isActive: false,
    );
  }

  group('AgronomicParameterRepository.read', () {
    test('reads active parameters by default', () async {
      bool? receivedFilter;

      final repository = AgronomicParameterRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [parameterRow()];
      });

      final result = await repository.getAgronomicParameters();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.id, parameterId);
      expect(result.single.code, 'GERMINATION_DAYS');
      expect(result.single.valueSchema, 'NUMERIC_SCALAR');
      expect(result.single.knowledgeScope, 'INTRINSIC');
      expect(result.single.quantityKind, 'TIME');
      expect(result.single.canonicalUnitId, unitId);
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive parameters', () async {
      bool? receivedFilter;

      final repository = AgronomicParameterRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [parameterRow(active: false)];
      });

      final result = await repository.getAgronomicParameters(
        activeOnly: false,
      );

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = AgronomicParameterRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getAgronomicParameters(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = parameterRow()..remove('knowledge_scope');

      final repository = AgronomicParameterRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getAgronomicParameters(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AgronomicParameterRepository.create', () {
    test('invokes exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'agronomic_parameter_id': parameterId,
          'code': 'GERMINATION_DAYS',
          'is_active': true,
          'row_version': 1,
          'created_at': createdAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.createAgronomicParameter(
        code: 'GERMINATION_DAYS',
        name: 'Giorni di germinazione',
        description: 'Durata indicativa della germinazione',
        valueSchema: 'NUMERIC_SCALAR',
        knowledgeScope: 'INTRINSIC',
        quantityKind: 'TIME',
        canonicalUnitId: unitId,
        allowsCrop: true,
        allowsCultivar: true,
        allowsProductionContext: false,
        allowsProtectionContext: false,
        allowsTrainingContext: false,
        allowsHarvestPurpose: false,
      );

      expect(invokedFunction, 'create_agronomic_parameter');
      expect(invokedParameters, {
        'parameter_code': 'GERMINATION_DAYS',
        'parameter_name': 'Giorni di germinazione',
        'parameter_description': 'Durata indicativa della germinazione',
        'parameter_value_schema': 'NUMERIC_SCALAR',
        'parameter_knowledge_scope': 'INTRINSIC',
        'parameter_quantity_kind': 'TIME',
        'parameter_canonical_unit_id': unitId,
        'parameter_allows_crop': true,
        'parameter_allows_cultivar': true,
        'parameter_allows_production_context': false,
        'parameter_allows_protection_context': false,
        'parameter_allows_training_context': false,
        'parameter_allows_harvest_purpose': false,
      });

      expect(result, isA<AgronomicParameterCreated>());
      final created = result as AgronomicParameterCreated;
      expect(created.agronomicParameterId, parameterId);
      expect(created.code, 'GERMINATION_DAYS');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps all create statuses', () async {
      final cases = <String, Type>{
        'forbidden': CreateAgronomicParameterForbidden,
        'invalid_input': CreateAgronomicParameterInvalidInput,
        'unit_not_found': CreateAgronomicParameterUnitNotFound,
        'dependency_inactive':
            CreateAgronomicParameterDependencyInactive,
        'duplicate_code': CreateAgronomicParameterDuplicateCode,
      };

      for (final entry in cases.entries) {
        final result = await createWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects unknown create status', () async {
      await expectLater(
        createWith({'status': 'unexpected'}),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });

    test('rejects malformed created payload', () async {
      await expectLater(
        createWith({
          'status': 'created',
          'agronomic_parameter_id': parameterId,
          'code': 'GERMINATION_DAYS',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });
  });

  group('AgronomicParameterRepository.update', () {
    test('invokes exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'agronomic_parameter_id': parameterId,
          'code': 'GERMINATION_DAYS',
          'is_active': true,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.updateAgronomicParameter(
        agronomicParameterId: parameterId,
        expectedRowVersion: 1,
        code: 'GERMINATION_DAYS',
        name: 'Giorni di germinazione',
        description: null,
        valueSchema: 'NUMERIC_SCALAR',
        knowledgeScope: 'INTRINSIC',
        quantityKind: 'TIME',
        canonicalUnitId: unitId,
        allowsCrop: true,
        allowsCultivar: true,
        allowsProductionContext: false,
        allowsProtectionContext: false,
        allowsTrainingContext: false,
        allowsHarvestPurpose: false,
      );

      expect(invokedFunction, 'update_agronomic_parameter');
      expect(invokedParameters, {
        'target_agronomic_parameter_id': parameterId,
        'expected_row_version': 1,
        'parameter_code': 'GERMINATION_DAYS',
        'parameter_name': 'Giorni di germinazione',
        'parameter_description': null,
        'parameter_value_schema': 'NUMERIC_SCALAR',
        'parameter_knowledge_scope': 'INTRINSIC',
        'parameter_quantity_kind': 'TIME',
        'parameter_canonical_unit_id': unitId,
        'parameter_allows_crop': true,
        'parameter_allows_cultivar': true,
        'parameter_allows_production_context': false,
        'parameter_allows_protection_context': false,
        'parameter_allows_training_context': false,
        'parameter_allows_harvest_purpose': false,
      });

      expect(result, isA<AgronomicParameterUpdated>());
      final updated = result as AgronomicParameterUpdated;
      expect(updated.agronomicParameterId, parameterId);
      expect(updated.code, 'GERMINATION_DAYS');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result = await updateWith({
        'status': 'unchanged',
        'agronomic_parameter_id': parameterId,
        'row_version': 1,
      });

      expect(result, isA<UpdateAgronomicParameterUnchanged>());
      final unchanged = result as UpdateAgronomicParameterUnchanged;
      expect(unchanged.agronomicParameterId, parameterId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version conflict', () async {
      final result = await updateWith({
        'status': 'version_conflict',
        'row_version': 3,
      });

      expect(result, isA<UpdateAgronomicParameterVersionConflict>());
      expect(
        (result as UpdateAgronomicParameterVersionConflict).rowVersion,
        3,
      );
    });

    test('maps every remaining update status', () async {
      final cases = <String, Type>{
        'forbidden': UpdateAgronomicParameterForbidden,
        'invalid_input': UpdateAgronomicParameterInvalidInput,
        'not_found': UpdateAgronomicParameterNotFound,
        'semantics_frozen': UpdateAgronomicParameterSemanticsFrozen,
        'enum_values_exist': UpdateAgronomicParameterEnumValuesExist,
        'unit_not_found': UpdateAgronomicParameterUnitNotFound,
        'dependency_inactive':
            UpdateAgronomicParameterDependencyInactive,
        'duplicate_code': UpdateAgronomicParameterDuplicateCode,
      };

      for (final entry in cases.entries) {
        final result = await updateWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects malformed version conflict', () async {
      await expectLater(
        updateWith({'status': 'version_conflict'}),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });

    test('rejects unknown update status', () async {
      await expectLater(
        updateWith({'status': 'unexpected'}),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });
  });

  group('AgronomicParameterRepository.setActive', () {
    test('invokes exact RPC and maps active changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'agronomic_parameter_id': parameterId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setAgronomicParameterActive(
        agronomicParameterId: parameterId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_agronomic_parameter_active');
      expect(invokedParameters, {
        'target_agronomic_parameter_id': parameterId,
        'expected_row_version': 1,
        'parameter_is_active': false,
      });

      expect(result, isA<AgronomicParameterActiveChanged>());
      final changed = result as AgronomicParameterActiveChanged;
      expect(changed.agronomicParameterId, parameterId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result = await setActiveWith({
        'status': 'unchanged',
        'agronomic_parameter_id': parameterId,
        'is_active': true,
        'row_version': 1,
      });

      expect(result, isA<SetAgronomicParameterActiveUnchanged>());
      final unchanged = result as SetAgronomicParameterActiveUnchanged;
      expect(unchanged.agronomicParameterId, parameterId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version conflict', () async {
      final result = await setActiveWith({
        'status': 'version_conflict',
        'row_version': 3,
      });

      expect(
        result,
        isA<SetAgronomicParameterActiveVersionConflict>(),
      );
      expect(
        (result as SetAgronomicParameterActiveVersionConflict).rowVersion,
        3,
      );
    });

    test('maps every remaining active status', () async {
      final cases = <String, Type>{
        'forbidden': SetAgronomicParameterActiveForbidden,
        'invalid_input': SetAgronomicParameterActiveInvalidInput,
        'not_found': SetAgronomicParameterActiveNotFound,
        'dependency_inactive':
            SetAgronomicParameterActiveDependencyInactive,
        'active_dependents': SetAgronomicParameterActiveDependents,
      };

      for (final entry in cases.entries) {
        final result = await setActiveWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects malformed active changed payload', () async {
      await expectLater(
        setActiveWith({
          'status': 'active_changed',
          'agronomic_parameter_id': parameterId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });

    test('rejects unknown active status', () async {
      await expectLater(
        setActiveWith({'status': 'unexpected'}),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });
  });

  group('AgronomicParameterRepository.protocol', () {
    test('rejects non-map RPC responses', () async {
      await expectLater(
        createWith(null),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });

    test('rejects maps with non-string keys', () async {
      await expectLater(
        createWith({1: 'invalid', 'status': 'forbidden'}),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });

    test('rejects timestamps without timezone', () async {
      await expectLater(
        createWith({
          'status': 'created',
          'agronomic_parameter_id': parameterId,
          'code': 'GERMINATION_DAYS',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-10-14T10:00:00',
        }),
        throwsA(isA<AgronomicParameterWriteProtocolException>()),
      );
    });
  });
}
