import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/write_authority/mutation_operation_contract.dart';

void main() {
  const profileId = '11111111-1111-4111-8111-111111111111';
  const operationId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const otherId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  const nilId = '00000000-0000-0000-0000-000000000000';

  MutationOperationIdentity identity({
    String profile = profileId,
    String operation = operationId,
    MutationOperationType type = MutationOperationType.createPlannedPlanting,
    int version = 1,
  }) => MutationOperationIdentity(
    profileId: profile,
    operationId: operation,
    operationType: type,
    requestSchemaVersion: version,
  );

  group('Mutation operation identity', () {
    test('normalizes UUID case', () {
      expect(identity(operation: operationId.toUpperCase()), identity());
    });

    test('equal identities have equal hashes', () {
      expect(identity().hashCode, identity().hashCode);
    });

    test('different profile is not equal', () {
      expect(identity(profile: otherId), isNot(identity()));
    });

    test('different operation is not equal', () {
      expect(identity(operation: otherId), isNot(identity()));
    });

    test('different operation type is not equal', () {
      expect(
        identity(type: MutationOperationType.updatePlannedPlanting),
        isNot(identity()),
      );
    });

    test('different request version is not equal', () {
      expect(identity(version: 2), isNot(identity()));
    });

    for (final invalid in ['', 'invalid', nilId, ' $operationId']) {
      test('rejects invalid profile UUID: $invalid', () {
        expect(() => identity(profile: invalid), throwsArgumentError);
      });

      test('rejects invalid operation UUID: $invalid', () {
        expect(() => identity(operation: invalid), throwsArgumentError);
      });
    }

    for (final version in [0, -1]) {
      test('rejects request version $version', () {
        expect(() => identity(version: version), throwsArgumentError);
      });
    }
  });

  group('Operation types and domains', () {
    test('contains exactly five seasonal planning mutations', () {
      expect(
        MutationOperationType.values.map((type) => type.wireValue),
        orderedEquals([
          'create_planned_planting',
          'update_planned_planting',
          'confirm_planned_planting',
          'cancel_planned_planting',
          'execute_planned_planting',
        ]),
      );

      expect(MutationDomain.seasonalPlanning.wireValue, 'seasonal_planning');

      for (final type in MutationOperationType.values) {
        expect(type.domain, MutationDomain.seasonalPlanning);
      }
    });
  });

  group('Local transition matrix', () {
    const allowed = {
      'idle:inFlight',
      'inFlight:succeeded',
      'inFlight:rejected',
      'inFlight:uncertain',
      'uncertain:reconciling',
      'reconciling:succeeded',
      'reconciling:rejected',
      'reconciling:uncertain',
      'reconciling:resolved',
    };

    for (final from in MutationOperationState.values) {
      for (final to in MutationOperationState.values) {
        final transition = '${from.name}:${to.name}';

        test(transition, () {
          expect(from.canTransitionTo(to), allowed.contains(transition));
        });
      }
    }

    test('terminal states are exactly the approved states', () {
      expect(
        MutationOperationState.values.where((state) => state.isTerminal),
        unorderedEquals([
          MutationOperationState.succeeded,
          MutationOperationState.rejected,
          MutationOperationState.resolved,
        ]),
      );
    });

    test('blocking states are exactly the approved states', () {
      expect(
        MutationOperationState.values.where((state) => state.blocksAdmission),
        unorderedEquals([
          MutationOperationState.inFlight,
          MutationOperationState.uncertain,
          MutationOperationState.reconciling,
        ]),
      );
    });
  });

  group('Server registry status', () {
    test('preserves wire values', () {
      expect(
        MutationRegistryStatus.values.map((state) => state.wireValue),
        orderedEquals(['PENDING', 'COMPLETED', 'CLOSED']),
      );
    });

    test('only completed and closed are terminal', () {
      expect(MutationRegistryStatus.pending.isTerminal, isFalse);
      expect(MutationRegistryStatus.completed.isTerminal, isTrue);
      expect(MutationRegistryStatus.closed.isTerminal, isTrue);
    });
  });

  group('Operation generations', () {
    MutationOperationGenerations generations({
      String recovery = operationId,
      String domain = otherId,
    }) => MutationOperationGenerations(
      recoveryGeneration: recovery,
      domainGeneration: domain,
    );

    test('normalizes and compares generations', () {
      final first = generations();
      final second = generations(
        recovery: operationId.toUpperCase(),
        domain: otherId.toUpperCase(),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('detects changed recovery generation', () {
      expect(generations(recovery: profileId), isNot(generations()));
    });

    test('detects changed domain generation', () {
      expect(generations(domain: profileId), isNot(generations()));
    });

    for (final invalid in ['', 'invalid', nilId]) {
      test('rejects invalid recovery generation: $invalid', () {
        expect(() => generations(recovery: invalid), throwsArgumentError);
      });

      test('rejects invalid domain generation: $invalid', () {
        expect(() => generations(domain: invalid), throwsArgumentError);
      });
    }
  });

  group('Immutable request snapshots and receipts', () {
    final generations = MutationOperationGenerations(
      recoveryGeneration: operationId,
      domainGeneration: otherId,
    );

    final fingerprint = MutationRequestFingerprint(List.filled(64, 'a').join());

    MutationRequestSnapshot snapshot({
      Map<String, Object?> parameters = const {},
    }) => MutationRequestSnapshot(
      identity: identity(),
      generations: generations,
      parameters: parameters,
    );

    MutationOperationReceipt receipt({
      MutationOperationIdentity? operation,
      MutationOperationGenerations? operationGenerations,
      MutationRegistryStatus status = MutationRegistryStatus.completed,
      MutationReceiptOutcome outcome = MutationReceiptOutcome.succeeded,
      MutationRequestFingerprint? requestFingerprint,
      bool omitFingerprint = false,
      int version = 1,
      String resultStatus = 'success',
      Map<String, Object?> payload = const {},
    }) => MutationOperationReceipt(
      identity: operation ?? identity(),
      generations: operationGenerations ?? generations,
      registryStatus: status,
      outcome: outcome,
      receiptSchemaVersion: version,
      resultStatus: resultStatus,
      resultPayload: payload,
      fingerprint: omitFingerprint ? null : requestFingerprint ?? fingerprint,
    );

    test('fingerprint normalizes hexadecimal case', () {
      final uppercase = MutationRequestFingerprint(
        fingerprint.value.toUpperCase(),
      );
      expect(uppercase, fingerprint);
      expect(uppercase.hashCode, fingerprint.hashCode);
    });

    for (final invalid in [
      '',
      List.filled(63, 'a').join(),
      List.filled(65, 'a').join(),
      List.filled(64, 'g').join(),
    ]) {
      test('rejects invalid fingerprint length ${invalid.length}', () {
        expect(() => MutationRequestFingerprint(invalid), throwsArgumentError);
      });
    }

    test('snapshot copies the source map', () {
      final input = <String, Object?>{'row_version': 1};
      final captured = snapshot(parameters: input);
      input['row_version'] = 2;
      expect(captured.parameters['row_version'], 1);
    });

    test('snapshot map cannot be modified', () {
      final captured = snapshot();
      expect(() => captured.parameters['new'] = 1, throwsUnsupportedError);
    });

    test('snapshot deeply copies nested maps and lists', () {
      final nested = <String, Object?>{'value': 1};
      final list = <Object?>[nested];
      final captured = snapshot(parameters: {'items': list});

      nested['value'] = 2;
      list.clear();

      expect(captured.parameters['items'], [
        {'value': 1},
      ]);
    });

    test('nested map cannot be modified', () {
      final captured = snapshot(
        parameters: {
          'nested': {'value': 1},
        },
      );
      final nested = captured.parameters['nested'] as Map<String, Object?>;

      expect(() => nested['value'] = 2, throwsUnsupportedError);
    });

    test('nested list cannot be modified', () {
      final captured = snapshot(
        parameters: {
          'items': [1, 2],
        },
      );
      final items = captured.parameters['items'] as List<Object?>;
      expect(() => items.add(3), throwsUnsupportedError);
    });

    test('preserves explicit null and supported JSON values', () {
      final captured = snapshot(
        parameters: {
          'null_value': null,
          'flag': true,
          'integer': 1,
          'decimal': 1.5,
          'text': 'value',
        },
      );
      expect(captured.parameters.containsKey('null_value'), isTrue);
      expect(captured.parameters['null_value'], isNull);
      expect(captured.parameters['flag'], isTrue);
      expect(captured.parameters['integer'], 1);
      expect(captured.parameters['decimal'], 1.5);
      expect(captured.parameters['text'], 'value');
    });

    for (final key in [
      'lock_token',
      'access_token',
      'refresh_token',
      'authorization',
      'target_client_id',
      'target_session_id',
      'client_instance_id',
      'session_id',
    ]) {
      test('rejects forbidden key $key', () {
        expect(
          () => snapshot(parameters: {key: 'secret'}),
          throwsArgumentError,
        );
      });
    }

    test('rejects nested credentials', () {
      expect(
        () => snapshot(
          parameters: {
            'nested': {'LOCK_TOKEN': 'secret'},
          },
        ),
        throwsArgumentError,
      );
    });

    test('rejects empty parameter key', () {
      expect(() => snapshot(parameters: {'': 1}), throwsArgumentError);
    });

    for (final invalid in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
      DateTime.utc(2026),
      Object(),
    ]) {
      test('rejects unsupported value $invalid', () {
        expect(
          () => snapshot(parameters: {'value': invalid}),
          throwsArgumentError,
        );
      });
    }

    test('receipt copies result payload', () {
      final payload = <String, Object?>{'row_version': 2};
      final historical = receipt(payload: payload);
      payload['row_version'] = 3;
      expect(historical.resultPayload['row_version'], 2);
    });

    test('receipt payload cannot be modified', () {
      final historical = receipt();
      expect(() => historical.resultPayload['new'] = 1, throwsUnsupportedError);
    });

    test('success maps to succeeded', () {
      expect(receipt().outcome.localState, MutationOperationState.succeeded);
    });

    test('rejection maps to rejected', () {
      expect(
        receipt(
          outcome: MutationReceiptOutcome.rejected,
          resultStatus: 'rejected',
        ).outcome.localState,
        MutationOperationState.rejected,
      );
    });

    test('closed maps to resolved', () {
      expect(
        receipt(
          status: MutationRegistryStatus.closed,
          outcome: MutationReceiptOutcome.neutralized,
          resultStatus: 'closed',
        ).outcome.localState,
        MutationOperationState.resolved,
      );
    });

    test('rejects pending terminal receipt', () {
      expect(
        () => receipt(status: MutationRegistryStatus.pending),
        throwsArgumentError,
      );
    });

    test('rejects closed success', () {
      expect(
        () => receipt(status: MutationRegistryStatus.closed),
        throwsArgumentError,
      );
    });

    test('rejects closed rejection', () {
      expect(
        () => receipt(
          status: MutationRegistryStatus.closed,
          outcome: MutationReceiptOutcome.rejected,
        ),
        throwsArgumentError,
      );
    });

    test('rejects completed neutralization', () {
      expect(
        () => receipt(outcome: MutationReceiptOutcome.neutralized),
        throwsArgumentError,
      );
    });

    test('rejects completed without fingerprint', () {
      expect(() => receipt(omitFingerprint: true), throwsArgumentError);
    });

    test('closed may lack fingerprint for preventive closure', () {
      final historical = receipt(
        status: MutationRegistryStatus.closed,
        outcome: MutationReceiptOutcome.neutralized,
        resultStatus: 'closed',
        omitFingerprint: true,
      );
      expect(historical.fingerprint, isNull);
      expect(
        historical.correlatesWith(snapshot(), expectedFingerprint: fingerprint),
        isFalse,
      );
    });

    test('rejects invalid receipt schema version', () {
      expect(() => receipt(version: 0), throwsArgumentError);
    });

    test('rejects empty result status', () {
      expect(() => receipt(resultStatus: ''), throwsArgumentError);
    });

    test('rejects whitespace result status', () {
      expect(() => receipt(resultStatus: ' success '), throwsArgumentError);
    });

    test('correlates matching identity generations and fingerprint', () {
      expect(
        receipt().correlatesWith(snapshot(), expectedFingerprint: fingerprint),
        isTrue,
      );
    });

    test('rejects correlation with different operation', () {
      expect(
        receipt(
          operation: identity(operation: otherId),
        ).correlatesWith(snapshot(), expectedFingerprint: fingerprint),
        isFalse,
      );
    });

    test('rejects correlation with different generations', () {
      expect(
        receipt(
          operationGenerations: MutationOperationGenerations(
            recoveryGeneration: otherId,
            domainGeneration: operationId,
          ),
        ).correlatesWith(snapshot(), expectedFingerprint: fingerprint),
        isFalse,
      );
    });

    test('rejects correlation with different fingerprint', () {
      expect(
        receipt().correlatesWith(
          snapshot(),
          expectedFingerprint: MutationRequestFingerprint(
            List.filled(64, 'b').join(),
          ),
        ),
        isFalse,
      );
    });
  });
}
