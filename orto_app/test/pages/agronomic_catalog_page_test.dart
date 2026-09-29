import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/catalog_authority_repository.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';
import 'package:orto_app/pages/agronomic_catalog_page.dart';

Widget _testApp({
  required CatalogAuthorityRepository repository,
  CropRepository? cropRepository,
}) {
  final effectiveCropRepository =
      cropRepository ??
      CropRepository.withLoader(({bool activeOnly = true}) async => []);

  return MaterialApp(
    home: AgronomicCatalogPage(
      repository: repository,
      cropRepository: effectiveCropRepository,
    ),
  );
}

void main() {
  group('AgronomicCatalogPage', () {
    testWidgets('shows loading while catalog capabilities are being fetched', (
      tester,
    ) async {
      final completer = Completer<dynamic>();

      final repository = CatalogAuthorityRepository.withInvoker((
        functionName,
        parameters,
      ) {
        expect(functionName, 'get_my_catalog_capabilities');
        expect(parameters, isEmpty);
        return completer.future;
      });

      await tester.pumpWidget(_testApp(repository: repository));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete({
        'status': 'ok',
        'can_manage_identity': true,
        'can_ingest': true,
        'can_review': true,
        'can_publish': true,
        'row_version': 1,
      });

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Catalogo Agronomico'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  testWidgets('shows active catalog authority capabilities', (tester) async {
    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(functionName, 'get_my_catalog_capabilities');
      expect(parameters, isEmpty);

      return {
        'status': 'ok',
        'can_manage_identity': true,
        'can_ingest': true,
        'can_review': true,
        'can_publish': true,
        'row_version': 1,
      };
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Catalogo Agronomico'), findsOneWidget);
    expect(find.text('Authority attiva'), findsOneWidget);
    expect(find.text('Gestione identità'), findsOneWidget);
    expect(find.text('Acquisizione dati'), findsOneWidget);
    expect(find.text('Revisione'), findsOneWidget);
    expect(find.text('Pubblicazione'), findsOneWidget);

    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows catalog initialization when authority is missing', (
    tester,
  ) async {
    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(functionName, 'get_my_catalog_capabilities');
      expect(parameters, isEmpty);

      return {
        'status': 'ok',
        'can_manage_identity': false,
        'can_ingest': false,
        'can_review': false,
        'can_publish': false,
        'row_version': null,
      };
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Catalogo non inizializzato'), findsOneWidget);
    expect(
      find.text(
        'L’autorità globale del Catalogo Agronomico non risulta inizializzata.',
      ),
      findsOneWidget,
    );
    expect(find.text('Inizializza Catalogo'), findsOneWidget);

    expect(find.text('Authority attiva'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('requires confirmation before claiming catalog authority', (
    tester,
  ) async {
    var claimCalls = 0;

    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(parameters, isEmpty);

      if (functionName == 'get_my_catalog_capabilities') {
        return {
          'status': 'ok',
          'can_manage_identity': false,
          'can_ingest': false,
          'can_review': false,
          'can_publish': false,
          'row_version': null,
        };
      }

      if (functionName == 'claim_initial_catalog_authority') {
        claimCalls += 1;
        return {'status': 'claimed'};
      }

      throw StateError('RPC inattesa: $functionName');
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inizializza Catalogo'));
    await tester.pumpAndSettle();

    expect(find.text('Inizializzare il Catalogo Agronomico?'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Conferma'), findsOneWidget);
    expect(claimCalls, 0);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('Inizializzare il Catalogo Agronomico?'), findsNothing);
    expect(claimCalls, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets('claims authority after confirmation and reloads capabilities', (
    tester,
  ) async {
    var capabilityCalls = 0;
    var claimCalls = 0;

    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(parameters, isEmpty);

      if (functionName == 'get_my_catalog_capabilities') {
        capabilityCalls += 1;

        if (capabilityCalls == 1) {
          return {
            'status': 'ok',
            'can_manage_identity': false,
            'can_ingest': false,
            'can_review': false,
            'can_publish': false,
            'row_version': null,
          };
        }

        return {
          'status': 'ok',
          'can_manage_identity': true,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 1,
        };
      }

      if (functionName == 'claim_initial_catalog_authority') {
        claimCalls += 1;
        return {
          'status': 'claimed',
          'can_manage_identity': true,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 1,
        };
      }

      throw StateError('RPC inattesa: $functionName');
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    expect(find.text('Catalogo non inizializzato'), findsOneWidget);
    expect(capabilityCalls, 1);
    expect(claimCalls, 0);

    await tester.tap(find.text('Inizializza Catalogo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    expect(claimCalls, 1);
    expect(capabilityCalls, 2);
    expect(find.text('Authority attiva'), findsOneWidget);
    expect(find.text('Catalogo non inizializzato'), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
  testWidgets('reloads capabilities when authority is already initialized', (
    tester,
  ) async {
    var capabilityCalls = 0;

    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(parameters, isEmpty);

      if (functionName == 'get_my_catalog_capabilities') {
        capabilityCalls += 1;

        if (capabilityCalls == 1) {
          return {
            'status': 'ok',
            'can_manage_identity': false,
            'can_ingest': false,
            'can_review': false,
            'can_publish': false,
            'row_version': null,
          };
        }

        return {
          'status': 'ok',
          'can_manage_identity': true,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 2,
        };
      }

      if (functionName == 'claim_initial_catalog_authority') {
        return {
          'status': 'already_initialized',
          'can_manage_identity': true,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 2,
        };
      }

      throw StateError('RPC inattesa: $functionName');
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inizializza Catalogo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    expect(capabilityCalls, 2);
    expect(find.text('Authority attiva'), findsOneWidget);
    expect(find.text('Catalogo non inizializzato'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'shows already assigned state when authority was claimed by another user',
    (tester) async {
      var capabilityCalls = 0;
      var claimCalls = 0;

      final repository = CatalogAuthorityRepository.withInvoker((
        functionName,
        parameters,
      ) async {
        expect(parameters, isEmpty);

        if (functionName == 'get_my_catalog_capabilities') {
          capabilityCalls += 1;
          return {
            'status': 'ok',
            'can_manage_identity': false,
            'can_ingest': false,
            'can_review': false,
            'can_publish': false,
            'row_version': null,
          };
        }

        if (functionName == 'claim_initial_catalog_authority') {
          claimCalls += 1;
          return {'status': 'already_claimed'};
        }

        throw StateError('RPC inattesa: $functionName');
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inizializza Catalogo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(claimCalls, 1);
      expect(capabilityCalls, 1);

      expect(find.text('Authority già assegnata'), findsOneWidget);
      expect(
        find.text(
          'L’autorità globale del Catalogo Agronomico è già stata assegnata.',
        ),
        findsOneWidget,
      );

      expect(find.text('Inizializza Catalogo'), findsNothing);
      expect(find.text('Authority attiva'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shows forbidden state when catalog authority initialization is denied',
    (tester) async {
      var capabilityCalls = 0;
      var claimCalls = 0;

      final repository = CatalogAuthorityRepository.withInvoker((
        functionName,
        parameters,
      ) async {
        expect(parameters, isEmpty);

        if (functionName == 'get_my_catalog_capabilities') {
          capabilityCalls += 1;
          return {
            'status': 'ok',
            'can_manage_identity': false,
            'can_ingest': false,
            'can_review': false,
            'can_publish': false,
            'row_version': null,
          };
        }

        if (functionName == 'claim_initial_catalog_authority') {
          claimCalls += 1;
          return {'status': 'forbidden'};
        }

        throw StateError('RPC inattesa: $functionName');
      });

      await tester.pumpWidget(_testApp(repository: repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Inizializza Catalogo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(claimCalls, 1);
      expect(capabilityCalls, 1);

      expect(find.text('Inizializzazione non autorizzata'), findsOneWidget);
      expect(
        find.text(
          'Non sei autorizzato a inizializzare l’Authority globale del Catalogo Agronomico.',
        ),
        findsOneWidget,
      );

      expect(find.text('Inizializza Catalogo'), findsNothing);
      expect(find.text('Authority attiva'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('shows technical error when catalog authority claim fails', (
    tester,
  ) async {
    var capabilityCalls = 0;
    var claimCalls = 0;

    final repository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(parameters, isEmpty);

      if (functionName == 'get_my_catalog_capabilities') {
        capabilityCalls += 1;
        return {
          'status': 'ok',
          'can_manage_identity': false,
          'can_ingest': false,
          'can_review': false,
          'can_publish': false,
          'row_version': null,
        };
      }

      if (functionName == 'claim_initial_catalog_authority') {
        claimCalls += 1;
        throw Exception('Errore RPC simulato');
      }

      throw StateError('RPC inattesa: $functionName');
    });

    await tester.pumpWidget(_testApp(repository: repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Inizializza Catalogo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conferma'));
    await tester.pumpAndSettle();

    expect(claimCalls, 1);
    expect(capabilityCalls, 1);

    expect(
      find.text('Errore durante l’inizializzazione del Catalogo.'),
      findsOneWidget,
    );

    expect(find.text('Authority attiva'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows empty crop catalog when authority is initialized', (
    tester,
  ) async {
    var cropLoads = 0;

    final authorityRepository = CatalogAuthorityRepository.withInvoker((
      functionName,
      parameters,
    ) async {
      expect(functionName, 'get_my_catalog_capabilities');
      expect(parameters, isEmpty);

      return {
        'status': 'ok',
        'can_manage_identity': true,
        'can_ingest': true,
        'can_review': true,
        'can_publish': true,
        'row_version': 1,
      };
    });

    final cropRepository = CropRepository.withLoader(({
      bool activeOnly = true,
    }) async {
      cropLoads += 1;
      expect(activeOnly, isTrue);
      return [];
    });

    await tester.pumpWidget(
      _testApp(repository: authorityRepository, cropRepository: cropRepository),
    );
    await tester.pumpAndSettle();

    expect(find.text('Authority attiva'), findsOneWidget);
    expect(cropLoads, 1);
    expect(find.text('Colture'), findsOneWidget);
    expect(
      find.text('Nessuna coltura presente nel Catalogo Agronomico.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
