import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/mutation_operation_contract.dart';
import 'package:orto_app/core/write_authority/mutation_operation_coordinator.dart';
import 'package:orto_app/core/write_authority/mutation_operation_journal.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/route_write_availability.dart';
import 'package:orto_app/core/write_authority/seasonal_planning_mutation_service.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/planned_planting_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/data/models/bed.dart';
import 'package:orto_app/data/models/bed_geometry.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/season.dart';
import 'package:orto_app/data/models/crop_cultivar.dart';
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

final class _RecoveryTestPersistence implements MutationJournalPersistence {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
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
  group('Salvataggio dal modulo di pianificazione', () {
    const gardenId = '55555555-5555-4555-8555-555555555555';
    const bedId = '66666666-6666-4666-8666-666666666666';
    const cropId = '77777777-7777-4777-8777-777777777777';
    const plantingId = '88888888-8888-4888-8888-888888888888';
    const planId = '99999999-9999-4999-8999-999999999999';

    final season = Season(
      id: _seasonId,
      gardenId: gardenId,
      year: 2026,
      name: 'Corrente',
      startDate: DateTime(2026, 11, 1),
      endDate: DateTime(2026, 12, 31),
      isActive: true,
      rowVersion: 1,
    );

    final bed = Bed(
      id: bedId,
      gardenId: gardenId,
      number: 1,
      isActive: true,
      rowVersion: 1,
      geometry: BedGeometry(
        id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        bedId: bedId,
        widthCm: 90,
        lengthCm: 700,
        validFrom: season.startDate,
        rowVersion: 1,
      ),
    );

    const crop = Crop(id: cropId, name: 'Carota');

    final draft = <String, dynamic>{
      'id': plantingId,
      'season_plan_id': planId,
      'profile_id': _profileId,
      'garden_id': gardenId,
      'season_id': _seasonId,
      'bed_id': bedId,
      'crop_id': cropId,
      'cultivar_id': null,
      'start_method': 'direct_rows',
      'planned_start_date': '2026-11-10',
      'planned_end_date': null,
      'start_position_cm': 0,
      'length_cm': 100,
      'occupied_width_cm': 40,
      'plant_spacing_cm': null,
      'row_spacing_cm': null,
      'rows_count': null,
      'plants_count': null,
      'seed_quantity_g': null,
      'status': 'draft',
      'executed_planting_id': null,
      'notes': null,
      'created_at': '2026-11-01T12:00:00Z',
      'updated_at': '2026-11-01T12:00:00Z',
      'row_version': 7,
    };

    Future<void> choose(
      WidgetTester tester,
      String fieldLabel,
      String value,
    ) async {
      final field = find.widgetWithText(
        DropdownButtonFormField<String>,
        fieldLabel,
      );
      final dropdown = find.descendant(
        of: field,
        matching: find.byType(DropdownButton<String>),
      );
      expect(dropdown, findsOneWidget);

      final button = tester.widget<DropdownButton<String>>(dropdown);
      final item = button.items!.singleWhere((item) => item.value == value);
      final label = (item.child as Text).data!;

      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      final option = find.text(label).hitTestable();
      expect(option, findsWidgets, reason: 'Voce $label nel menu $fieldLabel');
      await tester.tap(option.last);
      await tester.pumpAndSettle();
    }

    Future<void> enter(WidgetTester tester, String label, String value) async {
      final field = find.widgetWithText(TextFormField, label);
      final scrollable = find.byType(Scrollable).last;
      await tester.scrollUntilVisible(field, 120, scrollable: scrollable);
      await tester.enterText(field, value);
    }

    for (final (editing, rejected, description) in [
      (false, false, 'Creazione invia orto, stagione e data di fine assente'),
      (
        true,
        false,
        'Modifica invia ID, versione originale e valori aggiornati',
      ),
      (
        true,
        true,
        'Modifica rifiutata mostra il messaggio e conserva la lista',
      ),
    ]) {
      testWidgets(description, (tester) async {
        final fixture = _Fixture();
        await fixture.acquire();
        final availability = fixture.createAvailability();
        final calls = <(String, Map<String, dynamic>)>[];
        var loadCount = 0;
        final repository = PlannedPlantingRepository.withProviders(
          (name, parameters) async {
            calls.add((name, Map<String, dynamic>.from(parameters)));
            if (rejected) return {'status': 'forbidden'};
            return {
              'status': editing ? 'updated' : 'created',
              'planned_planting_id': plantingId,
              'season_plan_id': planId,
              'row_version': editing ? 8 : 1,
            };
          },
          fixture.authority.requireLeaseForWrite,
          loadPlannedPlantings: (_) async {
            loadCount++;
            if (loadCount == 1) {
              return editing ? [draft] : [];
            }
            if (rejected) return [draft];
            return [
              {...draft, 'length_cm': 120, 'row_version': editing ? 8 : 1},
            ];
          },
        );

        await tester.pumpWidget(
          MaterialApp(
            home: PlannedPlantingsPage(
              seasonId: _seasonId,
              seasonName: '2026 - Corrente',
              season: season,
              repository: repository,
              writeAvailability: availability,
              loadFormOptions: (requestedGardenId) async {
                expect(requestedGardenId, gardenId);
                return (
                  beds: [bed],
                  crops: [crop],
                  cultivars: <CropCultivar>[],
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        if (editing) {
          await tester.tap(find.byType(PopupMenuButton<String>).first);
          await tester.pumpAndSettle();
          await tester.tap(find.text('Modifica'));
          await tester.pumpAndSettle();
        } else {
          await tester.tap(find.text('Nuova pianificazione'));
          await tester.pumpAndSettle();
          await choose(tester, 'Aiuola', bedId);
          await choose(tester, 'Coltura', cropId);
          await choose(tester, 'Metodo di avvio', 'direct_rows');
        }

        await enter(tester, 'Lunghezza (cm)', '120');
        if (!editing) {
          await enter(tester, 'Larghezza occupata (cm)', '40');
        }

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

                  final save = find.text('Salva');
          expect(save, findsOneWidget);

          final formScroll = find.ancestor(
            of: save,
            matching: find.byType(Scrollable),
          );
          expect(formScroll, findsOneWidget);

          await tester.dragUntilVisible(
            save.hitTestable(),
            formScroll,
            const Offset(0, -250),
          );
          await tester.tap(save.hitTestable());
          await tester.pumpAndSettle();

        expect(
          calls,
          hasLength(1),
          reason: 'Il salvataggio deve inviare una RPC',
        );
        final (name, parameters) = calls.single;
        expect(
          name,
          editing ? 'update_planned_planting' : 'create_planned_planting',
        );
        expect(parameters['planting_length_cm'], 120);
        expect(parameters, containsPair('planting_end_date', null));
        if (editing) {
          expect(parameters['target_planned_planting_id'], plantingId);
          expect(parameters['expected_row_version'], 7);
          expect(parameters['planting_bed_id'], bedId);
        } else {
          expect(parameters['target_garden_id'], gardenId);
          expect(parameters['target_season_id'], _seasonId);
          expect(parameters['target_bed_id'], bedId);
        }
        expect(loadCount, 2);
        if (rejected) {
          expect(
            find.text(
              'Salvataggio rifiutato. Verifica i dati della pianificazione.',
            ),
            findsOneWidget,
          );
          expect(find.text('Pianificazione salvata.'), findsNothing);
          expect(find.textContaining('Lunghezza: 100 cm'), findsOneWidget);
        } else {
          expect(find.text('Pianificazione salvata.'), findsOneWidget);
          expect(find.textContaining('Lunghezza: 120 cm'), findsOneWidget);
        }
        await fixture.unmount(tester);
      });
    }
    testWidgets('Verifica esito recupera la conferma senza riscrivere', (
      tester,
    ) async {
      final fixture = _Fixture();
      await fixture.acquire();
      final availability = fixture.createAvailability();

      final coordinator = MutationOperationCoordinator();
      final journal = MutationOperationJournal(_RecoveryTestPersistence());
      final service = SeasonalPlanningMutationService(coordinator, journal);
      final identity = MutationOperationIdentity(
        profileId: _profileId,
        operationId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        operationType: MutationOperationType.confirmPlannedPlanting,
        requestSchemaVersion: 1,
      );
      final generations = MutationOperationGenerations(
        recoveryGeneration: 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        domainGeneration: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
      );
      final snapshot = MutationRequestSnapshot(
        identity: identity,
        generations: generations,
        parameters: {
          'target_planned_planting_id': plantingId,
          'expected_row_version': 7,
        },
      );
      final fingerprint = MutationRequestFingerprint('ab' * 32);
      final scope = coordinator.scopeOf(identity);
      expect(await journal.prepare(snapshot), isTrue);
      expect(await journal.recordFingerprint(snapshot, fingerprint), isTrue);

      final rpcCalls = <String>[];
      var receiptRead = false;
      final repository = PlannedPlantingRepository.withProviders(
        (name, parameters) async {
          rpcCalls.add(name);
          expect(name, 'get_seasonal_planning_mutation_receipt');
          expect(parameters['target_operation_id'], identity.operationId);
          receiptRead = true;
          return {
            'status': 'COMPLETED',
            'profile_id': identity.profileId,
            'operation_id': identity.operationId,
            'operation_domain': identity.domain.wireValue,
            'operation_type': identity.operationType.wireValue,
            'request_schema_version': 1,
            'receipt_schema_version': 1,
            'recovery_generation': generations.recoveryGeneration,
            'domain_generation': generations.domainGeneration,
            'request_fingerprint': fingerprint.value,
            'outcome': 'succeeded',
            'result_status': 'confirmed',
            'result_payload': {
              'status': 'confirmed',
              'planned_planting_id': plantingId,
              'row_version': 8,
            },
          };
        },
        fixture.authority.requireLeaseForWrite,
        mutationService: service,
        loadPlannedPlantings: (requestedSeasonId) async {
          expect(requestedSeasonId, _seasonId);
          return [
            if (receiptRead)
              {...draft, 'status': 'confirmed', 'row_version': 8}
            else
              draft,
          ];
        },
      ).forSeasonMutations(_seasonId);

      await tester.pumpWidget(
        MaterialApp(
          home: PlannedPlantingsPage(
            seasonId: _seasonId,
            seasonName: '2026 - Corrente',
            season: season,
            repository: repository,
            writeAvailability: availability,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Stato: Bozza'), findsOneWidget);
      expect(rpcCalls, isEmpty);

      await tester.tap(find.widgetWithText(TextButton, 'Verifica esito'));
      await tester.pumpAndSettle();

      expect(rpcCalls, ['get_seasonal_planning_mutation_receipt']);
      expect(find.textContaining('Stato: Confermata'), findsOneWidget);
      expect(
        find.text('Esito verificato. Elenco pianificazioni aggiornato.'),
        findsOneWidget,
      );
      expect(
        (await journal.load(scope)).status,
        MutationJournalReadStatus.absent,
      );
      await fixture.unmount(tester);
    });
  });
  testWidgets('Esegui sends the selected effective date', (tester) async {
    final fixture = _Fixture();
    await fixture.acquire();
    final availability = fixture.createAvailability();
    const plannedId = '55555555-5555-4555-8555-555555555555';
    const foreignId = '66666666-6666-4666-8666-666666666666';
    const status = 'confirmed';
    final row = <String, dynamic>{
      'id': plannedId,
      'season_plan_id': foreignId,
      'profile_id': _profileId,
      'garden_id': foreignId,
      'season_id': _seasonId,
      'bed_id': foreignId,
      'crop_id': foreignId,
      'cultivar_id': null,
      'start_method': 'direct_rows',
      'planned_start_date': '2026-11-06',
      'planned_end_date': '2026-12-15',
      'start_position_cm': 0,
      'length_cm': 100,
      'occupied_width_cm': 40,
      'plant_spacing_cm': null,
      'row_spacing_cm': 30,
      'rows_count': 2,
      'plants_count': null,
      'seed_quantity_g': null,
      'status': status,
      'executed_planting_id': null,
      'notes': null,
      'created_at': '2026-11-06T10:00:00Z',
      'updated_at': '2026-11-06T10:00:00Z',
      'row_version': 7,
    };
    final calls = <Map<String, dynamic>>[];
    final repository = PlannedPlantingRepository.withProviders(
      (name, parameters) async {
        expect(name, 'execute_planned_planting');
        calls.add(Map<String, dynamic>.of(parameters));
        row['status'] = 'executed';
        row['row_version'] = 8;
        row['executed_planting_id'] = foreignId;
        return {
          'status': 'executed',
          'planned_planting_id': plannedId,
          'planting_id': foreignId,
          'effective_start_date': parameters['effective_start_date'],
          'row_version': 8,
        };
      },
      fixture.authority.requireLeaseForWrite,
      loadPlannedPlantings: (_) async => [row],
    );
    await fixture.showPage(
      tester,
      repository: repository,
      availability: availability,
    );
    await tester.pumpAndSettle();

    Future<void> openPicker() async {
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esegui'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
    }

    await openPicker();
    Navigator.of(tester.element(find.byType(DatePickerDialog))).pop();
    await tester.pumpAndSettle();
    expect(calls, isEmpty);

    await openPicker();
    await tester.tap(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.text('7'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(calls, hasLength(1));
    expect(calls.single['target_planned_planting_id'], plannedId);
    expect(calls.single['expected_row_version'], 7);
    expect(calls.single['effective_start_date'], '2026-11-07');
    expect(find.text('Stato: Eseguita'), findsOneWidget);
    await fixture.unmount(tester);
  });

  for (final confirm in [true, false]) {
    final action = confirm ? 'Conferma' : 'Annulla';
    testWidgets('$action sends the selected planning version', (tester) async {
      final fixture = _Fixture();
      await fixture.acquire();
      final availability = fixture.createAvailability();
      final rpcResult = Completer<Map<String, dynamic>>();
      final calls = <String>[];
      final sent = <Map<String, dynamic>>[];
      const plannedId = '55555555-5555-4555-8555-555555555555';
      const foreignId = '66666666-6666-4666-8666-666666666666';
      final status = confirm ? 'draft' : 'confirmed';
      final row = <String, dynamic>{
        'id': plannedId,
        'season_plan_id': foreignId,
        'profile_id': _profileId,
        'garden_id': foreignId,
        'season_id': _seasonId,
        'bed_id': foreignId,
        'crop_id': foreignId,
        'cultivar_id': null,
        'start_method': 'direct_rows',
        'planned_start_date': '2026-11-06',
        'planned_end_date': '2026-12-15',
        'start_position_cm': 0,
        'length_cm': 100,
        'occupied_width_cm': 40,
        'plant_spacing_cm': null,
        'row_spacing_cm': 30,
        'rows_count': 2,
        'plants_count': null,
        'seed_quantity_g': null,
        'status': status,
        'executed_planting_id': null,
        'notes': null,
        'created_at': '2026-11-06T10:00:00Z',
        'updated_at': '2026-11-06T10:00:00Z',
        'row_version': 7,
      };
      final repository = PlannedPlantingRepository.withProviders(
        (name, parameters) {
          calls.add(name);
          sent.add(Map<String, dynamic>.of(parameters));
          return rpcResult.future;
        },
        fixture.authority.requireLeaseForWrite,
        loadPlannedPlantings: (_) async => [row],
      );
      final menu = find.byType(PopupMenuButton<String>);
      bool enabled() => tester.widget<PopupMenuButton<String>>(menu).enabled;

      final journal = MutationOperationJournal(
        _PlanningTestJournalPersistence(),
      );
      final pending = MutationRequestSnapshot(
        identity: MutationOperationIdentity(
          profileId: _profileId,
          operationId: '77777777-7777-4777-8777-777777777777',
          operationType: MutationOperationType.confirmPlannedPlanting,
          requestSchemaVersion: 1,
        ),
        generations: MutationOperationGenerations(
          recoveryGeneration: '88888888-8888-4888-8888-888888888888',
          domainGeneration: '99999999-9999-4999-8999-999999999999',
        ),
        parameters: {
          'target_planned_planting_id': plannedId,
          'expected_row_version': 7,
        },
      );
      expect(await journal.prepare(pending), isTrue);
      final blockedRepository = PlannedPlantingRepository.withProviders(
        (_, _) async => throw StateError('Unexpected planning RPC'),
        fixture.authority.requireLeaseForWrite,
        loadPlannedPlantings: (_) async => [row],
        mutationService: SeasonalPlanningMutationService(
          MutationOperationCoordinator(),
          journal,
        ),
        refreshAfterMutation: (_) async {},
      );
      await fixture.showPage(
        tester,
        repository: blockedRepository,
        availability: availability,
      );
      await tester.pumpAndSettle();
      expect(availability.canWrite, isTrue);
      expect(enabled(), isFalse);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      expect(find.text(action), findsNothing);
      expect(calls, isEmpty);

      await fixture.showPage(tester, repository: repository);
      await tester.pumpAndSettle();
      expect(enabled(), isFalse);
      expect(calls, isEmpty);

      await fixture.showPage(
        tester,
        repository: repository,
        availability: availability,
      );
      await tester.pumpAndSettle();
      expect(enabled(), isTrue);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text(action));
      await tester.pumpAndSettle();
      expect(enabled(), isFalse);
      expect(calls, [
        confirm ? 'confirm_planned_planting' : 'cancel_planned_planting',
      ]);
      expect(sent.single['target_planned_planting_id'], plannedId);
      expect(sent.single['expected_row_version'], 7);

      row['status'] = confirm ? 'confirmed' : 'cancelled';
      row['row_version'] = 8;
      rpcResult.complete({
        'status': row['status'],
        'planned_planting_id': plannedId,
        'row_version': 8,
      });
      await tester.pumpAndSettle();
      expect(
        find.text(
          confirm ? 'Pianificazione confermata.' : 'Pianificazione annullata.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
      await fixture.unmount(tester);
    });
  }

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

final class _PlanningTestJournalPersistence
    implements MutationJournalPersistence {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }
}
