import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/route_write_availability.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/planned_plantings_page.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _seasonId = '22222222-2222-4222-8222-222222222222';

const _identity = AppSessionIdentity(
  clientInstanceId: '33333333-3333-4333-8333-333333333333',
  sessionId: '44444444-4444-4444-8444-444444444444',
);

const _owner = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

const _writeLabel = 'Scrittura disponibile';
const _readOnlyLabel = 'Modalit\u00E0 sola lettura';

const _emptyLabel = 'Nessuna pianificazione presente per questa stagione.';

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

class _ObservedAvailability extends RouteWriteAvailability {
  _ObservedAvailability({
    required super.authority,
    required super.originalLease,
    required super.isContextValid,
    required super.scheduler,
  });

  bool get hasUiListeners => hasListeners;
}

class _Fixture {
  DateTime now = DateTime.utc(2026, 11, 24, 12);

  String acquisitionToken = 'token-ui-esclusivamente-fittizio';

  final controllerScheduler = _ManualScheduler();
  final routeScheduler = _ManualScheduler();

  final lockRpcNames = <String>[];
  final planningRpcNames = <String>[];
  final requestedSeasons = <String>[];

  late final ProfileWriteAuthorityController authority;

  _Fixture() {
    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        lockRpcNames.add(functionName);

        if (functionName == 'acquire_profile_edit_lock') {
          return {
            'status': 'acquired',
            'lock_token': acquisitionToken,
            'expires_at': now.add(const Duration(minutes: 2)).toIso8601String(),
            'row_version': 1,
          };
        }

        if (functionName == 'release_profile_edit_lock') {
          return {'status': 'released'};
        }

        throw StateError('Unexpected lock RPC: $functionName');
      }),
      controllerScheduler,
      utcNow: () => now,
    );

    addTearDown(authority.dispose);
  }

  Future<void> acquire() async {
    await authority.initialize(profileContext: _owner, identity: _identity);

    expect(authority.canWrite, isTrue);
  }

  RouteWriteAvailability createAvailability({bool Function()? contextValid}) {
    final availability = RouteWriteAvailability(
      authority: authority,
      originalLease: authority.requireLeaseForWrite(),
      isContextValid: contextValid ?? () => true,
      scheduler: routeScheduler,
    );

    addTearDown(availability.dispose);

    return availability;
  }

  PlannedPlantingRepository repository({
    Future<List<Map<String, dynamic>>> Function(String)? loader,
  }) {
    return PlannedPlantingRepository.withProviders(
      (functionName, parameters) async {
        planningRpcNames.add(functionName);
        throw StateError('Unexpected planning RPC: $functionName');
      },
      null,
      loadPlannedPlantings: (seasonId) async {
        requestedSeasons.add(seasonId);

        if (loader != null) {
          return loader(seasonId);
        }

        return <Map<String, dynamic>>[];
      },
    );
  }

  Future<void> showPage(
    WidgetTester tester, {
    required PlannedPlantingRepository repository,
    RouteWriteAvailability? availability,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PlannedPlantingsPage(
          seasonId: _seasonId,
          seasonName: '2026 - Corrente',
          repository: repository,
          writeAvailability: availability,
        ),
      ),
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(planningRpcNames, isEmpty);
  }
}

void _expectWritable() {
  expect(find.text(_writeLabel), findsOneWidget);
  expect(find.text(_readOnlyLabel), findsNothing);
  expect(find.byIcon(Icons.lock_open), findsOneWidget);
  expect(find.byIcon(Icons.lock_outline), findsNothing);
}

void _expectReadOnly() {
  expect(find.text(_readOnlyLabel), findsOneWidget);
  expect(find.text(_writeLabel), findsNothing);
  expect(find.byIcon(Icons.lock_outline), findsOneWidget);
  expect(find.byIcon(Icons.lock_open), findsNothing);
}

