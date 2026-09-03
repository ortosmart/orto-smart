import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/core/write_authority/profile_edit_lock.dart';
import 'package:orto_app/data/models/bed.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/crop_association.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/crop_association_repository.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';
import 'package:orto_app/data/repositories/planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/bed_page.dart';
import 'package:orto_app/pages/change_bed_geometry_page.dart';
import 'package:orto_app/pages/correct_bed_geometry_page.dart';
import 'package:orto_app/widgets/bed_layout_widget.dart';
import 'package:orto_app/widgets/garden/bed_card.dart';
import 'package:orto_app/widgets/garden/garden_map.dart';

const _gardenId = '11111111-1111-4111-8111-111111111111';
const _bedId = '22222222-2222-4222-8222-222222222222';
const _geometryId = '33333333-3333-4333-8333-333333333333';

class _ScheduledTask implements ScheduledWriteAuthorityTask {
  bool _active = true;

  @override
  bool get isActive => _active;

  @override
  void cancel() {
    _active = false;
  }
}

class _Scheduler implements WriteAuthorityScheduler {
  @override
  ScheduledWriteAuthorityTask schedule(
    Duration delay,
    ScheduledWriteAuthorityAction action,
  ) {
    // Il tempo è controllato dal test; nessun timer reale.
    return _ScheduledTask();
  }
}

Map<String, dynamic> _bedMap({
  String bedId = _bedId,
  String gardenId = _gardenId,
  String name = 'Aiuola iniziale',
  int widthCm = 90,
  int lengthCm = 700,
  bool isActive = true,
  int rowVersion = 1,
}) {
  return {
    'id': bedId,
    'garden_id': gardenId,
    'number': 1,
    'name': name,
    'notes': null,
    'is_active': isActive,
    'row_version': rowVersion,
    'bed_geometries': [
      {
        'id': _geometryId,
        'bed_id': bedId,
        'width_cm': widthCm,
        'length_cm': lengthCm,
        'valid_from': '2026-03-01',
        'valid_to': null,
        'row_version': 1,
      },
    ],
  };
}

class _PlantingRepositoryFake extends Fake implements PlantingRepository {
  final requestedBeds = <String>[];
  bool failNextLoad = false;

  @override
  Future<List<Planting>> getPlantingsByBed(String bedId) async {
    requestedBeds.add(bedId);

    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('Synthetic planting load failure');
    }

    return [];
  }
}

class _CropRepositoryFake extends Fake implements CropRepository {
  int calls = 0;

  @override
  Future<List<Crop>> getCrops() async {
    calls++;
    return [];
  }
}

class _CropAssociationRepositoryFake extends Fake
    implements CropAssociationRepository {
  int calls = 0;

  @override
  Future<List<CropAssociation>> getAllAssociations() async {
    calls++;
    return [];
  }
}

class _Harness {
  final plantings = _PlantingRepositoryFake();
  final crops = _CropRepositoryFake();
  final associations = _CropAssociationRepositoryFake();
  final requestedBeds = <List<String>>[];

  late final BedRepository repository;

  _Harness(Future<Map<String, dynamic>?> Function() loadBed) {
    repository = BedRepository.withLoader(
      (_) async => throw StateError('Unexpected list request'),
      (gardenId, bedId) {
        requestedBeds.add([gardenId, bedId]);
        return loadBed();
      },
    );
  }

  Widget app({Bed? bed}) {
    return MaterialApp(
      home: BedPage(
        bed: bed ?? Bed.fromMap(_bedMap()),
        repository: repository,
        plantingRepository: plantings,
        cropRepository: crops,
        cropAssociationRepository: associations,
      ),
    );
  }

  void expectNoCropLoads() {
    expect(plantings.requestedBeds, isEmpty);
    expect(crops.calls, 0);
    expect(associations.calls, 0);
  }

  void expectOneCropLoad() {
    expect(plantings.requestedBeds, [_bedId]);
    expect(crops.calls, 1);
    expect(associations.calls, 1);
  }
}

