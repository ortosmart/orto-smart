import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/mutation_operation_contract.dart';
import 'package:orto_app/core/write_authority/mutation_operation_coordinator.dart';
import 'package:orto_app/core/write_authority/mutation_operation_journal.dart';
import 'package:orto_app/core/write_authority/seasonal_planning_mutation_service.dart';

final class MemoryPersistence implements MutationJournalPersistence {
  final Map<String, String> values = {};

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  bool failRead = false;
  bool failWrite = false;
  bool discardWrite = false;

  Completer<void>? writeGate;

  @override
  Future<String?> read(String key) async {
    if (failRead) {
      throw StateError('Read failed');
    }

    return values[key];
  }

  @override
  Future<void> write(String key, String value) async {
    if (failWrite) {
      throw StateError('Write failed');
    }

    final gate = writeGate;

    if (gate != null) {
      await gate.future;
    }

    if (!discardWrite) {
      values[key] = value;
    }
  }
}

void main() {
  test('removes only the matching snapshot', () async {
    final journal = MutationOperationJournal(MemoryPersistence());
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
    final scope = (profileId: identity.profileId, domain: identity.domain);
    MutationRequestSnapshot request(int version) => MutationRequestSnapshot(
      identity: identity,
      generations: generations,
      parameters: {
        'target_planned_planting_id': '55555555-5555-4555-8555-555555555555',
        'expected_row_version': version,
      },
    );

    final original = request(1);
    expect(await journal.prepare(original), isTrue);
    expect(await journal.removeMatching(request(2)), isFalse);
    final retained = await journal.load(scope);
    expect(retained.status, MutationJournalReadStatus.present);
    expect(retained.snapshot?.parameters, original.parameters);

    final freshCoordinator = MutationOperationCoordinator();
    final service = SeasonalPlanningMutationService(freshCoordinator, journal);
    final recovered = await service.restoreFromJournal(identity.profileId);
    expect(recovered?.identity, identity);
    expect(recovered?.parameters, original.parameters);
    expect(
      freshCoordinator.operationOf(scope)?.state,
      MutationOperationState.uncertain,
    );
    expect(freshCoordinator.canAdmit(scope), isFalse);

    expect(await journal.removeMatching(original), isTrue);
    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.absent,
    );
  });

  const profile = '11111111-1111-4111-8111-111111111111';
  const otherProfile = '22222222-2222-4222-8222-222222222222';
  const firstId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const secondId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

  MutationRequestSnapshot snapshot({
    String profileId = profile,
    String operationId = firstId,
    int version = 1,
  }) => MutationRequestSnapshot(
    identity: MutationOperationIdentity(
      profileId: profileId,
      operationId: operationId,
      operationType: MutationOperationType.createPlannedPlanting,
      requestSchemaVersion: version,
    ),
    generations: MutationOperationGenerations(
      recoveryGeneration: firstId,
      domainGeneration: secondId,
    ),
    parameters: const {
      'expected_value': 1,
      'optional_value': null,
      'nested': {
        'items': [1, true, 'value'],
      },
    },
  );

  const MutationScope scope = (
    profileId: profile,
    domain: MutationDomain.seasonalPlanning,
  );

  late MemoryPersistence persistence;
  late MutationOperationJournal journal;

  setUp(() {
    persistence = MemoryPersistence();
    journal = MutationOperationJournal(persistence);
  });

  test('missing record is absent, not authoritative resolution', () async {
    final result = await journal.load(scope);

    expect(result.status, MutationJournalReadStatus.absent);
    expect(result.snapshot, isNull);
  });

  test('prepares and restores immutable request', () async {
    final original = snapshot();

    expect(await journal.prepare(original), isTrue);

    final restarted = MutationOperationJournal(persistence);
    final result = await restarted.load(scope);

    expect(result.status, MutationJournalReadStatus.present);
    expect(result.snapshot?.identity, original.identity);
    expect(result.snapshot?.generations, original.generations);
    expect(result.snapshot?.parameters, original.parameters);
  });

  test('existing record cannot be overwritten', () async {
    expect(await journal.prepare(snapshot()), isTrue);

    final original = persistence.values.values.single;

    expect(await journal.prepare(snapshot(operationId: secondId)), isFalse);

    expect(persistence.values.values.single, original);
  });

  test('duplicate prepare is rejected while first write is pending', () async {
    persistence.writeGate = Completer<void>();

    final first = journal.prepare(snapshot());

    expect(await journal.prepare(snapshot(operationId: secondId)), isFalse);

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );

    persistence.writeGate!.complete();

    expect(await first, isTrue);
  });

  test('profiles have separate records', () async {
    expect(await journal.prepare(snapshot()), isTrue);

    expect(await journal.prepare(snapshot(profileId: otherProfile)), isTrue);

    expect(persistence.values.length, 2);

    final result = await journal.load(scope);

    expect(result.snapshot?.identity.profileId, profile);
  });

  test('read failure blocks recovery and preparation', () async {
    persistence.failRead = true;

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );

    expect(await journal.prepare(snapshot()), isFalse);
    expect(persistence.values, isEmpty);
  });

  test('write failure rejects preparation', () async {
    persistence.failWrite = true;

    expect(await journal.prepare(snapshot()), isFalse);
  });

  test('missing read-back rejects preparation', () async {
    persistence.discardWrite = true;

    expect(await journal.prepare(snapshot()), isFalse);
  });

  test('corrupt record is preserved and blocks admission', () async {
    await journal.prepare(snapshot());

    final key = persistence.values.keys.single;
    persistence.values[key] = '{invalid';

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );

    expect(await journal.prepare(snapshot()), isFalse);
    expect(persistence.values[key], '{invalid');
  });

  test('unknown journal format is preserved', () async {
    await journal.prepare(snapshot());

    final key = persistence.values.keys.single;
    final raw = persistence.values[key]!.replaceFirst(
      '"format_version":1',
      '"format_version":2',
    );

    persistence.values[key] = raw;

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );

    expect(persistence.values[key], raw);
  });

  test('unsupported request version cannot be prepared', () async {
    expect(await journal.prepare(snapshot(version: 2)), isFalse);
  });

  test('record belonging to another profile is blocked', () async {
    await journal.prepare(snapshot());

    final key = persistence.values.keys.single;
    persistence.values[key] = persistence.values[key]!.replaceFirst(
      profile,
      otherProfile,
    );

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );
  });

  test('stored credential fields cause recovery block', () async {
    await journal.prepare(snapshot());

    final key = persistence.values.keys.single;
    persistence.values[key] = persistence.values[key]!.replaceFirst(
      '"expected_value":1',
      '"lock_token":"invalid-test-value"',
    );

    expect(
      (await journal.load(scope)).status,
      MutationJournalReadStatus.blocked,
    );
  });
}
