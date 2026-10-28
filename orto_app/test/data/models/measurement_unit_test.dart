
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/measurement_unit.dart';

void main() {
  Map<String, dynamic> validMap() => {
        'id': '11111111-1111-4111-8111-111111111111',
        'code': 'CM',
        'name': 'Centimetro',
        'symbol': 'cm',
        'quantity_kind': 'LENGTH',
        'to_base_factor': 0.01,
        'to_base_offset': 0,
        'description': 'Unità di lunghezza.',
        'is_active': true,
        'row_version': 1,
        'created_at': '2026-10-28T10:00:00Z',
        'updated_at': '2026-10-28T11:00:00+01:00',
      };

  group('MeasurementUnit.fromMap', () {
    test('parses all fields and normalizes timestamps to UTC', () {
      final unit = MeasurementUnit.fromMap(validMap());

      expect(unit.id, '11111111-1111-4111-8111-111111111111');
      expect(unit.code, 'CM');
      expect(unit.name, 'Centimetro');
      expect(unit.symbol, 'cm');
      expect(unit.quantityKind, 'LENGTH');
      expect(unit.toBaseFactor, 0.01);
      expect(unit.toBaseOffset, 0);
      expect(unit.description, 'Unità di lunghezza.');
      expect(unit.isActive, isTrue);
      expect(unit.rowVersion, 1);
      expect(unit.createdAt.isUtc, isTrue);
      expect(unit.updatedAt.isUtc, isTrue);
      expect(unit.createdAt, DateTime.utc(2026, 10, 28, 10));
      expect(unit.updatedAt, DateTime.utc(2026, 10, 28, 10));
    });

    test('accepts null description and inactive units', () {
      final unit = MeasurementUnit.fromMap({
        ...validMap(),
        'description': null,
        'is_active': false,
      });

      expect(unit.description, isNull);
      expect(unit.isActive, isFalse);
    });

    test('accepts integer and fractional numeric values', () {
      final unit = MeasurementUnit.fromMap({
        ...validMap(),
        'to_base_factor': 1,
        'to_base_offset': -0.5,
      });

      expect(unit.toBaseFactor, 1);
      expect(unit.toBaseOffset, -0.5);
    });

    test('rejects missing, empty and incorrectly typed strings', () {
      for (final field in [
        'id',
        'code',
        'name',
        'symbol',
        'quantity_kind',
      ]) {
        for (final value in [null, '', '   ', 123]) {
          expect(
            () => MeasurementUnit.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
            reason: '$field must reject $value',
          );
        }
      }
    });

    test('rejects invalid description types', () {
      expect(
        () => MeasurementUnit.fromMap({
          ...validMap(),
          'description': 42,
        }),
        throwsFormatException,
      );
    });

    test('rejects missing or incorrectly typed active flag', () {
      for (final value in [null, 1, 'true']) {
        expect(
          () => MeasurementUnit.fromMap({
            ...validMap(),
            'is_active': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects invalid row versions', () {
      for (final value in [null, 0, -1, 1.5, '1']) {
        expect(
          () => MeasurementUnit.fromMap({
            ...validMap(),
            'row_version': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects zero, negative and nonnumeric factors', () {
      for (final value in [null, 0, -1, '0.01']) {
        expect(
          () => MeasurementUnit.fromMap({
            ...validMap(),
            'to_base_factor': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects non-finite factors and offsets', () {
      for (final field in ['to_base_factor', 'to_base_offset']) {
        for (final value in [
          double.nan,
          double.infinity,
          double.negativeInfinity,
        ]) {
          expect(
            () => MeasurementUnit.fromMap({
              ...validMap(),
              field: value,
            }),
            throwsFormatException,
          );
        }
      }
    });

    test('rejects missing or nonnumeric offsets', () {
      for (final value in [null, '0']) {
        expect(
          () => MeasurementUnit.fromMap({
            ...validMap(),
            'to_base_offset': value,
          }),
          throwsFormatException,
        );
      }
    });

    test('rejects malformed timestamps and timestamps without timezone', () {
      for (final field in ['created_at', 'updated_at']) {
        for (final value in [
          null,
          '',
          'not-a-date',
          '2026-10-28T10:00:00',
          123,
        ]) {
          expect(
            () => MeasurementUnit.fromMap({
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
