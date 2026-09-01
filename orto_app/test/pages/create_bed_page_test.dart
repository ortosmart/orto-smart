import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/bed_write_result.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/create_bed_page.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_scope.dart';
import 'package:orto_app/data/models/bed.dart';
import 'package:orto_app/widgets/garden/bed_card.dart';
import 'package:orto_app/widgets/garden/garden_map.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';
const _gardenId = '22222222-2222-4222-8222-222222222222';

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

class _BedRepositoryFake extends Fake implements BedRepository {
  final calls = <Map<String, dynamic>>[];
  final requestedGardens = <String>[];
  final beds = <Bed>[];

  CreateBedResult result = const CreateBedDuplicateNumber();
  Future<CreateBedResult> Function()? onCreate;

  @override
  Future<List<Bed>> getBeds({required String gardenId}) async {
    requestedGardens.add(gardenId);
    return List<Bed>.of(beds);
  }

  @override
  Future<CreateBedResult> createBed({
    required String gardenId,
    required int number,
    String? name,
    String? notes,
    required int widthCm,
    required int lengthCm,
    DateTime? validFrom,
  }) async {
    calls.add({
      'gardenId': gardenId,
      'number': number,
      'name': name,
      'notes': notes,
      'widthCm': widthCm,
      'lengthCm': lengthCm,
      'validFrom': validFrom,
    });

    final handler = onCreate;
    if (handler != null) {
      return await handler();
    }

    return result;
  }
}

BedCreated _createdBed() {
  return BedCreated(
    bedId: '33333333-3333-4333-8333-333333333333',
    gardenId: _gardenId,
    number: 4,
    isActive: true,
    rowVersion: 1,
    createdAt: DateTime.utc(2026, 8, 31, 12),
    geometryId: '44444444-4444-4444-8444-444444444444',
    widthCm: 90,
    lengthCm: 700,
    validFrom: DateTime.utc(2026, 8, 30),
    validTo: null,
    geometryRowVersion: 1,
    geometryCreatedAt: DateTime.utc(2026, 8, 31, 12),
  );
}

Finder _field(String label) {
  return find.ancestor(
    of: find.byWidgetPredicate(
      (widget) => widget is TextField && widget.decoration?.labelText == label,
    ),
    matching: find.byType(TextFormField),
  );
}

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_field('Numero aiuola'), '4');
  await tester.enterText(_field('Nome (facoltativo)'), '  Aiuola nuova  ');
  await tester.enterText(_field('Larghezza (cm)'), '90');
  await tester.enterText(_field('Lunghezza (cm)'), '700');
  await tester.enterText(_field('Geometria valida dal'), '2026-08-30');
  await tester.enterText(_field('Note (facoltative)'), '  Nota di prova  ');
}

