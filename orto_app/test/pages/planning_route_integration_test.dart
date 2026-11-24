import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/profile/profile_context_scope.dart';
import 'package:orto_app/core/write_authority/planned_planting_write_result.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_scope.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/data/repositories/season_repository.dart';
import 'package:orto_app/pages/garden_page.dart';
import 'package:orto_app/pages/planned_plantings_page.dart';
import 'package:orto_app/pages/seasons_page.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';
const _seasonId = '33333333-3333-4333-8333-333333333333';
const _plannedPlantingId = '44444444-4444-4444-8444-444444444444';
const _clientId = '55555555-5555-4555-8555-555555555555';
const _sessionId = '66666666-6666-4666-8666-666666666666';
const _token = 'token-esclusivamente-fittizio';

const _owner = ProfileContext(
  profileId: _profileId,
  role: ProfileMemberRole.owner,
);

class _ScheduledTask implements ScheduledWriteAuthorityTask {
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  void cancel() => _active = false;
}

class _Scheduler implements WriteAuthorityScheduler {
  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) => _ScheduledTask();
}

class _Fixture {
  late final ProfileWriteAuthorityController authority;

  final navigatorKey = GlobalKey<NavigatorState>();
  final showGarden = ValueNotifier<bool>(true);

  final rpcNames = <String>[];
  final rpcParameters = <Map<String, dynamic>>[];
  final requestedSeasons = <String>[];

  String acquisitionToken = _token;

  Future<void> initialize() async {
    final now = DateTime.utc(2026, 11, 24, 12);

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        if (functionName == 'acquire_profile_edit_lock') {
          return {
            'status': 'acquired',
            'lock_token': acquisitionToken,
            'expires_at': '2026-11-24T12:02:00+00:00',
            'row_version': 1,
          };
        }

        if (functionName == 'release_profile_edit_lock') {
          return {'status': 'released'};
        }

        throw StateError('RPC inattesa: $functionName');
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);
    addTearDown(showGarden.dispose);

    await authority.initialize(
      profileContext: _owner,
      identity: const AppSessionIdentity(
        clientInstanceId: _clientId,
        sessionId: _sessionId,
      ),
    );

