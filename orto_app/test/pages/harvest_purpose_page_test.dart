import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/catalog_capabilities.dart';
import 'package:orto_app/data/repositories/harvest_purpose_repository.dart';
import 'package:orto_app/pages/harvest_purpose_page.dart';

const _capabilities = CatalogCapabilities(
  canManageIdentity: true,
  canIngest: true,
  canReview: true,
  canPublish: true,
  rowVersion: 1,
);

Map<String, dynamic> _purpose({
  required String id,
  required String code,
  required String name,
  String? description,
  bool isActive = true,
}) {
  return {
    'id': id,
    'code': code,
    'name': name,
    'description': description,
    'is_active': isActive,
    'row_version': 1,
    'created_at': '2026-10-16T10:00:00Z',
    'updated_at': '2026-10-16T10:00:00Z',
  };
}

Widget _testApp(
  HarvestPurposeRepository repository, {
  CatalogCapabilities capabilities = _capabilities,
}) {
  return MaterialApp(
    home: HarvestPurposePage(
      capabilities: capabilities,
      repository: repository,
    ),
  );
}

void main() {
  group('HarvestPurposePage - attivazione stato', () {
    testWidgets('attivazione riuscita aggiorna elenco e conferma', (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-2',
              code: 'DONAZIONE',
              name: 'Donazione',
              isActive: false,
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          expect(parameters['target_harvest_purpose_id'], 'purpose-2');
          expect(parameters['expected_row_version'], 1);
          expect(parameters['context_is_active'], isTrue);

          return {
            'status': 'active_changed',
            'harvest_purpose_id': 'purpose-2',
            'is_active': true,
            'row_version': 2,
            'updated_at': '2026-10-16T10:05:00Z',
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);
      expect(find.byTooltip('Attiva finalità'), findsOneWidget);

      await tester.tap(find.byTooltip('Attiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 2);
      expect(find.text('Finalità di raccolta attivata.'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets('disattivazione riuscita aggiorna elenco e conferma', (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          expect(parameters['context_is_active'], isFalse);

          return {
            'status': 'active_changed',
            'harvest_purpose_id': 'purpose-1',
            'is_active': false,
            'row_version': 2,
            'updated_at': '2026-10-16T10:05:00Z',
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);
      expect(find.byTooltip('Disattiva finalità'), findsOneWidget);

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 2);
      expect(find.text('Finalità di raccolta disattivata.'), findsOneWidget);
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets("errore tecnico mostra messaggio e mantiene la pagina utilizzabile", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          throw StateError('Errore RPC simulato');
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(
        find.text(
          'Errore durante l’aggiornamento dello stato. Verificare e riprovare.',
        ),
        findsOneWidget,
      );
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets("active_dependents impedisce la disattivazione", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          expect(parameters['context_is_active'], isFalse);
          return {'status': 'active_dependents'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(
        find.text(
          'Impossibile disattivare la finalità: esistono elementi dipendenti.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets("not_found non ricarica automaticamente l'elenco", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          return {'status': 'not_found'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(
        find.text('La finalità non è più disponibile. Aggiornare l’elenco.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
    testWidgets("invalid_input non ricarica automaticamente l'elenco", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          return {'status': 'invalid_input'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('I dati dell’operazione non sono validi.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets("forbidden non ricarica automaticamente l'elenco", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          return {'status': 'forbidden'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Operazione non autorizzata.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
    testWidgets("conflitto di versione non ricarica automaticamente l'elenco", (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'set_harvest_purpose_active');
          return {'status': 'version_conflict', 'row_version': 2};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Disattiva finalità'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(
        find.text(
          'La finalità è stata modificata altrove. Aggiornare l’elenco.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HarvestPurposePage - conflitto modifica', () {
    testWidgets('conflitto di versione blocca ulteriori salvataggi', (
      tester,
    ) async {
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);

          return {
            'status': 'version_conflict',
            'row_version': 2,
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(
        find.textContaining('I dati sono stati modificati altrove'),
        findsOneWidget,
      );

      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Salva'),
      );
      expect(saveButton.onPressed, isNull);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(rpcCalls, 1);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - modifica', () {
    testWidgets('errore tecnico mantiene aperta la modifica', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          throw StateError('Errore tecnico simulato');
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);
      expect(
        find.text('Errore durante la modifica. Verificare e riprovare.'),
        findsOneWidget,
      );
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Finalità di raccolta modificata.'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(rpcCalls, 1);
    });
    testWidgets('not_found mantiene aperta la modifica', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          return {'status': 'not_found'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);
      expect(
        find.text(
          'La finalità non è più disponibile. Aggiornare l’elenco.',
        ),
        findsOneWidget,
      );
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Finalità di raccolta modificata.'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(rpcCalls, 1);
    });
    testWidgets('invalid_input mantiene aperta la modifica', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          expect(parameters['context_name'], 'Nome aggiornato');
          return {'status': 'invalid_input'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Nome aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);
      expect(find.text('I dati inseriti non sono validi.'), findsOneWidget);
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Finalità di raccolta modificata.'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(rpcCalls, 1);
    });
    testWidgets('forbidden mantiene aperta la modifica', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          return {'status': 'forbidden'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);
      expect(find.text('Operazione non autorizzata.'), findsOneWidget);
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Finalità di raccolta modificata.'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(rpcCalls, 1);
    });
    testWidgets('unchanged chiude senza ricaricare elenco', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: 'Consumo familiare',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          expect(parameters['context_name'], 'Consumo familiare');

          return {
            'status': 'unchanged',
            'harvest_purpose_id': 'purpose-1',
            'row_version': 1,
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Finalità di raccolta modificata.'), findsNothing);
      expect(tester.takeException(), isNull);
    });
    testWidgets('modifica riuscita conserva il codice e aggiorna elenco', (
      tester,
    ) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          return [
            _purpose(
              id: 'purpose-1',
              code: 'CONSUMO',
              name: loadCalls == 1
                  ? 'Consumo familiare'
                  : 'Consumo domestico',
              description: loadCalls == 1
                  ? 'Descrizione iniziale'
                  : 'Descrizione aggiornata',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;

          expect(functionName, 'update_harvest_purpose');
          expect(parameters['target_harvest_purpose_id'], 'purpose-1');
          expect(parameters['expected_row_version'], 1);
          expect(parameters['context_name'], 'Consumo domestico');
          expect(parameters['context_description'], 'Descrizione aggiornata');
          expect(parameters.containsKey('context_code'), isFalse);

          return {
            'status': 'updated',
            'harvest_purpose_id': 'purpose-1',
            'code': 'CONSUMO',
            'is_active': true,
            'row_version': 2,
            'updated_at': '2026-10-16T11:00:00Z',
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Modifica finalità'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica finalità di raccolta'), findsOneWidget);
      expect(find.text('Codice: CONSUMO'), findsWidgets);

      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        ' Consumo domestico ',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Descrizione'),
        ' Descrizione aggiornata ',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 2);
      expect(find.text('Consumo domestico'), findsOneWidget);
      expect(find.text('Descrizione aggiornata'), findsOneWidget);
      expect(find.text('Codice: CONSUMO'), findsOneWidget);
      expect(find.text('Modifica finalità di raccolta'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - creazione', () {
    testWidgets('non invia RPC con codice e nome vuoti', (tester) async {
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) async {
          rpcCalls++;
          return {'status': 'invalid_input'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(find.text('Codice e nome sono obbligatori.'), findsOneWidget);
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);
      expect(rpcCalls, 0);
      expect(tester.takeException(), isNull);
    });

    testWidgets('creazione riuscita aggiorna elenco', (tester) async {
      var loadCalls = 0;
      var rpcCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;

          if (loadCalls == 1) return [];

          return [
            _purpose(
              id: 'purpose-created',
              code: 'CONSUMO',
              name: 'Consumo familiare',
              description: 'Uso domestico',
            ),
          ];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          expect(parameters['context_description'], 'Uso domestico');

          return {
            'status': 'created',
            'harvest_purpose_id': 'purpose-created',
            'code': 'CONSUMO',
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-16T10:00:00Z',
          };
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Descrizione'),
        'Uso domestico',
      );

      expect(rpcCalls, 0);

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 2);
      expect(find.text('Nuova finalità di raccolta'), findsNothing);
      expect(find.text('Finalità di raccolta creata.'), findsOneWidget);
      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Codice: CONSUMO'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - codice duplicato', () {
    testWidgets('codice duplicato mantiene aperta la finestra', (tester) async {
      var rpcCalls = 0;
      var loadCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          return {'status': 'duplicate_code'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Il codice è già utilizzato.'), findsOneWidget);
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - rifiuto RPC', () {
    testWidgets('rifiuto RPC mantiene aperta la finestra', (tester) async {
      var rpcCalls = 0;
      var loadCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          return {'status': 'forbidden'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Operazione non autorizzata.'), findsOneWidget);
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - input non valido', () {
    testWidgets('invalid_input mantiene aperta la finestra', (tester) async {
      var rpcCalls = 0;
      var loadCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          return {'status': 'invalid_input'};
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('I dati inseriti non sono validi.'), findsOneWidget);
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - errore tecnico', () {
    testWidgets('errore tecnico consente un nuovo tentativo', (tester) async {
      var rpcCalls = 0;
      var loadCalls = 0;

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [];
        },
        (functionName, parameters) async {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          throw StateError('Errore tecnico simulato');
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(
        find.text('Errore durante la creazione. Verificare e riprovare.'),
        findsOneWidget,
      );
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);

      await tester.tap(find.text('Crea'));
      await tester.pumpAndSettle();

      expect(rpcCalls, 2);
      expect(loadCalls, 1);
      expect(find.text('Nuova finalità di raccolta'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - doppio invio', () {
    testWidgets('impedisce doppio invio durante RPC in corso', (tester) async {
      var rpcCalls = 0;
      var loadCalls = 0;
      final pendingRpc = Completer<dynamic>();

      final repository = HarvestPurposeRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isFalse);
          loadCalls++;
          return [];
        },
        (functionName, parameters) {
          rpcCalls++;
          expect(functionName, 'create_harvest_purpose');
          expect(parameters['context_code'], 'CONSUMO');
          expect(parameters['context_name'], 'Consumo familiare');
          return pendingRpc.future;
        },
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(loadCalls, 1);

      await tester.tap(find.byTooltip('Nuova finalità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Codice *'),
        'CONSUMO',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome *'),
        'Consumo familiare',
      );

      await tester.tap(find.text('Crea'));
      await tester.pump();

      expect(rpcCalls, 1);

      final createButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Crea'),
      );
      expect(createButton.onPressed, isNull);

      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );

      pendingRpc.complete({'status': 'forbidden'});
      await tester.pumpAndSettle();

      expect(rpcCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Operazione non autorizzata.'), findsOneWidget);

      final enabledButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Crea'),
      );
      expect(enabledButton.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - autorizzazioni', () {
    testWidgets('mostra Nuova finalità con autorizzazione', (tester) async {
      final repository = HarvestPurposeRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Nuova finalità'), findsOneWidget);
      expect(find.byTooltip('Aggiorna elenco'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('nasconde Nuova finalità senza autorizzazione', (tester) async {
      const readOnlyCapabilities = CatalogCapabilities(
        canManageIdentity: false,
        canIngest: true,
        canReview: true,
        canPublish: true,
        rowVersion: 1,
      );

      final repository = HarvestPurposeRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      await tester.pumpWidget(
        _testApp(repository, capabilities: readOnlyCapabilities),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Nuova finalità'), findsNothing);
      expect(find.byTooltip('Aggiorna elenco'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
  group('HarvestPurposePage - autorizzazioni gestione', () {
    testWidgets(
      'comandi di gestione visibili solo con autorizzazione',
      (tester) async {
        var rpcCalls = 0;

        final repository = HarvestPurposeRepository.withProviders(
          ({bool activeOnly = true}) async {
            expect(activeOnly, isFalse);
            return [
              _purpose(
                id: 'purpose-1',
                code: 'CONSUMO',
                name: 'Consumo familiare',
              ),
            ];
          },
          (functionName, parameters) async {
            rpcCalls++;
            throw StateError('Scrittura RPC non prevista');
          },
        );

        await tester.pumpWidget(_testApp(repository));
        await tester.pumpAndSettle();

        expect(find.text('Consumo familiare'), findsOneWidget);
        expect(find.byTooltip('Modifica finalità'), findsOneWidget);
        expect(find.byTooltip('Disattiva finalità'), findsOneWidget);
        expect(rpcCalls, 0);

        const readOnlyCapabilities = CatalogCapabilities(
          canManageIdentity: false,
          canIngest: true,
          canReview: true,
          canPublish: true,
          rowVersion: 1,
        );

        await tester.pumpWidget(
          _testApp(
            repository,
            capabilities: readOnlyCapabilities,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Consumo familiare'), findsOneWidget);
        expect(find.byTooltip('Modifica finalità'), findsNothing);
        expect(find.byTooltip('Disattiva finalità'), findsNothing);
        expect(find.byTooltip('Attiva finalità'), findsNothing);
        expect(rpcCalls, 0);
        expect(tester.takeException(), isNull);
      },
    );
  });
  group('HarvestPurposePage - lettura', () {
    testWidgets('mostra il caricamento iniziale', (tester) async {
      final completer = Completer<List<Map<String, dynamic>>>();

      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) {
        expect(activeOnly, isFalse);
        return completer.future;
      });

      await tester.pumpWidget(_testApp(repository));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra un messaggio quando non ci sono finalità', (
      tester,
    ) async {
      final repository = HarvestPurposeRepository.withLoader(
        ({bool activeOnly = true}) async => [],
      );

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Nessuna finalità di raccolta presente.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mostra finalità attive e inattive', (tester) async {
      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        expect(activeOnly, isFalse);

        return [
          _purpose(
            id: 'purpose-1',
            code: 'CONSUMO',
            name: 'Consumo familiare',
            description: 'Destinata alla famiglia',
          ),
          _purpose(
            id: 'purpose-2',
            code: 'DONAZIONE',
            name: 'Donazione',
            isActive: false,
          ),
        ];
      });

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Consumo familiare'), findsOneWidget);
      expect(find.text('Codice: CONSUMO'), findsOneWidget);
      expect(find.text('Destinata alla famiglia'), findsOneWidget);
      expect(find.text('Donazione'), findsOneWidget);
      expect(find.text('Codice: DONAZIONE'), findsOneWidget);
      expect(find.text('Attiva'), findsOneWidget);
      expect(find.text('Non attiva'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('gestisce un errore di caricamento e permette di riprovare', (
      tester,
    ) async {
      var calls = 0;

      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        calls++;

        if (calls == 1) {
          throw StateError('Errore di lettura simulato');
        }

        return [];
      });

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.text('Errore durante il caricamento delle finalità di raccolta.'),
        findsOneWidget,
      );
      expect(calls, 1);

      await tester.tap(find.text('Riprova'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(
        find.text('Nessuna finalità di raccolta presente.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('aggiorna manualmente l’elenco', (tester) async {
      var calls = 0;

      final repository = HarvestPurposeRepository.withLoader(({
        bool activeOnly = true,
      }) async {
        expect(activeOnly, isFalse);
        calls++;

        if (calls == 1) {
          return [];
        }

        return [
          _purpose(
            id: 'purpose-3',
            code: 'CONSERVAZIONE',
            name: 'Conservazione',
          ),
        ];
      });

      await tester.pumpWidget(_testApp(repository));
      await tester.pumpAndSettle();

      expect(calls, 1);
      expect(
        find.text('Nessuna finalità di raccolta presente.'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Aggiorna elenco'));
      await tester.pumpAndSettle();

      expect(calls, 2);
      expect(find.text('Conservazione'), findsOneWidget);
      expect(find.text('Codice: CONSERVAZIONE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
