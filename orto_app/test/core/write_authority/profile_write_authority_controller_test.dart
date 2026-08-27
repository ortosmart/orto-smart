import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _clientInstanceId = '22222222-2222-4222-8222-222222222222';
const _sessionId = '33333333-3333-4333-8333-333333333333';
const _fakeToken = 'token-controller-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

const _ownerContext = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

const _workerContext = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.worker,
);

Map<String, dynamic> _acquiredResponse({
  int rowVersion = 1,
  String expiresAt = '2026-08-26T22:02:00+00:00',
}) {
  return {
    'status': 'acquired',
    'lock_token': _fakeToken,
    'expires_at': expiresAt,
    'row_version': rowVersion,
  };
}

class _NetworkFailure implements Exception {
  const _NetworkFailure();
}

class _QueuedRpc {
  final Queue<Object?> responses = Queue<Object?>();
  final List<String> functionNames = [];
  final List<Map<String, dynamic>> parameters = [];

  void enqueue(Object? response) {
    responses.add(response);
  }

  Future<dynamic> call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    functionNames.add(functionName);
    this.parameters.add(Map<String, dynamic>.from(parameters));

    if (responses.isEmpty) {
      throw StateError('Missing fake RPC response.');
    }

    final response = responses.removeFirst();

    if (response is Exception) {
      throw response;
    }

    return response;
  }
}

class _ManualScheduledTask implements ScheduledWriteAuthorityTask {
  final ScheduledWriteAuthorityAction _action;

  bool _isActive = true;

  _ManualScheduledTask(this._action);

  @override
  bool get isActive => _isActive;

  @override
  void cancel() {
    _isActive = false;
  }

  Future<void> run() async {
    if (!_isActive) {
      return;
    }

    _isActive = false;
    await _action();
  }
}

class _ManualScheduler implements WriteAuthorityScheduler {
  final Queue<_ManualScheduledTask> _tasks = Queue<_ManualScheduledTask>();

  final List<Duration> delays = [];

  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    final task = _ManualScheduledTask(action);

    delays.add(delay);
    _tasks.add(task);

    return task;
  }

  Future<void> runNext() async {
    while (_tasks.isNotEmpty && !_tasks.first.isActive) {
      _tasks.removeFirst();
    }

    if (_tasks.isEmpty) {
      throw StateError('No scheduled task available.');
    }

    final task = _tasks.removeFirst();
    await task.run();
  }
}

