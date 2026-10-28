
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/agronomic_parameter.dart';

void main() {
  const unitId = '11111111-1111-4111-8111-111111111111';
  const parameterId = '22222222-2222-4222-8222-222222222222';

  Map<String, dynamic> validMap() => {
        'id': parameterId,
        'code': 'PLANT_SPACING_CM',
        'name': 'Distanza tra piante',
        'description': 'Distanza consigliata tra piante.',
        'value_schema': 'NUMERIC_RANGE',
        'knowledge_scope': 'CONTEXTUAL',
        'quantity_kind': 'LENGTH',
        'canonical_unit_id': unitId,
        'allows_crop': true,
        'allows_cultivar': true,
        'allows_production_context': true,
        'allows_protection_context': true,
        'allows_training_context': true,
        'allows_harvest_purpose': true,
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-10-28T10:00:00Z',
        'updated_at': '2026-10-28T11:00:00+01:00',
      };

  group('AgronomicParameter.fromMap', () {
    test('parses all fields and normalizes timestamps to UTC', () {
      final parameter = AgronomicParameter.fromMap(validMap());

      expect(parameter.id, parameterId);
      expect(parameter.code, 'PLANT_SPACING_CM');
      expect(parameter.name, 'Distanza tra piante');
      expect(parameter.description, 'Distanza consigliata tra piante.');
      expect(parameter.valueSchema, 'NUMERIC_RANGE');
      expect(parameter.knowledgeScope, 'CONTEXTUAL');
      expect(parameter.quantityKind, 'LENGTH');
      expect(parameter.canonicalUnitId, unitId);
      expect(parameter.allowsCrop, isTrue);
      expect(parameter.allowsCultivar, isTrue);
      expect(parameter.allowsProductionContext, isTrue);
      expect(parameter.allowsProtectionContext, isTrue);
      expect(parameter.allowsTrainingContext, isTrue);
      expect(parameter.allowsHarvestPurpose, isTrue);
      expect(parameter.isActive, isTrue);
      expect(parameter.rowVersion, 1);
      expect(parameter.createdAt, DateTime.utc(2026, 10, 28, 10));
      expect(parameter.updatedAt, DateTime.utc(2026, 10, 28, 10));
      expect(parameter.createdAt.isUtc, isTrue);
      expect(parameter.updatedAt.isUtc, isTrue);
    });

    test('accepts numeric scalar with a canonical unit', () {
      final parameter = AgronomicParameter.fromMap({
        ...validMap(),
        'value_schema': 'NUMERIC_SCALAR',
      });

      expect(parameter.valueSchema, 'NUMERIC_SCALAR');
      expect(parameter.canonicalUnitId, unitId);
    });

    test('accepts intrinsic boolean without a unit or contexts', () {
      final parameter = AgronomicParameter.fromMap({
        ...validMap(),
        'value_schema': 'BOOLEAN',
        'knowledge_scope': 'INTRINSIC',
        'quantity_kind': null,
        'canonical_unit_id': null,
        'allows_production_context': false,
        'allows_protection_context': false,
        'allows_training_context': false,
        'allows_harvest_purpose': false,
      });

      expect(parameter.valueSchema, 'BOOLEAN');
      expect(parameter.knowledgeScope, 'INTRINSIC');
      expect(parameter.quantityKind, isNull);
      expect(parameter.canonicalUnitId, isNull);
    });

    test('accepts contextual enum without a unit', () {
      final parameter = AgronomicParameter.fromMap({
        ...validMap(),
        'value_schema': 'ENUM',
        'quantity_kind': null,
        'canonical_unit_id': null,
        'allows_production_context': false,
        'allows_protection_context': false,
        'allows_training_context': true,
        'allows_harvest_purpose': false,
      });

      expect(parameter.valueSchema, 'ENUM');
      expect(parameter.allowsTrainingContext, isTrue);
    });

    test('accepts null description and inactive status', () {
      final parameter = AgronomicParameter.fromMap({
        ...validMap(),
        'description': null,
        'is_active': false,
      });

      expect(parameter.description, isNull);
      expect(parameter.isActive, isFalse);
    });

    test('rejects missing, empty and incorrectly typed required strings', () {
      for (final field in ['id', 'code', 'name', 'value_schema',
        'knowledge_scope']) {
        for (final value in [null, '', '   ', 123]) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
            reason: '$field must reject $value',
          );
        }
      }
    });

    test('rejects invalid optional string types and empty values', () {
      for (final field in [
        'description',
        'quantity_kind',
        'canonical_unit_id',
      ]) {
        for (final value in ['', '   ', 123]) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
            reason: '$field must reject $value',
          );
        }
      }
    });

    test('rejects unknown value schemas', () {
      for (final value in ['TEXT', 'numeric_range', '']) {
        expect(
          () => AgronomicParameter.fromMap({
            ...validMap(),
            'value_schema': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects unknown knowledge scopes', () {
      for (final value in ['GLOBAL', 'contextual', '']) {
        expect(
          () => AgronomicParameter.fromMap({
            ...validMap(),
            'knowledge_scope': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('numeric schemas require quantity kind and canonical unit', () {
      for (final schema in ['NUMERIC_SCALAR', 'NUMERIC_RANGE']) {
        for (final field in ['quantity_kind', 'canonical_unit_id']) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              'value_schema': schema,
              field: null,
            }),
            throwsFormatException,
          );
        }
      }
    });

    test('boolean and enum schemas reject dimensional units', () {
      for (final schema in ['BOOLEAN', 'ENUM']) {
        for (final field in ['quantity_kind', 'canonical_unit_id']) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              'value_schema': schema,
              field: null,
            }),
            throwsFormatException,
          );
        }
      }
    });

    test('requires crop or cultivar as a target', () {
      expect(
        () => AgronomicParameter.fromMap({
          ...validMap(),
          'allows_crop': false,
          'allows_cultivar': false,
        }),
        throwsFormatException,
      );
    });

    test('intrinsic scope rejects enabled context flags', () {
      expect(
        () => AgronomicParameter.fromMap({
          ...validMap(),
          'knowledge_scope': 'INTRINSIC',
        }),
        throwsFormatException,
      );
    });

    test('contextual scope requires at least one context flag', () {
      expect(
        () => AgronomicParameter.fromMap({
          ...validMap(),
          'allows_production_context': false,
          'allows_protection_context': false,
          'allows_training_context': false,
          'allows_harvest_purpose': false,
        }),
        throwsFormatException,
      );
    });

    test('rejects invalid boolean flags', () {
      for (final field in [
        'allows_crop',
        'allows_cultivar',
        'allows_production_context',
        'allows_protection_context',
        'allows_training_context',
        'allows_harvest_purpose',
        'is_active',
      ]) {
        for (final value in [null, 1, 'true']) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
            reason: '$field must reject $value',
          );
        }
      }
    });

    test('rejects invalid row versions', () {
      for (final value in [null, 0, -1, 1.5, '1']) {
        expect(
          () => AgronomicParameter.fromMap({
            ...validMap(),
            'row_version': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects invalid timestamps or missing timezones', () {
      for (final field in ['created_at', 'updated_at']) {
        for (final value in [
          null,
          '',
          'not-a-date',
          '2026-10-28T10:00:00',
          123,
        ]) {
          expect(
            () => AgronomicParameter.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
            reason: '$field must reject $value',
          );
        }
      }
    });
  });
}
