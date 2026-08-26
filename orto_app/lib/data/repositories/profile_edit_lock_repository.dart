import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/identity/app_session_identity.dart';
import '../../core/write_authority/profile_edit_lock.dart';

typedef ProfileEditLockRpcInvoker =
    Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    );

class ProfileEditLockRepository {
  final ProfileEditLockRpcInvoker _invokeRpc;

  factory ProfileEditLockRepository({SupabaseClient? supabase}) {
    final client = supabase ?? Supabase.instance.client;

    return ProfileEditLockRepository.withRpcInvoker((functionName, parameters) {
      return client.rpc(functionName, params: parameters);
    });
  }

  ProfileEditLockRepository.withRpcInvoker(this._invokeRpc);
  Future<AcquireProfileEditLockResult> acquire({
    required String profileId,
    required AppSessionIdentity identity,
  }) async {
    final response = await _invokeRpc('acquire_profile_edit_lock', {
      'target_profile_id': profileId,
      'target_client_id': identity.clientInstanceId,
      'target_session_id': identity.sessionId,
    });

    final payload = _responseMap(response);
    final status = payload['status'];

    return switch (status) {
      'acquired' => ProfileEditLockAcquired(
        ProfileEditLockLease(
          profileId: profileId,
          identity: identity,
          lockToken: _requiredNonEmptyString(payload, 'lock_token'),
          expiresAt: _requiredDateTime(payload, 'expires_at'),
          rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        ),
      ),
      'already_held' => const ProfileEditLockAlreadyHeld(),
      'busy' => const ProfileEditLockBusy(),
      'forbidden' => const ProfileEditLockAcquireForbidden(),
      'invalid_input' => const ProfileEditLockAcquireInvalidInput(),
      _ => throw const ProfileEditLockProtocolException(),
    };
  }

  Future<HeartbeatProfileEditLockResult> heartbeat(
    ProfileEditLockLease lease,
  ) async {
    final response = await _invokeRpc('heartbeat_profile_edit_lock', {
      'target_profile_id': lease.profileId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
    });

    final payload = _responseMap(response);
    final status = payload['status'];

    return switch (status) {
      'renewed' => ProfileEditLockRenewed(
        lease.renewed(
          expiresAt: _requiredDateTime(payload, 'expires_at'),
          rowVersion: _requiredPositiveInteger(payload, 'row_version'),
        ),
      ),
      'not_holder' => const ProfileEditLockHeartbeatNotHolder(),
      'forbidden' => const ProfileEditLockHeartbeatForbidden(),
      _ => throw const ProfileEditLockProtocolException(),
    };
  }

  Future<ReleaseProfileEditLockResult> release(
    ProfileEditLockLease lease,
  ) async {
    final response = await _invokeRpc('release_profile_edit_lock', {
      'target_profile_id': lease.profileId,
      'target_client_id': lease.identity.clientInstanceId,
      'target_session_id': lease.identity.sessionId,
      'lock_token': lease.lockToken,
    });

    final payload = _responseMap(response);
    final status = payload['status'];

    return switch (status) {
      'released' => const ProfileEditLockReleased(),
      'not_holder' => const ProfileEditLockReleaseNotHolder(),
      'transfer_pending' => const ProfileEditLockTransferPending(),
      'forbidden' => const ProfileEditLockReleaseForbidden(),
      _ => throw const ProfileEditLockProtocolException(),
    };
  }

  Map<String, dynamic> _responseMap(dynamic response) {
    if (response is! Map) {
      throw const ProfileEditLockProtocolException();
    }

    try {
      return Map<String, dynamic>.from(response);
    } on Object {
      throw const ProfileEditLockProtocolException();
    }
  }

  String _requiredNonEmptyString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String || value.trim().isEmpty) {
      throw const ProfileEditLockProtocolException();
    }

    return value;
  }

  DateTime _requiredDateTime(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! String) {
      throw const ProfileEditLockProtocolException();
    }

    final parsedValue = DateTime.tryParse(value);

    if (parsedValue == null) {
      throw const ProfileEditLockProtocolException();
    }

    return parsedValue.toUtc();
  }

  int _requiredPositiveInteger(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is! int || value < 1) {
      throw const ProfileEditLockProtocolException();
    }

    return value;
  }
}
