import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/route_write_availability.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _token = 'token-route-esclusivamente-fittizio';

const _identity = AppSessionIdentity(
  clientInstanceId: '22222222-2222-4222-8222-222222222222',
  sessionId: '33333333-3333-4333-8333-333333333333',
);

const _ownerContext = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

class _QueuedRpc {
  final responses = Queue<Object?>();
  final functionNames = <String>[];

  Future<dynamic> call(
    String functionName,
    Map<String, dynamic> parameters,
  ) async {
    functionNames.add(functionName);

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

class _ManualTask implements ScheduledWriteAuthorityTask {
  final ScheduledWriteAuthorityAction action;

  bool _active = true;

  _ManualTask(this.action);

  @override
  bool get isActive => _active;

  @override
  void cancel() {
    _active = false;
  }

  Future<void> run() async {
    if (!_active) {
      return;
    }

    _active = false;
    await action();
  }
}

class _ManualScheduler implements WriteAuthorityScheduler {
  final tasks = <_ManualTask>[];
  final delays = <Duration>[];

  int get activeCount => tasks.where((task) => task.isActive).length;

  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    final task = _ManualTask(action);
    tasks.add(task);
    delays.add(delay);
    return task;
  }
}

void main() {
  late DateTime now;
  late _QueuedRpc rpc;
  late _ManualScheduler controllerScheduler;
  late _ManualScheduler routeScheduler;
  late ProfileWriteAuthorityController controller;

  setUp(() {
    now = DateTime.utc(2026, 8, 26, 22);
    rpc = _QueuedRpc();
    controllerScheduler = _ManualScheduler();
    routeScheduler = _ManualScheduler();

    controller = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(rpc.call),
      controllerScheduler,
      utcNow: () => now,
    );

    addTearDown(controller.dispose);
  });

  Future<ProfileEditLockLease> acquire() async {
    rpc.responses.add({
      'status': 'acquired',
      'lock_token': _token,
      'expires_at': '2026-08-26T22:02:00+00:00',
      'row_version': 1,
    });

    await controller.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    return controller.requireLeaseForWrite();
  }

  RouteWriteAvailability createAvailability({
    required ProfileEditLockLease? lease,
    bool Function()? contextValid,
  }) {
    final availability = RouteWriteAvailability(
      authority: controller,
      originalLease: lease,
      isContextValid: contextValid ?? () => true,
      scheduler: routeScheduler,
    );

    addTearDown(availability.dispose);

    return availability;
  }

  test('route without authority remains read only', () {
    final availability = RouteWriteAvailability(
      authority: null,
      originalLease: null,
      isContextValid: () => true,
      scheduler: routeScheduler,
    );

    addTearDown(availability.dispose);

    expect(availability.canWrite, isFalse);
    expect(routeScheduler.activeCount, 0);
    expect(rpc.functionNames, isEmpty);
  });