Future<void> _submit(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final button = find.byType(FilledButton);

  await Scrollable.ensureVisible(
    tester.element(button),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pumpAndSettle();

  expect(button.hitTestable(), findsOneWidget);

  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  late ProfileWriteAuthorityController authority;
  late _BedRepositoryFake repository;
  late DateTime now;
  bool? returnedResult;

  setUp(() async {
    now = DateTime.utc(2026, 8, 31, 12);
    returnedResult = null;
    repository = _BedRepositoryFake();

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');
        return {
          'status': 'acquired',
          'lock_token': 'token-create-bed-esclusivamente-fittizio',
          'expires_at': '2026-08-31T12:02:00+00:00',
          'row_version': 1,
        };
      }),
      _Scheduler(),
      utcNow: () => now,
    );

    addTearDown(authority.dispose);

    await authority.initialize(
      profileContext: const ProfileContext(
        profileId: _profileId,
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );
  });

  Future<void> openPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                returnedResult = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => CreateBedPage(
                      profileId: _profileId,
                      gardenId: _gardenId,
                      repository: repository,
                      authority: authority,
                    ),
                  ),
                );
              },
              child: const Text('Apri creazione'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Apri creazione'));
    await tester.pumpAndSettle();
  }

  testWidgets('pending creation prevents duplicate submissions', (
    tester,
  ) async {
    final response = Completer<CreateBedResult>();
    repository.onCreate = () => response.future;

    await openPage(tester);
    await _fillValidForm(tester);

    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    // Due tap prima della ricostruzione verificano anche
    // la protezione interna del metodo di salvataggio.
    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();

    expect(repository.calls, hasLength(1));
    expect(find.text('Salvataggio…'), findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(returnedResult, isNull);

    response.complete(_createdBed());
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(find.byType(CreateBedPage), findsNothing);
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uncertain outcome prevents another creation attempt', (
    tester,
  ) async {
    final response = Completer<CreateBedResult>();
    repository.onCreate = () => response.future;

    await openPage(tester);
    await _fillValidForm(tester);

    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pump();

    expect(repository.calls, hasLength(1));

    response.completeError(
      StateError('Synthetic network failure after submission'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(
      find.text(
        'Non è stato possibile confermare l’esito della creazione. '
        'Torna alla lista e aggiornala per verificare se l’aiuola '
        'è stata creata prima di effettuare un nuovo tentativo.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Synthetic network failure'), findsNothing);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(
      tester.widget<TextFormField>(_field('Numero aiuola')).controller!.text,
      '4',
    );

    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(returnedResult, isNull);

    // Dopo l'errore deve essere possibile uscire dalla pagina.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(CreateBedPage), findsNothing);
    expect(find.text('Apri creazione'), findsOneWidget);
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty date delegates the garden date to the server', (
    tester,
  ) async {
    repository.result = _createdBed();

    await openPage(tester);

    expect(
      tester
          .widget<TextFormField>(_field('Geometria valida dal'))
          .controller!
          .text,
      isEmpty,
    );

    await _fillValidForm(tester);
    await tester.enterText(_field('Geometria valida dal'), '');
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single['validFrom'], isNull);
    expect(find.byType(CreateBedPage), findsNothing);
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text beyond the limits prevents submission', (tester) async {
    await openPage(tester);
    await _fillValidForm(tester);

    await tester.enterText(
      _field('Nome (facoltativo)'),
      List.filled(81, 'a').join(),
    );
    await tester.enterText(
      _field('Note (facoltative)'),
      List.filled(1001, 'b').join(),
    );
    await _submit(tester);

    expect(repository.calls, isEmpty);
    expect(
      find.text('Il nome può contenere al massimo 80 caratteri.'),
      findsOneWidget,
    );
    expect(
      find.text('Le note possono contenere al massimo 1000 caratteri.'),
      findsOneWidget,
    );
    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('text exactly at the limits is accepted', (tester) async {
    repository.result = _createdBed();

    final name = List.filled(80, 'a').join();
    final notes = List.filled(1000, 'b').join();

    await openPage(tester);
    await _fillValidForm(tester);

    await tester.enterText(_field('Nome (facoltativo)'), name);
    await tester.enterText(_field('Note (facoltative)'), notes);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single['name'], name);
    expect(repository.calls.single['notes'], notes);
    expect(find.byType(CreateBedPage), findsNothing);
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('map opens creation and reloads the authoritative list', (
    tester,
  ) async {
    repository.onCreate = () async {
      repository.beds.add(
        Bed.fromMap({
          'id': '33333333-3333-4333-8333-333333333333',
          'garden_id': _gardenId,
          'number': 4,
          'name': 'Nome restituito dalla lista',
          'notes': null,
          'is_active': true,
          'row_version': 1,
          'bed_geometries': [
            {
              'id': '44444444-4444-4444-8444-444444444444',
              'bed_id': '33333333-3333-4333-8333-333333333333',
              'width_cm': 90,
              'length_cm': 700,
              'valid_from': '2026-08-30',
              'valid_to': null,
              'row_version': 1,
            },
          ],
        }),
      );
      return _createdBed();
    };

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileWriteAuthorityScope(
          controller: authority,
          child: Scaffold(
            body: SingleChildScrollView(
              child: GardenMap(
                profileId: _profileId,
                gardenId: _gardenId,
                repository: repository,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Nessuna aiuola abilitata in questo orto.'),
      findsOneWidget,
    );
    expect(repository.requestedGardens, [_gardenId]);
    expect(repository.calls, isEmpty);

    final createButton = find.byType(FilledButton);
    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);

    await tester.tap(createButton);
    await tester.pumpAndSettle();

    expect(find.byType(CreateBedPage), findsOneWidget);

    final page = tester.widget<CreateBedPage>(find.byType(CreateBedPage));
    expect(page.profileId, _profileId);
    expect(page.gardenId, _gardenId);
    expect(page.repository, same(repository));
    expect(page.authority, same(authority));

    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single['gardenId'], _gardenId);
    expect(repository.requestedGardens, [_gardenId, _gardenId]);
    expect(find.byType(CreateBedPage), findsNothing);
    expect(find.byType(BedCard), findsOneWidget);
    expect(find.text('Nome restituito dalla lista'), findsOneWidget);
    expect(find.text('Nessuna aiuola abilitata in questo orto.'), findsNothing);

    final card = tester.widget<BedCard>(find.byType(BedCard));
    expect(card.bed.number, 4);
    expect(card.bed.gardenId, _gardenId);
    expect(card.bed.widthCm, 90);
    expect(card.bed.lengthCm, 700);
    expect(tester.takeException(), isNull);
  });
  for (final uncertainOutcome in [false, true]) {
    testWidgets(
      'map reloads after ${uncertainOutcome ? 'uncertain outcome' : 'cancellation'}',
      (tester) async {
        repository.onCreate = () async {
          throw StateError('Synthetic uncertain creation outcome');
        };

        await tester.pumpWidget(
          MaterialApp(
            home: ProfileWriteAuthorityScope(
              controller: authority,
              child: Scaffold(
                body: SingleChildScrollView(
                  child: GardenMap(
                    profileId: _profileId,
                    gardenId: _gardenId,
                    repository: repository,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(repository.requestedGardens, [_gardenId]);

        await tester.tap(find.byType(FilledButton));
        await tester.pumpAndSettle();

        expect(find.byType(CreateBedPage), findsOneWidget);

        if (uncertainOutcome) {
          await _fillValidForm(tester);
          await _submit(tester);

          expect(repository.calls, hasLength(1));
          expect(
            find.textContaining(
              'Non è stato possibile confermare l’esito della creazione.',
            ),
            findsOneWidget,
          );
          expect(
            tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
            isNull,
          );
        } else {
          expect(repository.calls, isEmpty);
        }

        // La lista non viene riletta mentre il modulo è ancora aperto.
        expect(repository.requestedGardens, [_gardenId]);

        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(CreateBedPage), findsNothing);
        expect(repository.requestedGardens, [_gardenId, _gardenId]);
        expect(repository.calls, hasLength(uncertainOutcome ? 1 : 0));
        expect(
          find.text('Nessuna aiuola abilitata in questo orto.'),
          findsOneWidget,
        );
        expect(
          tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('map remains readable without write authority', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: GardenMap(
              profileId: _profileId,
              gardenId: _gardenId,
              repository: repository,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.requestedGardens, [_gardenId]);
    expect(
      find.text('Nessuna aiuola abilitata in questo orto.'),
      findsOneWidget,
    );
    expect(
      find.text('Creazione non disponibile: autorità di scrittura non attiva.'),
      findsOneWidget,
    );

    final button = find.byType(FilledButton);

    expect(button, findsOneWidget);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(find.byType(CreateBedPage), findsNothing);
    expect(repository.calls, isEmpty);
    expect(repository.requestedGardens, [_gardenId]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid numbers and dates prevent submission', (tester) async {
    await openPage(tester);

    await tester.enterText(_field('Numero aiuola'), '0');
    await tester.enterText(_field('Larghezza (cm)'), '-1');
    await tester.enterText(_field('Lunghezza (cm)'), 'abc');
    await tester.enterText(_field('Geometria valida dal'), '2026-02-30');

    await _submit(tester);

    expect(repository.calls, isEmpty);
    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(
      find.text('Inserisci un intero positivo, massimo 2147483647.'),
      findsNWidgets(3),
    );
    expect(find.text('Inserisci una data valida: AAAA-MM-GG.'), findsOneWidget);
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful creation submits values and returns true', (
    tester,
  ) async {
    repository.result = _createdBed();

    await openPage(tester);
    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single, {
      'gardenId': _gardenId,
      'number': 4,
      'name': 'Aiuola nuova',
      'notes': 'Nota di prova',
      'widthCm': 90,
      'lengthCm': 700,
      'validFrom': DateTime.utc(2026, 8, 30),
    });
    expect(find.byType(CreateBedPage), findsNothing);
    expect(find.text('Apri creazione'), findsOneWidget);
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate number preserves the form', (tester) async {
    await openPage(tester);
    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(
      find.text(
        'Questo numero è già utilizzato nell’orto, '
        'anche eventualmente da un’aiuola disabilitata.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<TextFormField>(_field('Numero aiuola')).controller!.text,
      '4',
    );
    expect(
      tester
          .widget<TextFormField>(_field('Nome (facoltativo)'))
          .controller!
          .text,
      '  Aiuola nuova  ',
    );
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('lease expiry before tapping prevents submission', (
    tester,
  ) async {
    await openPage(tester);
    await _fillValidForm(tester);

    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

    // Nessuna notifica o ricostruzione prima del tap:
    // il controllo al salvataggio deve rilevare la scadenza.
    now = DateTime.utc(2026, 8, 31, 12, 3);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(authority.status, ProfileWriteAuthorityStatus.lost);
    expect(find.byType(CreateBedPage), findsOneWidget);
    expect(
      find.text(
        'Autorità di scrittura non disponibile per questo profilo. '
        'I dati inseriti sono conservati.',
      ),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(
      tester.widget<TextFormField>(_field('Numero aiuola')).controller!.text,
      '4',
    );
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });
}
