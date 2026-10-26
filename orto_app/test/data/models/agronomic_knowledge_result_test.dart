import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/agronomic_knowledge_result.dart';

const p = '11111111-1111-4111-8111-111111111111';
const c = '22222222-2222-4222-8222-222222222222';
const a = '33333333-3333-4333-8333-333333333333';
const u = '44444444-4444-4444-8444-444444444444';
const e = '55555555-5555-4555-8555-555555555555';
const other = '66666666-6666-4666-8666-666666666666';

Map<String, dynamic> ids() => {
  'parameter_id': p,
  'crop_id': c,
  'cultivar_id': null,
  'production_context_id': null,
  'protection_context_id': null,
  'training_context_id': null,
  'harvest_purpose_id': null,
};

Map<String, dynamic> base({
  String kind = 'VALUE',
  String schema = 'NUMERIC_SCALAR',
}) => {
  ...ids(),
  'assertion_id': a,
  'revision_no': 1,
  'parameter_code': 'TEST_PARAMETER',
  'kind': kind,
  'value_schema': schema,
};

Map<String, dynamic> unit() => {
  'id': u,
  'code': 'cm',
  'name': 'centimetro',
  'symbol': 'cm',
  'quantity_kind': 'LENGTH',
};

Map<String, dynamic> resolved({String schema = 'NUMERIC_SCALAR'}) {
  final Map<String, dynamic> value;
  switch (schema) {
    case 'NUMERIC_SCALAR':
      value = {'type': schema, 'numeric_value': 27.5, 'unit': unit()};
    case 'NUMERIC_RANGE':
      value = {
        'type': schema,
        'numeric_min_value': 1.5,
        'numeric_max_value': 3.25,
        'unit': unit(),
      };
    case 'BOOLEAN':
      value = {'type': schema, 'boolean_value': false};
    case 'ENUM':
      value = {
        'type': schema,
        'enum_value': {'id': e, 'code': 'TEST', 'name': 'Test'},
      };
    default:
      throw ArgumentError.value(schema);
  }
  return {'status': 'RESOLVED', ...base(schema: schema), 'value': value};
}

AgronomicKnowledgeRequest request({String? cultivarId}) =>
    AgronomicKnowledgeRequest(
      parameterId: p,
      cropId: c,
      cultivarId: cultivarId,
      productionContextId: null,
      protectionContextId: null,
      trainingContextId: null,
      harvestPurposeId: null,
    );

