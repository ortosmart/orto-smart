import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/agronomic_knowledge_result.dart';
import 'package:orto_app/data/repositories/agronomic_knowledge_repository.dart';

void main() {
  const parameterId = '11111111-1111-4111-8111-111111111111';
  const cropId = '22222222-2222-4222-8222-222222222222';
  const cultivarId = '33333333-3333-4333-8333-333333333333';
  const productionId = '44444444-4444-4444-8444-444444444444';
  const protectionId = '55555555-5555-4555-8555-555555555555';
  const trainingId = '66666666-6666-4666-8666-666666666666';
  const harvestId = '77777777-7777-4777-8777-777777777777';
  const otherId = '88888888-8888-4888-8888-888888888888';
  const assertionId = '99999999-9999-4999-8999-999999999999';

  AgronomicKnowledgeRequest request({bool withContexts = false}) {
    return AgronomicKnowledgeRequest(
      parameterId: parameterId,
      cropId: cropId,
      cultivarId: withContexts ? cultivarId : null,
      productionContextId: withContexts ? productionId : null,
      protectionContextId: withContexts ? protectionId : null,
      trainingContextId: withContexts ? trainingId : null,
      harvestPurposeId: withContexts ? harvestId : null,
    );
  }

  Map<String, dynamic> identifiers({bool withContexts = false}) => {
    'parameter_id': parameterId,
    'crop_id': cropId,
    'cultivar_id': withContexts ? cultivarId : null,
    'production_context_id': withContexts ? productionId : null,
    'protection_context_id': withContexts ? protectionId : null,
    'training_context_id': withContexts ? trainingId : null,
    'harvest_purpose_id': withContexts ? harvestId : null,
  };

  Map<String, dynamic> noApproved({bool withContexts = false}) => {
    'status': 'NO_APPROVED_VALUE',
    ...identifiers(withContexts: withContexts),
  };

  Map<String, dynamic> metadata() => {
    ...identifiers(),
    'assertion_id': assertionId,
    'revision_no': 1,
    'parameter_code': 'PLANT_SPACING',
    'kind': 'VALUE',
    'value_schema': 'NUMERIC_SCALAR',
  };

  Map<String, dynamic> resolved() => {
    'status': 'RESOLVED',
    ...metadata(),
    'value': {
      'type': 'NUMERIC_SCALAR',
      'numeric_value': 27.5,
      'unit': {
        'id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'code': 'cm',
        'name': 'centimetro',
        'symbol': 'cm',
        'quantity_kind': 'LENGTH',
      },
    },
  };

  AgronomicKnowledgeRepository repositoryFor(
    Future<dynamic> Function(String, Map<String, dynamic>) invoker,
  ) {
    return AgronomicKnowledgeRepository.withRpcInvoker(invoker);
  }

  group('AgronomicKnowledgeRepository RPC', () {
    test(
      'invoca esattamente la RPC con sette parametri null espliciti',
      () async {
        var calls = 0;
        String? invokedName;
        Map<String, dynamic>? invokedParameters;

        final repository = repositoryFor((name, parameters) async {
          calls++;
          invokedName = name;
          invokedParameters = parameters;
          return noApproved();
        });

        final result = await repository.resolve(request());

        expect(calls, 1);
        expect(invokedName, 'resolve_agronomic_knowledge');
        expect(invokedParameters, {
          'target_parameter_id': parameterId,
          'target_crop_id': cropId,
          'target_cultivar_id': null,
          'target_production_context_id': null,
          'target_protection_context_id': null,
          'target_training_context_id': null,
          'target_harvest_purpose_id': null,
        });
        expect(result, isA<AgronomicNoApprovedValue>());
      },
    );

    test('trasmette tutti i contesti specificati', () async {
      final repository = repositoryFor((name, parameters) async {
        expect(parameters, {
          'target_parameter_id': parameterId,
          'target_crop_id': cropId,
          'target_cultivar_id': cultivarId,
          'target_production_context_id': productionId,
          'target_protection_context_id': protectionId,
          'target_training_context_id': trainingId,
          'target_harvest_purpose_id': harvestId,
        });
        return noApproved(withContexts: true);
      });

      expect(
        await repository.resolve(request(withContexts: true)),
        isA<AgronomicNoApprovedValue>(),
      );
    });

    test('restituisce NOT_APPLICABLE senza fallback', () async {
      final repository = repositoryFor(
        (name, parameters) async => {
          'status': 'NOT_APPLICABLE',
          'assertion_id': assertionId,
          'revision_no': 1,
          'parameter_code': 'PLANT_SPACING',
          'kind': 'NOT_APPLICABLE',
          'value_schema': 'NUMERIC_SCALAR',
          ...identifiers(),
        },
      );

      expect(
        await repository.resolve(request()),
        isA<AgronomicNotApplicable>(),
      );
    });

    test('conserva un conflitto senza richiamare la RPC', () async {
      var calls = 0;
      final repository = repositoryFor((name, parameters) async {
        calls++;
        return {
          'status': 'RESOLUTION_CONFLICT',
          'conflict_reason': 'MULTIPLE_APPROVED_ASSERTIONS',
        };
      });

      final result = await repository.resolve(request());

      expect(result, isA<AgronomicResolutionConflict>());
      expect(calls, 1);
    });

    test('conserva gli errori previsti dal resolver', () async {
      final repository = repositoryFor(
        (name, parameters) async => {'status': 'parameter_not_found'},
      );

      final result = await repository.resolve(request());

      expect(result, isA<AgronomicResolverFailure>());
    });

    test('rifiuta risposte non Map', () async {
      final repository = repositoryFor(
        (name, parameters) async => ['NO_APPROVED_VALUE'],
      );

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rifiuta Map con chiavi non String', () async {
      final repository = repositoryFor(
        (name, parameters) async => <Object, dynamic>{1: 'NO_APPROVED_VALUE'},
      );

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rifiuta stati sconosciuti', () async {
      final repository = repositoryFor(
        (name, parameters) async => {'status': 'UNKNOWN_STATUS'},
      );

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rifiuta identificativi discordanti', () async {
      final payload = noApproved()..['crop_id'] = otherId;
      final repository = repositoryFor((name, parameters) async => payload);

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('rifiuta identificativi mancanti', () async {
      final payload = noApproved()..remove('harvest_purpose_id');
      final repository = repositoryFor((name, parameters) async => payload);

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('propaga errori di comunicazione senza fallback', () async {
      var calls = 0;
      final failure = StateError('RPC unavailable');

      final repository = repositoryFor((name, parameters) async {
        calls++;
        throw failure;
      });

      await expectLater(repository.resolve(request()), throwsA(same(failure)));
      expect(calls, 1);
    });

    test('restituisce RESOLVED con valore numerico e metadati', () async {
      var calls = 0;
      final repository = repositoryFor((name, parameters) async {
        calls++;
        return resolved();
      });

      final result = await repository.resolve(request());

      expect(result, isA<AgronomicResolved>());
      final resolvedResult = result as AgronomicResolved;
      expect(resolvedResult.metadata.parameterCode, 'PLANT_SPACING');
      expect(resolvedResult.value, isA<AgronomicNumericScalar>());
      expect(
        (resolvedResult.value as AgronomicNumericScalar).numericValue,
        27.5,
      );
      expect(calls, 1);
    });

    test('rifiuta identificativi discordanti in RESOLVED', () async {
      final payload = resolved()..['crop_id'] = otherId;
      final repository = repositoryFor((name, parameters) async => payload);

      await expectLater(
        repository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('gestisce conflitto con metadati e verifica identita', () async {
      var calls = 0;
      final repository = repositoryFor((name, parameters) async {
        calls++;
        return {
          'status': 'RESOLUTION_CONFLICT',
          'conflict_reason': 'INACTIVE_CANONICAL_UNIT',
          ...metadata(),
        };
      });

      final result = await repository.resolve(request());

      expect(result, isA<AgronomicResolutionConflict>());
      final conflict = result as AgronomicResolutionConflict;
      expect(conflict.reason, 'INACTIVE_CANONICAL_UNIT');
      expect(conflict.metadata, isNotNull);
      expect(calls, 1);

      final invalidPayload = {
        'status': 'RESOLUTION_CONFLICT',
        'conflict_reason': 'INACTIVE_CANONICAL_UNIT',
        ...metadata(),
        'crop_id': otherId,
      };
      final invalidRepository = repositoryFor(
        (name, parameters) async => invalidPayload,
      );

      await expectLater(
        invalidRepository.resolve(request()),
        throwsA(isA<FormatException>()),
      );
    });

    test('errore del resolver non provoca chiamate aggiuntive', () async {
      var calls = 0;
      final repository = repositoryFor((name, parameters) async {
        calls++;
        return {'status': 'crop_inactive'};
      });

      final result = await repository.resolve(request());

      expect(result, isA<AgronomicResolverFailure>());
      expect((result as AgronomicResolverFailure).status, 'crop_inactive');
      expect(calls, 1);
    });
  });
}
