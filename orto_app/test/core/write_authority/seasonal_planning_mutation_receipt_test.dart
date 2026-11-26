import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/core/write_authority/mutation_operation_contract.dart';
import 'package:orto_app/core/write_authority/mutation_operation_coordinator.dart';
import 'package:orto_app/core/write_authority/mutation_operation_journal.dart';
import 'package:orto_app/core/write_authority/seasonal_planning_mutation_service.dart';
import 'package:orto_app/core/write_authority/seasonal_planning_mutation_transport.dart';

void main() {
  const plannedId = '55555555-5555-4555-8555-555555555555';
  final identity = MutationOperationIdentity(
    profileId: '11111111-1111-4111-8111-111111111111',
    operationId: '22222222-2222-4222-8222-222222222222',
    operationType: MutationOperationType.confirmPlannedPlanting,
    requestSchemaVersion: 1,
  );
  final generations = MutationOperationGenerations(
    recoveryGeneration: '33333333-3333-4333-8333-333333333333',
    domainGeneration: '44444444-4444-4444-8444-444444444444',
  );
  final snapshot = MutationRequestSnapshot(
    identity: identity,
    generations: generations,
    parameters: {
      'target_planned_planting_id': plannedId,
      'expected_row_version': 1,
    },
  );
  final fingerprint = MutationRequestFingerprint('ab' * 32);
  final response = <String, dynamic>{
    'status': 'COMPLETED',
    'profile_id': identity.profileId,
    'operation_id': identity.operationId,
    'operation_domain': identity.domain.wireValue,
    'operation_type': identity.operationType.wireValue,
    'request_schema_version': 1,
    'receipt_schema_version': 1,
    'recovery_generation': generations.recoveryGeneration,
    'domain_generation': generations.domainGeneration,
    'request_fingerprint': fingerprint.value,
    'outcome': 'succeeded',
    'result_status': 'confirmed',
    'result_payload': {
      'status': 'confirmed',
      'planned_planting_id': plannedId,
      'row_version': 2,
    },
  };

  test('accepts a matching completed receipt', () {
    final receipt = SeasonalPlanningMutationTransport.validateTerminalReceipt(
      response,
      snapshot,
      expectedFingerprint: fingerprint,
    );
    expect(receipt.identity, identity);
    expect(receipt.registryStatus, MutationRegistryStatus.completed);
    expect(receipt.fingerprint, fingerprint);
    expect(receipt.resultPayload, response['result_payload']);
  });

  for (final refreshFails in [false, true]) {
    test(
      refreshFails
          ? 'keeps the journal when refresh fails'
          : 'recovers a persisted fingerprint and finalizes only after refresh',
      () async {
        final coordinator = MutationOperationCoordinator();
        final journal = MutationOperationJournal(_ReceiptTestPersistence());
        final service = SeasonalPlanningMutationService(coordinator, journal);
        final scope = coordinator.scopeOf(identity);
        expect(await journal.prepare(snapshot), isTrue);
        expect(await journal.recordFingerprint(snapshot, fingerprint), isTrue);
        var receiptRead = false;
        final transport = SeasonalPlanningMutationTransport((
          name,
          params,
        ) async {
          expect(name, 'get_seasonal_planning_mutation_receipt');
          expect(params['target_operation_id'], identity.operationId);
          receiptRead = true;
          return response;
        });

        final finalization = service.recoverTerminalFromJournal(
          profileId: identity.profileId,
          transport: transport,
          refresh: (recoveredSnapshot) async {
            expect(recoveredSnapshot.identity, identity);
            expect(receiptRead, isTrue);
            expect(coordinator.canAdmit(scope), isFalse);
            expect(
              (await journal.load(scope)).status,
              MutationJournalReadStatus.present,
            );
            if (refreshFails) throw StateError('Refresh failed');
          },
        );

        if (refreshFails) {
          await expectLater(finalization, throwsStateError);
          expect(
            (await journal.load(scope)).status,
            MutationJournalReadStatus.present,
          );
          expect(
            coordinator.operationOf(scope)?.state,
            MutationOperationState.uncertain,
          );
          expect(coordinator.canAdmit(scope), isFalse);
        } else {
          expect((await finalization)?.identity, identity);
          expect(
            (await journal.load(scope)).status,
            MutationJournalReadStatus.absent,
          );
          expect(coordinator.operationOf(scope), isNull);
          expect(coordinator.canAdmit(scope), isTrue);
        }
      },
    );
  }

  test('repository waits for the refresh before completing', () async {
    final coordinator = MutationOperationCoordinator();
    final journal = MutationOperationJournal(_ReceiptTestPersistence());
    final service = SeasonalPlanningMutationService(coordinator, journal);
    final refreshStarted = Completer<void>();
    final refreshFinished = Completer<void>();
    final lease = ProfileEditLockLease(
      profileId: identity.profileId,
      identity: const AppSessionIdentity(
        clientInstanceId: '88888888-8888-4888-8888-888888888888',
        sessionId: '99999999-9999-4999-8999-999999999999',
      ),
      lockToken: 'test-only',
      expiresAt: DateTime.utc(2099),
      rowVersion: 1,
    );
    final names = <String>[];
    final repository = PlannedPlantingRepository.withProviders(
      (name, parameters) async {
        names.add(name);
        return switch (name) {
          'get_seasonal_planning_mutation_generations' => <String, dynamic>{
            'status': 'ready',
            'recovery_generation': generations.recoveryGeneration,
            'domain_generation': generations.domainGeneration,
          },
          'register_confirm_planned_planting' => <String, dynamic>{
            'status': 'PENDING',
            'request_fingerprint': fingerprint.value,
          },
          'confirm_planned_planting' => <String, dynamic>{
            'status': 'confirmed',
          },
          'get_seasonal_planning_mutation_receipt' => <String, dynamic>{
            ...response,
            'operation_id': parameters['target_operation_id'],
          },
          _ => throw StateError('Unexpected RPC'),
        };
      },
      () => lease,
      mutationService: service,
      refreshAfterMutation: (request) {
        expect(request.parameters, snapshot.parameters);
        refreshStarted.complete();
        return refreshFinished.future;
      },
    );
    final scope = coordinator.scopeOf(identity);
    var completed = false;
    final pending = repository
        .confirmPlannedPlanting(
          plannedPlantingId: plannedId,
          expectedRowVersion: 1,
        )
        .then((result) {
          completed = true;
          return result;
        });

    await Future.any([refreshStarted.future, pending.then<void>((_) {})]);
    expect(refreshStarted.isCompleted, isTrue);
    expect(completed, isFalse);
    expect(coordinator.canAdmit(scope), isFalse);
    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.present,
    );
    refreshFinished.complete();
    await pending;
    expect(completed, isTrue);
    expect(coordinator.canAdmit(scope), isTrue);
    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.absent,
    );
    expect(names, [
      'get_seasonal_planning_mutation_generations',
      'register_confirm_planned_planting',
      'confirm_planned_planting',
      'get_seasonal_planning_mutation_receipt',
    ]);
  });

  final mismatches = <String, String>{
    'operation_id': plannedId,
    'domain_generation': plannedId,
    'request_fingerprint': 'cd' * 32,
  };
  for (final mismatch in mismatches.entries) {
    test('rejects a mismatched ${mismatch.key}', () {
      expect(
        () => SeasonalPlanningMutationTransport.validateTerminalReceipt(
          {...response, mismatch.key: mismatch.value},
          snapshot,
          expectedFingerprint: fingerprint,
        ),
        throwsFormatException,
      );
    });
  }
}

final class _ReceiptTestPersistence implements MutationJournalPersistence {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