void main() {
  group('Stati e valori', () {
    test('NUMERIC_SCALAR conserva il valore e l’unita', () {
      final result = AgronomicKnowledgeResult.fromMap(resolved());
      expect(result, isA<AgronomicResolved>());
      final value =
          (result as AgronomicResolved).value as AgronomicNumericScalar;
      expect(value.numericValue, 27.5);
      expect(value.unit.code, 'cm');
      expect(value.unit.symbol, 'cm');
      expect(result.metadata.revisionNo, 1);
      verifyAgronomicKnowledgeIdentity(request(), result);
    });

    test('NUMERIC_RANGE conserva entrambi gli estremi', () {
      final result =
          AgronomicKnowledgeResult.fromMap(resolved(schema: 'NUMERIC_RANGE'))
              as AgronomicResolved;
      final value = result.value as AgronomicNumericRange;
      expect(value.minimum, 1.5);
      expect(value.maximum, 3.25);
    });

    test('BOOLEAN conserva false senza confonderlo con assenza', () {
      final result =
          AgronomicKnowledgeResult.fromMap(resolved(schema: 'BOOLEAN'))
              as AgronomicResolved;
      expect((result.value as AgronomicBoolean).value, isFalse);
    });

    test('ENUM conserva identita e metadati', () {
      final result =
          AgronomicKnowledgeResult.fromMap(resolved(schema: 'ENUM'))
              as AgronomicResolved;
      final value = result.value as AgronomicEnum;
      expect(value.id, e);
      expect(value.code, 'TEST');
      expect(value.name, 'Test');
    });

    test('NO_APPROVED_VALUE conserva identificativi e non ha valore', () {
      final result = AgronomicKnowledgeResult.fromMap({
        'status': 'NO_APPROVED_VALUE',
        ...ids(),
      });
      expect(result, isA<AgronomicNoApprovedValue>());
      verifyAgronomicKnowledgeIdentity(request(), result);
    });

    test('NOT_APPLICABLE richiede kind corretto', () {
      final result = AgronomicKnowledgeResult.fromMap({
        'status': 'NOT_APPLICABLE',
        ...base(kind: 'NOT_APPLICABLE'),
      });
      expect(result, isA<AgronomicNotApplicable>());
      verifyAgronomicKnowledgeIdentity(request(), result);
      expect(
        () => AgronomicKnowledgeResult.fromMap({
          'status': 'NOT_APPLICABLE',
          ...base(),
        }),
        throwsFormatException,
      );
    });
  });

  group('Conflitti', () {
    const reasons = [
      'MULTIPLE_APPROVED_ASSERTIONS',
      'INACTIVE_CANONICAL_UNIT',
      'NON_CANONICAL_UNIT',
      'INACTIVE_ENUM_VALUE',
      'UNSUPPORTED_VALUE_SCHEMA',
    ];
    for (final reason in reasons) {
      test('riconosce $reason con il payload previsto', () {
        final map = <String, dynamic>{
          'status': 'RESOLUTION_CONFLICT',
          'conflict_reason': reason,
          if (reason != 'MULTIPLE_APPROVED_ASSERTIONS') ...base(),
        };
        final result =
            AgronomicKnowledgeResult.fromMap(map)
                as AgronomicResolutionConflict;
        expect(result.reason, reason);
        expect(
          result.metadata == null,
          reason == 'MULTIPLE_APPROVED_ASSERTIONS',
        );
      });
    }
    test('rifiuta conflitto senza motivo', () {
      expect(
        () =>
            AgronomicKnowledgeResult.fromMap({'status': 'RESOLUTION_CONFLICT'}),
        throwsFormatException,
      );
    });
    test('rifiuta conflitto con metadati obbligatori mancanti', () {
      expect(
        () => AgronomicKnowledgeResult.fromMap({
          'status': 'RESOLUTION_CONFLICT',
          'conflict_reason': 'NON_CANONICAL_UNIT',
        }),
        throwsFormatException,
      );
    });
  });

  group('Errori RPC', () {
    const statuses = [
      'unauthenticated',
      'invalid_input',
      'parameter_not_found',
      'parameter_inactive',
      'crop_not_found',
      'crop_inactive',
      'cultivar_not_found',
      'cultivar_crop_mismatch',
      'cultivar_inactive',
      'production_context_not_found',
      'production_context_inactive',
      'protection_context_not_found',
      'protection_context_inactive',
      'training_context_not_found',
      'training_context_inactive',
      'harvest_purpose_not_found',
      'harvest_purpose_inactive',
    ];
    for (final status in statuses) {
      test('riconosce $status come errore, non assenza', () {
        final result = AgronomicKnowledgeResult.fromMap({'status': status});
        expect(result, isA<AgronomicResolverFailure>());
        expect((result as AgronomicResolverFailure).status, status);
      });
    }
    for (final target in ['CROP', 'CULTIVAR']) {
      test('invalid_target con $target', () {
        final result =
            AgronomicKnowledgeResult.fromMap({
                  'status': 'invalid_target',
                  'target_level': target,
                })
                as AgronomicResolverFailure;
        expect(result.detail, target);
      });
    }
    for (final context in [
      'PRODUCTION',
      'PROTECTION',
      'TRAINING',
      'HARVEST_PURPOSE',
    ]) {
      test('invalid_context con $context', () {
        final result =
            AgronomicKnowledgeResult.fromMap({
                  'status': 'invalid_context',
                  'context_type': context,
                })
                as AgronomicResolverFailure;
        expect(result.detail, context);
      });
    }
    test('rifiuta dettagli mancanti o sconosciuti', () {
      for (final map in [
        {'status': 'invalid_target'},
        {'status': 'invalid_target', 'target_level': 'BED'},
        {'status': 'invalid_context'},
        {'status': 'invalid_context', 'context_type': 'UNKNOWN'},
        {'status': 'not_a_real_status'},
      ]) {
        expect(
          () => AgronomicKnowledgeResult.fromMap(map),
          throwsFormatException,
        );
      }
    });
  });

  group('Contratto JSON e numeri', () {
    test('rifiuta status assente e value assente in RESOLVED', () {
      expect(() => AgronomicKnowledgeResult.fromMap({}), throwsFormatException);
      final map = resolved()..remove('value');
      expect(
        () => AgronomicKnowledgeResult.fromMap(map),
        throwsFormatException,
      );
    });
    test('rifiuta schema diverso da value.type e kind errato', () {
      final mismatch = resolved();
      (mismatch['value'] as Map<String, dynamic>)['type'] = 'BOOLEAN';
      expect(
        () => AgronomicKnowledgeResult.fromMap(mismatch),
        throwsFormatException,
      );
      final wrongKind = resolved()..['kind'] = 'NOT_APPLICABLE';
      expect(
        () => AgronomicKnowledgeResult.fromMap(wrongKind),
        throwsFormatException,
      );
    });
    test('rifiuta revisione zero, negativa o non intera', () {
      for (final revision in [0, -1, 1.5, '1']) {
        final map = resolved()..['revision_no'] = revision;
        expect(
          () => AgronomicKnowledgeResult.fromMap(map),
          throwsFormatException,
        );
      }
    });
    test('rifiuta numero come stringa, NaN e infinito', () {
      for (final invalid in [
        '27.5',
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        final map = resolved();
        (map['value'] as Map<String, dynamic>)['numeric_value'] = invalid;
        expect(
          () => AgronomicKnowledgeResult.fromMap(map),
          throwsFormatException,
        );
      }
    });
    test('rifiuta intervallo invertito', () {
      final map = resolved(schema: 'NUMERIC_RANGE');
      (map['value'] as Map<String, dynamic>)['numeric_min_value'] = 4;
      expect(
        () => AgronomicKnowledgeResult.fromMap(map),
        throwsFormatException,
      );
    });
    test('ammette zero e valori negativi nel parser generico', () {
      for (final number in [0, -2.5]) {
        final map = resolved();
        (map['value'] as Map<String, dynamic>)['numeric_value'] = number;
        final result =
            AgronomicKnowledgeResult.fromMap(map) as AgronomicResolved;
        expect((result.value as AgronomicNumericScalar).numericValue, number);
      }
    });
    test('rifiuta unit mancante o con UUID non valido', () {
      final missing = resolved();
      (missing['value'] as Map<String, dynamic>).remove('unit');
      expect(
        () => AgronomicKnowledgeResult.fromMap(missing),
        throwsFormatException,
      );
      final invalid = resolved();
      ((invalid['value'] as Map<String, dynamic>)['unit']
              as Map<String, dynamic>)['id'] =
          'bad';
      expect(
        () => AgronomicKnowledgeResult.fromMap(invalid),
        throwsFormatException,
      );
    });
    test('rifiuta enum incompleto e boolean non bool', () {
      final enumMap = resolved(schema: 'ENUM');
      ((enumMap['value'] as Map<String, dynamic>)['enum_value']
              as Map<String, dynamic>)
          .remove('id');
      expect(
        () => AgronomicKnowledgeResult.fromMap(enumMap),
        throwsFormatException,
      );
      final boolMap = resolved(schema: 'BOOLEAN');
      (boolMap['value'] as Map<String, dynamic>)['boolean_value'] = 0;
      expect(
        () => AgronomicKnowledgeResult.fromMap(boolMap),
        throwsFormatException,
      );
    });
    test('rifiuta value in assenza e non applicabilita', () {
      for (final map in [
        {'status': 'NO_APPROVED_VALUE', ...ids(), 'value': null},
        {
          'status': 'NOT_APPLICABLE',
          ...base(kind: 'NOT_APPLICABLE'),
          'value': null,
        },
      ]) {
        expect(
          () => AgronomicKnowledgeResult.fromMap(map),
          throwsFormatException,
        );
      }
    });
    test('accetta campi aggiuntivi senza usarli', () {
      final map = resolved()..['future_field'] = 'ignored';
      expect(AgronomicKnowledgeResult.fromMap(map), isA<AgronomicResolved>());
    });
    test('rifiuta identificatore obbligatorio nullo e nullable assente', () {
      final nullId = resolved()..['parameter_id'] = null;
      expect(
        () => AgronomicKnowledgeResult.fromMap(nullId),
        throwsFormatException,
      );
      final missing = resolved()..remove('cultivar_id');
      expect(
        () => AgronomicKnowledgeResult.fromMap(missing),
        throwsFormatException,
      );
    });
  });

  group('Identita esatta', () {
    test('impedisce modifiche agli identificativi del risultato', () {
      final result = AgronomicNoApprovedValue({
        'parameter_id': p,
        'crop_id': c,
      });

      expect(
        () => result.identifiers['parameter_id'] = other,
        throwsUnsupportedError,
      );
    });

    test('protegge il risultato dalle modifiche alla mappa originale', () {
      final original = <String, String?>{'parameter_id': p, 'crop_id': c};

      final result = AgronomicNoApprovedValue(original);

      original['parameter_id'] = other;

      expect(result.identifiers['parameter_id'], p);
    });
    test('rifiuta parametro e coltura differenti', () {
      for (final key in ['parameter_id', 'crop_id']) {
        final map = resolved()..[key] = other;
        final result = AgronomicKnowledgeResult.fromMap(map);
        expect(
          () => verifyAgronomicKnowledgeIdentity(request(), result),
          throwsFormatException,
        );
      }
    });
    test('distingue cultivar null da cultivar specifica', () {
      final map = resolved()..['cultivar_id'] = other;
      final result = AgronomicKnowledgeResult.fromMap(map);
      expect(
        () => verifyAgronomicKnowledgeIdentity(request(), result),
        throwsFormatException,
      );
      verifyAgronomicKnowledgeIdentity(request(cultivarId: other), result);
    });
    test('verifica separatamente tutti e quattro i contesti', () {
      for (final key in [
        'production_context_id',
        'protection_context_id',
        'training_context_id',
        'harvest_purpose_id',
      ]) {
        final map = resolved()..[key] = other;
        final result = AgronomicKnowledgeResult.fromMap(map);
        expect(
          () => verifyAgronomicKnowledgeIdentity(request(), result),
          throwsFormatException,
        );
      }
    });
    test('rifiuta UUID malformati nella richiesta', () {
      expect(
        () => AgronomicKnowledgeRequest(
          parameterId: 'invalid',
          cropId: c,
          cultivarId: null,
          productionContextId: null,
          protectionContextId: null,
          trainingContextId: null,
          harvestPurposeId: null,
        ),
        throwsFormatException,
      );
    });
  });
}
