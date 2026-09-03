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
import 'package:orto_app/pages/edit_bed_page.dart';

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
    // Il tempo è controllato dal test; nessun timer reale.
    return _ScheduledTask();
  }
}

class _BedRepositoryFake extends Fake implements BedRepository {
  final calls = <Map<String, dynamic>>[];

  UpdateBedResult result = const UpdateBedDuplicateNumber();
  Future<UpdateBedResult> Function()? onUpdate;

  @override
  Future<UpdateBedResult> updateBed({
    required String bedId,
    required int expectedRowVersion,
    required int number,
    String? name,
    String? notes,
  }) async {
    calls.add({
      'bedId': bedId,
      'expectedRowVersion': expectedRowVersion,
      'number': number,
      'name': name,
      'notes': notes,
    });

    final callback = onUpdate;
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
    'notes': 'Note iniziali',
    'is_active': true,
    'row_version': 3,
    'bed_geometries': [
      {
        'id': 'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
        'bed_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        'width_cm': 90,
        'length_cm': 700,
        'row_version': 1,
        'valid_from': '2026-01-01',
        'valid_to': null,
        'created_at': '2026-01-01T10:00:00+00:00',
      },
    ],
  });
}

void main() {
  late ProfileWriteAuthorityController authority;
  late _BedRepositoryFake repository;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 9, 2, 12);
    repository = _BedRepositoryFake();

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');

        return {
          'status': 'acquired',
          'lock_token': 'token-edit-bed-esclusivamente-fittizio',
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
        profileId: _profileId,
        role: ProfileMemberRole.owner,
      ),
      identity: const AppSessionIdentity(
        clientInstanceId: '55555555-5555-4555-8555-555555555555',
        sessionId: '66666666-6666-4666-8666-666666666666',
      ),
    );
  });
  testWidgets('mostra i valori correnti dell aiuola', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    expect(find.text('Modifica aiuola'), findsOneWidget);

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    expect(fields, hasLength(3));
    expect(fields[0].controller?.text, '1');
    expect(fields[1].controller?.text, 'Aiuola nord');
    expect(fields[2].controller?.text, 'Note iniziali');

    expect(find.text('Salva modifiche'), findsOneWidget);
  });
  testWidgets('salva le modifiche e chiude con esito positivo', (tester) async {
    final bed = _testBed();

    repository.result = BedUpdated(
      bedId: bed.id,
      gardenId: bed.gardenId,
      number: 2,
      rowVersion: 4,
      updatedAt: DateTime.utc(2026, 9, 2, 12, 1),
    );

    bool? returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedResult = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditBedPage(
                          bed: bed,
                          repository: repository,
                          authority: authority,
                        ),
                      ),
                    );
                  },
                  child: const Text('Apri modifica'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Apri modifica'));
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[0]), '2');
    await tester.enterText(find.byWidget(fields[1]), 'Aiuola aggiornata');
    await tester.enterText(find.byWidget(fields[2]), 'Note aggiornate');

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single, {
      'bedId': bed.id,
      'expectedRowVersion': 3,
      'number': 2,
      'name': 'Aiuola aggiornata',
      'notes': 'Note aggiornate',
    });

    expect(returnedResult, isTrue);
    expect(find.text('Apri modifica'), findsOneWidget);
  });
  testWidgets('chiude con esito positivo se i dati sono invariati', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = UpdateBedUnchanged(
      bedId: bed.id,
      gardenId: bed.gardenId,
      rowVersion: bed.rowVersion,
      updatedAt: DateTime.utc(2026, 9, 2, 12, 1),
    );

    bool? returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    returnedResult = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditBedPage(
                          bed: bed,
                          repository: repository,
                          authority: authority,
                        ),
                      ),
                    );
                  },
                  child: const Text('Apri modifica'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Apri modifica'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(returnedResult, isTrue);
    expect(find.text('Apri modifica'), findsOneWidget);
  });
  testWidgets('mostra un messaggio in caso di conflitto di versione', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = UpdateBedVersionConflict(
      bedId: bed.id,
      expectedRowVersion: bed.rowVersion,
      currentRowVersion: bed.rowVersion + 1,
      updatedAt: DateTime.utc(2026, 9, 2, 12, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text(
        'L’aiuola è stata modificata da un’altra sessione. '
        'Torna indietro e aggiorna i dati prima di riprovare.',
      ),
      findsOneWidget,
    );
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets('mostra un messaggio se il numero aiuola è duplicato', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const UpdateBedDuplicateNumber();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Questo numero è già utilizzato nell’orto.'),
      findsOneWidget,
    );
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets('mostra un messaggio se la modifica non è autorizzata', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const UpdateBedForbidden();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Non sei autorizzato a modificare questa aiuola.'),
      findsOneWidget,
    );
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets('mostra un messaggio se il server rifiuta la scrittura', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const UpdateBedWriteForbidden();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Il server non ha autorizzato la scrittura.'),
      findsOneWidget,
    );
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets('mostra un messaggio se l aiuola non esiste più', (tester) async {
    final bed = _testBed();

    repository.result = const UpdateBedNotFound();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(find.text('L’aiuola non è più disponibile.'), findsOneWidget);
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets('mostra un messaggio se il server rifiuta i dati', (
    tester,
  ) async {
    final bed = _testBed();

    repository.result = const UpdateBedInvalidInput();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(
      find.text('Il server ha rifiutato i dati. Controlla i valori inseriti.'),
      findsOneWidget,
    );
    expect(find.text('Modifica aiuola'), findsOneWidget);
  });
  testWidgets(
    'blocca nuovi tentativi se l esito della modifica è sconosciuto',
    (tester) async {
      final bed = _testBed();

      repository.onUpdate = () async {
        throw StateError('errore simulato');
      };

      await tester.pumpWidget(
        MaterialApp(
          home: EditBedPage(
            bed: bed,
            repository: repository,
            authority: authority,
          ),
        ),
      );

      await tester.tap(find.text('Salva modifiche'));
      await tester.pumpAndSettle();

      expect(repository.calls, hasLength(1));
      expect(
        find.text(
          'Non è stato possibile confermare l’esito della modifica. '
          'Torna alla pagina precedente e aggiorna l’aiuola prima di '
          'effettuare un nuovo tentativo.',
        ),
        findsOneWidget,
      );

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Salva modifiche'),
      );

      expect(saveButton.onPressed, isNull);
    },
  );
  testWidgets('non salva se la lease scade prima del salvataggio', (
    tester,
  ) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    await tester.pumpAndSettle();

    final button = find.widgetWithText(FilledButton, 'Salva modifiche');

    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);

    // La lease ottenuta nel setUp scade alle 12:02.
    // Spostiamo il tempo oltre la scadenza senza notificare preventivamente
    // la pagina: il controllo al salvataggio deve rilevarla.
    now = DateTime.utc(2026, 9, 2, 12, 3);

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
    expect(find.byType(EditBedPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('non salva se il numero aiuola non è valido', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
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

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(
      find.text('Inserisci un intero positivo, massimo 2147483647.'),
      findsOneWidget,
    );
    expect(find.byType(EditBedPage), findsOneWidget);
  });
  testWidgets('non salva se il nome supera 80 caratteri', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[1]), 'A' * 81);

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(
      find.text('Il nome può contenere al massimo 80 caratteri.'),
      findsOneWidget,
    );
    expect(find.byType(EditBedPage), findsOneWidget);
  });
  testWidgets('non salva se le note superano 1000 caratteri', (tester) async {
    final bed = _testBed();

    await tester.pumpWidget(
      MaterialApp(
        home: EditBedPage(
          bed: bed,
          repository: repository,
          authority: authority,
        ),
      ),
    );

    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();

    await tester.enterText(find.byWidget(fields[2]), 'N' * 1001);

    await tester.tap(find.text('Salva modifiche'));
    await tester.pumpAndSettle();

    expect(repository.calls, isEmpty);
    expect(
      find.text('Le note possono contenere al massimo 1000 caratteri.'),
      findsOneWidget,
    );
    expect(find.byType(EditBedPage), findsOneWidget);
  });
}
