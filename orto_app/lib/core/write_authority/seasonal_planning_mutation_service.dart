import 'package:uuid/uuid.dart';

import 'mutation_operation_contract.dart';
import 'mutation_operation_coordinator.dart';
import 'mutation_operation_journal.dart';
import 'profile_edit_lock.dart';
import 'profile_write_authority_controller.dart';
import 'seasonal_planning_mutation_transport.dart';

final class SeasonalPlanningMutationService {
  SeasonalPlanningMutationService(this._coordinator, this._journal);

  final MutationOperationCoordinator _coordinator;
  final MutationOperationJournal _journal;
  final Set<MutationScope> _preparing = {};

  Future<bool> canStartMutation(String profileId) async {
    final scope = (
      profileId: profileId.toLowerCase(),
      domain: MutationDomain.seasonalPlanning,
    );

    bool isIdle() =>
        !_preparing.contains(scope) &&
        _coordinator.operationOf(scope) == null &&
        _coordinator.availabilityOf(scope) !=
            MutationCoordinatorAvailability.recoveryBlocked;

    if (!isIdle()) return false;
    final entry = await _journal.load(scope);
    return entry.status == MutationJournalReadStatus.absent && isIdle();
  }

  Future<MutationRequestSnapshot?> restoreFromJournal(String profileId) async {
    final scope = (
      profileId: profileId.toLowerCase(),
      domain: MutationDomain.seasonalPlanning,
    );
    if (!_preparing.add(scope)) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    try {
      final current = _coordinator.operationOf(scope);
      if (current != null) {
        if (current.state != MutationOperationState.uncertain) {
          throw const ProfileWriteAuthorityUnavailableException();
        }
        return current.snapshot;
      }

      final entry = await _journal.load(scope);
      if (entry.status == MutationJournalReadStatus.absent) {
        return null;
      }
      final snapshot = entry.snapshot;
      if (entry.status != MutationJournalReadStatus.present ||
          snapshot == null ||
          !_coordinator.restoreUncertain(snapshot)) {
        _coordinator.blockAdmission(scope);
        throw const ProfileWriteAuthorityUnavailableException();
      }
      return snapshot;
    } finally {
      _preparing.remove(scope);
    }
  }

  Future<
    ({
      Map<String, dynamic> response,
      MutationRequestSnapshot snapshot,
      MutationRequestFingerprint fingerprint,
    })
  >
  submit({
    required MutationOperationType operationType,
    required Map<String, Object?> parameters,
    required SeasonalPlanningMutationTransport transport,
    required ProfileEditLockLease Function() requireLease,
  }) async {
    final initialLease = requireLease();
    final identity = MutationOperationIdentity(
      profileId: initialLease.profileId,
      operationId: const Uuid().v4(),
      operationType: operationType,
      requestSchemaVersion: 1,
    );
    final scope = _coordinator.scopeOf(identity);
    if (!_preparing.add(scope)) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    var admitted = false;
    try {
      if (_coordinator.operationOf(scope) != null ||
          _coordinator.availabilityOf(scope) ==
              MutationCoordinatorAvailability.recoveryBlocked) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final journalState = await _journal.load(scope);
      if (journalState.status != MutationJournalReadStatus.absent) {
        _coordinator.blockAdmission(scope);
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final generations = await transport.getGenerations(
        _sameLease(initialLease, requireLease()),
      );
      final snapshot = MutationRequestSnapshot(
        identity: identity,
        generations: generations,
        parameters: parameters,
      );
      if (!_coordinator.markReady(scope) || !_coordinator.tryAdmit(snapshot)) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      admitted = true;
      if (!await _journal.prepare(snapshot)) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final registration = await transport.register(
        snapshot,
        _sameLease(initialLease, requireLease()),
      );
      final rawFingerprint = registration['request_fingerprint'];
      if (registration['status'] != 'PENDING' || rawFingerprint is! String) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final fingerprint = MutationRequestFingerprint(rawFingerprint);
      if (!await _journal.recordFingerprint(snapshot, fingerprint)) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final response = await transport.execute(
        snapshot,
        _sameLease(initialLease, requireLease()),
      );
      return (response: response, snapshot: snapshot, fingerprint: fingerprint);
    } on Object {
      if (admitted) {
        _coordinator.transition(identity, MutationOperationState.uncertain);
      }
      rethrow;
    } finally {
      _preparing.remove(scope);
    }
  }

  Future<MutationOperationReceipt?> recoverTerminalFromJournal({
    required String profileId,
    required SeasonalPlanningMutationTransport transport,
    required Future<void> Function(MutationRequestSnapshot snapshot) refresh,
  }) async {
    final snapshot = await restoreFromJournal(profileId);
    if (snapshot == null) return null;

    final entry = await _journal.load(_coordinator.scopeOf(snapshot.identity));
    if (entry.status != MutationJournalReadStatus.present ||
        entry.snapshot?.identity != snapshot.identity) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    return finalizeTerminal(
      snapshot: snapshot,
      expectedFingerprint: entry.fingerprint,
      transport: transport,
      refresh: () => refresh(snapshot),
    );
  }

  Future<MutationOperationReceipt> finalizeTerminal({
    required MutationRequestSnapshot snapshot,
    required MutationRequestFingerprint? expectedFingerprint,
    required SeasonalPlanningMutationTransport transport,
    required Future<void> Function() refresh,
  }) async {
    final identity = snapshot.identity;
    final scope = _coordinator.scopeOf(identity);
    if (!_preparing.add(scope)) {
      throw const ProfileWriteAuthorityUnavailableException();
    }

    var ownsOperation = false;
    try {
      final current = _coordinator.operationOf(scope);
      if (current == null ||
          current.snapshot.identity != identity ||
          (current.state != MutationOperationState.inFlight &&
              current.state != MutationOperationState.uncertain)) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      ownsOperation = true;
      if (current.state == MutationOperationState.uncertain &&
          !_coordinator.transition(
            identity,
            MutationOperationState.reconciling,
          )) {
        throw const ProfileWriteAuthorityUnavailableException();
      }

      final receipt = SeasonalPlanningMutationTransport.validateTerminalReceipt(
        await transport.readReceipt(identity),
        current.snapshot,
        expectedFingerprint: expectedFingerprint,
      );
      await refresh();
      if (!await _journal.removeMatching(
        current.snapshot,
        expectedFingerprint: expectedFingerprint,
      )) {
        throw const ProfileWriteAuthorityUnavailableException();
      }
      final terminalState = receipt.outcome.localState;
      if (!_coordinator.transition(identity, terminalState) ||
          !_coordinator.retireTerminal(identity) ||
          !_coordinator.markReady(scope)) {
        _coordinator.blockAdmission(scope);
        throw const ProfileWriteAuthorityUnavailableException();
      }
      return receipt;
    } on Object {
      if (ownsOperation) {
        _coordinator.transition(identity, MutationOperationState.uncertain);
      }
      rethrow;
    } finally {
      _preparing.remove(scope);
    }
  }

  static ProfileEditLockLease _sameLease(
    ProfileEditLockLease original,
    ProfileEditLockLease current,
  ) {
    if (original.profileId != current.profileId ||
        original.identity.clientInstanceId !=
            current.identity.clientInstanceId ||
        original.identity.sessionId != current.identity.sessionId ||
        original.lockToken != current.lockToken) {
      throw const ProfileWriteAuthorityUnavailableException();
    }
    return current;
  }
}