class _WriteHarness {
  final plantings = _PlantingRepositoryFake();
  final crops = _CropRepositoryFake();
  final associations = _CropAssociationRepositoryFake();
  final requestedBeds = <List<String>>[];
  final rpcCalls = <Map<String, dynamic>>[];

  late final BedRepository repository;

  _WriteHarness({
    required Future<Map<String, dynamic>?> Function() loadBed,
    required Future<dynamic> Function(
      String functionName,
      Map<String, dynamic> parameters,
    )
    invokeRpc,
  }) {
    repository = BedRepository.withProviders(
      (_) async => throw StateError('Unexpected list request'),
      (functionName, parameters) async {
        rpcCalls.add({'functionName': functionName, 'parameters': parameters});

        return invokeRpc(functionName, parameters);
      },
      () => ProfileEditLockLease(
        profileId: '44444444-4444-4444-8444-444444444444',
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
        lockToken: 'token-bed-page-esclusivamente-fittizio',
        expiresAt: DateTime.utc(2026, 9, 2, 23),
        rowVersion: 1,
      ),
      (gardenId, bedId) {
        requestedBeds.add([gardenId, bedId]);
        return loadBed();
      },
    );
  }
}

void main() {
  group('BedPage authoritative reading', () {
    testWidgets(
      'opens the real detail from the map with injected repositories',
      (tester) async {
        final plantings = _PlantingRepositoryFake();
        final crops = _CropRepositoryFake();
        final associations = _CropAssociationRepositoryFake();
        final requestedGardens = <String>[];
        final requestedDetails = <List<String>>[];

        final repository = BedRepository.withLoader(
          (gardenId) async {
            requestedGardens.add(gardenId);
            return [_bedMap(name: 'Nome nella lista')];
          },
          (gardenId, bedId) async {
            requestedDetails.add([gardenId, bedId]);
            return _bedMap(
              name: 'Nome riletto nel dettaglio',
              widthCm: 120,
              lengthCm: 600,
              rowVersion: 3,
            );
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GardenMap(
                  gardenId: _gardenId,
                  repository: repository,
                  plantingRepository: plantings,
                  cropRepository: crops,
                  cropAssociationRepository: associations,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BedCard), findsOneWidget);
        expect(find.text('Nome nella lista'), findsOneWidget);
        expect(requestedGardens, [_gardenId]);
        expect(requestedDetails, isEmpty);
        expect(plantings.requestedBeds, isEmpty);
        expect(crops.calls, 0);
        expect(associations.calls, 0);

        await tester.tap(find.byType(BedCard));
        await tester.pumpAndSettle();

        expect(find.byType(BedPage), findsOneWidget);

        final page = tester.widget<BedPage>(find.byType(BedPage));

        expect(page.repository, same(repository));
        expect(page.plantingRepository, same(plantings));
        expect(page.cropRepository, same(crops));
        expect(page.cropAssociationRepository, same(associations));
        expect(find.text('Nome riletto nel dettaglio'), findsOneWidget);
        expect(find.text('Nome nella lista'), findsNothing);
        expect(find.text('120 × 600 cm'), findsOneWidget);

        final layout = tester.widget<BedLayoutWidget>(
          find.byType(BedLayoutWidget),
        );

        expect(layout.bed.id, _bedId);
        expect(layout.bed.gardenId, _gardenId);
        expect(layout.bed.rowVersion, 3);
        expect(requestedDetails, [
          [_gardenId, _bedId],
        ]);
        expect(plantings.requestedBeds, [_bedId]);
        expect(crops.calls, 1);
        expect(associations.calls, 1);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(BedPage), findsNothing);
        expect(find.byType(BedCard), findsOneWidget);
        expect(requestedGardens, [_gardenId]);
        expect(requestedDetails, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );

    for (final changeGardenOnly in [false, true]) {
      testWidgets(
        'reloads when only ${changeGardenOnly ? 'gardenId' : 'bedId'} '
        'changes with the same repositories',
        (tester) async {
          const secondBedId = '44444444-4444-4444-8444-444444444444';
          const secondGardenId = '66666666-6666-4666-8666-666666666666';

          final nextBedId = changeGardenOnly ? _bedId : secondBedId;
          final nextGardenId = changeGardenOnly ? secondGardenId : _gardenId;
          final response = Completer<Map<String, dynamic>?>();
          var attempts = 0;

          final harness = _Harness(() async {
            attempts++;
            if (attempts == 1) {
              return _bedMap(name: 'Dettaglio precedente');
            }
            return response.future;
          });

          await tester.pumpWidget(harness.app());
          await tester.pumpAndSettle();

          expect(find.text('Dettaglio precedente'), findsOneWidget);
          harness.expectOneCropLoad();

          final originalState = tester.state(find.byType(BedPage));

          await tester.pumpWidget(
            harness.app(
              bed: Bed.fromMap(
                _bedMap(
                  bedId: nextBedId,
                  gardenId: nextGardenId,
                  name: 'Dato provvisorio',
                ),
              ),
            ),
          );
          await tester.pump();

          expect(tester.state(find.byType(BedPage)), same(originalState));
          expect(attempts, 2);
          expect(harness.requestedBeds, [
            [_gardenId, _bedId],
            [nextGardenId, nextBedId],
          ]);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('Dettaglio precedente'), findsNothing);
          expect(find.text('Dato provvisorio'), findsNothing);
          expect(find.byType(BedLayoutWidget), findsNothing);
          expect(find.text('Aggiungi coltura'), findsNothing);
          harness.expectOneCropLoad();

          response.complete(
            _bedMap(
              bedId: nextBedId,
              gardenId: nextGardenId,
              name: 'Nuovo dettaglio verificato',
              widthCm: 100,
              lengthCm: 550,
              rowVersion: 2,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Nuovo dettaglio verificato'), findsOneWidget);
          expect(find.text('Dettaglio precedente'), findsNothing);
          expect(find.text('Dato provvisorio'), findsNothing);
          expect(find.text('100 × 550 cm'), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);

          final layout = tester.widget<BedLayoutWidget>(
            find.byType(BedLayoutWidget),
          );

          expect(layout.bed.id, nextBedId);
          expect(layout.bed.gardenId, nextGardenId);
          expect(layout.bed.rowVersion, 2);
          expect(harness.plantings.requestedBeds, [_bedId, nextBedId]);
          expect(harness.crops.calls, 2);
          expect(harness.associations.calls, 2);
          expect(attempts, 2);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('hides the initial detail while loading', (tester) async {
      final response = Completer<Map<String, dynamic>?>();
      final harness = _Harness(() => response.future);

      await tester.pumpWidget(harness.app());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Aiuola iniziale'), findsNothing);
      expect(find.text('Dimensioni'), findsNothing);
      expect(find.byType(BedLayoutWidget), findsNothing);
      expect(find.text('Aggiungi coltura'), findsNothing);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      harness.expectNoCropLoads();

      response.complete(_bedMap(name: 'Aiuola riletta'));
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Aiuola riletta'), findsOneWidget);
      harness.expectOneCropLoad();
      expect(tester.takeException(), isNull);
    });

    testWidgets('refresh reloads the bed and hides previous data', (
      tester,
    ) async {
      final refreshedResponse = Completer<Map<String, dynamic>?>();
      var attempts = 0;

      final harness = _Harness(() async {
        attempts++;
        if (attempts == 1) {
          return _bedMap(name: 'Prima lettura');
        }
        return refreshedResponse.future;
      });

      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      expect(find.text('Prima lettura'), findsOneWidget);
      harness.expectOneCropLoad();

      await tester.tap(find.byTooltip('Aggiorna'));
      await tester.pump();

      expect(attempts, 2);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Prima lettura'), findsNothing);
      expect(find.text('Dimensioni'), findsNothing);
      expect(find.byType(BedLayoutWidget), findsNothing);
      expect(find.text('Aggiungi coltura'), findsNothing);
      harness.expectOneCropLoad();

      refreshedResponse.complete(
        _bedMap(
          name: 'Seconda lettura',
          widthCm: 100,
          lengthCm: 600,
          isActive: false,
          rowVersion: 5,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Prima lettura'), findsNothing);
      expect(find.text('Seconda lettura'), findsOneWidget);
      expect(find.text('100 × 600 cm'), findsOneWidget);

      final layout = tester.widget<BedLayoutWidget>(
        find.byType(BedLayoutWidget),
      );

      expect(layout.bed.widthCm, 100);
      expect(layout.bed.lengthCm, 600);
      expect(layout.bed.isActive, isFalse);
      expect(layout.bed.rowVersion, 5);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
        [_gardenId, _bedId],
      ]);
      expect(harness.plantings.requestedBeds, [_bedId, _bedId]);
      expect(harness.crops.calls, 2);
      expect(harness.associations.calls, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ignores a response after the page is removed', (tester) async {
      final response = Completer<Map<String, dynamic>?>();
      final harness = _Harness(() => response.future);

      await tester.pumpWidget(harness.app());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      harness.expectNoCropLoads();

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Pagina successiva'))),
      );

      expect(find.byType(BedPage), findsNothing);

      response.complete(_bedMap(name: 'Risposta tardiva'));
      await tester.pumpAndSettle();

      expect(find.text('Pagina successiva'), findsOneWidget);
      expect(find.text('Risposta tardiva'), findsNothing);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      harness.expectNoCropLoads();
      expect(tester.takeException(), isNull);
    });
    for (final oldRequestFails in [false, true]) {
      testWidgets(
        'ignores an obsolete ${oldRequestFails ? 'error' : 'response'} '
        'after repositories change',
        (tester) async {
          final oldResponse = Completer<Map<String, dynamic>?>();
          final newResponse = Completer<Map<String, dynamic>?>();
          final oldHarness = _Harness(() => oldResponse.future);
          final newHarness = _Harness(() => newResponse.future);

          await tester.pumpWidget(oldHarness.app());

          final originalState = tester.state(find.byType(BedPage));

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          oldHarness.expectNoCropLoads();

          await tester.pumpWidget(newHarness.app());
          await tester.pump();

          expect(tester.state(find.byType(BedPage)), same(originalState));
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(oldHarness.requestedBeds, [
            [_gardenId, _bedId],
          ]);
          expect(newHarness.requestedBeds, [
            [_gardenId, _bedId],
          ]);
          oldHarness.expectNoCropLoads();
          newHarness.expectNoCropLoads();

          newResponse.complete(
            _bedMap(
              name: 'Risposta corrente',
              widthCm: 110,
              lengthCm: 650,
              rowVersion: 3,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Risposta corrente'), findsOneWidget);
          newHarness.expectOneCropLoad();
          oldHarness.expectNoCropLoads();

          if (oldRequestFails) {
            oldResponse.completeError(StateError('Synthetic obsolete failure'));
          } else {
            oldResponse.complete(_bedMap(name: 'Risposta superata'));
          }
          await tester.pumpAndSettle();

          expect(find.text('Risposta corrente'), findsOneWidget);
          expect(find.text('Risposta superata'), findsNothing);
          expect(find.text('110 × 650 cm'), findsOneWidget);
          expect(
            find.text('Non è stato possibile caricare l’aiuola.'),
            findsNothing,
          );
          expect(find.text('Riprova'), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsNothing);

          final layout = tester.widget<BedLayoutWidget>(
            find.byType(BedLayoutWidget),
          );

          expect(layout.bed.rowVersion, 3);
          expect(layout.bed.widthCm, 110);
          expect(layout.bed.lengthCm, 650);
          oldHarness.expectNoCropLoads();
          newHarness.expectOneCropLoad();
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('crop failure preserves the bed and retries only crops', (
      tester,
    ) async {
      final harness = _Harness(() async => _bedMap(name: 'Aiuola disponibile'));
      harness.plantings.failNextLoad = true;

      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      expect(find.text('Aiuola disponibile'), findsOneWidget);
      expect(find.text('90 × 700 cm'), findsOneWidget);
      expect(
        find.text('Non è stato possibile caricare l’aiuola.'),
        findsNothing,
      );
      expect(
        find.text('Aiuola non disponibile nell’orto richiesto.'),
        findsNothing,
      );
      expect(
        find.textContaining('Errore nel caricamento delle colture:'),
        findsOneWidget,
      );
      expect(find.byType(BedLayoutWidget), findsNothing);
      expect(find.text('Riprova'), findsOneWidget);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      harness.expectOneCropLoad();
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Riprova'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Errore nel caricamento delle colture:'),
        findsNothing,
      );
      expect(find.text('Riprova'), findsNothing);
      expect(find.byType(BedLayoutWidget), findsOneWidget);

      final layout = tester.widget<BedLayoutWidget>(
        find.byType(BedLayoutWidget),
      );

      expect(layout.bed.id, _bedId);
      expect(layout.bed.name, 'Aiuola disponibile');
      expect(layout.bed.widthCm, 90);
      expect(layout.bed.lengthCm, 700);

      // La riprova delle colture non deve rileggere l'aiuola.
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      expect(harness.plantings.requestedBeds, [_bedId, _bedId]);
      expect(harness.crops.calls, 2);
      expect(harness.associations.calls, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses the reloaded dimensions, status and version', (
      tester,
    ) async {
      final harness = _Harness(
        () async => _bedMap(
          name: 'Aiuola aggiornata',
          widthCm: 120,
          lengthCm: 500,
          isActive: false,
          rowVersion: 4,
        ),
      );

      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      expect(find.text('Aiuola iniziale'), findsNothing);
      expect(find.text('Aiuola aggiornata'), findsOneWidget);
      expect(find.text('120 × 500 cm'), findsOneWidget);
      expect(find.text('90 × 700 cm'), findsNothing);
      expect(find.byType(BedLayoutWidget), findsOneWidget);

      final layout = tester.widget<BedLayoutWidget>(
        find.byType(BedLayoutWidget),
      );

      expect(layout.bed.id, _bedId);
      expect(layout.bed.gardenId, _gardenId);
      expect(layout.bed.widthCm, 120);
      expect(layout.bed.lengthCm, 500);
      expect(layout.bed.isActive, isFalse);
      expect(layout.bed.rowVersion, 4);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      harness.expectOneCropLoad();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows unavailable without loading crops', (tester) async {
      final harness = _Harness(() async => null);

      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      expect(
        find.text('Aiuola non disponibile nell’orto richiesto.'),
        findsOneWidget,
      );
      expect(
        find.text('Non è stato possibile caricare l’aiuola.'),
        findsNothing,
      );
      expect(find.text('Riprova'), findsOneWidget);
      expect(find.text('Aiuola iniziale'), findsNothing);
      expect(find.text('Aggiungi coltura'), findsNothing);
      expect(find.byType(BedLayoutWidget), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
      ]);
      harness.expectNoCropLoads();
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows a generic error and retries on request', (tester) async {
      const technicalDetail = 'Synthetic internal bed failure';
      var attempts = 0;

      final harness = _Harness(() async {
        attempts++;
        if (attempts == 1) {
          throw StateError(technicalDetail);
        }
        return _bedMap(name: 'Aiuola recuperata');
      });

      await tester.pumpWidget(harness.app());
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare l’aiuola.'),
        findsOneWidget,
      );
      expect(
        find.text('Aiuola non disponibile nell’orto richiesto.'),
        findsNothing,
      );
      expect(find.textContaining(technicalDetail), findsNothing);
      expect(find.text('Riprova'), findsOneWidget);
      expect(find.byType(BedLayoutWidget), findsNothing);
      harness.expectNoCropLoads();
      expect(attempts, 1);

      await tester.pump(const Duration(seconds: 1));

      expect(attempts, 1);
      harness.expectNoCropLoads();

      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(
        find.text('Non è stato possibile caricare l’aiuola.'),
        findsNothing,
      );
      expect(find.text('Riprova'), findsNothing);
      expect(find.text('Aiuola recuperata'), findsOneWidget);
      expect(find.byType(BedLayoutWidget), findsOneWidget);
      expect(attempts, 2);
      expect(harness.requestedBeds, [
        [_gardenId, _bedId],
        [_gardenId, _bedId],
      ]);
      harness.expectOneCropLoad();
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets('apre la pagina di modifica geometria dalla card Dimensioni', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 9, 2, 12);

    final authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-bed-page-geometry-fittizio',
          'expires_at': '2026-09-02T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: '44444444-4444-4444-8444-444444444444',
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );

    final harness = _WriteHarness(
      loadBed: () async => _bedMap(),
      invokeRpc: (functionName, parameters) async {
        throw StateError('RPC non attesa');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BedPage(
          bed: Bed.fromMap(_bedMap()),
          authority: authority,
          repository: harness.repository,
          plantingRepository: harness.plantings,
          cropRepository: harness.crops,
          cropAssociationRepository: harness.associations,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Dimensioni'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeBedGeometryPage), findsOneWidget);
    expect(find.text('Modifica geometria'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('apre la pagina di correzione geometria', (tester) async {
    final now = DateTime.utc(2026, 9, 2, 12);

    final authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-bed-page-correction-fittizio',
          'expires_at': '2026-09-02T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: '44444444-4444-4444-8444-444444444444',
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );

    final harness = _WriteHarness(
      loadBed: () async => _bedMap(),
      invokeRpc: (functionName, parameters) async {
        throw StateError('RPC non attesa');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BedPage(
          bed: Bed.fromMap(_bedMap()),
          authority: authority,
          repository: harness.repository,
          plantingRepository: harness.plantings,
          cropRepository: harness.crops,
          cropAssociationRepository: harness.associations,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Correggi geometria'));
    await tester.pumpAndSettle();

    expect(find.byType(CorrectBedGeometryPage), findsOneWidget);
    expect(find.text('Correggi geometria'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('rilegge l aiuola dopo la correzione della geometria', (
    tester,
  ) async {
    var loadCount = 0;
    final now = DateTime.utc(2026, 9, 2, 12);

    final authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-bed-page-correction-reload-fittizio',
          'expires_at': '2026-09-02T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: '44444444-4444-4444-8444-444444444444',
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );

    final harness = _WriteHarness(
      loadBed: () async {
        loadCount++;

        return _bedMap(
          widthCm: loadCount == 1 ? 90 : 95,
          lengthCm: loadCount == 1 ? 700 : 710,
          rowVersion: loadCount == 1 ? 1 : 2,
        );
      },
      invokeRpc: (functionName, parameters) async {
        expect(functionName, 'correct_bed_geometry');
        expect(parameters['target_bed_id'], _bedId);
        expect(parameters['target_geometry_id'], _geometryId);
        expect(parameters['expected_row_version'], 1);
        expect(parameters['geometry_width_cm'], 95);
        expect(parameters['geometry_length_cm'], 710);
        expect(parameters['geometry_valid_from'], '2026-03-02');
        expect(parameters['correction_reason'], 'Rettifica misura errata');

        return {
          'status': 'corrected',
          'bed_id': _bedId,
          'garden_id': _gardenId,
          'row_version': 2,
          'updated_at': '2026-09-03T09:01:00+00:00',
          'geometry_id': _geometryId,
          'width_cm': 95,
          'length_cm': 710,
          'valid_from': '2026-03-02',
          'valid_to': null,
          'geometry_row_version': 2,
          'geometry_updated_at': '2026-09-03T09:01:00+00:00',
          'correction_id': 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
          'correction_created_at': '2026-09-03T09:01:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BedPage(
          bed: Bed.fromMap(_bedMap()),
          authority: authority,
          repository: harness.repository,
          plantingRepository: harness.plantings,
          cropRepository: harness.crops,
          cropAssociationRepository: harness.associations,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('90 × 700 cm'), findsOneWidget);

    await tester.tap(find.text('Correggi geometria'));
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[0]), '95');
    await tester.enterText(find.byWidget(fields[1]), '710');
    await tester.enterText(find.byWidget(fields[2]), '02/03/2026');
    await tester.enterText(
      find.byWidget(fields[3]),
      '  Rettifica misura errata  ',
    );

    await tester.tap(find.text('Conferma correzione'));
    await tester.pumpAndSettle();

    expect(find.byType(CorrectBedGeometryPage), findsNothing);
    expect(harness.rpcCalls, hasLength(1));
    expect(loadCount, 2);
    expect(find.text('95 × 710 cm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('rilegge l aiuola dopo la modifica della geometria', (
    tester,
  ) async {
    var loadCount = 0;
    final now = DateTime.utc(2026, 9, 2, 12);

    final authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-bed-page-geometry-reload-fittizio',
          'expires_at': '2026-09-02T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: '44444444-4444-4444-8444-444444444444',
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );

    final harness = _WriteHarness(
      loadBed: () async {
        loadCount++;

        return _bedMap(
          widthCm: loadCount == 1 ? 90 : 100,
          lengthCm: loadCount == 1 ? 700 : 750,
          rowVersion: loadCount == 1 ? 1 : 2,
        );
      },
      invokeRpc: (functionName, parameters) async {
        expect(functionName, 'change_bed_geometry');
        expect(parameters['target_bed_id'], _bedId);
        expect(parameters['expected_row_version'], 1);
        expect(parameters['geometry_width_cm'], 100);
        expect(parameters['geometry_length_cm'], 750);
        expect(parameters['geometry_valid_from'], '2026-09-03');

        return {
          'status': 'changed',
          'bed_id': _bedId,
          'garden_id': _gardenId,
          'row_version': 2,
          'updated_at': '2026-09-03T08:01:00+00:00',
          'geometry_id': 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
          'width_cm': 100,
          'length_cm': 750,
          'valid_from': '2026-09-03',
          'valid_to': null,
          'geometry_row_version': 1,
          'geometry_created_at': '2026-09-03T08:01:00+00:00',
          'previous_geometry_id': _geometryId,
          'previous_geometry_valid_to': '2026-09-03',
          'previous_geometry_row_version': 2,
          'previous_geometry_updated_at': '2026-09-03T08:01:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BedPage(
          bed: Bed.fromMap(_bedMap()),
          authority: authority,
          repository: harness.repository,
          plantingRepository: harness.plantings,
          cropRepository: harness.crops,
          cropAssociationRepository: harness.associations,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('90 × 700 cm'), findsOneWidget);

    await tester.tap(find.text('Dimensioni'));
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[0]), '100');
    await tester.enterText(find.byWidget(fields[1]), '750');
    await tester.enterText(find.byWidget(fields[2]), '03/09/2026');

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(find.byType(ChangeBedGeometryPage), findsNothing);
    expect(
      find.textContaining('Non è stato possibile confermare'),
      findsNothing,
    );

    expect(harness.rpcCalls, hasLength(1));
    expect(loadCount, 2);
    expect(find.byType(ChangeBedGeometryPage), findsNothing);
    expect(find.text('100 × 750 cm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  group('BedPage active state writing', () {
    testWidgets('disattiva una aiuola attiva', (tester) async {
      var loadCount = 0;
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async {
          loadCount++;

          return _bedMap(
            isActive: loadCount == 1,
            rowVersion: loadCount == 1 ? 1 : 2,
          );
        },
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');
          expect(parameters['target_bed_id'], _bedId);
          expect(parameters['expected_row_version'], 1);
          expect(parameters['bed_is_active'], isFalse);

          return {
            'status': 'updated',
            'bed_id': _bedId,
            'garden_id': _gardenId,
            'is_active': false,
            'row_version': 2,
            'updated_at': '2026-09-02T12:01:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Attiva'), findsOneWidget);

      var switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isTrue);
      expect(switchTile.onChanged, isNotNull);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(loadCount, 2);
      expect(find.text('Disattivata'), findsOneWidget);

      switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));

      expect(switchTile.value, isFalse);
      expect(tester.takeException(), isNull);
    });
    testWidgets('riattiva una aiuola disattivata', (tester) async {
      var loadCount = 0;
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async {
          loadCount++;

          return _bedMap(
            isActive: loadCount != 1,
            rowVersion: loadCount == 1 ? 1 : 2,
          );
        },
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');
          expect(parameters['target_bed_id'], _bedId);
          expect(parameters['expected_row_version'], 1);
          expect(parameters['bed_is_active'], isTrue);

          return {
            'status': 'updated',
            'bed_id': _bedId,
            'garden_id': _gardenId,
            'is_active': true,
            'row_version': 2,
            'updated_at': '2026-09-02T12:01:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap(isActive: false)),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Disattivata'), findsOneWidget);

      var switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isFalse);
      expect(switchTile.onChanged, isNotNull);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(loadCount, 2);
      expect(find.text('Attiva'), findsOneWidget);

      switchTile = tester.widget<SwitchListTile>(find.byType(SwitchListTile));

      expect(switchTile.value, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore in caso di conflitto di versione sullo stato', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');
          expect(parameters['expected_row_version'], 1);

          return {
            'status': 'version_conflict',
            'bed_id': _bedId,
            'expected_row_version': 1,
            'current_row_version': 2,
            'updated_at': '2026-09-02T12:01:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(
        find.text(
          'L’aiuola è stata modificata da un’altra sessione. '
          'Aggiorna i dati prima di riprovare.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore se la modifica dello stato non è autorizzata', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');

          return {'status': 'forbidden'};
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(
        find.text('Non sei autorizzato a modificare questa aiuola.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore se il server rifiuta la scrittura dello stato', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');

          return {'status': 'write_forbidden'};
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(
        find.text('Il server non ha autorizzato la scrittura.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore se l aiuola non esiste più', (tester) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');

          return {'status': 'not_found'};
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(find.text('L’aiuola non è più disponibile.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore se il server rifiuta la modifica dello stato', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');

          return {'status': 'invalid_input'};
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(
        find.text('Il server ha rifiutato la modifica dello stato.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets('mostra errore se l esito della modifica non è confermato', (
      tester,
    ) async {
      final now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          expect(functionName, 'set_bed_active');
          throw StateError('errore simulato');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, hasLength(1));
      expect(
        find.text('Non è stato possibile confermare l’esito della modifica.'),
        findsOneWidget,
      );

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isTrue);
      expect(tester.takeException(), isNull);
    });
    testWidgets('non modifica lo stato se la lease scade prima del tap', (
      tester,
    ) async {
      var now = DateTime.utc(2026, 9, 2, 12);

      final authority = ProfileWriteAuthorityController(
        ProfileEditLockRepository.withRpcInvoker((
          functionName,
          parameters,
        ) async {
          expect(functionName, 'acquire_profile_edit_lock');

          return {
            'status': 'acquired',
            'lock_token': 'token-bed-page-authority-fittizio',
            'expires_at': '2026-09-02T12:02:00+00:00',
            'row_version': 1,
          };
        }),
        _Scheduler(),
        utcNow: () => now,
      );

      addTearDown(authority.dispose);

      await authority.initialize(
        profileContext: const ProfileContext(
          profileId: '44444444-4444-4444-8444-444444444444',
          role: ProfileMemberRole.owner,
        ),
        identity: const AppSessionIdentity(
          clientInstanceId: '55555555-5555-4555-8555-555555555555',
          sessionId: '66666666-6666-4666-8666-666666666666',
        ),
      );

      final harness = _WriteHarness(
        loadBed: () async => _bedMap(isActive: true, rowVersion: 1),
        invokeRpc: (functionName, parameters) async {
          fail('La RPC non deve essere chiamata con lease scaduta.');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BedPage(
            bed: Bed.fromMap(_bedMap()),
            authority: authority,
            repository: harness.repository,
            plantingRepository: harness.plantings,
            cropRepository: harness.crops,
            cropAssociationRepository: harness.associations,
          ),
        ),
      );

      await tester.pumpAndSettle();

      now = DateTime.utc(2026, 9, 2, 12, 3);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(harness.rpcCalls, isEmpty);
      expect(
        find.text('Autorità di scrittura non disponibile.'),
        findsOneWidget,
      );

      final switchTile = tester.widget<SwitchListTile>(
        find.byType(SwitchListTile),
      );

      expect(switchTile.value, isTrue);
      expect(tester.takeException(), isNull);
    });
  });
}
