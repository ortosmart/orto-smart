import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/profile/profile_context_scope.dart';
import 'package:orto_app/core/profile/profile_session_gate.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_scope.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _clientInstanceId = '22222222-2222-4222-8222-222222222222';
const _sessionId = '33333333-3333-4333-8333-333333333333';
const _fakeToken = 'token-gate-esclusivamente-fittizio';

const _ownerContext = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

const _identity = AppSessionIdentity(
  clientInstanceId: _clientInstanceId,
  sessionId: _sessionId,
);

Map<String, dynamic> _acquiredResponse() {
  return {
    'status': 'acquired',
    'lock_token': _fakeToken,
    'expires_at': '2026-08-27T22:30:00+00:00',
    'row_version': 1,
  };
}

class _InitializationFailure implements Exception {
  const _InitializationFailure();
}

class _QueuedRpc {
  final Queue<Object?> responses = Queue<Object?>();
  final List<String> functionNames = [];

  void enqueue(Object? response) {
    responses.add(response);
  }

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

class _RecordedTask implements ScheduledWriteAuthorityTask {
  bool _isActive = true;

  @override
  bool get isActive => _isActive;

  @override
  void cancel() {
    _isActive = false;
  }
}

class _RecordingScheduler implements WriteAuthorityScheduler {
  final List<Duration> delays = [];

  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    delays.add(delay);

    return _RecordedTask();
  }
}

ProfileWriteAuthorityController _createController(
  _QueuedRpc rpc,
  _RecordingScheduler scheduler,
) {
  return ProfileWriteAuthorityController(
    ProfileEditLockRepository.withRpcInvoker(rpc.call),
    scheduler,
    utcNow: () => DateTime.utc(2026, 8, 27, 22),
  );
}

