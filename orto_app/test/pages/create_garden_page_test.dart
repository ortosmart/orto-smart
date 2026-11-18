import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/identity/app_session_identity.dart';
import 'package:orto_app/core/profile/profile_context.dart';
import 'package:orto_app/core/write_authority/garden_write_result.dart';
import 'package:orto_app/core/write_authority/profile_write_authority_controller.dart';
import 'package:orto_app/core/write_authority/write_authority_scheduler.dart';
import 'package:orto_app/data/repositories/garden_repository.dart';
import 'package:orto_app/data/repositories/profile_edit_lock_repository.dart';
import 'package:orto_app/pages/create_garden_page.dart';

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
    return _ScheduledTask();
  }
}

class _GardenRepositoryFake extends Fake implements GardenRepository {
  final calls = <Map<String, dynamic>>[];
  CreateGardenResult result = const CreateGardenDuplicateName();
  Future<CreateGardenResult> Function()? onCreate;

  @override
  Future<CreateGardenResult> createGarden({
    required String profileId,
    required String name,
    String? description,
    double? latitude,
    double? longitude,
    int? elevationM,
    required String timezone,
    required String countryCode,
    String? municipality,
    String? locality,
    String? streetAddress,
  }) async {
    calls.add({
      'profileId': profileId,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'elevationM': elevationM,
      'timezone': timezone,
      'countryCode': countryCode,
      'municipality': municipality,
      'locality': locality,
      'streetAddress': streetAddress,
    });

    final handler = onCreate;
    return handler != null ? await handler() : result;
  }
}

GardenCreated _createdGarden() {
  return GardenCreated(
    gardenId: _gardenId,
    rowVersion: 1,
    createdAt: DateTime.utc(2026, 11, 15, 12),
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
  await tester.enterText(_field('Nome orto *'), '  Orto nuovo  ');
  await tester.enterText(_field('Latitudine *'), '45.85');
  await tester.enterText(_field('Longitudine *'), '12.62');
  await tester.enterText(_field('Altitudine (m) *'), '25');
}

Future<void> _submit(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();

  final button = find.byType(FilledButton);
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  late ProfileWriteAuthorityController authority;
  late _GardenRepositoryFake repository;
  late DateTime now;
  bool? returnedResult;

  setUp(() async {
    now = DateTime.utc(2026, 11, 15, 12);
    returnedResult = null;
    repository = _GardenRepositoryFake();

    authority = ProfileWriteAuthorityController(
      ProfileEditLockRepository.withRpcInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'acquire_profile_edit_lock');
        return {
          'status': 'acquired',
          'lock_token': 'token-create-garden-esclusivamente-fittizio',
          'expires_at': '2026-11-15T12:02:00+00:00',
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
                    builder: (_) => CreateGardenPage(
                      profileId: _profileId,
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

  testWidgets('required fields prevent invalid creation', (tester) async {
    await openPage(tester);
    await _submit(tester);

    expect(repository.calls, isEmpty);
    expect(find.text('Campo obbligatorio.'), findsOneWidget);
    expect(find.text('Inserisci un numero valido.'), findsNWidgets(2));
    expect(find.text('Inserisci un intero tra -100 e 5000.'), findsOneWidget);
    expect(find.byType(CreateGardenPage), findsOneWidget);
  });

  testWidgets('successful creation passes normalized values and returns true', (
    tester,
  ) async {
    repository.result = _createdGarden();
    await openPage(tester);
    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(repository.calls.single, containsPair('profileId', _profileId));
    expect(repository.calls.single, containsPair('name', 'Orto nuovo'));
    expect(repository.calls.single, containsPair('latitude', 45.85));
    expect(repository.calls.single, containsPair('longitude', 12.62));
    expect(repository.calls.single, containsPair('elevationM', 25));
    expect(repository.calls.single, containsPair('timezone', 'Europe/Rome'));
    expect(repository.calls.single, containsPair('countryCode', 'IT'));
    expect(find.byType(CreateGardenPage), findsNothing);
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending creation prevents duplicate submissions', (
    tester,
  ) async {
    final response = Completer<CreateGardenResult>();
    repository.onCreate = () => response.future;

    await openPage(tester);
    await _fillValidForm(tester);

    final button = find.byType(FilledButton);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.tap(button);
    await tester.pump();

    expect(repository.calls, hasLength(1));
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(returnedResult, isNull);

    response.complete(_createdGarden());
    await tester.pumpAndSettle();

    expect(repository.calls, hasLength(1));
    expect(returnedResult, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('duplicate name preserves the form for correction', (
    tester,
  ) async {
    await openPage(tester);
    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(find.text('Esiste già un orto con questo nome.'), findsOneWidget);
    expect(find.byType(CreateGardenPage), findsOneWidget);
    expect(
      tester.widget<TextFormField>(_field('Nome orto *')).controller!.text,
      '  Orto nuovo  ',
    );
    expect(returnedResult, isNull);
  });

  testWidgets('uncertain outcome prevents another creation attempt', (
    tester,
  ) async {
    repository.onCreate = () async => throw StateError('Synthetic failure');

    await openPage(tester);
    await _fillValidForm(tester);
    await _submit(tester);

    expect(repository.calls, hasLength(1));
    expect(
      find.textContaining('Non è stato possibile confermare'),
      findsOneWidget,
    );

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
    expect(returnedResult, isNull);
    expect(tester.takeException(), isNull);
  });
}