    expect(authority.canWrite, isTrue);
  }

  Future<void> mount(
    WidgetTester tester, {
    PlannedPlantingRepository? injectedRepository,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: ProfileContextScope(
          profileContext: _owner,
          child: ProfileWriteAuthorityScope(
            controller: authority,
            child: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: showGarden,
                builder: (context, visible, child) {
                  return visible ? child! : const SizedBox.shrink();
                },
                child: GardenPage(
                  plannedPlantingRepository: injectedRepository,
                  repository: GardenRepository.withLoader(
                    (_) async => [
                      {
                        'id': _gardenId,
                        'profile_id': _profileId,
                        'name': 'Orto di prova',
                        'description': 'Descrizione di prova',
                        'is_active': true,
                        'row_version': 1,
                      },
                    ],
                  ),
                  bedRepository: BedRepository.withLoader((_) async => []),
                  plantingRepository: PlantingRepository.withLoader(
                    (_) async => <Map<String, dynamic>>[],
                  ),
                  seasonRepository: SeasonRepository.withProviders(
                    (_) async => <String, dynamic>{},
                    (_, _) async => <String, dynamic>{},
                    null,
                    (gardenId) async => [
                      {
                        'id': _seasonId,
                        'garden_id': gardenId,
                        'year': 2026,
                        'name': 'Corrente',
                        'start_date': '2026-01-01',
                        'end_date': null,
                        'is_active': true,
                        'notes': null,
                        'row_version': 1,
                      },
                    ],
                  ),
                  plannedPlantingRpcInvoker: (functionName, parameters) async {
                    rpcNames.add(functionName);
                    rpcParameters.add(Map<String, dynamic>.from(parameters));

                    if (functionName != 'confirm_planned_planting') {
                      throw StateError('RPC inattesa: $functionName');
                    }

                    return {
                      'status': 'confirmed',
                      'planned_planting_id': _plannedPlantingId,
                      'row_version': 2,
                    };
                  },
                  plannedPlantingListLoader: (seasonId) async {
                    requestedSeasons.add(seasonId);
                    return <Map<String, dynamic>>[];
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<SeasonsPage> openSeasons(WidgetTester tester) async {
    expect(find.text('Stagioni'), findsOneWidget);

    await tester.tap(find.text('Stagioni'));
    await tester.pumpAndSettle();

    expect(find.byType(SeasonsPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    return tester.widget<SeasonsPage>(find.byType(SeasonsPage));
  }

  Future<PlannedPlantingsPage> openPlantings(WidgetTester tester) async {
    await tester.tap(find.text('2026 - Corrente'));
    await tester.pumpAndSettle();

    expect(find.byType(PlannedPlantingsPage), findsOneWidget);
    expect(tester.takeException(), isNull);

    return tester.widget<PlannedPlantingsPage>(
      find.byType(PlannedPlantingsPage),
    );
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }
}

void main() {
  testWidgets('T01 N01-N02: seasons retain originating write availability', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.initialize();
    await fixture.mount(tester);

    final seasons = await fixture.openSeasons(tester);
    final availability = seasons.writeAvailability!;
    final lifetime = seasons.planningRouteLifetime!;

    expect(availability.canWrite, isTrue);
    expect(lifetime.isClosed, isFalse);
    expect(lifetime.availability, same(availability));
    expect(seasons.plannedPlantingRepository, isNotNull);
    expect(fixture.rpcNames, isEmpty);

    await fixture.unmount(tester);
  });

  testWidgets('T02 N03-N04: child route shares repository and original lease', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.initialize();
    await fixture.mount(tester);

    final seasons = await fixture.openSeasons(tester);
    final plantings = await fixture.openPlantings(tester);

    expect(plantings.writeAvailability, same(seasons.writeAvailability));
    expect(plantings.repository, same(seasons.plannedPlantingRepository));
    expect(plantings.writeAvailability!.canWrite, isTrue);
    expect(fixture.requestedSeasons, [_seasonId]);

    final result = await plantings.repository.confirmPlannedPlanting(
      plannedPlantingId: _plannedPlantingId,
      expectedRowVersion: 1,
    );

    expect(result, isA<ConfirmPlannedPlantingConfirmed>());
    expect(fixture.rpcNames, ['confirm_planned_planting']);

    final parameters = fixture.rpcParameters.single;

    expect(parameters['target_profile_id'], _profileId);
    expect(parameters['target_client_id'], _clientId);
    expect(parameters['target_session_id'], _sessionId);
    expect(parameters['lock_token'], _token);
    expect(parameters['target_planned_planting_id'], _plannedPlantingId);
    expect(parameters['expected_row_version'], 1);

    await fixture.unmount(tester);
  });

  testWidgets('T03 N05-N06: pop and reopen preserve originating availability', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.initialize();
    await fixture.mount(tester);

    final seasons = await fixture.openSeasons(tester);
    final availability = seasons.writeAvailability!;
    final first = await fixture.openPlantings(tester);

    fixture.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(find.byType(SeasonsPage), findsOneWidget);
    expect(find.byType(PlannedPlantingsPage), findsNothing);
    expect(availability.canWrite, isTrue);
    expect(seasons.planningRouteLifetime!.isClosed, isFalse);

    final second = await fixture.openPlantings(tester);

    expect(second, isNot(same(first)));
    expect(second.writeAvailability, same(availability));
    expect(second.repository, same(first.repository));
    expect(availability.canWrite, isTrue);
    expect(fixture.requestedSeasons, [_seasonId, _seasonId]);
    expect(fixture.rpcNames, isEmpty);

    await fixture.unmount(tester);
  });

  testWidgets(
    'T04 N07: closing seasons permanently revokes repository writes',
    (tester) async {
      final fixture = _Fixture();
      await fixture.initialize();
      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final availability = seasons.writeAvailability!;
      final lifetime = seasons.planningRouteLifetime!;
      final repository = seasons.plannedPlantingRepository!;

      expect(availability.canWrite, isTrue);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(SeasonsPage), findsNothing);
      expect(find.byType(GardenPage), findsOneWidget);
      expect(fixture.authority.canWrite, isTrue);
      expect(availability.canWrite, isFalse);
      expect(lifetime.isClosed, isTrue);

      await expectLater(
        repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      final reopened = await fixture.openSeasons(tester);

      expect(reopened.writeAvailability, isNot(same(availability)));
      expect(reopened.writeAvailability!.canWrite, isTrue);
      expect(availability.canWrite, isFalse);
      expect(lifetime.isClosed, isTrue);

      await fixture.unmount(tester);
    },
  );

  testWidgets('T05 N08: removing seasons revokes a surviving child route', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.initialize();
    await fixture.mount(tester);

    final seasons = await fixture.openSeasons(tester);
    final availability = seasons.writeAvailability!;
    final lifetime = seasons.planningRouteLifetime!;

    final seasonsRoute = ModalRoute.of(
      tester.element(find.byType(SeasonsPage)),
    )!;

    final plantings = await fixture.openPlantings(tester);

    expect(availability.canWrite, isTrue);
    expect(plantings.writeAvailability, same(availability));

    fixture.navigatorKey.currentState!.removeRoute(seasonsRoute);

    expect(availability.canWrite, isFalse);

    await tester.pumpAndSettle();

    expect(find.byType(PlannedPlantingsPage), findsOneWidget);
    expect(find.byType(SeasonsPage, skipOffstage: false), findsNothing);
    expect(lifetime.isClosed, isTrue);
    expect(fixture.authority.canWrite, isTrue);
    expect(availability.canWrite, isFalse);

    void listener() {}

    availability.addListener(listener);
    availability.removeListener(listener);

    await expectLater(
      plantings.repository.confirmPlannedPlanting(
        plannedPlantingId: _plannedPlantingId,
        expectedRowVersion: 1,
      ),
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );

    expect(fixture.rpcNames, isEmpty);
    expect(tester.takeException(), isNull);

    fixture.navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();

    expect(find.byType(GardenPage), findsOneWidget);
    expect(find.byType(PlannedPlantingsPage), findsNothing);
    expect(availability.canWrite, isFalse);
    expect(tester.takeException(), isNull);

    await fixture.unmount(tester);
  });

  testWidgets(
    'T06 N09: navigator destruction closes planning lifetime safely',
    (tester) async {
      final fixture = _Fixture();
      await fixture.initialize();
      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final plantings = await fixture.openPlantings(tester);
      final availability = seasons.writeAvailability!;
      final lifetime = seasons.planningRouteLifetime!;

      expect(availability.canWrite, isTrue);
      expect(lifetime.isClosed, isFalse);

      await fixture.unmount(tester);

      expect(fixture.navigatorKey.currentState, isNull);
      expect(lifetime.isClosed, isTrue);
      expect(availability.canWrite, isFalse);
      expect(fixture.authority.canWrite, isTrue);

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'T07 N11: destroying GardenPage revokes surviving planning routes',
    (tester) async {
      final fixture = _Fixture();
      await fixture.initialize();
      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final plantings = await fixture.openPlantings(tester);

      final availability = seasons.writeAvailability!;
      final lifetime = seasons.planningRouteLifetime!;

      expect(availability.canWrite, isTrue);
      expect(lifetime.isClosed, isFalse);

      var notifications = 0;

      void listener() {
        notifications++;
      }

      availability.addListener(listener);

      fixture.showGarden.value = false;

      await tester.pumpAndSettle();

      expect(find.byType(GardenPage, skipOffstage: false), findsNothing);

      expect(find.byType(SeasonsPage, skipOffstage: false), findsOneWidget);

      expect(find.byType(PlannedPlantingsPage), findsOneWidget);

      expect(fixture.authority.canWrite, isTrue);
      expect(availability.canWrite, isFalse);
      expect(lifetime.isClosed, isFalse);
      expect(notifications, 1);

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      availability.removeListener(listener);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(SeasonsPage), findsOneWidget);
      expect(availability.canWrite, isFalse);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(lifetime.isClosed, isTrue);
      expect(availability.canWrite, isFalse);
      expect(tester.takeException(), isNull);

      await fixture.unmount(tester);
    },
  );

  testWidgets(
    'T08 N10: authority loss and new lease cannot reactivate old route',
    (tester) async {
      final fixture = _Fixture();
      await fixture.initialize();
      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final plantings = await fixture.openPlantings(tester);
      final availability = seasons.writeAvailability!;

      expect(availability.canWrite, isTrue);

      var notifications = 0;

      void listener() {
        notifications++;
      }

      availability.addListener(listener);

      final releaseFuture = fixture.authority.release();

      expect(fixture.authority.canWrite, isFalse);
      expect(availability.canWrite, isFalse);
      expect(notifications, 1);

      await releaseFuture;
      await tester.pumpAndSettle();

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      fixture.acquisitionToken = 'nuovo-token-fittizio';

      await fixture.authority.initialize(
        profileContext: _owner,
        identity: const AppSessionIdentity(
          clientInstanceId: _clientId,
          sessionId: _sessionId,
        ),
      );

      await tester.pumpAndSettle();

      expect(fixture.authority.canWrite, isTrue);
      expect(availability.canWrite, isFalse);
      expect(notifications, 1);

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      availability.removeListener(listener);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      final reopened = await fixture.openSeasons(tester);
      final newPlantings = await fixture.openPlantings(tester);

      expect(reopened.writeAvailability, isNot(same(availability)));
      expect(reopened.writeAvailability!.canWrite, isTrue);
      expect(availability.canWrite, isFalse);

      final result = await newPlantings.repository.confirmPlannedPlanting(
        plannedPlantingId: _plannedPlantingId,
        expectedRowVersion: 1,
      );

      expect(result, isA<ConfirmPlannedPlantingConfirmed>());
      expect(fixture.rpcNames, ['confirm_planned_planting']);
      expect(
        fixture.rpcParameters.single['lock_token'],
        'nuovo-token-fittizio',
      );

      await fixture.unmount(tester);
    },
  );

  testWidgets('T09 N12: concurrent authority release and unmount remain safe', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.initialize();
    await fixture.mount(tester);

    final seasons = await fixture.openSeasons(tester);
    final plantings = await fixture.openPlantings(tester);
    final availability = seasons.writeAvailability!;
    final lifetime = seasons.planningRouteLifetime!;

    expect(availability.canWrite, isTrue);

    var notifications = 0;

    void listener() {
      notifications++;
    }

    availability.addListener(listener);

    final releaseFuture = fixture.authority.release();

    expect(availability.canWrite, isFalse);

    await fixture.unmount(tester);
    await releaseFuture;

    expect(fixture.authority.canWrite, isFalse);
    expect(availability.canWrite, isFalse);
    expect(lifetime.isClosed, isTrue);
    expect(notifications, 1);

    await expectLater(
      plantings.repository.confirmPlannedPlanting(
        plannedPlantingId: _plannedPlantingId,
        expectedRowVersion: 1,
      ),
      throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
    );

    expect(fixture.rpcNames, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'T10 R03: initially read-only route cannot acquire write authority',
    (tester) async {
      final fixture = _Fixture();

      await fixture.initialize();
      await fixture.authority.release();

      expect(fixture.authority.canWrite, isFalse);

      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final plantings = await fixture.openPlantings(tester);

      final availability = seasons.writeAvailability!;
      final lifetime = seasons.planningRouteLifetime!;

      expect(availability.canWrite, isFalse);
      expect(lifetime.isClosed, isFalse);
      expect(plantings.writeAvailability, same(availability));
      expect(plantings.repository, same(seasons.plannedPlantingRepository));

      expect(fixture.requestedSeasons, [_seasonId]);

      var notifications = 0;

      void listener() {
        notifications++;
      }

      availability.addListener(listener);

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      fixture.acquisitionToken = 'token-dopo-sola-lettura';

      await fixture.authority.initialize(
        profileContext: _owner,
        identity: const AppSessionIdentity(
          clientInstanceId: _clientId,
          sessionId: _sessionId,
        ),
      );

      await tester.pumpAndSettle();

      expect(fixture.authority.canWrite, isTrue);
      expect(availability.canWrite, isFalse);
      expect(notifications, 0);

      await expectLater(
        plantings.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      availability.removeListener(listener);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(lifetime.isClosed, isTrue);
      expect(availability.canWrite, isFalse);

      final reopened = await fixture.openSeasons(tester);
      final newPlantings = await fixture.openPlantings(tester);

      expect(reopened.writeAvailability, isNot(same(availability)));

      expect(reopened.writeAvailability!.canWrite, isTrue);
      expect(availability.canWrite, isFalse);

      final result = await newPlantings.repository.confirmPlannedPlanting(
        plannedPlantingId: _plannedPlantingId,
        expectedRowVersion: 1,
      );

      expect(result, isA<ConfirmPlannedPlantingConfirmed>());
      expect(fixture.rpcNames, ['confirm_planned_planting']);

      expect(
        fixture.rpcParameters.single['lock_token'],
        'token-dopo-sola-lettura',
      );

      expect(fixture.requestedSeasons, [_seasonId, _seasonId]);

      expect(tester.takeException(), isNull);

      await fixture.unmount(tester);
    },
  );

  test('T11 R05: RPC provider without list loader is rejected', () {
    expect(
      () => GardenPage(
        plannedPlantingRpcInvoker: (_, _) async => <String, dynamic>{},
      ),
      throwsA(
        isA<AssertionError>().having(
          (error) => error.message,
          'message',
          'Both planning transport providers must be supplied together.',
        ),
      ),
    );
  });

  test('T12 R05: list loader without RPC provider is rejected', () {
    expect(
      () => GardenPage(
        plannedPlantingListLoader: (_) async => <Map<String, dynamic>>[],
      ),
      throwsA(
        isA<AssertionError>().having(
          (error) => error.message,
          'message',
          'Both planning transport providers must be supplied together.',
        ),
      ),
    );
  });

  test('T13 R05: complete transport provider pair is accepted', () {
    Future<dynamic> rpcInvoker(
      String functionName,
      Map<String, dynamic> parameters,
    ) async {
      return <String, dynamic>{};
    }

    Future<List<Map<String, dynamic>>> listLoader(String seasonId) async {
      return <Map<String, dynamic>>[];
    }

    final page = GardenPage(
      plannedPlantingRpcInvoker: rpcInvoker,
      plannedPlantingListLoader: listLoader,
    );

    expect(page.plannedPlantingRpcInvoker, same(rpcInvoker));
    expect(page.plannedPlantingListLoader, same(listLoader));
    expect(page.plannedPlantingRepository, isNull);
  });

  testWidgets(
    'T14 R01-R05: incompatible repository and providers fail safely',
    (tester) async {
      final fixture = _Fixture();

      await fixture.initialize();

      final originalLease = fixture.authority.requireLeaseForWrite();

      var injectedRpcCalls = 0;
      var injectedLeaseCalls = 0;
      var injectedLoaderCalls = 0;

      final injectedRepository = PlannedPlantingRepository.withProviders(
        (_, _) async {
          injectedRpcCalls++;
          throw StateError('Injected RPC must not be called.');
        },
        () {
          injectedLeaseCalls++;
          return fixture.authority.requireLeaseForWrite();
        },
        loadPlannedPlantings: (_) async {
          injectedLoaderCalls++;
          return <Map<String, dynamic>>[];
        },
      );

      await fixture.mount(tester, injectedRepository: injectedRepository);

      expect(find.text('Stagioni'), findsOneWidget);

      await tester.tap(find.text('Stagioni'));

      expect(
        tester.takeException(),
        isA<StateError>().having(
          (error) => error.message,
          'message',
          'Planning repository and transport providers cannot be combined.',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(GardenPage), findsOneWidget);

      expect(find.byType(SeasonsPage, skipOffstage: false), findsNothing);

      expect(
        find.byType(PlannedPlantingsPage, skipOffstage: false),
        findsNothing,
      );

      expect(fixture.navigatorKey.currentState!.canPop(), isFalse);

      expect(fixture.authority.canWrite, isTrue);

      final currentLease = fixture.authority.requireLeaseForWrite();

      expect(currentLease.profileId, originalLease.profileId);
      expect(currentLease.lockToken, originalLease.lockToken);

      expect(
        currentLease.identity.clientInstanceId,
        originalLease.identity.clientInstanceId,
      );

      expect(currentLease.identity.sessionId, originalLease.identity.sessionId);

      expect(fixture.rpcNames, isEmpty);
      expect(fixture.requestedSeasons, isEmpty);

      expect(injectedRpcCalls, 0);
      expect(injectedLeaseCalls, 0);
      expect(injectedLoaderCalls, 0);

      expect(tester.takeException(), isNull);

      await fixture.mount(tester);

      final seasons = await fixture.openSeasons(tester);
      final plantings = await fixture.openPlantings(tester);

      expect(seasons.writeAvailability!.canWrite, isTrue);
      expect(seasons.planningRouteLifetime!.isClosed, isFalse);

      expect(plantings.writeAvailability, same(seasons.writeAvailability));

      final result = await plantings.repository.confirmPlannedPlanting(
        plannedPlantingId: _plannedPlantingId,
        expectedRowVersion: 1,
      );

      expect(result, isA<ConfirmPlannedPlantingConfirmed>());
      expect(fixture.rpcNames, ['confirm_planned_planting']);

      expect(
        fixture.rpcParameters.single['lock_token'],
        originalLease.lockToken,
      );

      expect(fixture.requestedSeasons, [_seasonId]);

      expect(injectedRpcCalls, 0);
      expect(injectedLeaseCalls, 0);
      expect(injectedLoaderCalls, 0);

      await fixture.authority.release();
      await tester.pumpAndSettle();

      expect(seasons.writeAvailability!.canWrite, isFalse);

      await fixture.unmount(tester);
    },
  );

  testWidgets(
    'T15 UI-T14: navigation preserves consultation after authority loss',
    (tester) async {
      final fixture = _Fixture();
      await fixture.initialize();
      await fixture.mount(tester);

      const writeLabel = 'Scrittura disponibile';
      const readOnlyLabel = 'Modalit\u00E0 sola lettura';
      const emptyLabel = 'Nessuna pianificazione presente per questa stagione.';

      void expectWritable() {
        expect(find.text(writeLabel), findsOneWidget);
        expect(find.text(readOnlyLabel), findsNothing);
        expect(find.byIcon(Icons.lock_open), findsOneWidget);
        expect(find.text(emptyLabel), findsOneWidget);
      }

      void expectReadOnly() {
        expect(find.text(readOnlyLabel), findsOneWidget);
        expect(find.text(writeLabel), findsNothing);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.text(emptyLabel), findsOneWidget);
      }

      final seasons = await fixture.openSeasons(tester);
      final firstPage = await fixture.openPlantings(tester);

      final availability = seasons.writeAvailability!;
      final lifetime = seasons.planningRouteLifetime!;

      expect(firstPage.writeAvailability, same(availability));
      expect(availability.canWrite, isTrue);
      expect(lifetime.isClosed, isFalse);

      expectWritable();

      expect(fixture.requestedSeasons, [_seasonId]);
      expect(fixture.rpcNames, isEmpty);

      await fixture.authority.release();
      await tester.pumpAndSettle();

      expect(fixture.authority.canWrite, isFalse);
      expect(availability.canWrite, isFalse);

      expectReadOnly();

      expect(fixture.requestedSeasons, [_seasonId]);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(SeasonsPage), findsOneWidget);
      expect(lifetime.isClosed, isFalse);

      final secondPage = await fixture.openPlantings(tester);

      expect(secondPage.writeAvailability, same(availability));
      expect(secondPage.repository, same(firstPage.repository));

      expectReadOnly();

      expect(fixture.requestedSeasons, [_seasonId, _seasonId]);

      fixture.acquisitionToken = 'new-navigation-ui-test-token';

      await fixture.authority.initialize(
        profileContext: _owner,
        identity: const AppSessionIdentity(
          clientInstanceId: _clientId,
          sessionId: _sessionId,
        ),
      );

      await tester.pumpAndSettle();

      expect(fixture.authority.canWrite, isTrue);
      expect(availability.canWrite, isFalse);

      expectReadOnly();

      expect(fixture.requestedSeasons, [_seasonId, _seasonId]);

      await expectLater(
        secondPage.repository.confirmPlannedPlanting(
          plannedPlantingId: _plannedPlantingId,
          expectedRowVersion: 1,
        ),
        throwsA(isA<ProfileWriteAuthorityUnavailableException>()),
      );

      expect(fixture.rpcNames, isEmpty);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(SeasonsPage), findsOneWidget);

      final thirdPage = await fixture.openPlantings(tester);

      expect(thirdPage.writeAvailability, same(availability));
      expect(thirdPage.repository, same(firstPage.repository));

      expectReadOnly();

      expect(fixture.requestedSeasons, [_seasonId, _seasonId, _seasonId]);

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      fixture.navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.byType(GardenPage), findsOneWidget);
      expect(lifetime.isClosed, isTrue);
      expect(availability.canWrite, isFalse);

      final reopened = await fixture.openSeasons(tester);
      final newPage = await fixture.openPlantings(tester);

      expect(reopened.writeAvailability, isNot(same(availability)));

      expect(newPage.writeAvailability, same(reopened.writeAvailability));

      expect(newPage.repository, isNot(same(firstPage.repository)));

      expect(reopened.writeAvailability!.canWrite, isTrue);
      expect(availability.canWrite, isFalse);

      expectWritable();

      expect(fixture.requestedSeasons, [
        _seasonId,
        _seasonId,
        _seasonId,
        _seasonId,
      ]);

      expect(fixture.rpcNames, isEmpty);
      expect(tester.takeException(), isNull);

      await fixture.unmount(tester);

      expect(fixture.rpcNames, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
}