void main() {
  testWidgets('shows loading and then exposes a ready controller', (
    tester,
  ) async {
    final rpc = _QueuedRpc()..enqueue(_acquiredResponse());
    final scheduler = _RecordingScheduler();
    final profileCompleter = Completer<ProfileContext>();

    late ProfileWriteAuthorityController controller;
    late ProfileWriteAuthorityController scopedController;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileSessionGate(
          resolveProfileContext: () => profileCompleter.future,
          createSessionIdentity: () async => _identity,
          createController: () {
            controller = _createController(rpc, scheduler);
            return controller;
          },
          loading: const SizedBox(key: Key('loading')),
          failureBuilder: (context, failure, retry) {
            return const SizedBox(key: Key('failure'));
          },
          child: Builder(
            builder: (context) {
              scopedController = ProfileWriteAuthorityScope.read(context);

              return const SizedBox(key: Key('ready'));
            },
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('loading')), findsOneWidget);
    expect(find.byKey(const Key('ready')), findsNothing);

    profileCompleter.complete(_ownerContext);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('loading')), findsNothing);
    expect(find.byKey(const Key('ready')), findsOneWidget);
    expect(scopedController, same(controller));
    expect(controller.status, ProfileWriteAuthorityStatus.writer);
    expect(controller.canWrite, isTrue);
    expect(scheduler.delays, [
      ProfileWriteAuthorityController.heartbeatInterval,
    ]);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);
  });

  testWidgets('retries after Profile resolution fails', (tester) async {
    final rpc = _QueuedRpc()..enqueue(_acquiredResponse());
    final scheduler = _RecordingScheduler();

    var resolutionAttempts = 0;
    Object? reportedFailure;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileSessionGate(
          resolveProfileContext: () async {
            resolutionAttempts += 1;

            if (resolutionAttempts == 1) {
              throw const _InitializationFailure();
            }

            return _ownerContext;
          },
          createSessionIdentity: () async => _identity,
          createController: () {
            return _createController(rpc, scheduler);
          },
          loading: const SizedBox(key: Key('loading')),
          failureBuilder: (context, failure, retry) {
            reportedFailure = failure;

            return GestureDetector(
              key: const Key('retry'),
              behavior: HitTestBehavior.opaque,
              onTap: retry,
              child: const SizedBox(width: 100, height: 50),
            );
          },
          child: const SizedBox(key: Key('ready')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('retry')), findsOneWidget);
    expect(reportedFailure, isA<_InitializationFailure>());
    expect(resolutionAttempts, 1);
    expect(rpc.functionNames, isEmpty);

    await tester.tap(find.byKey(const Key('retry')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('retry')), findsNothing);
    expect(find.byKey(const Key('ready')), findsOneWidget);
    expect(resolutionAttempts, 2);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);
  });

  testWidgets('releases the lease when the gate is removed', (tester) async {
    final rpc = _QueuedRpc()
      ..enqueue(_acquiredResponse())
      ..enqueue({'status': 'released'});

    final scheduler = _RecordingScheduler();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileSessionGate(
          resolveProfileContext: () async => _ownerContext,
          createSessionIdentity: () async => _identity,
          createController: () {
            return _createController(rpc, scheduler);
          },
          loading: const SizedBox(),
          failureBuilder: (context, failure, retry) {
            return const SizedBox();
          },
          child: const SizedBox(key: Key('ready')),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ready')), findsOneWidget);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
    ]);
  });

  testWidgets('ignores Profile resolution completed after removal', (
    tester,
  ) async {
    final rpc = _QueuedRpc();
    final scheduler = _RecordingScheduler();
    final profileCompleter = Completer<ProfileContext>();

    var identityCreations = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProfileSessionGate(
          resolveProfileContext: () => profileCompleter.future,
          createSessionIdentity: () async {
            identityCreations += 1;
            return _identity;
          },
          createController: () {
            return _createController(rpc, scheduler);
          },
          loading: const SizedBox(key: Key('loading')),
          failureBuilder: (context, failure, retry) {
            return const SizedBox();
          },
          child: const SizedBox(key: Key('ready')),
        ),
      ),
    );

    expect(find.byKey(const Key('loading')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());

    profileCompleter.complete(_ownerContext);

    await tester.pumpAndSettle();

    expect(identityCreations, 0);
    expect(rpc.functionNames, isEmpty);
    expect(scheduler.delays, isEmpty);
  });
  testWidgets('publishes Profile context only after initialization completes', (
    tester,
  ) async {
    final rpc = _QueuedRpc()
      ..enqueue(_acquiredResponse())
      ..enqueue({'status': 'released'});
    final scheduler = _RecordingScheduler();
    final identityCompleter = Completer<AppSessionIdentity>();

    ProfileContext? receivedContext;
    ProfileWriteAuthorityController? receivedController;

    await tester.pumpWidget(
      ProfileSessionGate(
        resolveProfileContext: () async => _ownerContext,
        createSessionIdentity: () => identityCompleter.future,
        createController: () => _createController(rpc, scheduler),
        loading: const SizedBox(key: Key('context-loading')),
        failureBuilder: (context, failure, retry) {
          return const SizedBox(key: Key('context-failure'));
        },
        child: Builder(
          builder: (context) {
            receivedContext = ProfileContextScope.of(context);
            receivedController = ProfileWriteAuthorityScope.read(context);

            return const SizedBox(key: Key('context-ready'));
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('context-loading')), findsOneWidget);
    expect(find.byType(ProfileContextScope), findsNothing);
    expect(receivedContext, isNull);
    expect(receivedController, isNull);
    expect(rpc.functionNames, isEmpty);

    identityCompleter.complete(_identity);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('context-loading')), findsNothing);
    expect(find.byKey(const Key('context-ready')), findsOneWidget);
    expect(find.byType(ProfileContextScope), findsOneWidget);
    expect(receivedContext, same(_ownerContext));
    expect(receivedController!.status, ProfileWriteAuthorityStatus.writer);
    expect(rpc.functionNames, ['acquire_profile_edit_lock']);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();

    expect(find.byType(ProfileContextScope), findsNothing);
    expect(rpc.functionNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
    ]);
  });

  for (final role in [ProfileMemberRole.worker, ProfileMemberRole.viewer]) {
    testWidgets('exposes ${role.name} Profile context without a lease', (
      tester,
    ) async {
      final rpc = _QueuedRpc();
      final scheduler = _RecordingScheduler();
      final memberContext = ProfileContext(profileId: _profileId, role: role);

      ProfileContext? receivedContext;
      ProfileWriteAuthorityController? receivedController;

      await tester.pumpWidget(
        ProfileSessionGate(
          resolveProfileContext: () async => memberContext,
          createSessionIdentity: () async => _identity,
          createController: () => _createController(rpc, scheduler),
          loading: const SizedBox(key: Key('member-loading')),
          failureBuilder: (context, failure, retry) {
            return const SizedBox(key: Key('member-failure'));
          },
          child: Builder(
            builder: (context) {
              receivedContext = ProfileContextScope.read(context);
              receivedController = ProfileWriteAuthorityScope.read(context);

              return const SizedBox(key: Key('member-ready'));
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('member-ready')), findsOneWidget);
      expect(find.byKey(const Key('member-failure')), findsNothing);
      expect(receivedContext, same(memberContext));
      expect(receivedContext!.profileId, _profileId);
      expect(receivedContext!.role, role);
      expect(receivedController!.canWrite, isFalse);
      expect(
        receivedController!.status,
        ProfileWriteAuthorityStatus.readOnlyMember,
      );
      expect(
        () => receivedController!.requireLeaseForWrite(),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );
      expect(rpc.functionNames, isEmpty);
      expect(scheduler.delays, isEmpty);

      await tester.pumpWidget(const SizedBox());
      await tester.pump();

      expect(find.byType(ProfileContextScope), findsNothing);
      expect(rpc.functionNames, isEmpty);
    });
  }
}
