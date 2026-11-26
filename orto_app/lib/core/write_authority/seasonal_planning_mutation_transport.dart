import 'mutation_operation_contract.dart';
import 'profile_edit_lock.dart';
import 'profile_write_authority_controller.dart';

typedef SeasonalPlanningRpcInvoker =
    Future<dynamic> Function(String functionName, Map<String, dynamic> params);

final class SeasonalPlanningMutationTransport {
  const SeasonalPlanningMutationTransport(this._invoke);

  final SeasonalPlanningRpcInvoker _invoke;

  Future<MutationOperationGenerations> getGenerations(
    ProfileEditLockLease lease,
  ) async {
    final response = await _call(
      'get_seasonal_planning_mutation_generations',
      _leaseParameters(lease),
    );
    if (response['status'] == 'registry_unavailable') {
      throw const ProfileWriteAuthorityUnavailableException();
    }
    final recoveryGeneration = response['recovery_generation'];
    final domainGeneration = response['domain_generation'];
    if (response['status'] != 'ready' ||
        recoveryGeneration is! String ||
        domainGeneration is! String) {
      throw const FormatException('Invalid mutation generations response.');
    }
    return MutationOperationGenerations(
      recoveryGeneration: recoveryGeneration,
      domainGeneration: domainGeneration,
    );
  }

  Future<Map<String, dynamic>> register(
    MutationRequestSnapshot snapshot,
    ProfileEditLockLease lease,
  ) => _call(
    'register_${snapshot.identity.operationType.wireValue}',
    _mutationParameters(snapshot, lease),
  );

  Future<Map<String, dynamic>> execute(
    MutationRequestSnapshot snapshot,
    ProfileEditLockLease lease,
  ) => _call(
    snapshot.identity.operationType.wireValue,
    _mutationParameters(snapshot, lease),
  );

  Future<Map<String, dynamic>> readReceipt(
    MutationOperationIdentity identity,
  ) => _call('get_seasonal_planning_mutation_receipt', {
    'target_profile_id': identity.profileId,
    'target_operation_id': identity.operationId,
  });

  Future<Map<String, dynamic>> closeIntent(
    MutationRequestSnapshot snapshot,
    ProfileEditLockLease lease,
  ) {
    final identity = snapshot.identity;
    if (identity.profileId != lease.profileId.toLowerCase()) {
      throw const ProfileWriteAuthorityUnavailableException();
    }
    return _call('close_seasonal_planning_mutation_intent', {
      ..._leaseParameters(lease),
      'target_operation_id': identity.operationId,
      'target_operation_type': identity.operationType.wireValue,
      'target_request_schema_version': identity.requestSchemaVersion,
      'target_recovery_generation': snapshot.generations.recoveryGeneration,
      'target_domain_generation': snapshot.generations.domainGeneration,
    });
  }

  static MutationOperationReceipt validateTerminalReceipt(
    Map<String, dynamic> response,
    MutationRequestSnapshot snapshot, {
    required MutationRequestFingerprint? expectedFingerprint,
  }) {
    final identity = snapshot.identity;
    final generations = snapshot.generations;
    if (response['profile_id'] != identity.profileId ||
        response['operation_id'] != identity.operationId ||
        response['operation_domain'] != identity.domain.wireValue ||
        response['operation_type'] != identity.operationType.wireValue ||
        response['request_schema_version'] != identity.requestSchemaVersion ||
        response['receipt_schema_version'] != 1 ||
        response['recovery_generation'] != generations.recoveryGeneration ||
        response['domain_generation'] != generations.domainGeneration) {
      throw const FormatException('Mutation receipt correlation failed.');
    }

    final status = response['status'];
    final rawOutcome = response['outcome'];
    final rawFingerprint = response['request_fingerprint'];
    final resultStatus = response['result_status'];
    final resultPayload = response['result_payload'];
    final registryStatus = switch (status) {
      'COMPLETED' => MutationRegistryStatus.completed,
      'CLOSED' => MutationRegistryStatus.closed,
      _ => throw const FormatException('Mutation receipt is not terminal.'),
    };

    final outcome = switch (rawOutcome) {
      'succeeded' => MutationReceiptOutcome.succeeded,
      'rejected' => MutationReceiptOutcome.rejected,
      'neutralized' => MutationReceiptOutcome.neutralized,
      _ => throw const FormatException('Invalid mutation receipt outcome.'),
    };

    final fingerprint = switch (rawFingerprint) {
      null => null,
      String value => MutationRequestFingerprint(value),
      _ => throw const FormatException('Invalid mutation receipt fingerprint.'),
    };

    if (!response.containsKey('request_fingerprint') ||
        fingerprint != expectedFingerprint ||
        (registryStatus == MutationRegistryStatus.completed &&
            fingerprint == null) ||
        resultStatus is! String ||
        resultPayload is! Map<String, dynamic>) {
      throw const FormatException('Invalid mutation receipt content.');
    }

    if (registryStatus == MutationRegistryStatus.closed) {
      if (resultStatus != 'neutralized' || resultPayload.isNotEmpty) {
        throw const FormatException('Invalid closed mutation receipt.');
      }
    } else if (resultPayload['status'] != resultStatus) {
      throw const FormatException('Mutation receipt result status mismatch.');
    }

    return MutationOperationReceipt(
      identity: identity,
      generations: generations,
      registryStatus: registryStatus,
      outcome: outcome,
      receiptSchemaVersion: 1,
      resultStatus: resultStatus,
      resultPayload: resultPayload,
      fingerprint: fingerprint,
    );
  }

  Future<Map<String, dynamic>> _call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    final response = await _invoke(functionName, parameters);
    if (response is! Map<String, dynamic> || response['status'] is! String) {
      throw const FormatException('Invalid planning mutation response.');
    }
    return response;
  }

  static Map<String, dynamic> _mutationParameters(
    MutationRequestSnapshot snapshot,
    ProfileEditLockLease lease,
  ) {
    final identity = snapshot.identity;
    if (identity.profileId != lease.profileId.toLowerCase() ||
        identity.domain != MutationDomain.seasonalPlanning ||
        identity.requestSchemaVersion != 1) {
      throw const ProfileWriteAuthorityUnavailableException();
    }
    return {
      ...snapshot.parameters,
      ..._leaseParameters(lease),
      'operation_id': identity.operationId,
      'request_schema_version': identity.requestSchemaVersion,
      'recovery_generation': snapshot.generations.recoveryGeneration,
      'domain_generation': snapshot.generations.domainGeneration,
    };
  }

  static Map<String, dynamic> _leaseParameters(ProfileEditLockLease lease) => {
    'target_profile_id': lease.profileId,
    'target_client_id': lease.identity.clientInstanceId,
    'target_session_id': lease.identity.sessionId,
    'lock_token': lease.lockToken,
  };
}
