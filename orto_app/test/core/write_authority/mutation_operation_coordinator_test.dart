import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/write_authority/mutation_operation_contract.dart';
import 'package:orto_app/core/write_authority/mutation_operation_coordinator.dart';

void main() {
  const profile = '11111111-1111-4111-8111-111111111111';
  const otherProfile = '22222222-2222-4222-8222-222222222222';
  const firstId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  const secondId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

  MutationRequestSnapshot snapshot({
    String profileId = profile,
    String operationId = firstId,
    MutationOperationType type = MutationOperationType.createPlannedPlanting,
  }) => MutationRequestSnapshot(
    identity: MutationOperationIdentity(
      profileId: profileId,
      operationId: operationId,
      operationType: type,
      requestSchemaVersion: 1,
    ),
    generations: MutationOperationGenerations(
      recoveryGeneration: firstId,
      domainGeneration: secondId,
    ),
    parameters: const {},
  );

  group('Mutation coordinator', () {
    late MutationOperationCoordinator coordinator;
    late MutationRequestSnapshot first;
    late MutationScope scope;

    setUp(() {
      coordinator = MutationOperationCoordinator();
      first = snapshot();
      scope = coordinator.scopeOf(first.identity);
    });

    test('initial availability is fail closed', () {
      expect(
        coordinator.availabilityOf(scope),
        MutationCoordinatorAvailability.initializing,
      );
      expect(coordinator.canAdmit(scope), isFalse);
      expect(coordinator.tryAdmit(first), isFalse);
    });

    test('ready scope admits synchronously', () {
      expect(coordinator.markReady(scope), isTrue);
      expect(coordinator.tryAdmit(first), isTrue);
      expect(
        coordinator.operationOf(scope)?.state,
        MutationOperationState.inFlight,
      );
      expect(coordinator.canAdmit(scope), isFalse);
    });

    for (final initial in MutationOperationType.values) {
      for (final competing in MutationOperationType.values) {
        test('blocks ${initial.name} then ${competing.name}', () {
          final admitted = snapshot(type: initial);
          final contender = snapshot(operationId: secondId, type: competing);

          coordinator.markReady(scope);

          expect(coordinator.tryAdmit(admitted), isTrue);
          expect(coordinator.tryAdmit(contender), isFalse);
          expect(
            coordinator.operationOf(scope)?.snapshot.identity,
            admitted.identity,
          );
        });
      }
    }

    test('different profiles have independent admission', () {
      final other = snapshot(profileId: otherProfile);
      final otherScope = coordinator.scopeOf(other.identity);

      coordinator.markReady(scope);
      coordinator.markReady(otherScope);

      expect(coordinator.tryAdmit(first), isTrue);
      expect(coordinator.tryAdmit(other), isTrue);
    });

    test('cannot mark an occupied scope ready', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);

      expect(coordinator.markReady(scope), isFalse);
    });

    test('uncertainty preserves exclusion', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);

      expect(
        coordinator.transition(
          first.identity,
          MutationOperationState.uncertain,
        ),
        isTrue,
      );

      expect(coordinator.canAdmit(scope), isFalse);
      expect(coordinator.retireTerminal(first.identity), isFalse);
    });

    test('reconciliation cannot be bypassed', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.transition(first.identity, MutationOperationState.uncertain);

      expect(
        coordinator.transition(
          first.identity,
          MutationOperationState.succeeded,
        ),
        isFalse,
      );

      expect(
        coordinator.transition(
          first.identity,
          MutationOperationState.reconciling,
        ),
        isTrue,
      );

      expect(
        coordinator.transition(first.identity, MutationOperationState.resolved),
        isTrue,
      );
    });

    test('terminal state cannot be reopened', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.transition(first.identity, MutationOperationState.succeeded);

      expect(
        coordinator.transition(first.identity, MutationOperationState.inFlight),
        isFalse,
      );
    });

    test('terminal outcome does not restore admission', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.transition(first.identity, MutationOperationState.succeeded);

      expect(coordinator.canAdmit(scope), isFalse);
      expect(coordinator.retireTerminal(first.identity), isTrue);
      expect(coordinator.canAdmit(scope), isFalse);

      expect(coordinator.markReady(scope), isTrue);
      expect(coordinator.canAdmit(scope), isTrue);
    });

    test('retired operation identity cannot be reused', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.transition(first.identity, MutationOperationState.rejected);
      coordinator.retireTerminal(first.identity);
      coordinator.markReady(scope);

      expect(coordinator.tryAdmit(first), isFalse);

      expect(
        coordinator.tryAdmit(
          snapshot(type: MutationOperationType.updatePlannedPlanting),
        ),
        isFalse,
      );

      expect(coordinator.tryAdmit(snapshot(operationId: secondId)), isTrue);
    });

    test('late response cannot change a newer operation', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.transition(first.identity, MutationOperationState.succeeded);
      coordinator.retireTerminal(first.identity);
      coordinator.markReady(scope);

      final second = snapshot(operationId: secondId);
      coordinator.tryAdmit(second);

      expect(
        coordinator.transition(first.identity, MutationOperationState.rejected),
        isFalse,
      );

      expect(coordinator.retireTerminal(first.identity), isFalse);

      expect(
        coordinator.operationOf(scope)?.snapshot.identity,
        second.identity,
      );
    });

    test('blocking admission preserves the current operation', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.blockAdmission(scope);

      expect(
        coordinator.availabilityOf(scope),
        MutationCoordinatorAvailability.recoveryBlocked,
      );
      expect(coordinator.operationOf(scope)?.snapshot, first);
      expect(coordinator.canAdmit(scope), isFalse);
    });

    test('retiring terminal operation preserves recovery block', () {
      coordinator.markReady(scope);
      coordinator.tryAdmit(first);
      coordinator.blockAdmission(scope);

      coordinator.transition(first.identity, MutationOperationState.rejected);

      expect(coordinator.retireTerminal(first.identity), isTrue);

      expect(
        coordinator.availabilityOf(scope),
        MutationCoordinatorAvailability.recoveryBlocked,
      );
    });

    test('unknown operation cannot transition or retire', () {
      expect(
        coordinator.transition(
          first.identity,
          MutationOperationState.succeeded,
        ),
        isFalse,
      );

      expect(coordinator.retireTerminal(first.identity), isFalse);
    });
  });
}
