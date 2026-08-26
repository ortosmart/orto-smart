import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _clientInstanceId = '22222222-2222-4222-8222-222222222222';
const _sessionId = '33333333-3333-4333-8333-333333333333';
const _fakeToken = 'token-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

ProfileEditLockLease _lease({int rowVersion = 1}) {
  return ProfileEditLockLease(
    profileId: _profileId,
    identity: _identity,
    lockToken: _fakeToken,
    expiresAt: DateTime.utc(2026, 8, 26, 22),
    rowVersion: rowVersion,
  );
}

class _RpcRecorder {
  dynamic response;
  String? functionName;
  Map<String, dynamic>? parameters;

  Future<dynamic> call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    this.functionName = functionName;
    this.parameters = Map<String, dynamic>.from(parameters);

    return response;
  }
}

void main() {
  late _RpcRecorder rpc;
  late ProfileEditLockRepository repository;

  setUp(() {
    rpc = _RpcRecorder();
    repository = ProfileEditLockRepository.withRpcInvoker(rpc.call);
  });

  group('acquire', () {
    test('creates a lease only from a complete acquired response', () async {
      rpc.response = {
        'status': 'acquired',
        'lock_token': _fakeToken,
        'expires_at': '2026-08-26T22:02:00+00:00',
        'row_version': 4,
      };

      final result = await repository.acquire(
        profileId: _profileId,
        identity: _identity,
      );

      expect(result, isA<ProfileEditLockAcquired>());

      final lease = (result as ProfileEditLockAcquired).lease;

      expect(lease.profileId, _profileId);
      expect(lease.identity, same(_identity));
      expect(lease.lockToken, _fakeToken);
      expect(lease.expiresAt, DateTime.utc(2026, 8, 26, 22, 2));
      expect(lease.rowVersion, 4);
      expect(lease.toString(), isNot(contains(_fakeToken)));

      expect(rpc.functionName, 'acquire_profile_edit_lock');
      expect(rpc.parameters, {
        'target_profile_id': _profileId,
        'target_client_id': _clientInstanceId,
        'target_session_id': _sessionId,
      });
    });

    final statusCases = <String, Matcher>{
      'already_held': isA<ProfileEditLockAlreadyHeld>(),
      'busy': isA<ProfileEditLockBusy>(),
      'forbidden': isA<ProfileEditLockAcquireForbidden>(),
      'invalid_input': isA<ProfileEditLockAcquireInvalidInput>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final result = await repository.acquire(
          profileId: _profileId,
          identity: _identity,
        );

        expect(result, statusCase.value);
      });
    }
    test('rejects an incomplete acquired response', () async {
      rpc.response = {
        'status': 'acquired',
        'expires_at': '2026-08-26T22:02:00+00:00',
        'row_version': 4,
      };

      await expectLater(
        repository.acquire(profileId: _profileId, identity: _identity),
        throwsA(isA<ProfileEditLockProtocolException>()),
      );
    });

    test('rejects an unknown status', () async {
      rpc.response = {'status': 'stato-sconosciuto'};

      await expectLater(
        repository.acquire(profileId: _profileId, identity: _identity),
        throwsA(isA<ProfileEditLockProtocolException>()),
      );
    });

    test('rejects a response that is not an object', () async {
      rpc.response = 'risposta-non-valida';

      await expectLater(
        repository.acquire(profileId: _profileId, identity: _identity),
        throwsA(isA<ProfileEditLockProtocolException>()),
      );
    });
  });
  group('heartbeat', () {
    test('renews the lease while preserving identity and token', () async {
      final originalLease = _lease(rowVersion: 4);

      rpc.response = {
        'status': 'renewed',
        'expires_at': '2026-08-26T22:04:00+00:00',
        'row_version': 5,
      };

      final result = await repository.heartbeat(originalLease);

      expect(result, isA<ProfileEditLockRenewed>());

      final renewedLease = (result as ProfileEditLockRenewed).lease;

      expect(renewedLease.profileId, originalLease.profileId);
      expect(renewedLease.identity, same(originalLease.identity));
      expect(renewedLease.lockToken, originalLease.lockToken);
      expect(renewedLease.expiresAt, DateTime.utc(2026, 8, 26, 22, 4));
      expect(renewedLease.rowVersion, 5);

      expect(rpc.functionName, 'heartbeat_profile_edit_lock');
      expect(rpc.parameters, {
        'target_profile_id': _profileId,
        'target_client_id': _clientInstanceId,
        'target_session_id': _sessionId,
        'lock_token': _fakeToken,
      });
    });

    final statusCases = <String, Matcher>{
      'not_holder': isA<ProfileEditLockHeartbeatNotHolder>(),
      'forbidden': isA<ProfileEditLockHeartbeatForbidden>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final result = await repository.heartbeat(_lease());

        expect(result, statusCase.value);
      });
    }

    test('rejects malformed renewal data', () async {
      rpc.response = {
        'status': 'renewed',
        'expires_at': 'data-non-valida',
        'row_version': 0,
      };

      await expectLater(
        repository.heartbeat(_lease()),
        throwsA(isA<ProfileEditLockProtocolException>()),
      );
    });
  });
  group('release', () {
    final statusCases = <String, Matcher>{
      'released': isA<ProfileEditLockReleased>(),
      'not_holder': isA<ProfileEditLockReleaseNotHolder>(),
      'transfer_pending': isA<ProfileEditLockTransferPending>(),
      'forbidden': isA<ProfileEditLockReleaseForbidden>(),
    };

    for (final statusCase in statusCases.entries) {
      test('maps ${statusCase.key}', () async {
        rpc.response = {'status': statusCase.key};

        final result = await repository.release(_lease());

        expect(result, statusCase.value);
        expect(rpc.functionName, 'release_profile_edit_lock');
        expect(rpc.parameters, {
          'target_profile_id': _profileId,
          'target_client_id': _clientInstanceId,
          'target_session_id': _sessionId,
          'lock_token': _fakeToken,
        });
      });
    }

    test('rejects an unknown status', () async {
      rpc.response = {'status': 'stato-sconosciuto'};

      await expectLater(
        repository.release(_lease()),
        throwsA(isA<ProfileEditLockProtocolException>()),
      );
    });
  });
}
