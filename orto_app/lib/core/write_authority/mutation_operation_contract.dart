/// Domain in which mutation admission is coordinated.
enum MutationDomain {
  seasonalPlanning('seasonal_planning');

  const MutationDomain(this.wireValue);

  final String wireValue;
}

/// Supported authoritative mutations.
enum MutationOperationType {
  createPlannedPlanting('create_planned_planting'),
  updatePlannedPlanting('update_planned_planting'),
  confirmPlannedPlanting('confirm_planned_planting'),
  cancelPlannedPlanting('cancel_planned_planting'),
  executePlannedPlanting('execute_planned_planting');

  const MutationOperationType(this.wireValue);

  final String wireValue;

  MutationDomain get domain => MutationDomain.seasonalPlanning;
}

/// Local operation state, independent of route and write authority.
enum MutationOperationState {
  idle,
  inFlight,
  succeeded,
  rejected,
  uncertain,
  reconciling,
  resolved;

  bool get isTerminal =>
      this == succeeded || this == rejected || this == resolved;

  bool get blocksAdmission =>
      this == inFlight || this == uncertain || this == reconciling;

  /// Structural transition only. Authoritative evidence is required
  /// separately before accepting a terminal outcome.
  bool canTransitionTo(MutationOperationState next) => switch (this) {
    idle => next == inFlight,
    inFlight => next == succeeded || next == rejected || next == uncertain,
    uncertain => next == reconciling,
    reconciling =>
      next == succeeded ||
          next == rejected ||
          next == uncertain ||
          next == resolved,
    succeeded || rejected || resolved => false,
  };
}

/// Persistent server registry state.
///
/// A terminal state must never be reopened.
enum MutationRegistryStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  closed('CLOSED');

  const MutationRegistryStatus(this.wireValue);

  final String wireValue;

  bool get isTerminal => this != pending;
}

/// Immutable correlation identity.
///
/// This identity is not a credential and does not grant write authority.
/// Session IDs, lease tokens and device IDs are deliberately excluded.
final class MutationOperationIdentity {
  MutationOperationIdentity({
    required String profileId,
    required String operationId,
    required this.operationType,
    required this.requestSchemaVersion,
  }) : profileId = _validatedUuid(profileId, 'profileId'),
       operationId = _validatedUuid(operationId, 'operationId') {
    if (requestSchemaVersion < 1) {
      throw ArgumentError.value(
        requestSchemaVersion,
        'requestSchemaVersion',
        'Must be positive.',
      );
    }
  }

  final String profileId;
  final String operationId;
  final MutationOperationType operationType;
  final int requestSchemaVersion;

  MutationDomain get domain => operationType.domain;

  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  );

  static String _validatedUuid(String value, String name) {
    final normalized = value.toLowerCase();

    if (!_uuidPattern.hasMatch(normalized) ||
        normalized == '00000000-0000-0000-0000-000000000000') {
      throw ArgumentError.value(value, name, 'Invalid UUID.');
    }

    return normalized;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutationOperationIdentity &&
          profileId == other.profileId &&
          operationId == other.operationId &&
          operationType == other.operationType &&
          requestSchemaVersion == other.requestSchemaVersion;

  @override
  int get hashCode =>
      Object.hash(profileId, operationId, operationType, requestSchemaVersion);
}

/// Server-issued generations associated with an immutable request.
///
/// These values are not credentials. They must not be replaced
/// automatically when recovering an uncertain operation.
final class MutationOperationGenerations {
  MutationOperationGenerations({
    required String recoveryGeneration,
    required String domainGeneration,
  }) : recoveryGeneration = MutationOperationIdentity._validatedUuid(
         recoveryGeneration,
         'recoveryGeneration',
       ),
       domainGeneration = MutationOperationIdentity._validatedUuid(
         domainGeneration,
         'domainGeneration',
       );

  final String recoveryGeneration;
  final String domainGeneration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutationOperationGenerations &&
          recoveryGeneration == other.recoveryGeneration &&
          domainGeneration == other.domainGeneration;

  @override
  int get hashCode => Object.hash(recoveryGeneration, domainGeneration);
}

/// An immutable SHA-256 fingerprint issued by the authoritative server.
///
/// This class validates the representation, not the authenticity of
/// the fingerprint or its correspondence to a request.
final class MutationRequestFingerprint {
  MutationRequestFingerprint(String value) : value = value.toLowerCase() {
    if (!_pattern.hasMatch(this.value)) {
      throw ArgumentError.value(value, 'value', 'Invalid SHA-256.');
    }
  }

  final String value;

