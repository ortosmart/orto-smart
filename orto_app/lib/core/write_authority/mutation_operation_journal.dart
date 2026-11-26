import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'mutation_operation_contract.dart';
import 'mutation_operation_coordinator.dart';

/// Local persistence is not authoritative evidence of a server outcome.
abstract interface class MutationJournalPersistence {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}

/// Existing application dependency. No cached preference reads.
///
/// This adapter does not guarantee transactional or crash-safe durability.
final class SharedPreferencesMutationJournalPersistence
    implements MutationJournalPersistence {
  SharedPreferencesMutationJournalPersistence({this._preferences});

  SharedPreferencesAsync? _preferences;

  SharedPreferencesAsync get _storage =>
      _preferences ??= SharedPreferencesAsync();

  @override
  Future<String?> read(String key) => _storage.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _storage.setString(key, value);

  @override
  Future<void> remove(String key) => _storage.remove(key);
}

enum MutationJournalReadStatus { absent, present, blocked }

final class MutationJournalReadResult {
  const MutationJournalReadResult._(
    this.status,
    this.snapshot, [
    this.fingerprint,
  ]);

  final MutationJournalReadStatus status;
  final MutationRequestSnapshot? snapshot;
  final MutationRequestFingerprint? fingerprint;
}

/// Versioned local write-ahead record.
///
/// Any recovered request is uncertain until authoritative reconciliation.
/// Local storage never proves that a remote mutation was not executed.
final class MutationOperationJournal {
  MutationOperationJournal(this._persistence);

  final MutationJournalPersistence _persistence;

  static const int formatVersion = 1;

  final Set<String> _busyKeys = {};

  String _key(MutationScope scope) {
    final identity = MutationOperationIdentity(
      profileId: scope.profileId,
      operationId: scope.profileId,
      operationType: MutationOperationType.createPlannedPlanting,
      requestSchemaVersion: 1,
    );

    return 'orto.mutation.v1.${identity.profileId}.${scope.domain.wireValue}';
  }

  String _encode(
    MutationRequestSnapshot snapshot, {
    MutationRequestFingerprint? fingerprint,
  }) => jsonEncode({
    'format_version': formatVersion,
    'profile_id': snapshot.identity.profileId,
    'operation_id': snapshot.identity.operationId,
    'operation_type': snapshot.identity.operationType.wireValue,
    'request_schema_version': snapshot.identity.requestSchemaVersion,
    'recovery_generation': snapshot.generations.recoveryGeneration,
    'domain_generation': snapshot.generations.domainGeneration,
    'parameters': snapshot.parameters,
    if (fingerprint != null) 'request_fingerprint': fingerprint.value,
  });

  MutationRequestSnapshot _decode(String raw, MutationScope scope) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    data.remove('request_fingerprint');

    const requiredKeys = {
      'format_version',
      'profile_id',
      'operation_id',
      'operation_type',
      'request_schema_version',
      'recovery_generation',
      'domain_generation',
      'parameters',
    };

    if (data.length != requiredKeys.length ||
        !data.keys.every(requiredKeys.contains) ||
        data['format_version'] is! int ||
        data['format_version'] != formatVersion) {
      throw const FormatException('Unsupported journal format.');
    }

    final type = MutationOperationType.values.singleWhere(
      (type) => type.wireValue == data['operation_type'],
    );

    final identity = MutationOperationIdentity(
      profileId: data['profile_id'] as String,
      operationId: data['operation_id'] as String,
      operationType: type,
      requestSchemaVersion: data['request_schema_version'] as int,
    );

    if (identity.profileId != scope.profileId.toLowerCase() ||
        identity.domain != scope.domain ||
        identity.requestSchemaVersion != 1) {
      throw const FormatException('Incompatible journal scope or contract.');
    }

    return MutationRequestSnapshot(
      identity: identity,
      generations: MutationOperationGenerations(
        recoveryGeneration: data['recovery_generation'] as String,
        domainGeneration: data['domain_generation'] as String,
      ),
      parameters: Map<String, Object?>.from(data['parameters'] as Map),
    );
  }

  MutationRequestFingerprint? _readFingerprint(String raw) {
    final data = jsonDecode(raw) as Map<String, dynamic>;
    if (!data.containsKey('request_fingerprint')) return null;
    final fingerprint = data['request_fingerprint'];
    if (fingerprint is! String) {
      throw const FormatException('Invalid journal fingerprint.');
    }
    return MutationRequestFingerprint(fingerprint);
  }

  Future<MutationJournalReadResult> load(MutationScope scope) async {
    try {
      final key = _key(scope);

      if (_busyKeys.contains(key)) {
        return const MutationJournalReadResult._(
          MutationJournalReadStatus.blocked,
          null,
        );
      }

      final raw = await _persistence.read(key);

      if (_busyKeys.contains(key)) {
        return const MutationJournalReadResult._(
          MutationJournalReadStatus.blocked,
          null,
        );
      }

      if (raw == null) {
        return const MutationJournalReadResult._(
          MutationJournalReadStatus.absent,
          null,
        );
      }

      return MutationJournalReadResult._(
        MutationJournalReadStatus.present,
        _decode(raw, scope),
        _readFingerprint(raw),
      );
    } catch (_) {
      return const MutationJournalReadResult._(
        MutationJournalReadStatus.blocked,
        null,
      );
    }
  }

  Future<bool> recordFingerprint(
    MutationRequestSnapshot snapshot,
    MutationRequestFingerprint fingerprint,
  ) async {
    final scope = (
      profileId: snapshot.identity.profileId,
      domain: snapshot.identity.domain,
    );
    final key = _key(scope);
    if (!_busyKeys.add(key)) return false;
    try {
      final stored = await _persistence.read(key);
      final updated = _encode(snapshot, fingerprint: fingerprint);
      if (stored == updated) return true;
      if (stored != _encode(snapshot)) return false;
      await _persistence.write(key, updated);
      return await _persistence.read(key) == updated;
    } catch (_) {
      return false;
    } finally {
      _busyKeys.remove(key);
    }
  }

  /// Call only after validating the authoritative terminal outcome.
  Future<bool> removeMatching(
    MutationRequestSnapshot snapshot, {
    MutationRequestFingerprint? expectedFingerprint,
  }) async {
    final scope = (
      profileId: snapshot.identity.profileId,
      domain: snapshot.identity.domain,
    );
    final key = _key(scope);
    if (!_busyKeys.add(key)) {
      return false;
    }

    try {
      final stored = await _persistence.read(key);
      if (stored != _encode(snapshot) &&
          stored != _encode(snapshot, fingerprint: expectedFingerprint)) {
        return false;
      }
      await _persistence.remove(key);
      return await _persistence.read(key) == null;
    } catch (_) {
      return false;
    } finally {
      _busyKeys.remove(key);
    }
  }

  /// Never replaces an existing unresolved record.
  ///
  /// A failed write or read-back must prevent remote invocation.
  Future<bool> prepare(MutationRequestSnapshot snapshot) async {
    final scope = (
      profileId: snapshot.identity.profileId,
      domain: snapshot.identity.domain,
    );

    final key = _key(scope);

    if (!_busyKeys.add(key)) {
      return false;
    }

    try {
      if (snapshot.identity.requestSchemaVersion != 1 ||
          await _persistence.read(key) != null) {
        return false;
      }

      final encoded = _encode(snapshot);

      await _persistence.write(key, encoded);

      return await _persistence.read(key) == encoded;
    } catch (_) {
      return false;
    } finally {
      _busyKeys.remove(key);
    }
  }
}
