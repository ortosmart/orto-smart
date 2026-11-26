import 'mutation_operation_contract.dart';

/// Availability is separate from the state of an individual mutation.
enum MutationCoordinatorAvailability {
  initializing,
  ready,
  recoveryRequired,
  recoveryBlocked,
}

/// Coordination scope shared by all mutations of the same domain.
typedef MutationScope = ({String profileId, MutationDomain domain});

/// An immutable view of a coordinated operation.
final class CoordinatedMutation {
  const CoordinatedMutation._({required this.snapshot, required this.state});

  final MutationRequestSnapshot snapshot;
  final MutationOperationState state;
}

/// Synchronous, process-local admission and transition coordinator.
///
/// Server authority, durable persistence and authoritative recovery
/// must be supplied by the integration layer. This coordinator alone
/// is not sufficient to authorize a remote mutation.
final class MutationOperationCoordinator {
  final Map<MutationScope, CoordinatedMutation> _operations = {};

  final Map<MutationScope, MutationCoordinatorAvailability> _availability = {};

  final Set<(String, String)> _usedOperationIds = {};

  MutationScope scopeOf(MutationOperationIdentity identity) =>
      (profileId: identity.profileId, domain: identity.domain);

  MutationCoordinatorAvailability availabilityOf(MutationScope scope) =>
      _availability[scope] ?? MutationCoordinatorAvailability.initializing;

  CoordinatedMutation? operationOf(MutationScope scope) => _operations[scope];

  bool canAdmit(MutationScope scope) =>
      availabilityOf(scope) == MutationCoordinatorAvailability.ready &&
      !_operations.containsKey(scope);

  /// The integration layer must verify all readiness conditions first.
  bool markReady(MutationScope scope) {
    if (_operations.containsKey(scope)) {
      return false;
    }

    _availability[scope] = MutationCoordinatorAvailability.ready;
    return true;
  }

  /// Blocks new admission without discarding the current operation.
  void blockAdmission(MutationScope scope) {
    _availability[scope] = MutationCoordinatorAvailability.recoveryBlocked;
  }

  /// Admission occurs synchronously before any asynchronous work.
  bool tryAdmit(MutationRequestSnapshot snapshot) {
    final identity = snapshot.identity;
    final scope = scopeOf(identity);
    final operationKey = (identity.profileId, identity.operationId);

    if (!canAdmit(scope) || _usedOperationIds.contains(operationKey)) {
      return false;
    }

    _usedOperationIds.add(operationKey);

    _operations[scope] = CoordinatedMutation._(
      snapshot: snapshot,
      state: MutationOperationState.inFlight,
    );

    _availability[scope] = MutationCoordinatorAvailability.recoveryRequired;

    return true;
  }

  /// Restores a journal entry without admitting a new remote mutation.
  bool restoreUncertain(MutationRequestSnapshot snapshot) {
    final identity = snapshot.identity;
    final scope = scopeOf(identity);
    final operationKey = (identity.profileId, identity.operationId);
    if (_operations.containsKey(scope) ||
        !_usedOperationIds.add(operationKey)) {
      return false;
    }

    _operations[scope] = CoordinatedMutation._(
      snapshot: snapshot,
      state: MutationOperationState.uncertain,
    );
    _availability[scope] = MutationCoordinatorAvailability.recoveryRequired;
    return true;
  }

  /// Correlation and structural transition checks.
  ///
  /// The caller must independently validate authoritative evidence
  /// before requesting a terminal transition.
  bool transition(
    MutationOperationIdentity identity,
    MutationOperationState next,
  ) {
    final scope = scopeOf(identity);
    final current = _operations[scope];

    if (current == null ||
        current.snapshot.identity != identity ||
        !current.state.canTransitionTo(next)) {
      return false;
    }

    _operations[scope] = CoordinatedMutation._(
      snapshot: current.snapshot,
      state: next,
    );

    return true;
  }

  /// A terminal state alone never restores operational availability.
  ///
  /// The integration layer must first complete durable finalization,
  /// authoritative reconciliation and the required data refresh.
  bool retireTerminal(MutationOperationIdentity identity) {
    final scope = scopeOf(identity);
    final current = _operations[scope];

    if (current == null ||
        current.snapshot.identity != identity ||
        !current.state.isTerminal) {
      return false;
    }

    _operations.remove(scope);

    if (availabilityOf(scope) !=
        MutationCoordinatorAvailability.recoveryBlocked) {
      _availability[scope] = MutationCoordinatorAvailability.recoveryRequired;
    }

    return true;
  }
}