  test('route opened without lease remains read only', () async {
    final availability = createAvailability(lease: null);

    var notifications = 0;
    availability.addListener(() => notifications++);

    expect(availability.canWrite, isFalse);

    await acquire();
    availability.refresh();

    expect(controller.canWrite, isTrue);
    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);
  });

  test('valid original lease enables route writes', () async {
    final lease = await acquire();
    final rpcCount = rpc.functionNames.length;

    final availability = createAvailability(lease: lease);

    expect(availability.canWrite, isTrue);
    expect(routeScheduler.activeCount, 1);
    expect(routeScheduler.delays.single, const Duration(minutes: 2));
    expect(rpc.functionNames.length, rpcCount);
  });

  test('invalid initial context disables route writes', () async {
    final lease = await acquire();

    final availability = createAvailability(
      lease: lease,
      contextValid: () => false,
    );

    expect(availability.canWrite, isFalse);
    expect(routeScheduler.activeCount, 0);
  });

  test('route disables writes at lease expiry without heartbeat', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;
    availability.addListener(() => notifications++);

    final rpcCount = rpc.functionNames.length;

    now = DateTime.utc(2026, 8, 26, 22, 2);

    expect(availability.canWrite, isFalse);

    await routeScheduler.tasks.single.run();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);
    expect(rpc.functionNames.length, rpcCount);
    expect(controller.status, ProfileWriteAuthorityStatus.writer);
  });

  test('route refresh disables writes when context becomes invalid', () async {
    final lease = await acquire();
    var valid = true;

    final availability = createAvailability(
      lease: lease,
      contextValid: () => valid,
    );

    var notifications = 0;
    availability.addListener(() => notifications++);

    valid = false;
    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);

    availability.refresh();

    expect(notifications, 1);
  });

  test('route refresh restores valid original context', () async {
    final lease = await acquire();
    var valid = true;

    final availability = createAvailability(
      lease: lease,
      contextValid: () => valid,
    );

    var notifications = 0;
    availability.addListener(() => notifications++);

    valid = false;
    availability.refresh();

    valid = true;
    availability.refresh();

    expect(availability.canWrite, isTrue);
    expect(notifications, 2);
    expect(routeScheduler.activeCount, 1);
  });

  test('context validation exception fails closed', () async {
    final lease = await acquire();
    var fail = false;

    final availability = createAvailability(
      lease: lease,
      contextValid: () {
        if (fail) {
          throw StateError('Context unavailable');
        }

        return true;
      },
    );

    var notifications = 0;
    availability.addListener(() => notifications++);

    fail = true;
    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);
  });

  test('obsolete expiry callback cannot alter current schedule', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;
    availability.addListener(() => notifications++);

    final obsoleteTask = routeScheduler.tasks.single;

    availability.refresh();

    expect(obsoleteTask.isActive, isFalse);
    expect(routeScheduler.activeCount, 1);

    final taskCount = routeScheduler.tasks.length;

    await obsoleteTask.action();

    expect(availability.canWrite, isTrue);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 1);
    expect(routeScheduler.tasks.length, taskCount);
  });

  test(
    'route preserves writes and reschedules expiry after lease renewal',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);

      var notifications = 0;
      availability.addListener(() => notifications++);

      final obsoleteTask = routeScheduler.tasks.single;

      rpc.responses.add({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:04:00+00:00',
        'row_version': 2,
      });

      now = now.add(const Duration(seconds: 30));

      await controllerScheduler.tasks
          .where((task) => task.isActive)
          .single
          .run();

      expect(controller.rowVersion, 2);
      expect(availability.canWrite, isTrue);
      expect(notifications, 0);
      expect(obsoleteTask.isActive, isFalse);
      expect(routeScheduler.activeCount, 1);
      expect(
        routeScheduler.delays.last,
        const Duration(minutes: 3, seconds: 30),
      );

      now = DateTime.utc(2026, 8, 26, 22, 2);
      await obsoleteTask.action();

      expect(availability.canWrite, isTrue);
      expect(notifications, 0);
      expect(routeScheduler.activeCount, 1);

      now = DateTime.utc(2026, 8, 26, 22, 4);

      await routeScheduler.tasks.where((task) => task.isActive).single.run();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      expect(rpc.functionNames, [
        'acquire_profile_edit_lock',
        'heartbeat_profile_edit_lock',
      ]);
    },
  );

  test(
    'route disables writes during recovery and restores original lease',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);

      var notifications = 0;
      availability.addListener(() => notifications++);

      rpc.responses.add(Exception('Simulated network failure'));

      rpc.responses.add({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:04:00+00:00',
        'row_version': 2,
      });

      now = now.add(const Duration(seconds: 30));

      await controllerScheduler.tasks
          .where((task) => task.isActive)
          .single
          .run();

      expect(controller.status, ProfileWriteAuthorityStatus.recovering);
      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      now = now.add(const Duration(seconds: 10));

      await controllerScheduler.tasks
          .where((task) => task.isActive)
          .single
          .run();

      expect(controller.status, ProfileWriteAuthorityStatus.writer);
      expect(controller.rowVersion, 2);
      expect(availability.canWrite, isTrue);
      expect(notifications, 2);
      expect(routeScheduler.activeCount, 1);

      expect(
        routeScheduler.delays.last,
        const Duration(minutes: 3, seconds: 20),
      );

      expect(rpc.functionNames, [
        'acquire_profile_edit_lock',
        'heartbeat_profile_edit_lock',
        'heartbeat_profile_edit_lock',
      ]);
    },
  );

  test(
    'route remains read only after release and acquisition with a different token',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);

      var notifications = 0;
      availability.addListener(() => notifications++);

      final obsoleteTask = routeScheduler.tasks.single;

      expect(availability.canWrite, isTrue);

      rpc.responses.add({'status': 'released'});

      await controller.release();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(obsoleteTask.isActive, isFalse);
      expect(routeScheduler.activeCount, 0);

      rpc.responses.add({
        'status': 'acquired',
        'lock_token': 'token-route-nuovo-esclusivamente-fittizio',
        'expires_at': '2026-08-26T22:05:00+00:00',
        'row_version': 1,
      });

      await controller.initialize(
        profileContext: _ownerContext,
        identity: _identity,
      );

      expect(controller.canWrite, isTrue);
      expect(controller.canWriteWithLease(lease), isFalse);
      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      availability.refresh();
      await obsoleteTask.action();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      expect(rpc.functionNames, [
        'acquire_profile_edit_lock',
        'release_profile_edit_lock',
        'acquire_profile_edit_lock',
      ]);
    },
  );

  test(
    'disposed route cancels expiry and ignores subsequent authority changes',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);

      var notifications = 0;
      availability.addListener(() => notifications++);

      final obsoleteTask = routeScheduler.tasks.single;

      availability.dispose();

      expect(availability.canWrite, isFalse);
      expect(obsoleteTask.isActive, isFalse);
      expect(routeScheduler.activeCount, 0);

      rpc.responses.add({
        'status': 'renewed',
        'expires_at': '2026-08-26T22:04:00+00:00',
        'row_version': 2,
      });

      now = now.add(const Duration(seconds: 30));

      await controllerScheduler.tasks
          .where((task) => task.isActive)
          .single
          .run();

      expect(controller.canWrite, isTrue);

      availability.refresh();
      await obsoleteTask.action();

      expect(availability.canWrite, isFalse);
      expect(notifications, 0);
      expect(routeScheduler.activeCount, 0);
    },
  );

  test('route denies writes after direct authority disposal', () async {
    final localRpc = _QueuedRpc();
    final localControllerScheduler = _ManualScheduler();
    final localRouteScheduler = _ManualScheduler();

    final localController = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(localRpc.call),
      localControllerScheduler,
      utcNow: () => now,
    );

    localRpc.responses.add({
      'status': 'acquired',
      'lock_token': _token,
      'expires_at': '2026-08-26T22:02:00+00:00',
      'row_version': 1,
    });

    await localController.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final lease = localController.requireLeaseForWrite();

    final availability = RouteWriteAvailability(
      authority: localController,
      originalLease: lease,
      isContextValid: () => true,
      scheduler: localRouteScheduler,
    );

    addTearDown(availability.dispose);

    var notifications = 0;
    availability.addListener(() => notifications++);

    final obsoleteTask = localRouteScheduler.tasks.single;

    expect(availability.canWrite, isTrue);

    localController.dispose();

    expect(availability.canWrite, isFalse);
    expect(localControllerScheduler.activeCount, 0);

    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(localRouteScheduler.activeCount, 0);
    expect(obsoleteTask.isActive, isFalse);

    await obsoleteTask.action();

    expect(notifications, 1);
    expect(localRouteScheduler.activeCount, 0);

    expect(localRpc.functionNames, ['acquire_profile_edit_lock']);
  });

  test('route opened with invalid context remains read only', () async {
    final lease = await acquire();

    var contextValid = false;

    final availability = createAvailability(
      lease: lease,
      contextValid: () => contextValid,
    );

    var notifications = 0;
    availability.addListener(() => notifications++);

    expect(controller.canWrite, isTrue);
    expect(availability.canWrite, isFalse);
    expect(routeScheduler.activeCount, 0);

    contextValid = true;

    expect(availability.canWrite, isFalse);

    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);

    rpc.responses.add({
      'status': 'renewed',
      'expires_at': '2026-08-26T22:04:00+00:00',
      'row_version': 2,
    });

    now = now.add(const Duration(seconds: 30));

    await controllerScheduler.tasks.where((task) => task.isActive).single.run();

    expect(controller.canWrite, isTrue);
    expect(controller.rowVersion, 2);
    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);
  });

  test(
    'controller returns exact remaining lease duration without side effects',
    () async {
      final lease = await acquire();
      var notifications = 0;

      controller.addListener(() => notifications++);

      final scheduledCount = controllerScheduler.tasks.length;

      expect(
        controller.remainingWriteDurationForLease(lease),
        const Duration(minutes: 2),
      );

      now = now.add(const Duration(seconds: 45));

      expect(
        controller.remainingWriteDurationForLease(lease),
        const Duration(seconds: 75),
      );

      expect(controller.status, ProfileWriteAuthorityStatus.writer);
      expect(controller.rowVersion, 1);
      expect(notifications, 0);
      expect(controllerScheduler.tasks.length, scheduledCount);
      expect(rpc.functionNames, ['acquire_profile_edit_lock']);
    },
  );

  test('remaining lease duration becomes null at exact expiry', () async {
    final lease = await acquire();
    var notifications = 0;

    controller.addListener(() => notifications++);

    final scheduledCount = controllerScheduler.tasks.length;

    now = lease.expiresAt.subtract(const Duration(microseconds: 1));

    expect(
      controller.remainingWriteDurationForLease(lease),
      const Duration(microseconds: 1),
    );

    now = lease.expiresAt;

    expect(controller.remainingWriteDurationForLease(lease), isNull);

    now = now.add(const Duration(seconds: 1));

    expect(controller.remainingWriteDurationForLease(lease), isNull);

    expect(controller.canWrite, isFalse);
    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(notifications, 0);
    expect(controllerScheduler.tasks.length, scheduledCount);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);
  });

  test(
    'early route expiry callback reschedules positive remaining duration',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);
      var notifications = 0;

      availability.addListener(() => notifications++);

      expect(routeScheduler.delays.last, const Duration(minutes: 2));

      now = now.add(const Duration(seconds: 45));

      await routeScheduler.tasks.where((task) => task.isActive).single.run();

      expect(availability.canWrite, isTrue);
      expect(notifications, 0);
      expect(routeScheduler.activeCount, 1);
      expect(routeScheduler.delays.last, const Duration(seconds: 75));

      now = lease.expiresAt;

      await routeScheduler.tasks.where((task) => task.isActive).single.run();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      expect(
        routeScheduler.delays.every((delay) => delay > Duration.zero),
        isTrue,
      );

      expect(rpc.functionNames, ['acquire_profile_edit_lock']);
    },
  );

  test('route opened at exact lease expiry schedules no timer', () async {
    final lease = await acquire();

    now = lease.expiresAt;

    final availability = createAvailability(lease: lease);
    var notifications = 0;

    availability.addListener(() => notifications++);

    expect(availability.canWrite, isFalse);
    expect(routeScheduler.activeCount, 0);
    expect(routeScheduler.delays, isEmpty);

    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);
    expect(routeScheduler.delays, isEmpty);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);
  });

  test('remaining duration uses renewed expiry for original lease', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    rpc.responses.add({
      'status': 'renewed',
      'expires_at': '2026-08-26T22:04:00+00:00',
      'row_version': 2,
    });

    now = now.add(const Duration(seconds: 30));

    await controllerScheduler.tasks.where((task) => task.isActive).single.run();

    expect(controller.rowVersion, 2);

    expect(
      controller.remainingWriteDurationForLease(lease),
      const Duration(minutes: 3, seconds: 30),
    );

    expect(availability.canWrite, isTrue);
    expect(routeScheduler.activeCount, 1);

    expect(routeScheduler.delays.last, const Duration(minutes: 3, seconds: 30));

    now = lease.expiresAt;

    expect(
      controller.remainingWriteDurationForLease(lease),
      const Duration(minutes: 2),
    );

    expect(availability.canWrite, isTrue);

    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'heartbeat_profile_edit_lock',
    ]);
  });

  test(
    'route revokes writes synchronously before controller disposal',
    () async {
      final localRpc = _QueuedRpc();
      final localControllerScheduler = _ManualScheduler();
      final localRouteScheduler = _ManualScheduler();

      final localController = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker(localRpc.call),
        localControllerScheduler,
        utcNow: () => now,
      );

      localRpc.responses.add({
        'status': 'acquired',
        'lock_token': _token,
        'expires_at': '2026-08-26T22:02:00+00:00',
        'row_version': 1,
      });

      await localController.initialize(
        profileContext: _ownerContext,
        identity: _identity,
      );

      final lease = localController.requireLeaseForWrite();

      final availability = RouteWriteAvailability(
        authority: localController,
        originalLease: lease,
        isContextValid: () => true,
        scheduler: localRouteScheduler,
      );

      addTearDown(availability.dispose);

      var notifications = 0;
      availability.addListener(() => notifications++);

      final obsoleteTask = localRouteScheduler.tasks
          .where((task) => task.isActive)
          .single;

      expect(availability.canWrite, isTrue);

      localRpc.responses.add({'status': 'released'});

      final releaseFuture = localController.release();

      expect(localController.canWrite, isFalse);
      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(localRouteScheduler.activeCount, 0);
      expect(obsoleteTask.isActive, isFalse);

      localController.dispose();

      await releaseFuture;

      expect(availability.canWrite, isFalse);
      expect(localControllerScheduler.activeCount, 0);
      expect(localRouteScheduler.activeCount, 0);

      await obsoleteTask.action();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(localRouteScheduler.activeCount, 0);

      expect(localRpc.functionNames, [
        'acquire_profile_edit_lock',
        'release_profile_edit_lock',
      ]);
    },
  );

  test('remaining duration reads the authority clock only once', () async {
    final localRpc = _QueuedRpc();
    final localScheduler = _ManualScheduler();

    var reads = 0;
    var boundaryMode = false;

    final expiry = DateTime.utc(2026, 8, 26, 22, 2);

    final localController = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(localRpc.call),
      localScheduler,
      utcNow: () {
        if (!boundaryMode) {
          return now;
        }

        reads++;

        return reads == 1
            ? expiry.subtract(const Duration(microseconds: 1))
            : expiry;
      },
    );

    addTearDown(localController.dispose);

    localRpc.responses.add({
      'status': 'acquired',
      'lock_token': _token,
      'expires_at': '2026-08-26T22:02:00+00:00',
      'row_version': 1,
    });

    await localController.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final lease = localController.requireLeaseForWrite();

    boundaryMode = true;

    expect(
      localController.remainingWriteDurationForLease(lease),
      const Duration(microseconds: 1),
    );

    expect(reads, 1);

    expect(localController.remainingWriteDurationForLease(lease), isNull);

    expect(reads, 2);

    expect(localController.status, ProfileWriteAuthorityStatus.writer);

    expect(localRpc.functionNames, ['acquire_profile_edit_lock']);
  });

  test('route opening uses one temporal evaluation', () async {
    final localRpc = _QueuedRpc();
    final localControllerScheduler = _ManualScheduler();
    final localRouteScheduler = _ManualScheduler();

    var reads = 0;
    var contextChecks = 0;
    var boundaryMode = false;

    final expiry = DateTime.utc(2026, 8, 26, 22, 2);

    final localController = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(localRpc.call),
      localControllerScheduler,
      utcNow: () {
        if (!boundaryMode) {
          return now;
        }

        reads++;

        return reads == 1
            ? expiry.subtract(const Duration(microseconds: 1))
            : expiry;
      },
    );

    addTearDown(localController.dispose);

    localRpc.responses.add({
      'status': 'acquired',
      'lock_token': _token,
      'expires_at': '2026-08-26T22:02:00+00:00',
      'row_version': 1,
    });

    await localController.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final lease = localController.requireLeaseForWrite();

    boundaryMode = true;

    final availability = RouteWriteAvailability(
      authority: localController,
      originalLease: lease,
      isContextValid: () {
        contextChecks++;
        return true;
      },
      scheduler: localRouteScheduler,
    );

    addTearDown(availability.dispose);

    expect(reads, 1);
    expect(contextChecks, 1);
    expect(localRouteScheduler.activeCount, 1);

    expect(localRouteScheduler.delays.single, const Duration(microseconds: 1));

    var notifications = 0;

    availability.addListener(() {
      notifications++;
    });

    expect(availability.canWrite, isFalse);
    expect(reads, 2);

    await localRouteScheduler.tasks.single.run();

    expect(notifications, 1);
    expect(localRouteScheduler.activeCount, 0);
    expect(availability.canWrite, isFalse);
  });

  test('route refresh shares one temporal evaluation with its timer', () async {
    final localRpc = _QueuedRpc();
    final localControllerScheduler = _ManualScheduler();
    final localRouteScheduler = _ManualScheduler();

    var reads = 0;
    var contextChecks = 0;
    var boundaryMode = false;

    final expiry = DateTime.utc(2026, 8, 26, 22, 2);

    final localController = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker(localRpc.call),
      localControllerScheduler,
      utcNow: () {
        if (!boundaryMode) {
          return now;
        }

        reads++;

        return reads == 1
            ? expiry.subtract(const Duration(microseconds: 1))
            : expiry;
      },
    );

    addTearDown(localController.dispose);

    localRpc.responses.add({
      'status': 'acquired',
      'lock_token': _token,
      'expires_at': '2026-08-26T22:02:00+00:00',
      'row_version': 1,
    });

    await localController.initialize(
      profileContext: _ownerContext,
      identity: _identity,
    );

    final lease = localController.requireLeaseForWrite();

    final availability = RouteWriteAvailability(
      authority: localController,
      originalLease: lease,
      isContextValid: () {
        contextChecks++;
        return true;
      },
      scheduler: localRouteScheduler,
    );

    addTearDown(availability.dispose);

    expect(availability.canWrite, isTrue);

    var notifications = 0;

    availability.addListener(() {
      notifications++;
    });

    final obsoleteTask = localRouteScheduler.tasks.single;

    contextChecks = 0;
    boundaryMode = true;

    availability.refresh();

    expect(reads, 1);
    expect(contextChecks, 1);
    expect(notifications, 0);
    expect(obsoleteTask.isActive, isFalse);
    expect(localRouteScheduler.activeCount, 1);

    expect(localRouteScheduler.delays.last, const Duration(microseconds: 1));

    await obsoleteTask.action();

    expect(reads, 1);
    expect(notifications, 0);
    expect(localRouteScheduler.activeCount, 1);

    await localRouteScheduler.tasks.last.run();

    expect(reads, 2);
    expect(notifications, 1);
    expect(localRouteScheduler.activeCount, 0);
    expect(availability.canWrite, isFalse);

    expect(localRpc.functionNames, ['acquire_profile_edit_lock']);
  });

  test(
    'route denies writes when lease expires during context validation',
    () async {
      final lease = await acquire();

      var expireDuringValidation = false;

      final availability = createAvailability(
        lease: lease,
        contextValid: () {
          if (expireDuringValidation) {
            now = lease.expiresAt;
          }

          return true;
        },
      );

      expect(availability.canWrite, isTrue);

      var notifications = 0;

      availability.addListener(() {
        notifications++;
      });

      final obsoleteTask = routeScheduler.tasks.single;

      now = lease.expiresAt.subtract(const Duration(microseconds: 1));

      expireDuringValidation = true;

      availability.refresh();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);
      expect(obsoleteTask.isActive, isFalse);

      await obsoleteTask.action();

      expect(notifications, 1);
      expect(routeScheduler.activeCount, 0);

      expect(rpc.functionNames, ['acquire_profile_edit_lock']);
    },
  );

  test('T26 invalidate immediately revokes route writes', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    expect(availability.canWrite, isTrue);

    final rpcCount = rpc.functionNames.length;

    availability.invalidate();

    expect(availability.canWrite, isFalse);
    expect(controller.canWrite, isTrue);
    expect(rpc.functionNames.length, rpcCount);
  });

  test('T27 invalidate cancels the route expiry timer', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    final task = routeScheduler.tasks.single;

    expect(task.isActive, isTrue);
    expect(routeScheduler.activeCount, 1);

    availability.invalidate();

    expect(task.isActive, isFalse);
    expect(routeScheduler.activeCount, 0);
  });

  test('T28 invalidate notifies the revocation synchronously', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    final observedStates = <bool>[];

    availability.addListener(() {
      observedStates.add(availability.canWrite);
    });

    availability.invalidate();

    expect(observedStates, [false]);
  });

  test('T29 repeated invalidation is idempotent', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;
    availability.addListener(() => notifications++);

    final taskCount = routeScheduler.tasks.length;

    availability.invalidate();
    availability.invalidate();
    availability.invalidate();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);
    expect(routeScheduler.tasks.length, taskCount);
  });

  test('T30 heartbeat cannot reactivate an invalidated route', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;
    availability.addListener(() => notifications++);

    availability.invalidate();

    final taskCount = routeScheduler.tasks.length;

    rpc.responses.add({
      'status': 'renewed',
      'expires_at': '2026-08-26T22:04:00+00:00',
      'row_version': 2,
    });

    now = DateTime.utc(2026, 8, 26, 22, 0, 30);

    await controllerScheduler.tasks.where((task) => task.isActive).single.run();

    expect(controller.canWrite, isTrue);
    expect(
      controller.remainingWriteDurationForLease(lease),
      const Duration(minutes: 3, seconds: 30),
    );

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);
    expect(routeScheduler.tasks.length, taskCount);

    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'heartbeat_profile_edit_lock',
    ]);
  });

  test('T31 refresh cannot reactivate an invalidated route', () async {
    final lease = await acquire();

    var valid = true;
    var contextChecks = 0;

    final availability = createAvailability(
      lease: lease,
      contextValid: () {
        contextChecks++;
        return valid;
      },
    );

    var notifications = 0;
    availability.addListener(() => notifications++);

    valid = false;
    availability.refresh();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);

    availability.invalidate();

    final checksAfterInvalidation = contextChecks;

    valid = true;
    availability.refresh();
    availability.refresh();

    expect(controller.canWrite, isTrue);
    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(contextChecks, checksAfterInvalidation);
    expect(routeScheduler.activeCount, 0);
  });

  test('T32 invalidating an initially read only route is silent', () async {
    final availability = createAvailability(lease: null);

    var notifications = 0;
    availability.addListener(() => notifications++);

    availability.invalidate();

    await acquire();

    availability.refresh();

    expect(controller.canWrite, isTrue);
    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);
    expect(routeScheduler.tasks, isEmpty);
  });

  test('T33 invalidate after dispose is harmless', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;
    availability.addListener(() => notifications++);

    availability.dispose();

    expect(availability.invalidate, returnsNormally);
    expect(availability.invalidate, returnsNormally);

    expect(availability.canWrite, isFalse);
    expect(notifications, 0);
    expect(routeScheduler.activeCount, 0);
  });

  test(
    'T34 obsolete expiry callback cannot affect invalidated route',
    () async {
      final lease = await acquire();
      final availability = createAvailability(lease: lease);

      var notifications = 0;
      availability.addListener(() => notifications++);

      final obsoleteTask = routeScheduler.tasks.single;

      availability.invalidate();

      final taskCount = routeScheduler.tasks.length;

      now = lease.expiresAt;

      await obsoleteTask.action();

      expect(availability.canWrite, isFalse);
      expect(notifications, 1);
      expect(obsoleteTask.isActive, isFalse);
      expect(routeScheduler.activeCount, 0);
      expect(routeScheduler.tasks.length, taskCount);

      expect(rpc.functionNames, ['acquire_profile_edit_lock']);
    },
  );

  test('T35 invalidated notifier remains usable until disposal', () async {
    final lease = await acquire();
    final availability = createAvailability(lease: lease);

    var notifications = 0;

    void listener() {
      notifications++;
    }

    availability.addListener(listener);

    availability.invalidate();

    expect(notifications, 1);

    availability.removeListener(listener);

    expect(() => availability.addListener(listener), returnsNormally);

    availability.removeListener(listener);

    expect(availability.dispose, returnsNormally);
    expect(availability.dispose, returnsNormally);
    expect(availability.refresh, returnsNormally);

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);
    expect(routeScheduler.activeCount, 0);
  });
}