  static final RegExp _pattern = RegExp(r'^[0-9a-f]{64}$');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MutationRequestFingerprint && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Immutable request data, excluding authentication and lease credentials.
///
/// Operation-specific semantic validation remains mandatory before
/// registration and execution.
final class MutationRequestSnapshot {
  MutationRequestSnapshot({
    required this.identity,
    required this.generations,
    required Map<String, Object?> parameters,
  }) : parameters = _freezeMutationMap(parameters);

  final MutationOperationIdentity identity;
  final MutationOperationGenerations generations;
  final Map<String, Object?> parameters;
}

/// A historical terminal outcome, independent of current entity state.
enum MutationReceiptOutcome {
  succeeded,
  rejected,
  neutralized;

  MutationOperationState get localState => switch (this) {
    succeeded => MutationOperationState.succeeded,
    rejected => MutationOperationState.rejected,
    neutralized => MutationOperationState.resolved,
  };
}

/// Immutable terminal receipt.
///
/// A neutralized operation cannot execute in the future, but this does
/// not by itself establish that it never executed historically.
final class MutationOperationReceipt {
  MutationOperationReceipt({
    required this.identity,
    required this.generations,
    required this.registryStatus,
    required this.outcome,
    required this.receiptSchemaVersion,
    required this.resultStatus,
    required Map<String, Object?> resultPayload,
    this.fingerprint,
  }) : resultPayload = _freezeMutationMap(resultPayload) {
    if (receiptSchemaVersion < 1) {
      throw ArgumentError.value(receiptSchemaVersion, 'receiptSchemaVersion');
    }

    if (resultStatus.isEmpty || resultStatus.trim() != resultStatus) {
      throw ArgumentError.value(resultStatus, 'resultStatus');
    }

    if (!registryStatus.isTerminal) {
      throw ArgumentError('A terminal receipt cannot be pending.');
    }

    if (registryStatus == MutationRegistryStatus.closed &&
        outcome != MutationReceiptOutcome.neutralized) {
      throw ArgumentError('Closed requires neutralized outcome.');
    }

    if (registryStatus == MutationRegistryStatus.completed &&
        outcome == MutationReceiptOutcome.neutralized) {
      throw ArgumentError('Completed cannot be neutralized.');
    }

    if (registryStatus == MutationRegistryStatus.completed &&
        fingerprint == null) {
      throw ArgumentError('Completed requires a fingerprint.');
    }
  }

  final MutationOperationIdentity identity;
  final MutationOperationGenerations generations;
  final MutationRegistryStatus registryStatus;
  final MutationReceiptOutcome outcome;
  final int receiptSchemaVersion;
  final String resultStatus;
  final Map<String, Object?> resultPayload;
  final MutationRequestFingerprint? fingerprint;

  /// Correlation is necessary but not sufficient for accepting a receipt.
  ///
  /// Schema compatibility, authoritative origin and operation-specific
  /// semantics must be checked separately.
  bool correlatesWith(
    MutationRequestSnapshot snapshot, {
    required MutationRequestFingerprint expectedFingerprint,
  }) =>
      identity == snapshot.identity &&
      generations == snapshot.generations &&
      fingerprint == expectedFingerprint;
}

Map<String, Object?> _freezeMutationMap(Map<String, Object?> source) {
  final result = <String, Object?>{};

  for (final entry in source.entries) {
    final key = entry.key;

    if (key.isEmpty) {
      throw ArgumentError('Empty mutation parameter key.');
    }

    final normalized = key.toLowerCase();

    const forbiddenKeys = {
      'lock_token',
      'locktoken',
      'lease_token',
      'leasetoken',
      'access_token',
      'accesstoken',
      'refresh_token',
      'refreshtoken',
      'authorization',
      'password',
      'target_client_id',
      'target_session_id',
      'client_instance_id',
      'session_id',
      'clientinstanceid',
      'sessionid',
      'targetclientid',
      'targetsessionid',
    };

    if (forbiddenKeys.contains(normalized)) {
      throw ArgumentError('Credentials or session identity are forbidden.');
    }

    result[key] = _freezeMutationValue(entry.value);
  }

  return Map<String, Object?>.unmodifiable(result);
}

Object? _freezeMutationValue(Object? value) {
  if (value == null || value is String || value is bool || value is int) {
    return value;
  }

  if (value is double && value.isFinite) {
    return value;
  }

  if (value is Map<String, Object?>) {
    return _freezeMutationMap(value);
  }

  if (value is List<Object?>) {
    return List<Object?>.unmodifiable(value.map(_freezeMutationValue));
  }

  throw ArgumentError('Unsupported mutation value type.');
}