void main() {
  late _QueuedRpc rpc;
  late _ManualScheduler scheduler;
  late ProfileWriteAuthorityController controller;

  var now = DateTime.utc(2026, 8, 26, 22);

  setUp(() {
    now = DateTime.utc(2026, 8, 26, 22);
    rpc = _QueuedRpc();
    scheduler = _ManualScheduler();

    controller = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(rpc.call),
      scheduler,
      utcNow: () => now,
    );

    addTearDown(controller.dispose);
  });

  test('worker remains read only without acquiring a lock', () async {
    await controller.initialize(
      profileContext: _workerContext,
      identity: _identity,
    );

    expect(controller.status, ProfileWriteAuthorityStatus.readOnlyMember);
    expect(controller.canWrite, isFalse);
    expect(rpc.functionNames, isEmpty);
    expect(scheduler.delays, isEmpty);
    expect(
      controller.requireLeaseForWrite,
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );
  });

  test('owner becomes writer after a valid acquisition', () async {
    rpc.enqueue(_acquiredResponse());

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(controller.requireLeaseForWrite().lockToken, _fakeToken);
    expect(scheduler.delays, [
      ProfileWriteAuthorityController.heartbeatInterval,
    ]);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);
  });
  final acquisitionCases =
      <(String serverStatus, ProfileWriteAuthorityStatus expectedStatus)>[
        ('already_held', ProfileWriteAuthorityStatus.alreadyHeldWithoutToken),
        ('busy', ProfileWriteAuthorityStatus.busy),
        ('forbidden', ProfileWriteAuthorityStatus.forbidden),
        ('invalid_input', ProfileWriteAuthorityStatus.protocolError),
      ];

  for (final acquisitionCase in acquisitionCases) {
    test('maps acquisition ${acquisitionCase.$1}', () async {
      rpc.enqueue({'status': acquisitionCase.$1});

      await controller.initialize(
        profileContext: _ownerContext,
        identity: _identity,
      );

      expect(controller.status, acquisitionCase.$2);
      expect(controller.canWrite, isFalse);
      expect(
        controller.requireLeaseForWrite,
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(scheduler.delays, isEmpty);
    });
  }

  test('retries acquisition after a network failure', () async {
    rpc
      ..enqueue(const _NetworkFailure())
      ..enqueue(_acquiredResponse());

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    expect(controller.status, ProfileWriteAuthorityStatus.recovering);
    expect(controller.canWrite, isFalse);
    expect(scheduler.delays, [ProfileWriteAuthorityController.retryInterval]);

    await scheduler.runNext();

    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(scheduler.delays, [
      ProfileWriteAuthorityController.retryInterval,
      ProfileWriteAuthorityController.heartbeatInterval,
    ]);
  });
  test('renews the lease after the normal heartbeat interval', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:02:30+00:00',
        'row_version': 2,
      });

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    await scheduler.runNext();

    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(controller.rowVersion, 2);
    expect(scheduler.delays, [
      ProfileWriteAuthorityController.heartbeatInterval,
      ProfileWriteAuthorityController.heartbeatInterval,
    ]);
  });

  test('suspends writes and retries after heartbeat network failure', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue(const _NetworkFailure())
      ..enqueue({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:02:40+00:00',
        'row_version': 2,
      });

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    await scheduler.runNext();

    expect(controller.status, ProfileWriteAuthorityStatus.recovering);
    expect(controller.canWrite, isFalse);
    expect(
      controller.requireLeaseForWrite,
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );
    expect(
      scheduler.delays.last,
      ProfileWriteAuthorityController.retryInterval,
    );

    await scheduler.runNext();

    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(controller.rowVersion, 2);
    expect(
      scheduler.delays.last,
      ProfileWriteAuthorityController.heartbeatInterval,
    );
  });
  final heartbeatLossCases =
      <(String serverStatus, ProfileWriteAuthorityStatus expectedStatus)>[
        ('not_holder', ProfileWriteAuthorityStatus.lost),
        ('forbidden', ProfileWriteAuthorityStatus.forbidden),
      ];

  for (final heartbeatCase in heartbeatLossCases) {
    test('heartbeat ${heartbeatCase.$1} removes write authority', () async {
      rpc
        ..enqueue(_acquiredResponse())
        ..enqueue({'status': heartbeatCase.$1});

      await controller.initialize(
        profileContext: _ownerContext,
        identity: _identity,
      );

      await scheduler.runNext();

      expect(controller.status, heartbeatCase.$2);
      expect(controller.canWrite, isFalse);
      expect(controller.expiresAt, isNull);
      expect(controller.rowVersion, isNull);
      expect(
        controller.requireLeaseForWrite,
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(scheduler.delays, [
        ProfileWriteAuthorityController.heartbeatInterval,
      ]);
    });
  }

  test('malformed heartbeat response fails closed', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue({
        'status': 'renewed',
        'expires_at': 'data-non-valida',
        'row_version': 2,
      });

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    await scheduler.runNext();

    expect(controller.status, ProfileWriteAuthorityStatus.protocolError);
    expect(controller.canWrite, isFalse);
    expect(controller.expiresAt, isNull);
  });
  test('an expired local lease is removed before a write', () async {
    rpc.enqueue(_acquiredResponse());

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    now = DateTime.utc(2026, 8, 26, 22, 3);

    expect(controller.canWrite, isFalse);
    expect(
      controller.requireLeaseForWrite,
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );
    expect(controller.status, ProfileWriteAuthorityStatus.lost);
    expect(controller.expiresAt, isNull);
  });

  test('verifyNow suspends writes until the server renews the lease', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:02:20+00:00',
        'row_version': 2,
      });

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    await controller.verifyNow();

    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(controller.rowVersion, 2);
  });

  test('release removes local authority immediately', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue({'status': 'released'});

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final result = await controller.release();

    expect(result, isNotNull);
    expect(controller.status, ProfileWriteAuthorityStatus.released);
    expect(controller.canWrite, isFalse);
    expect(controller.expiresAt, isNull);
    expect(controller.rowVersion, isNull);
    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
    ]);
  });

  test('release stays fail-closed after a network failure', () async {
    rpc
      ..enqueue(_acquiredResponse())
      ..enqueue(const _NetworkFailure());

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final result = await controller.release();

    expect(result, isNull);
    expect(controller.status, ProfileWriteAuthorityStatus.released);
    expect(controller.canWrite, isFalse);
    expect(controller.expiresAt, isNull);
  });
  test('releases a stale acquisition after the Profile changes', () async {
    final acquisitionCompleter = Completer<dynamic>();

    rpc
      ..enqueue(acquisitionCompleter.future)
      ..enqueue({'status': 'released'});

    final previousInitialization = controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    await controller.initialize(
      profileContext: _workerContext,
      identity: _identity,
    );

    acquisitionCompleter.complete(_acquiredResponse());

    await previousInitialization;

    expect(controller.status, ProfileWriteAuthorityStatus.readOnlyMember);
    expect(controller.canWrite, isFalse);
    expect(controller.expiresAt, isNull);
    expect(controller.rowVersion, isNull);
    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
    ]);
    expect(scheduler.delays, isEmpty);
  });
}