void main() {
  testWidgets('T01: absent availability displays read-only status', (
    tester,
  ) async {
    final fixture = _Fixture();

    await fixture.showPage(tester, repository: fixture.repository());

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.lockRpcNames, isEmpty);
    expect(fixture.routeScheduler.activeCount, 0);

    await fixture.unmount(tester);
  });

  testWidgets('T02: valid original lease displays writable status', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    expect(availability.canWrite, isTrue);
    _expectWritable();

    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 1);
    expect(fixture.lockRpcNames, ['acquire_profile_edit_lock']);

    await fixture.unmount(tester);
  });

  testWidgets('T03: invalid initial context displays read-only status', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability(contextValid: () => false);

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    expect(fixture.authority.canWrite, isTrue);
    expect(availability.canWrite, isFalse);
    _expectReadOnly();

    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);

    await fixture.unmount(tester);
  });

  testWidgets('T08: write status remains visible during loading', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();
    final completer = Completer<List<Map<String, dynamic>>>();

    await fixture.showPage(
      tester,
      repository: fixture.repository(loader: (_) => completer.future),
      availability: availability,
    );

    _expectWritable();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    completer.complete([]);

    await tester.pumpAndSettle();

    _expectWritable();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    await fixture.unmount(tester);
  });

  testWidgets('T09: read-only status remains visible with empty list', (
    tester,
  ) async {
    final fixture = _Fixture();

    await fixture.showPage(tester, repository: fixture.repository());

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    await fixture.unmount(tester);
  });

  testWidgets('T10: error and retry preserve write availability status', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    var calls = 0;

    final repository = fixture.repository(
      loader: (_) async {
        calls++;

        if (calls == 1) {
          throw StateError('Simulated loading error');
        }

        return <Map<String, dynamic>>[];
      },
    );

    await fixture.showPage(
      tester,
      repository: repository,
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    expect(
      find.text('Non è stato possibile caricare le pianificazioni.'),
      findsOneWidget,
    );

    expect(find.text('Riprova'), findsOneWidget);
    expect(find.textContaining('Simulated loading error'), findsNothing);
    expect(calls, 1);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();

    _expectWritable();

    expect(find.text('Riprova'), findsNothing);
    expect(find.text(_emptyLabel), findsOneWidget);
    expect(calls, 2);

    expect(fixture.requestedSeasons, [_seasonId, _seasonId]);

    expect(fixture.lockRpcNames, ['acquire_profile_edit_lock']);

    await fixture.unmount(tester);
  });

  testWidgets('T04: authority release updates visible status', (tester) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    final releaseFuture = fixture.authority.release();

    expect(fixture.authority.canWrite, isFalse);
    expect(availability.canWrite, isFalse);

    await tester.pump();

    _expectReadOnly();

    await releaseFuture;
    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);
    expect(fixture.lockRpcNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
    ]);

    await fixture.unmount(tester);
  });

  testWidgets('T05: lease expiry updates status without heartbeat', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    expect(fixture.routeScheduler.activeCount, 1);
    expect(fixture.routeScheduler.delays.single, const Duration(minutes: 2));

    fixture.now = fixture.now.add(const Duration(minutes: 2));

    expect(availability.canWrite, isFalse);

    await fixture.routeScheduler.tasks.single.run();
    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);
    expect(fixture.authority.status, ProfileWriteAuthorityStatus.writer);
    expect(fixture.lockRpcNames, ['acquire_profile_edit_lock']);

    await fixture.unmount(tester);
  });

  testWidgets('T06: route invalidation updates status permanently', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    availability.invalidate();

    await tester.pumpAndSettle();

    expect(fixture.authority.canWrite, isTrue);
    expect(availability.canWrite, isFalse);

    _expectReadOnly();

    availability.refresh();

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);
    expect(fixture.lockRpcNames, ['acquire_profile_edit_lock']);

    await fixture.unmount(tester);
  });

  testWidgets('T07: new lease cannot reactivate invalidated route', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = fixture.createAvailability();

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    availability.invalidate();

    await tester.pumpAndSettle();

    _expectReadOnly();

    await fixture.authority.release();

    fixture.acquisitionToken = 'new-ui-test-token';

    await fixture.acquire();

    availability.refresh();

    await tester.pumpAndSettle();

    expect(fixture.authority.canWrite, isTrue);
    expect(
      fixture.authority.requireLeaseForWrite().lockToken,
      'new-ui-test-token',
    );
    expect(availability.canWrite, isFalse);

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);
    expect(fixture.lockRpcNames, [
      'acquire_profile_edit_lock',
      'release_profile_edit_lock',
      'acquire_profile_edit_lock',
    ]);

    await fixture.unmount(tester);
  });

  testWidgets('T11: availability transitions do not reload data', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    var contextValid = true;

    final availability = fixture.createAvailability(
      contextValid: () => contextValid,
    );

    final completer = Completer<List<Map<String, dynamic>>>();

    final repository = fixture.repository(loader: (_) => completer.future);

    await fixture.showPage(
      tester,
      repository: repository,
      availability: availability,
    );

    _expectWritable();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    contextValid = false;
    availability.refresh();

    await tester.pump();

    _expectReadOnly();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    completer.complete([]);

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    contextValid = true;
    availability.refresh();

    await tester.pumpAndSettle();

    _expectWritable();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);

    availability.invalidate();

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);
    expect(fixture.lockRpcNames, ['acquire_profile_edit_lock']);

    await fixture.unmount(tester);
  });

  testWidgets('T12: unmount removes UI listener without disposing notifier', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    final availability = _ObservedAvailability(
      authority: fixture.authority,
      originalLease: fixture.authority.requireLeaseForWrite(),
      isContextValid: () => true,
      scheduler: fixture.routeScheduler,
    );

    addTearDown(availability.dispose);

    expect(availability.hasUiListeners, isFalse);
    expect(availability.canWrite, isTrue);

    await fixture.showPage(
      tester,
      repository: fixture.repository(),
      availability: availability,
    );

    await tester.pumpAndSettle();

    _expectWritable();

    expect(availability.hasUiListeners, isTrue);
    expect(fixture.requestedSeasons, [_seasonId]);

    await fixture.unmount(tester);

    expect(availability.hasUiListeners, isFalse);
    expect(availability.canWrite, isTrue);

    var notifications = 0;

    void listener() {
      notifications++;
    }

    availability.addListener(listener);

    expect(availability.hasUiListeners, isTrue);

    availability.invalidate();

    expect(availability.canWrite, isFalse);
    expect(notifications, 1);

    availability.removeListener(listener);

    expect(availability.hasUiListeners, isFalse);
    expect(fixture.routeScheduler.activeCount, 0);

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.planningRpcNames, isEmpty);
  });

  testWidgets('T13: replacing notifier transfers UI subscription', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.acquire();

    var firstContextValid = true;
    var secondContextValid = true;

    final first = _ObservedAvailability(
      authority: fixture.authority,
      originalLease: fixture.authority.requireLeaseForWrite(),
      isContextValid: () => firstContextValid,
      scheduler: fixture.routeScheduler,
    );

    final second = _ObservedAvailability(
      authority: fixture.authority,
      originalLease: fixture.authority.requireLeaseForWrite(),
      isContextValid: () => secondContextValid,
      scheduler: fixture.routeScheduler,
    );

    addTearDown(first.dispose);
    addTearDown(second.dispose);

    final repository = fixture.repository();

    expect(first.hasUiListeners, isFalse);
    expect(second.hasUiListeners, isFalse);

    await fixture.showPage(tester, repository: repository, availability: first);

    await tester.pumpAndSettle();

    _expectWritable();

    expect(first.hasUiListeners, isTrue);
    expect(second.hasUiListeners, isFalse);
    expect(fixture.requestedSeasons, [_seasonId]);

    secondContextValid = false;
    second.refresh();

    expect(second.canWrite, isFalse);

    await fixture.showPage(
      tester,
      repository: repository,
      availability: second,
    );

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(first.hasUiListeners, isFalse);
    expect(second.hasUiListeners, isTrue);
    expect(fixture.requestedSeasons, [_seasonId]);

    firstContextValid = false;
    first.refresh();

    await tester.pumpAndSettle();

    _expectReadOnly();

    firstContextValid = true;
    first.refresh();

    await tester.pumpAndSettle();

    expect(first.canWrite, isTrue);

    _expectReadOnly();

    expect(first.hasUiListeners, isFalse);
    expect(fixture.requestedSeasons, [_seasonId]);

    secondContextValid = true;
    second.refresh();

    await tester.pumpAndSettle();

    _expectWritable();

    expect(second.hasUiListeners, isTrue);

    first.invalidate();

    await tester.pumpAndSettle();

    _expectWritable();

    second.invalidate();

    await tester.pumpAndSettle();

    _expectReadOnly();

    expect(find.text(_emptyLabel), findsOneWidget);
    expect(fixture.requestedSeasons, [_seasonId]);
    expect(fixture.routeScheduler.activeCount, 0);

    await fixture.unmount(tester);

    expect(first.hasUiListeners, isFalse);
    expect(second.hasUiListeners, isFalse);
    expect(fixture.planningRpcNames, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
