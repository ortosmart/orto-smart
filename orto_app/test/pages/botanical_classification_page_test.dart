import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/data/models/catalog_capabilities.dart';
import 'package:orto_app/data/repositories/botanical_taxon_repository.dart';
import 'package:orto_app/pages/botanical_classification_page.dart';

void main() {
  testWidgets('loads all botanical classifications and shows them', (
    tester,
  ) async {
    bool? requestedActiveOnly;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        requestedActiveOnly = activeOnly;

        return [
          {
            'id': 'taxon-1',
            'parent_taxon_id': null,
            'rank': 'SPECIES',
            'scientific_name': 'Daucus carota',
            'authorship': null,
            'is_hybrid': false,
            'description': 'Carota',
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-08T08:00:00Z',
            'updated_at': '2026-10-08T08:00:00Z',
          },
        ];
      },
      (functionName, parameters) async {
        throw StateError('RPC non prevista in questo test');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(requestedActiveOnly, isFalse);
    expect(find.text('Classificazione botanica'), findsOneWidget);
    expect(find.text('Daucus carota'), findsOneWidget);
    expect(find.text('SPECIES'), findsOneWidget);
  });
  testWidgets(
    'shows authorship and inactive status for botanical classification',
    (tester) async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          return [
            {
              'id': 'taxon-1',
              'parent_taxon_id': null,
              'rank': 'SPECIES',
              'scientific_name': 'Brassica oleracea',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': null,
              'is_active': false,
              'row_version': 2,
              'created_at': '2026-10-08T08:00:00Z',
              'updated_at': '2026-10-08T09:00:00Z',
            },
          ];
        },
        (functionName, parameters) async {
          throw StateError('RPC non prevista in questo test');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Brassica oleracea'), findsOneWidget);
      expect(find.text('SPECIES · L.'), findsOneWidget);
      expect(find.text('Inattiva'), findsOneWidget);
    },
  );
  testWidgets(
    'hides create botanical classification action without identity capability',
    (tester) async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          return [];
        },
        (functionName, parameters) async {
          fail('Taxon write path must not be called');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: false,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nuova voce botanica'), findsNothing);
      expect(
        find.text('Nessuna voce presente nella classificazione botanica.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shows create botanical classification action and opens dialog with identity capability',
    (tester) async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          return [];
        },
        (functionName, parameters) async {
          fail('Taxon write path must not be called');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nuova voce botanica'), findsOneWidget);
      expect(
        find.text('Nessuna voce presente nella classificazione botanica.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Nuova voce botanica'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AlertDialog, 'Nuova voce botanica'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextField, 'Nome scientifico'),
        findsOneWidget,
      );
      expect(find.byType(DropdownButtonFormField<String?>), findsOneWidget);
      expect(find.text('Crea'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
  'requires scientific name before creating botanical classification',
  (tester) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        return [];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

        await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(writeCalls, 0);
    expect(
      find.text('Il nome scientifico è obbligatorio.'),
      findsOneWidget,
    );
    expect(find.text('Crea'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  },
);
  testWidgets(
    'creates botanical classification with expected parameters and reloads data',
    (tester) async {
      var taxonLoads = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          taxonLoads += 1;

          if (taxonLoads == 1) {
            return [];
          }

          return [
            {
              'id': 'taxon-1',
              'parent_taxon_id': null,
              'rank': 'SPECIES',
              'scientific_name': 'Solanum lycopersicum',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Pomodoro',
              'is_active': true,
              'row_version': 1,
              'created_at': '2026-10-08T08:00:00Z',
              'updated_at': '2026-10-08T08:00:00Z',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'create_botanical_taxon');
          expect(parameters, {
            'target_parent_taxon_id': null,
            'taxon_rank': 'SPECIES',
            'taxon_scientific_name': 'Solanum lycopersicum',
            'taxon_authorship': 'L.',
            'taxon_is_hybrid': false,
            'taxon_description': 'Pomodoro',
          });

          return {
            'status': 'created',
            'botanical_taxon_id': 'taxon-1',
            'row_version': 1,
            'created_at': '2026-10-08T08:00:00Z',
            'updated_at': '2026-10-08T08:00:00Z',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(taxonLoads, 1);

      await tester.tap(find.text('Nuova voce botanica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome scientifico'),
        'Solanum lycopersicum',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Autore'), 'L.');
      await tester.enterText(
        find.widgetWithText(TextField, 'Descrizione'),
        'Pomodoro',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(taxonLoads, 2);

      expect(
        find.widgetWithText(AlertDialog, 'Nuova voce botanica'),
        findsNothing,
      );
      expect(find.text('Solanum lycopersicum'), findsOneWidget);
      expect(find.text('SPECIES · L.'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
  'keeps create botanical classification dialog open on duplicate identity',
  (tester) async {
    var taxonLoads = 0;
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isFalse);
        return [];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'create_botanical_taxon');
        expect(parameters, {
          'target_parent_taxon_id': null,
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'taxon_authorship': null,
          'taxon_is_hybrid': false,
          'taxon_description': null,
        });

        return {'status': 'duplicate_identity'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome scientifico'),
      'Solanum lycopersicum',
    );

    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(writeCalls, 1);
    expect(taxonLoads, 1);

    expect(
      find.text('Esiste già una voce con questa classificazione botanica.'),
      findsOneWidget,
    );
    expect(find.text('Crea'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'shows dependency inactive when selected parent botanical classification is inactive',
  (tester) async {
    var taxonLoads = 0;
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'create_botanical_taxon');
        expect(parameters, {
          'target_parent_taxon_id': '11111111-1111-4111-8111-111111111111',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'taxon_authorship': null,
          'taxon_is_hybrid': false,
          'taxon_description': null,
        });

        return {'status': 'dependency_inactive'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome scientifico'),
      'Solanum lycopersicum',
    );

    await tester.tap(find.text('Nessuno'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('GENUS · Solanum').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Crea'));
    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(writeCalls, 1);
    expect(taxonLoads, 1);

    expect(
      find.text('La classificazione superiore selezionata non è attiva.'),
      findsOneWidget,
    );
    expect(find.text('Crea'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'cancels create botanical classification without calling write path',
  (tester) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        return [];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome scientifico'),
      'Solanum lycopersicum',
    );

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(writeCalls, 0);

    // Rimane solo il pulsante della pagina: il dialog è chiuso.
    expect(find.text('Nuova voce botanica'), findsOneWidget);
    expect(find.text('Crea'), findsNothing);
    expect(find.text('Annulla'), findsNothing);
    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'prevents duplicate create botanical classification submission while rpc is pending',
  (tester) async {
    var taxonLoads = 0;
    var writeCalls = 0;

    final rpcCompleter = Completer<Map<String, dynamic>>();

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isFalse);

        if (taxonLoads == 1) {
          return [];
        }

        return [
          {
            'id': '33333333-3333-4333-8333-333333333333',
            'parent_taxon_id': null,
            'rank': 'SPECIES',
            'scientific_name': 'Solanum lycopersicum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) {
        writeCalls += 1;

        expect(functionName, 'create_botanical_taxon');
        expect(parameters, {
          'target_parent_taxon_id': null,
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'taxon_authorship': null,
          'taxon_is_hybrid': false,
          'taxon_description': null,
        });

        return rpcCompleter.future;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome scientifico'),
      'Solanum lycopersicum',
    );

    // Primo invio: la RPC rimane intenzionalmente in attesa.
    await tester.tap(find.text('Crea'));
    await tester.pump();

    expect(writeCalls, 1);

    // Durante la RPC il pulsante Crea deve essere disabilitato.
    final createButton = tester.widget<FilledButton>(
      find.byType(FilledButton).last,
    );

    expect(createButton.onPressed, isNull);

    // Un ulteriore tentativo sul pulsante disabilitato non deve
    // generare una seconda chiamata RPC.
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(writeCalls, 1);

    // Completiamo la RPC simulando una creazione riuscita.
    rpcCompleter.complete({
      'status': 'created',
      'botanical_taxon_id': '33333333-3333-4333-8333-333333333333',
      'row_version': 1,
      'created_at': '2026-10-03T07:00:00+00:00',
      'updated_at': '2026-10-03T07:00:00+00:00',
    });

    await tester.pumpAndSettle();

    // Una sola scrittura e una seconda lettura dopo la creazione.
    expect(writeCalls, 1);
    expect(taxonLoads, 2);

    expect(find.text('Solanum lycopersicum'), findsOneWidget);
    expect(tester.takeException(), isNull);
  },
);
  testWidgets(
    'blocks retry when create botanical classification outcome is uncertain',
    (tester) async {
      var taxonLoads = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          taxonLoads += 1;
          return [];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'create_botanical_taxon');
          expect(parameters, {
            'target_parent_taxon_id': null,
            'taxon_rank': 'SPECIES',
            'taxon_scientific_name': 'Solanum lycopersicum',
            'taxon_authorship': 'L.',
            'taxon_is_hybrid': false,
            'taxon_description': 'Pomodoro',
          });

          throw StateError('Esito RPC non verificabile');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(taxonLoads, 1);

      await tester.tap(find.text('Nuova voce botanica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome scientifico'),
        'Solanum lycopersicum',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Autore'), 'L.');
      await tester.enterText(
        find.widgetWithText(TextField, 'Descrizione'),
        'Pomodoro',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);

      // Nessun reload mentre il dialog conserva lo stato
      // dell'operazione dall'esito incerto.
      expect(taxonLoads, 1);
      expect(
        find.widgetWithText(AlertDialog, 'Nuova voce botanica'),
        findsOneWidget,
      );

      expect(
        find.text(
          'Non è stato possibile verificare l\'esito della creazione. '
          'Chiudi questa finestra: i dati verranno ricaricati prima di '
          'un nuovo tentativo.',
        ),
        findsOneWidget,
      );

      // Dopo un esito incerto non deve essere possibile inviare
      // nuovamente create_botanical_taxon.
      final createButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Crea'),
      );
      expect(createButton.onPressed, isNull);

      // Anche i campi modificabili devono essere bloccati.
      final scientificNameField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Nome scientifico'),
      );
      final authorshipField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Autore'),
      );
      final descriptionField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Descrizione'),
      );

      expect(scientificNameField.enabled, isFalse);
      expect(authorshipField.enabled, isFalse);
      expect(descriptionField.enabled, isFalse);

      final rankDropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>),
      );
      final parentDropdown = tester.widget<DropdownButtonFormField<String?>>(
        find.byType(DropdownButtonFormField<String?>),
      );

      expect(rankDropdown.onChanged, isNull);
      expect(parentDropdown.onChanged, isNull);

      final hybridCheckbox = tester.widget<CheckboxListTile>(
        find.widgetWithText(CheckboxListTile, 'Ibrido'),
      );
      expect(hybridCheckbox.onChanged, isNull);

      // Annulla rimane disponibile per uscire in sicurezza.
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Annulla'),
      );
      expect(cancelButton.onPressed, isNotNull);

      // Nessun retry automatico.
      expect(writeCalls, 1);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reloads botanical classifications after closing create dialog with uncertain outcome',
    (tester) async {
      var taxonLoads = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          taxonLoads += 1;

          if (taxonLoads == 1) {
            return [];
          }

          // Stato autoritativo dopo l'esito incerto:
          // la create potrebbe essere stata applicata dal server.
          return [
            {
              'id': 'taxon-1',
              'parent_taxon_id': null,
              'rank': 'SPECIES',
              'scientific_name': 'Solanum lycopersicum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': true,
              'row_version': 1,
              'created_at': '2026-10-08T08:00:00Z',
              'updated_at': '2026-10-08T08:00:00Z',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'create_botanical_taxon');
          expect(parameters, {
            'target_parent_taxon_id': null,
            'taxon_rank': 'SPECIES',
            'taxon_scientific_name': 'Solanum lycopersicum',
            'taxon_authorship': null,
            'taxon_is_hybrid': false,
            'taxon_description': null,
          });

          throw StateError('Esito RPC non verificabile');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(taxonLoads, 1);

      await tester.tap(find.text('Nuova voce botanica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome scientifico'),
        'Solanum lycopersicum',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      // Nessun reload mentre il dialog rimane aperto.
      expect(writeCalls, 1);
      expect(taxonLoads, 1);
      expect(
        find.widgetWithText(AlertDialog, 'Nuova voce botanica'),
        findsOneWidget,
      );

      // L'utente chiude il dialog in sicurezza.
      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();

      // Nessuna seconda create.
      expect(writeCalls, 1);

      // Dopo la chiusura viene riletto lo stato autoritativo.
      expect(taxonLoads, 2);

      expect(
        find.widgetWithText(AlertDialog, 'Nuova voce botanica'),
        findsNothing,
      );
      expect(find.text('Solanum lycopersicum'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
  'hides edit botanical classification actions without identity management capability',
  (tester) async {
    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: false,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solanum'), findsOneWidget);
    expect(find.text('Modifica'), findsNothing);
    expect(find.text('Disattiva'), findsNothing);
    expect(find.text('Riattiva'), findsNothing);
    expect(tester.takeException(), isNull);
  },
);
  testWidgets(
    'shows edit botanical classification action and opens dialog with identity capability',
    (tester) async {
      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);

          return [
            {
              'id': 'taxon-1',
              'parent_taxon_id': null,
              'rank': 'SPECIES',
              'scientific_name': 'Solanum lycopersicum',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Pomodoro',
              'is_active': true,
              'row_version': 3,
              'created_at': '2026-10-08T08:00:00Z',
              'updated_at': '2026-10-08T08:00:00Z',
            },
          ];
        },
        (functionName, parameters) async {
          fail('Il Write Path non deve essere chiamato aprendo il dialog.');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Solanum lycopersicum'), findsOneWidget);
      expect(find.text('Modifica'), findsOneWidget);

      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AlertDialog, 'Modifica classificazione botanica'),
        findsOneWidget,
      );
     final scientificNameField = tester.widget<TextFormField>(
  find.widgetWithText(TextFormField, 'Nome scientifico'),
);
expect(scientificNameField.initialValue, 'Solanum lycopersicum');

final authorshipField = tester.widget<TextFormField>(
  find.widgetWithText(TextFormField, 'Autore'),
);
expect(authorshipField.initialValue, 'L.');

final descriptionField = tester.widget<TextFormField>(
  find.widgetWithText(TextFormField, 'Descrizione'),
);
expect(descriptionField.initialValue, 'Pomodoro');

final rankField = tester.widget<DropdownButtonFormField<String>>(
  find.widgetWithText(
    DropdownButtonFormField<String>,
    'Rango',
  ),
);
expect(rankField.initialValue, 'SPECIES');

final hybridCheckbox = tester.widget<CheckboxListTile>(
  find.widgetWithText(CheckboxListTile, 'Ibrido'),
);
expect(hybridCheckbox.value, isFalse);

expect(find.text('Salva'), findsOneWidget);
expect(find.text('Annulla'), findsOneWidget);
expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
  'edit botanical classification excludes itself from parent choices',
  (tester) async {
    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
          {
            'id': '22222222-2222-4222-8222-222222222222',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Capsicum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final solanumTile = find.ancestor(
      of: find.text('Solanum'),
      matching: find.byType(ListTile),
    );

    await tester.tap(
      find.descendant(
        of: solanumTile,
        matching: find.text('Modifica'),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    await tester.tap(find.text('Nessuno'));
    await tester.pumpAndSettle();

    expect(find.text('GENUS · Capsicum'), findsOneWidget);
    expect(find.text('GENUS · Solanum'), findsNothing);

    expect(tester.takeException(), isNull);
  },
);
  testWidgets(
    'updates botanical classification with original row version and reloads data',
    (tester) async {
      var taxonLoads = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          taxonLoads += 1;

          return [
            {
              'id': 'taxon-1',
              'parent_taxon_id': null,
              'rank': 'SPECIES',
              'scientific_name': taxonLoads == 1
                  ? 'Solanum lycopersicum'
                  : 'Solanum lycopersicum L.',
              'authorship': null,
              'is_hybrid': false,
              'description': 'Pomodoro',
              'is_active': true,
              'row_version': taxonLoads == 1 ? 3 : 4,
              'created_at': '2026-10-08T08:00:00Z',
              'updated_at': '2026-10-08T08:00:00Z',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'update_botanical_taxon');
          expect(parameters, {
            'target_botanical_taxon_id': 'taxon-1',
            'expected_row_version': 3,
            'target_parent_taxon_id': null,
            'taxon_rank': 'SPECIES',
            'taxon_scientific_name': 'Solanum lycopersicum L.',
            'taxon_authorship': null,
            'taxon_is_hybrid': false,
            'taxon_description': 'Pomodoro',
          });

          return {
            'status': 'updated',
            'botanical_taxon_id': 'taxon-1',
            'row_version': 4,
            'updated_at': '2026-10-08T08:30:00Z',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(taxonLoads, 1);

      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome scientifico'),
        'Solanum lycopersicum L.',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(taxonLoads, 2);

      expect(
        find.widgetWithText(AlertDialog, 'Modifica classificazione botanica'),
        findsNothing,
      );

      expect(find.text('Solanum lycopersicum L.'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
  'closes edit dialog and reloads botanical classification when update is unchanged',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(parameters, {
          'target_botanical_taxon_id':
              '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 7,
          'target_parent_taxon_id': null,
          'taxon_rank': 'GENUS',
          'taxon_scientific_name': 'Solanum',
          'taxon_authorship': 'L.',
          'taxon_is_hybrid': false,
          'taxon_description': 'Descrizione originale',
        });

        return {
          'status': 'unchanged',
          'botanical_taxon_id':
              '11111111-1111-4111-8111-111111111111',
          'row_version': 7,
          'updated_at': '2026-10-03T07:00:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // "unchanged" è comunque un esito positivo.
    expect(
      find.text('Modifica classificazione botanica'),
      findsNothing,
    );

    // Dopo l'esito positivo rileggiamo lo stato autorevole dal DB.
    expect(loadCalls, 2);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when update is forbidden',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'forbidden'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // L'errore non deve chiudere il dialog.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Un errore deterministico non richiede un reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'Non sei autorizzato a modificare la classificazione botanica.',
      ),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when update has invalid input',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'invalid_input'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // L'errore deterministico non deve chiudere il dialog.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Nessun reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text('I dati inseriti non sono validi. Controlla i campi.'),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when update is not found',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'not_found'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // Il dialog deve rimanere aperto.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Nessun reload automatico per questo esito deterministico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'La voce botanica da modificare non è più disponibile.',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when parent is not found',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'parent_not_found'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // Il dialog deve rimanere aperto.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Nessun reload automatico per questo esito deterministico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'La classificazione superiore selezionata non è più disponibile.',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when parent is inactive',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'dependency_inactive'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // Il dialog deve rimanere aperto.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Nessun reload automatico per questo esito deterministico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'La classificazione superiore selezionata non è attiva.',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'keeps edit botanical classification dialog open when identity is duplicate',
  (tester) async {
    var loadCalls = 0;
    var updateCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);

        return {'status': 'duplicate_identity'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // Il dialog deve rimanere aperto.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    // Nessun reload automatico per questo esito deterministico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'Esiste già una voce con questa classificazione botanica.',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'cancels edit botanical classification without calling write path',
  (tester) async {
    var loadCalls = 0;
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome scientifico'),
      'Solanum modificato',
    );

    await tester.ensureVisible(find.text('Annulla'));
    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    // Annullare non deve invocare alcun Write Path.
    expect(writeCalls, 0);

    // Annullare non deve provocare un reload.
    expect(loadCalls, 1);

    // Il dialog deve essere chiuso.
    expect(
      find.text('Modifica classificazione botanica'),
      findsNothing,
    );

    // La pagina rimane disponibile.
    expect(find.text('Modifica'), findsOneWidget);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'requires scientific name when editing botanical classification',
  (tester) async {
    var loadCalls = 0;
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 7,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome scientifico'),
      '',
    );

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    // La validazione locale deve bloccare il Write Path.
    expect(writeCalls, 0);

    // Nessun reload.
    expect(loadCalls, 1);

    // Il dialog deve restare aperto.
    expect(
      find.text('Modifica classificazione botanica'),
      findsOneWidget,
    );

    expect(
      find.text('Il nome scientifico è obbligatorio.'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'prevents duplicate edit botanical classification submission while rpc is pending',
  (tester) async {
    var taxonLoads = 0;
    var writeCalls = 0;

    final rpcCompleter = Completer<Map<String, dynamic>>();

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isFalse);

        if (taxonLoads == 1) {
          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Descrizione originale',
              'is_active': true,
              'row_version': 7,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-03T07:00:00+00:00',
            },
          ];
        }

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum aggiornato',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': 8,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T08:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) {
        writeCalls += 1;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);
        expect(
          parameters['taxon_scientific_name'],
          'Solanum aggiornato',
        );

        return rpcCompleter.future;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(taxonLoads, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome scientifico'),
      'Solanum aggiornato',
    );

    // Primo invio: la RPC rimane intenzionalmente in attesa.
    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pump();

    expect(writeCalls, 1);

    // Durante la RPC il pulsante Salva deve essere disabilitato.
    final saveButton = tester.widget<FilledButton>(
      find.byType(FilledButton).last,
    );

    expect(saveButton.onPressed, isNull);

    // Un secondo tentativo non deve generare una seconda RPC.
    await tester.tap(find.byType(FilledButton).last);
    await tester.pump();

    expect(writeCalls, 1);

    // Completiamo la prima RPC simulando un aggiornamento riuscito.
    rpcCompleter.complete({
      'status': 'updated',
      'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
      'row_version': 8,
      'updated_at': '2026-10-03T08:00:00+00:00',
    });

    await tester.pumpAndSettle();

    // Una sola scrittura e un solo reload successivo.
    expect(writeCalls, 1);
    expect(taxonLoads, 2);

    // Il dialog deve essere chiuso dopo il successo.
    expect(
      find.text('Modifica classificazione botanica'),
      findsNothing,
    );

    // Il valore autorevole riletto dal DB deve essere visualizzato.
    expect(find.text('Solanum aggiornato'), findsOneWidget);

    expect(tester.takeException(), isNull);
  },
);
  testWidgets(
    'blocks retry and reloads botanical classification after edit version conflict',
    (tester) async {
      var loadCalls = 0;
      var updateCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          if (loadCalls == 1) {
            return [
              {
                'id': '11111111-1111-4111-8111-111111111111',
                'parent_taxon_id': null,
                'rank': 'GENUS',
                'scientific_name': 'Solanum',
                'authorship': 'L.',
                'is_hybrid': false,
                'description': 'Descrizione originale',
                'is_active': true,
                'row_version': 7,
                'created_at': '2026-10-03T07:00:00+00:00',
                'updated_at': '2026-10-03T07:00:00+00:00',
              },
            ];
          }

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum aggiornato da altro utente',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Descrizione aggiornata',
              'is_active': true,
              'row_version': 8,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-03T08:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          updateCalls += 1;

          expect(functionName, 'update_botanical_taxon');
          expect(
            parameters['target_botanical_taxon_id'],
            '11111111-1111-4111-8111-111111111111',
          );
          expect(parameters['expected_row_version'], 7);
          expect(
            parameters['taxon_scientific_name'],
            'Solanum modificato localmente',
          );

          return {
            'status': 'version_conflict',
            'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'expected_row_version': 7,
            'current_row_version': 8,
            'updated_at': '2026-10-03T08:00:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome scientifico'),
        'Solanum modificato localmente',
      );

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(updateCalls, 1);
      expect(loadCalls, 1);

      // Il conflitto mantiene aperto il dialog e conserva i dati locali.
      expect(find.text('Modifica classificazione botanica'), findsOneWidget);
      expect(find.text('Solanum modificato localmente'), findsOneWidget);

      expect(
        find.text(
          'La classificazione botanica è stata modificata nel frattempo. '
          'Ricarica i dati prima di effettuare una nuova modifica.',
        ),
        findsOneWidget,
      );

      // Non è consentito riutilizzare il row_version ormai obsoleto.
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Salva'),
      );
      expect(saveButton.onPressed, isNull);

      // La chiusura rimane disponibile.
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Annulla'),
      );
      expect(cancelButton.onPressed, isNotNull);

      // Nessun retry automatico.
      expect(updateCalls, 1);

      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();

      // Solo dopo la chiusura rileggiamo lo stato autoritativo.
      expect(updateCalls, 1);
      expect(loadCalls, 2);

      expect(find.text('Modifica classificazione botanica'), findsNothing);
      expect(find.text('Solanum aggiornato da altro utente'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'blocks retry when edit botanical classification outcome is uncertain',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Descrizione originale',
              'is_active': true,
              'row_version': 7,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-03T07:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'update_botanical_taxon');
          expect(
            parameters['target_botanical_taxon_id'],
            '11111111-1111-4111-8111-111111111111',
          );
          expect(parameters['expected_row_version'], 7);

          throw StateError('Esito RPC non verificabile');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome scientifico'),
        'Solanum modificato localmente',
      );

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(loadCalls, 1);

      // L'esito della scrittura non è noto: il dialog resta aperto
      // e conserva i dati locali inseriti dall'utente.
      expect(find.text('Modifica classificazione botanica'), findsOneWidget);
      expect(find.text('Solanum modificato localmente'), findsOneWidget);

      expect(
        find.text(
          'Non è stato possibile verificare l\'esito del salvataggio. '
          'Ricarica i dati prima di effettuare una nuova modifica.',
        ),
        findsOneWidget,
      );

      // Non deve essere possibile ripetere la scrittura sullo stato
      // potenzialmente già modificato dal server.
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Salva'),
      );
      expect(saveButton.onPressed, isNull);

      // Annulla rimane disponibile per uscire dal dialog.
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Annulla'),
      );
      expect(cancelButton.onPressed, isNotNull);

      // Nessun retry automatico e nessun reload mentre
      // il dialog conserva lo stato dell'operazione incerta.
      expect(writeCalls, 1);
      expect(loadCalls, 1);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reloads botanical classification after closing edit dialog with uncertain outcome',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          if (loadCalls == 1) {
            return [
              {
                'id': '11111111-1111-4111-8111-111111111111',
                'parent_taxon_id': null,
                'rank': 'GENUS',
                'scientific_name': 'Solanum',
                'authorship': 'L.',
                'is_hybrid': false,
                'description': 'Descrizione originale',
                'is_active': true,
                'row_version': 7,
                'created_at': '2026-10-03T07:00:00+00:00',
                'updated_at': '2026-10-03T07:00:00+00:00',
              },
            ];
          }

          // Simula lo stato autoritativo riletto dopo l'esito incerto:
          // la prima RPC potrebbe essere stata applicata dal server.
          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum salvato dal server',
              'authorship': 'L.',
              'is_hybrid': false,
              'description': 'Descrizione originale',
              'is_active': true,
              'row_version': 8,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-03T08:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'update_botanical_taxon');
          expect(
            parameters['target_botanical_taxon_id'],
            '11111111-1111-4111-8111-111111111111',
          );
          expect(parameters['expected_row_version'], 7);

          throw StateError('Esito RPC non verificabile');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome scientifico'),
        'Solanum modificato localmente',
      );

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      // Nessun reload mentre il dialog conserva ancora
      // i dati locali dopo l'esito incerto.
      expect(writeCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Solanum modificato localmente'), findsOneWidget);

      // L'utente chiude il dialog.
      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();

      // Nessuna seconda scrittura.
      expect(writeCalls, 1);

      // Solo adesso rileggiamo lo stato autoritativo.
      expect(loadCalls, 2);

      expect(find.text('Modifica classificazione botanica'), findsNothing);
      expect(find.text('Solanum salvato dal server'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reloads authoritative botanical classification after activation version conflict',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          if (loadCalls == 1) {
            return [
              {
                'id': '11111111-1111-4111-8111-111111111111',
                'parent_taxon_id': null,
                'rank': 'GENUS',
                'scientific_name': 'Solanum',
                'authorship': null,
                'is_hybrid': false,
                'description': null,
                'is_active': false,
                'row_version': 3,
                'created_at': '2026-10-03T07:00:00+00:00',
                'updated_at': '2026-10-04T07:00:00+00:00',
              },
            ];
          }

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': true,
              'row_version': 4,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-04T08:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'set_botanical_taxon_active');
          expect(
            parameters['target_botanical_taxon_id'],
            '11111111-1111-4111-8111-111111111111',
          );
          expect(parameters['expected_row_version'], 3);
          expect(parameters['taxon_is_active'], isTrue);

          return {
            'status': 'version_conflict',
            'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'expected_row_version': 3,
            'current_row_version': 4,
            'updated_at': '2026-10-04T08:00:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);
      expect(find.text('Riattiva'), findsOneWidget);

      await tester.tap(find.text('Riattiva'));

      // La modifica lifecycle mantiene attivo il progress indicator finché
      // il dialog di esito non viene chiuso, quindi qui non usiamo
      // pumpAndSettle().
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(writeCalls, 1);
      expect(loadCalls, 2);

      expect(
        find.textContaining('La classificazione botanica è stata modificata'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'I dati sono stati ricaricati prima di effettuare una nuova operazione.',
        ),
        findsOneWidget,
      );

      // Il reload autoritativo è già avvenuto, ma finché il dialog resta
      // aperto l'operazione lifecycle è ancora pending.
      expect(find.text('Riattiva'), findsNothing);
      expect(find.text('Disattiva'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Nessun retry automatico con il vecchio row_version.
      expect(writeCalls, 1);

      // Chiudendo il dialog termina l'operazione e il finally rimuove
      // lo stato pending.
      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(loadCalls, 2);

      // Ora la UI espone lo stato autoritativo riletto dal DB.
      expect(find.text('Riattiva'), findsNothing);
      expect(find.text('Disattiva'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reloads authoritative botanical classification after uncertain activation outcome',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': loadCalls > 1,
              'row_version': loadCalls > 1 ? 4 : 3,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': loadCalls > 1
                  ? '2026-10-04T08:00:00+00:00'
                  : '2026-10-04T07:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'set_botanical_taxon_active');
          expect(
            parameters['target_botanical_taxon_id'],
            '11111111-1111-4111-8111-111111111111',
          );
          expect(parameters['expected_row_version'], 3);
          expect(parameters['taxon_is_active'], isTrue);

          throw Exception('simulated uncertain outcome');
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);
      expect(find.text('Riattiva'), findsOneWidget);

      await tester.tap(find.text('Riattiva'));

      // Il lifecycle resta pending finché il dialog di esito incerto
      // non viene chiuso, quindi non usiamo pumpAndSettle().
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(writeCalls, 1);
      expect(loadCalls, 2);

      expect(find.text('Stato da verificare'), findsOneWidget);
      expect(
        find.textContaining(
          'Non è stato possibile verificare l\'esito dell\'operazione.',
        ),
        findsOneWidget,
      );

      // Il DB è già stato riletto, ma l'operazione rimane pending
      // fino alla chiusura del dialog.
      expect(find.text('Riattiva'), findsNothing);
      expect(find.text('Disattiva'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // L'esito incerto non deve provocare alcun retry.
      expect(writeCalls, 1);

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();

      // Il finally ha terminato il pending e la UI mostra
      // lo stato autoritativo riletto dal DB.
      expect(writeCalls, 1);
      expect(loadCalls, 2);
      expect(find.text('Riattiva'), findsNothing);
      expect(find.text('Disattiva'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      final deactivateButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Disattiva'),
      );
      expect(deactivateButton.onPressed, isNotNull);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('asks confirmation before deactivating a taxon', (tester) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-04T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista prima della conferma');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Disattiva'), findsOneWidget);

    await tester.tap(find.text('Disattiva'));
    await tester.pumpAndSettle();

    expect(
      find.text('Disattivare la classificazione botanica?'),
      findsOneWidget,
    );
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Conferma'), findsOneWidget);

    // Aprire la conferma non deve ancora invocare il Write Path.
    expect(writeCalls, 0);

    expect(tester.takeException(), isNull);
  });
  testWidgets('cancels taxon deactivation without calling write path', (
    tester,
  ) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-04T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Disattiva'));
    await tester.pumpAndSettle();

    expect(
      find.text('Disattivare la classificazione botanica?'),
      findsOneWidget,
    );
    expect(writeCalls, 0);

    await tester.tap(find.text('Annulla'));
    await tester.pumpAndSettle();

    expect(find.text('Disattivare la classificazione botanica?'), findsNothing);
    expect(writeCalls, 0);

    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'deactivates taxon with original row version and reloads botanical classification',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': loadCalls == 1,
              'row_version': loadCalls == 1 ? 3 : 4,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': loadCalls == 1
                  ? '2026-10-04T07:00:00+00:00'
                  : '2026-10-04T08:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'set_botanical_taxon_active');
          expect(parameters, {
            'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'expected_row_version': 3,
            'taxon_is_active': false,
          });

          return {
            'status': 'active_changed',
            'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'is_active': false,
            'row_version': 4,
            'updated_at': '2026-10-04T08:00:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);
      expect(writeCalls, 0);

      await tester.tap(find.text('Disattiva'));
      await tester.pumpAndSettle();

      expect(
        find.text('Disattivare la classificazione botanica?'),
        findsOneWidget,
      );
      expect(writeCalls, 0);

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(loadCalls, 2);

      expect(find.text('Inattiva'), findsOneWidget);
      expect(find.text('Riattiva'), findsOneWidget);
      expect(find.text('Disattiva'), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reloads botanical classification when taxon deactivation is unchanged',
    (tester) async {
      var loadCalls = 0;
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls += 1;

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': true,
              'row_version': 3,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-04T07:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'set_botanical_taxon_active');
          expect(parameters, {
            'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'expected_row_version': 3,
            'taxon_is_active': false,
          });

          return {
            'status': 'unchanged',
            'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'is_active': true,
            'row_version': 3,
            'updated_at': '2026-10-04T07:00:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.text('Disattiva'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(writeCalls, 1);
      expect(loadCalls, 2);

      // La risposta "unchanged" non viene usata per inventare uno stato
      // locale: la classificazione viene riletta dalla fonte autoritativa.
      expect(find.text('Disattiva'), findsOneWidget);
      expect(find.text('Riattiva'), findsNothing);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('shows active taxon dependents and omits zero categories', (
    tester,
  ) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-04T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'set_botanical_taxon_active');
        expect(parameters, {
          'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 3,
          'taxon_is_active': false,
        });

        return {
          'status': 'active_dependents',
          'active_child_taxa_count': 2,
          'active_crops_count': 0,
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Disattiva'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Conferma'));

    // Il risultato active_dependents apre un dialog informativo mentre
    // l'operazione lifecycle è ancora pending. Il progress indicator resta
    // quindi attivo finché il dialog non viene chiuso.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(writeCalls, 1);

    expect(
      find.text('Impossibile disattivare la classificazione botanica'),
      findsOneWidget,
    );
    expect(
      find.textContaining('2 classificazioni botaniche attive'),
      findsOneWidget,
    );

    // Le categorie con conteggio zero non devono essere mostrate.
    expect(find.textContaining('colture'), findsNothing);

    // Finché il dialog resta aperto, l'operazione lifecycle è ancora pending.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Disattiva'), findsNothing);

    // Nessun retry automatico.
    expect(writeCalls, 1);

    // Chiudendo il dialog termina l'operazione e il finally rimuove
    // lo stato pending.
    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    expect(writeCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // La disattivazione è stata rifiutata dal server: il Taxon resta attivo
    // e l'azione può essere nuovamente utilizzata.
    expect(find.text('Disattiva'), findsOneWidget);
    expect(find.text('Riattiva'), findsNothing);

    final deactivateButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Disattiva'),
    );
    expect(deactivateButton.onPressed, isNotNull);

    expect(tester.takeException(), isNull);
  });
  testWidgets(
  'reactivates botanical classification without confirmation and reloads taxonomy',
  (tester) async {
    var loadCalls = 0;
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);
        loadCalls += 1;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': loadCalls > 1,
            'row_version': loadCalls == 1 ? 2 : 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': loadCalls == 1
                ? '2026-10-04T07:00:00+00:00'
                : '2026-10-04T08:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'set_botanical_taxon_active');
        expect(parameters, {
          'target_botanical_taxon_id':
              '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 2,
          'taxon_is_active': true,
        });

        return {
          'status': 'active_changed',
          'botanical_taxon_id':
              '11111111-1111-4111-8111-111111111111',
          'is_active': true,
          'row_version': 3,
          'updated_at': '2026-10-04T08:00:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);
    expect(writeCalls, 0);
    expect(find.text('Inattiva'), findsOneWidget);
    expect(find.text('Riattiva'), findsOneWidget);

    await tester.tap(find.text('Riattiva'));
    await tester.pumpAndSettle();

    // La riattivazione non richiede conferma.
    expect(
      find.text('Disattivare la classificazione botanica?'),
      findsNothing,
    );

    // Una sola scrittura e reload autorevole.
    expect(writeCalls, 1);
    expect(loadCalls, 2);

    // La UI deve riflettere lo stato riletto.
    expect(find.text('Inattiva'), findsNothing);
    expect(find.text('Riattiva'), findsNothing);
    expect(find.text('Disattiva'), findsOneWidget);

    expect(tester.takeException(), isNull);
  },
);
testWidgets(
  'blocks duplicate botanical classification activation writes while request is pending',
  (tester) async {
    var writeCalls = 0;
    final writeCompleter = Completer<Map<String, dynamic>>();

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': false,
            'row_version': 2,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-04T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'set_botanical_taxon_active');
        expect(parameters, {
          'target_botanical_taxon_id':
              '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 2,
          'taxon_is_active': true,
        });

        return writeCompleter.future;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riattiva'));
    await tester.pump();

    expect(writeCalls, 1);

// Durante la richiesta la classificazione è in stato pending:
// l'azione Riattiva non deve più essere disponibile.
expect(find.text('Riattiva'), findsNothing);
expect(find.byType(CircularProgressIndicator), findsOneWidget);

// Nessuna seconda RPC deve essere stata avviata.
expect(writeCalls, 1);

writeCompleter.complete({
      'status': 'active_changed',
      'botanical_taxon_id':
          '11111111-1111-4111-8111-111111111111',
      'is_active': true,
      'row_version': 3,
      'updated_at': '2026-10-04T08:00:00+00:00',
    });

    await tester.pumpAndSettle();

    expect(writeCalls, 1);
    expect(tester.takeException(), isNull);
  },
);

  testWidgets('explains inactive parent when taxon reactivation is blocked', (
    tester,
  ) async {
    var writeCalls = 0;

    final repository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isFalse);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': '22222222-2222-4222-8222-222222222222',
            'rank': 'SPECIES',
            'scientific_name': 'Solanum lycopersicum',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': false,
            'row_version': 3,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-04T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        writeCalls += 1;

        expect(functionName, 'set_botanical_taxon_active');
        expect(parameters, {
          'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 3,
          'taxon_is_active': true,
        });

        return {'status': 'dependency_inactive'};
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BotanicalClassificationPage(
          capabilities: const CatalogCapabilities(
            canManageIdentity: true,
            canIngest: true,
            canReview: true,
            canPublish: true,
            rowVersion: 1,
          ),
          repository: repository,
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Riattiva'), findsOneWidget);

    await tester.tap(find.text('Riattiva'));

    // Il dialog dependency_inactive viene mostrato mentre l'operazione
    // lifecycle è ancora pending.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(writeCalls, 1);

    expect(
      find.text('Impossibile riattivare la classificazione botanica'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'classificazione superiore deve essere riattivata prima',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(writeCalls, 1);

    // Durante il dialog il lifecycle resta pending.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Riattiva'), findsNothing);

    await tester.tap(find.widgetWithText(TextButton, 'OK'));
    await tester.pumpAndSettle();

    // Dopo il finally il Taxon resta inattivo e può essere nuovamente
    // sottoposto a riattivazione.
    expect(writeCalls, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Riattiva'), findsOneWidget);
    expect(find.text('Disattiva'), findsNothing);

    final reactivateButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Riattiva'),
    );
    expect(reactivateButton.onPressed, isNotNull);

    expect(tester.takeException(), isNull);
  });
  for (final testCase in [
    (
      status: 'forbidden',
      expectedMessage:
          'Non sei autorizzato a modificare lo stato della classificazione botanica.',
    ),
    (
      status: 'invalid_input',
      expectedMessage:
          'La richiesta di modifica dello stato della classificazione botanica non è valida.',
    ),
    (
      status: 'not_found',
      expectedMessage: 'La classificazione botanica non è più disponibile.',
    ),
  ]) {
    testWidgets('shows ${testCase.status} taxon activation error', (
      tester,
    ) async {
      var writeCalls = 0;

      final repository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);

          return [
            {
              'id': '11111111-1111-4111-8111-111111111111',
              'parent_taxon_id': null,
              'rank': 'GENUS',
              'scientific_name': 'Solanum',
              'authorship': null,
              'is_hybrid': false,
              'description': null,
              'is_active': false,
              'row_version': 3,
              'created_at': '2026-10-03T07:00:00+00:00',
              'updated_at': '2026-10-04T07:00:00+00:00',
            },
          ];
        },
        (functionName, parameters) async {
          writeCalls += 1;

          expect(functionName, 'set_botanical_taxon_active');
          expect(parameters, {
            'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'expected_row_version': 3,
            'taxon_is_active': true,
          });

          return {'status': testCase.status};
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BotanicalClassificationPage(
            capabilities: const CatalogCapabilities(
              canManageIdentity: true,
              canIngest: true,
              canReview: true,
              canPublish: true,
              rowVersion: 1,
            ),
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Riattiva'), findsOneWidget);

      await tester.tap(find.text('Riattiva'));

      // Il dialog di errore viene mostrato mentre il lifecycle è ancora
      // pending, quindi non usiamo pumpAndSettle() finché resta aperto.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(writeCalls, 1);
      expect(find.text('Operazione non completata'), findsOneWidget);
      expect(find.text(testCase.expectedMessage), findsOneWidget);

      // Nessun retry automatico.
      expect(writeCalls, 1);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Riattiva'), findsNothing);

      await tester.tap(find.widgetWithText(TextButton, 'OK'));
      await tester.pumpAndSettle();

      // Dopo il finally il Taxon resta inattivo e l'azione torna disponibile.
      expect(writeCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Riattiva'), findsOneWidget);
      expect(find.text('Disattiva'), findsNothing);

      final reactivateButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Riattiva'),
      );
      expect(reactivateButton.onPressed, isNotNull);

      expect(tester.takeException(), isNull);
    });
  }
}
