import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/bed_write_result.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/models/bed.dart';
import 'package:orto_app/data/repositories/bed_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/change_bed_geometry_page.dart';

const _profileId = '11111111-1111-4111-8111-111111111111';

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
    return _ScheduledTask();
  }
}

class _BedRepositoryFake extends Fake implements BedRepository {
  final calls = <Map<String, dynamic>>[];

  ChangeBedGeometryResult result = const ChangeBedGeometryInvalidInput();
  Future<ChangeBedGeometryResult> Function()? onChange;

  @override
  Future<ChangeBedGeometryResult> changeBedGeometry({
    required String bedId,
    required int expectedRowVersion,
    required int widthCm,
    required int lengthCm,
    required DateTime validFrom,
  }) async {
    calls.add({
      'bedId': bedId,
      'expectedRowVersion': expectedRowVersion,
      'widthCm': widthCm,
      'lengthCm': lengthCm,
      'validFrom': validFrom,
    });

    final callback = onChange;
    if (callback != null) {
      return callback();
    }

    return result;
  }
}

Bed _testBed() {
  return Bed.fromMap({
    'id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'garden_id': 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'number': 1,
    'name': 'Aiuola nord',
    'notes': null,
    'is_active': true,
    'row_version': 3,
    'bed_geometries': [
      {
        'id': 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        'bed_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'width_cm': 90,
        'length_cm': 700,
        'valid_from': '2026-01-15',
        'valid_to': null,
        'row_version': 2,
      },
    ],
  });
}

