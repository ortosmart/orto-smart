
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/measurement_unit_write_result.dart';
import 'package:orto_app/data/repositories/measurement_unit_repository.dart';

void main() {
  const unitId = '11111111-1111-4111-8111-111111111111';
  const createdAt = '2026-10-14T10:00:00Z';
  const updatedAt = '2026-10-14T11:00:00Z';

  Map<String, dynamic> unitRow({
    bool active = true,
    int version = 1,
  }) => {
    'id': unitId,
    'code': 'CM',
    'name': 'Centimetro',
    'symbol': 'cm',
    'quantity_kind': 'LENGTH',
    'to_base_factor': 0.01,
    'to_base_offset': 0,
    'description': 'Unità di lunghezza',
    'is_active': active,
    'row_version': version,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  MeasurementUnitRepository repositoryForRpc(
    dynamic response, {
    void Function(String, Map<String, dynamic>)? inspect,
  }) {
    return MeasurementUnitRepository.withProviders(
      ({bool activeOnly = true}) async => <Map<String, dynamic>>[],
      (functionName, parameters) async {
        inspect?.call(functionName, parameters);
        return response;
      },
    );
  }

  Future<CreateMeasurementUnitResult> createWith(dynamic response) {
    return repositoryForRpc(response).createMeasurementUnit(
      code: 'CM',
      name: 'Centimetro',
      symbol: 'cm',
      quantityKind: 'LENGTH',
      toBaseFactor: 0.01,
      toBaseOffset: 0,
      description: 'Unità di lunghezza',
    );
  }

  Future<UpdateMeasurementUnitResult> updateWith(dynamic response) {
    return repositoryForRpc(response).updateMeasurementUnit(
      measurementUnitId: unitId,
      expectedRowVersion: 1,
      code: 'CM',
      name: 'Centimetro aggiornato',
      symbol: 'cm',
      quantityKind: 'LENGTH',
      toBaseFactor: 0.01,
      toBaseOffset: 0,
      description: null,
    );
  }

  Future<SetMeasurementUnitActiveResult> setActiveWith(dynamic response) {
    return repositoryForRpc(response).setMeasurementUnitActive(
      measurementUnitId: unitId,
      expectedRowVersion: 1,
      isActive: false,
    );
  }

  group('MeasurementUnitRepository.read', () {
    test('reads active units by default', () async {
      bool? receivedFilter;

      final repository = MeasurementUnitRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [unitRow()];
      });

      final result = await repository.getMeasurementUnits();

      expect(receivedFilter, isTrue);
      expect(result, hasLength(1));
      expect(result.single.id, unitId);
      expect(result.single.code, 'CM');
      expect(result.single.name, 'Centimetro');
      expect(result.single.symbol, 'cm');
      expect(result.single.quantityKind, 'LENGTH');
      expect(result.single.toBaseFactor, 0.01);
      expect(result.single.toBaseOffset, 0);
      expect(result.single.isActive, isTrue);
    });

    test('can request inactive units', () async {
      bool? receivedFilter;

      final repository = MeasurementUnitRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        receivedFilter = activeOnly;
        return [unitRow(active: false)];
      });

      final result = await repository.getMeasurementUnits(
        activeOnly: false,
      );

      expect(receivedFilter, isFalse);
      expect(result.single.isActive, isFalse);
    });

    test('returns an empty list', () async {
      final repository = MeasurementUnitRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      expect(await repository.getMeasurementUnits(), isEmpty);
    });

    test('rejects malformed rows', () async {
      final row = unitRow()..remove('quantity_kind');

      final repository = MeasurementUnitRepository.withLoader(
        ({bool activeOnly = true}) async => [row],
      );

      await expectLater(
        repository.getMeasurementUnits(),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('MeasurementUnitRepository.create', () {
    test('invokes the exact RPC and maps created', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'created',
          'measurement_unit_id': unitId,
          'code': 'CM',
          'is_active': true,
          'row_version': 1,
          'created_at': createdAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.createMeasurementUnit(
        code: 'CM',
        name: 'Centimetro',
        symbol: 'cm',
        quantityKind: 'LENGTH',
        toBaseFactor: 0.01,
        toBaseOffset: 0,
        description: 'Unità di lunghezza',
      );

      expect(invokedFunction, 'create_measurement_unit');
      expect(invokedParameters, {
        'unit_code': 'CM',
        'unit_name': 'Centimetro',
        'unit_symbol': 'cm',
        'unit_quantity_kind': 'LENGTH',
        'unit_to_base_factor': 0.01,
        'unit_to_base_offset': 0,
        'unit_description': 'Unità di lunghezza',
      });

      expect(result, isA<MeasurementUnitCreated>());
      final created = result as MeasurementUnitCreated;
      expect(created.measurementUnitId, unitId);
      expect(created.code, 'CM');
      expect(created.isActive, isTrue);
      expect(created.rowVersion, 1);
      expect(created.createdAt, DateTime.utc(2026, 10, 14, 10));
    });

    test('maps every non-success create status', () async {
      final cases = <String, Type>{
        'forbidden': CreateMeasurementUnitForbidden,
        'invalid_input': CreateMeasurementUnitInvalidInput,
        'duplicate_code': CreateMeasurementUnitDuplicateCode,
      };

      for (final entry in cases.entries) {
        final result = await createWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects unknown create status', () async {
      await expectLater(
        createWith({'status': 'unexpected'}),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects malformed created payload', () async {
      await expectLater(
        createWith({
          'status': 'created',
          'measurement_unit_id': unitId,
          'code': 'CM',
          'is_active': true,
          'row_version': 0,
          'created_at': createdAt,
        }),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });
  });

  group('MeasurementUnitRepository.update', () {
    test('invokes the exact RPC and maps updated', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'updated',
          'measurement_unit_id': unitId,
          'code': 'CM',
          'is_active': true,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.updateMeasurementUnit(
        measurementUnitId: unitId,
        expectedRowVersion: 1,
        code: 'CM',
        name: 'Centimetro aggiornato',
        symbol: 'cm',
        quantityKind: 'LENGTH',
        toBaseFactor: 0.01,
        toBaseOffset: 0,
        description: null,
      );

      expect(invokedFunction, 'update_measurement_unit');
      expect(invokedParameters, {
        'target_measurement_unit_id': unitId,
        'expected_row_version': 1,
        'unit_code': 'CM',
        'unit_name': 'Centimetro aggiornato',
        'unit_symbol': 'cm',
        'unit_quantity_kind': 'LENGTH',
        'unit_to_base_factor': 0.01,
        'unit_to_base_offset': 0,
        'unit_description': null,
      });

      expect(result, isA<MeasurementUnitUpdated>());
      final updated = result as MeasurementUnitUpdated;
      expect(updated.measurementUnitId, unitId);
      expect(updated.code, 'CM');
      expect(updated.isActive, isTrue);
      expect(updated.rowVersion, 2);
      expect(updated.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result = await updateWith({
        'status': 'unchanged',
        'measurement_unit_id': unitId,
        'row_version': 1,
      });

      expect(result, isA<UpdateMeasurementUnitUnchanged>());
      final unchanged = result as UpdateMeasurementUnitUnchanged;
      expect(unchanged.measurementUnitId, unitId);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result = await updateWith({
        'status': 'version_conflict',
        'row_version': 3,
      });

      expect(result, isA<UpdateMeasurementUnitVersionConflict>());
      expect(
        (result as UpdateMeasurementUnitVersionConflict).rowVersion,
        3,
      );
    });

    test('maps every remaining update status', () async {
      final cases = <String, Type>{
        'forbidden': UpdateMeasurementUnitForbidden,
        'invalid_input': UpdateMeasurementUnitInvalidInput,
        'not_found': UpdateMeasurementUnitNotFound,
        'semantics_frozen': UpdateMeasurementUnitSemanticsFrozen,
        'unit_in_use': UpdateMeasurementUnitInUse,
        'duplicate_code': UpdateMeasurementUnitDuplicateCode,
      };

      for (final entry in cases.entries) {
        final result = await updateWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects malformed version_conflict', () async {
      await expectLater(
        updateWith({'status': 'version_conflict'}),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects unknown update status', () async {
      await expectLater(
        updateWith({'status': 'unexpected'}),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });
  });

  group('MeasurementUnitRepository.setActive', () {
    test('invokes the exact RPC and maps active_changed', () async {
      String? invokedFunction;
      Map<String, dynamic>? invokedParameters;

      final repository = repositoryForRpc(
        {
          'status': 'active_changed',
          'measurement_unit_id': unitId,
          'is_active': false,
          'row_version': 2,
          'updated_at': updatedAt,
        },
        inspect: (functionName, parameters) {
          invokedFunction = functionName;
          invokedParameters = parameters;
        },
      );

      final result = await repository.setMeasurementUnitActive(
        measurementUnitId: unitId,
        expectedRowVersion: 1,
        isActive: false,
      );

      expect(invokedFunction, 'set_measurement_unit_active');
      expect(invokedParameters, {
        'target_measurement_unit_id': unitId,
        'expected_row_version': 1,
        'unit_is_active': false,
      });

      expect(result, isA<MeasurementUnitActiveChanged>());
      final changed = result as MeasurementUnitActiveChanged;
      expect(changed.measurementUnitId, unitId);
      expect(changed.isActive, isFalse);
      expect(changed.rowVersion, 2);
      expect(changed.updatedAt, DateTime.utc(2026, 10, 14, 11));
    });

    test('maps unchanged', () async {
      final result = await setActiveWith({
        'status': 'unchanged',
        'measurement_unit_id': unitId,
        'is_active': true,
        'row_version': 1,
      });

      expect(result, isA<SetMeasurementUnitActiveUnchanged>());
      final unchanged = result as SetMeasurementUnitActiveUnchanged;
      expect(unchanged.measurementUnitId, unitId);
      expect(unchanged.isActive, isTrue);
      expect(unchanged.rowVersion, 1);
    });

    test('maps version_conflict', () async {
      final result = await setActiveWith({
        'status': 'version_conflict',
        'row_version': 3,
      });

      expect(result, isA<SetMeasurementUnitActiveVersionConflict>());
      expect(
        (result as SetMeasurementUnitActiveVersionConflict).rowVersion,
        3,
      );
    });

    test('maps every remaining set-active status', () async {
      final cases = <String, Type>{
        'forbidden': SetMeasurementUnitActiveForbidden,
        'invalid_input': SetMeasurementUnitActiveInvalidInput,
        'not_found': SetMeasurementUnitActiveNotFound,
        'active_dependents': SetMeasurementUnitActiveDependents,
      };

      for (final entry in cases.entries) {
        final result = await setActiveWith({'status': entry.key});
        expect(result.runtimeType, entry.value, reason: entry.key);
      }
    });

    test('rejects malformed active_changed payload', () async {
      await expectLater(
        setActiveWith({
          'status': 'active_changed',
          'measurement_unit_id': unitId,
          'is_active': 'false',
          'row_version': 2,
          'updated_at': updatedAt,
        }),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects unknown set-active status', () async {
      await expectLater(
        setActiveWith({'status': 'unexpected'}),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });
  });

  group('MeasurementUnitRepository.protocol', () {
    test('rejects non-map RPC responses', () async {
      await expectLater(
        createWith(null),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects maps with non-string keys', () async {
      await expectLater(
        createWith({1: 'invalid', 'status': 'forbidden'}),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects invalid timestamps', () async {
      await expectLater(
        createWith({
          'status': 'created',
          'measurement_unit_id': unitId,
          'code': 'CM',
          'is_active': true,
          'row_version': 1,
          'created_at': 'not-a-date',
        }),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });

    test('rejects timestamps without timezone', () async {
      await expectLater(
        createWith({
          'status': 'created',
          'measurement_unit_id': unitId,
          'code': 'CM',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-10-14T10:00:00',
        }),
        throwsA(isA<MeasurementUnitWriteProtocolException>()),
      );
    });
  });
}