void main() {
  late ProfileWriteAuthorityController authority;
  late _BedRepositoryFake repository;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 9, 3, 8);

    repository = _BedRepositoryFake();

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-change-geometry-esclusivamente-fittizio',
          'expires_at': '2026-09-03T08:02:00+00:00',
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

  testWidgets('mostra i valori della geometria corrente', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    expect(fields, hasLength(3));
    expect(fields[0].controller?.text, '90');
    expect(fields[1].controller?.text, '700');
    expect(fields[2].controller?.text, '15/01/2026');

    expect(find.text('Modifica geometria'), findsOneWidget);
    expect(find.text('Salva nuova geometria'), findsOneWidget);
  });

  testWidgets('salva una nuova geometria e chiude con esito positivo', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = BedGeometryChanged(
      bedId: bed.id,
      gardenId: bed.gardenId,
      rowVersion: 4,
      updatedAt: DateTime.utc(2026, 9, 3, 8, 1),
      geometryId: 'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
      widthCm: 100,
      lengthCm: 750,
      validFrom: DateTime.utc(2026, 9, 3),
      validTo: null,
      geometryRowVersion: 1,
      geometryCreatedAt: DateTime.utc(2026, 9, 3, 8, 1),
      previousGeometry: PreviousBedGeometry(
        geometryId: bed.geometry.id,
        validTo: DateTime.utc(2026, 9, 3),
        rowVersion: 3,
        updatedAt: DateTime.utc(2026, 9, 3, 8, 1),
      ),
    );

    bool? returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ChangeBedGeometryPage(
                        bed: bed,
                        repository: repository,
                        authority: authority,
                      ),
                    ),
                  );
                },
                child: const Text('Apri geometria'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Apri geometria'));
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[0]), '100');
    await tester.enterText(find.byWidget(fields[1]), '750');
    await tester.enterText(find.byWidget(fields[2]), '03/09/2026');

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single, {
      'bedId': bed.id,
      'expectedRowVersion': 3,
      'widthCm': 100,
      'lengthCm': 750,
      'validFrom': DateTime.utc(2026, 9, 3),
    });

    expect(returnedResult, isTrue);
    expect(find.text('Apri geometria'), findsOneWidget);
  });

  testWidgets('chiude con esito positivo se la geometria e invariata', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = ChangeBedGeometryUnchanged(
      bedId: bed.id,
      gardenId: bed.gardenId,
      rowVersion: bed.rowVersion,
      updatedAt: DateTime.utc(2026, 9, 3, 8, 1),
      geometryId: bed.geometry.id,
      geometryRowVersion: bed.geometry.rowVersion,
      geometryUpdatedAt: DateTime.utc(2026, 9, 3, 8, 1),
    );

    bool? returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  returnedResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => ChangeBedGeometryPage(
                        bed: bed,
                        repository: repository,
                        authority: authority,
                      ),
                    ),
                  );
                },
                child: const Text('Apri geometria'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Apri geometria'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(returnedResult, isTrue);
  });

  testWidgets('segnala quando serve una correzione storica', (tester) async {
    final bed = _testBed();

    repository.result = BedGeometryCorrectionRequired(
      bedId: bed.id,
      gardenId: bed.gardenId,
      rowVersion: bed.rowVersion,
      updatedAt: DateTime.utc(2026, 9, 3, 8, 1),
      geometryId: bed.geometry.id,
      geometryRowVersion: bed.geometry.rowVersion,
      geometryUpdatedAt: DateTime.utc(2026, 9, 3, 8, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text(
        'La data indicata richiede una correzione della geometria '
        'storica. Torna indietro e usa la funzione di correzione.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mostra un messaggio in caso di conflitto di versione', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = ChangeBedGeometryVersionConflict(
      bedId: bed.id,
      expectedRowVersion: bed.rowVersion,
      currentRowVersion: bed.rowVersion + 1,
      updatedAt: DateTime.utc(2026, 9, 3, 8, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text(
        'L’aiuola è stata modificata da un’altra sessione. '
        'Torna indietro e aggiorna i dati prima di riprovare.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mostra un messaggio se la modifica non e autorizzata', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const ChangeBedGeometryForbidden();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text(
        'Non sei autorizzato a modificare la geometria di questa aiuola.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('mostra un messaggio se il server rifiuta la scrittura', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const ChangeBedGeometryWriteForbidden();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Il server non ha autorizzato la scrittura.'),
      findsOneWidget,
    );
  });

  testWidgets('mostra un messaggio se l aiuola non esiste piu', (tester) async {
    final bed = _testBed();

    repository.result = const ChangeBedGeometryNotFound();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(find.text('L’aiuola non è più disponibile.'), findsOneWidget);
  });

  testWidgets('mostra un messaggio se il server rifiuta i dati', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const ChangeBedGeometryInvalidInput();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Il server ha rifiutato i dati. Controlla i valori inseriti.'),
      findsOneWidget,
    );
  });

  testWidgets('blocca nuovi tentativi se l esito e sconosciuto', (
    tester,
  ) async {
    final bed = _testBed();

    repository.onChange = () async {
      throw StateError('errore simulato');
    };

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));

    expect(
      find.text(
        'Non è stato possibile confermare l’esito della modifica. '
        'Torna alla pagina precedente e aggiorna l’aiuola '
        'prima di effettuare un nuovo tentativo.',
      ),
      findsOneWidget,
    );

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Salva nuova geometria'),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('non salva se la lease scade prima del salvataggio', (
    tester,
  ) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final button = find.widgetWithText(FilledButton, 'Salva nuova geometria');

    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

    now = DateTime.utc(2026, 9, 3, 8, 3);

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(authority.status, ProfileWriteAuthorityStatus.lost);

    expect(
      find.text(
        'Autorità di scrittura non disponibile. '
        'I dati inseriti sono conservati.',
      ),
      findsOneWidget,
    );

    expect(tester.widget<FilledButton>(button).onPressed, isNull);
  });

  testWidgets('non salva larghezza non valida', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[0]), '0');

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(
      find.text('Inserisci un intero positivo, massimo 2147483647.'),
      findsOneWidget,
    );
  });

  testWidgets('non salva una data non valida', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeBedGeometryPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[2]), '30/02/2026');

    await tester.tap(find.text('Salva nuova geometria'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(find.text('Inserisci una data valida: GG/MM/AAAA.'), findsOneWidget);
  });
}
