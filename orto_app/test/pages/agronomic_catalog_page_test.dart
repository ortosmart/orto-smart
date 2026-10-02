import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/repositories/catalog_authority_repository.dart';
import 'package:orto_app/data/repositories/botanical_taxon_repository.dart';
import 'package:orto_app/data/repositories/crop_repository.dart';
import 'package:orto_app/data/repositories/crop_cultivar_repository.dart';
import 'package:orto_app/pages/agronomic_catalog_page.dart';

Widget _testApp({
  required CatalogAuthorityRepository repository,
  BotanicalTaxonRepository? taxonRepository,
  CropRepository? cropRepository,
  CropCultivarRepository? cultivarRepository,
}) {
  final effectiveTaxonRepository =
      taxonRepository ??
      BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async => [],
        (functionName, parameters) =>
            throw UnsupportedError('Taxon write not expected in UI test'),
      );
  final effectiveCropRepository =
      cropRepository ??
      CropRepository.withLoader(({bool activeOnly = true}) async => []);

  final effectiveCultivarRepository =
      cultivarRepository ??
      CropCultivarRepository.withLoader(
        ({String? cropId, bool activeOnly = true}) async => [],
      );

  return MaterialApp(
    home: AgronomicCatalogPage(
      repository: repository,
      taxonRepository: effectiveTaxonRepository,
      cropRepository: effectiveCropRepository,
      cultivarRepository: effectiveCultivarRepository,
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
  testWidgets('shows empty botanical taxonomy when authority is initialized', (
    tester,
  ) async {
    var taxonLoads = 0;

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

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isTrue);
        return [];
      },
      (functionName, parameters) =>
          throw UnsupportedError('Taxon write not expected in UI test'),
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(taxonLoads, 1);
    expect(find.text('Tassonomia botanica'), findsOneWidget);
    expect(
      find.text('Nessun taxon presente nella tassonomia botanica.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows botanical taxa returned by the global taxonomy', (
    tester,
  ) async {
    var taxonLoads = 0;

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

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isTrue);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'FAMILY',
            'scientific_name': 'Solanaceae',
            'authorship': null,
            'is_hybrid': false,
            'description': null,
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-02T08:00:00+00:00',
            'updated_at': '2026-10-02T08:00:00+00:00',
          },
          {
            'id': '22222222-2222-4222-8222-222222222222',
            'parent_taxon_id': '11111111-1111-4111-8111-111111111111',
            'rank': 'SPECIES',
            'scientific_name': 'Solanum lycopersicum',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Pomodoro',
            'is_active': true,
            'row_version': 1,
            'created_at': '2026-10-02T08:00:00+00:00',
            'updated_at': '2026-10-02T08:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) =>
          throw UnsupportedError('Taxon write not expected in UI test'),
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(taxonLoads, 1);
    expect(find.text('Tassonomia botanica'), findsOneWidget);

    expect(find.text('Solanaceae'), findsOneWidget);
    expect(find.text('FAMILY'), findsOneWidget);

    expect(find.text('Solanum lycopersicum'), findsOneWidget);
    expect(find.text('SPECIES · L.'), findsOneWidget);

    expect(
      find.text('Nessun taxon presente nella tassonomia botanica.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows error when loading botanical taxonomy fails', (
    tester,
  ) async {
    var taxonLoads = 0;

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

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isTrue);
        throw Exception('Errore caricamento tassonomia');
      },
      (functionName, parameters) =>
          throw UnsupportedError('Taxon write not expected in UI test'),
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(taxonLoads, 1);
    expect(find.text('Tassonomia botanica'), findsOneWidget);
    expect(
      find.text('Errore durante il caricamento della tassonomia botanica.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows crops returned by the global catalog', (tester) async {
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

      return [
        {
          'crop_id': '33333333-3333-4333-8333-333333333333',
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    await tester.pumpWidget(
      _testApp(repository: authorityRepository, cropRepository: cropRepository),
    );
    await tester.pumpAndSettle();

    expect(cropLoads, 1);
    expect(find.text('Colture'), findsOneWidget);
    expect(find.text('Pomodoro'), findsOneWidget);
    expect(find.text('Solanum lycopersicum'), findsOneWidget);
    expect(find.text('Solanaceae'), findsOneWidget);
    expect(
      find.text('Nessuna coltura presente nel Catalogo Agronomico.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows crop when scientific name and family are missing', (
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

      return [
        {
          'crop_id': '44444444-4444-4444-8444-444444444444',
          'canonical_name': 'Coltura senza tassonomia',
          'description': null,
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': null,
          'taxon_rank': null,
          'taxon_scientific_name': null,
          'family_taxon_id': null,
          'family_scientific_name': null,
        },
      ];
    });

    await tester.pumpWidget(
      _testApp(repository: authorityRepository, cropRepository: cropRepository),
    );
    await tester.pumpAndSettle();

    expect(cropLoads, 1);
    expect(find.text('Colture'), findsOneWidget);
    expect(find.text('Coltura senza tassonomia'), findsOneWidget);
    expect(
      find.text('Nessuna coltura presente nel Catalogo Agronomico.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('loads cultivars for the selected crop', (tester) async {
    const cropId = '33333333-3333-4333-8333-333333333333';

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
      return [
        {
          'crop_id': cropId,
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    var cultivarLoads = 0;
    String? requestedCropId;

    final cultivarRepository = CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      cultivarLoads += 1;
      requestedCropId = cropId;

      expect(activeOnly, isTrue);

      return [];
    });

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        cropRepository: cropRepository,
        cultivarRepository: cultivarRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pomodoro'), findsOneWidget);
    expect(cultivarLoads, 0);

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    expect(cultivarLoads, 1);
    expect(requestedCropId, cropId);
  });
  testWidgets('shows empty cultivars state for the selected crop', (
    tester,
  ) async {
    const cropId = '33333333-3333-4333-8333-333333333333';

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
      return [
        {
          'crop_id': cropId,
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    final cultivarRepository = CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      expect(cropId, '33333333-3333-4333-8333-333333333333');
      expect(activeOnly, isTrue);
      return [];
    });

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        cropRepository: cropRepository,
        cultivarRepository: cultivarRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    expect(find.text('Cultivar di Pomodoro'), findsOneWidget);
    expect(find.text('Nessuna cultivar presente.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows cultivars for the selected crop', (tester) async {
    const cropId = '33333333-3333-4333-8333-333333333333';

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
      expect(activeOnly, isTrue);

      return [
        {
          'crop_id': cropId,
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    final cultivarRepository = CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      expect(cropId, '33333333-3333-4333-8333-333333333333');
      expect(activeOnly, isTrue);

      return [
        {
          'cultivar_id': '44444444-4444-4444-8444-444444444444',
          'crop_id': cropId,
          'crop_canonical_name': 'Pomodoro',
          'canonical_name': 'San Marzano',
          'verification_status': 'REVIEW',
          'description': 'Cultivar di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
        },
      ];
    });

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        cropRepository: cropRepository,
        cultivarRepository: cultivarRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pomodoro'), findsOneWidget);

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    expect(find.text('Cultivar di Pomodoro'), findsOneWidget);
    expect(find.text('San Marzano'), findsOneWidget);
    expect(find.text('REVIEW · Cultivar di prova'), findsOneWidget);
    expect(find.text('Nessuna cultivar presente.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('shows error when loading cultivars fails', (tester) async {
    const cropId = '33333333-3333-4333-8333-333333333333';

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
      expect(activeOnly, isTrue);

      return [
        {
          'crop_id': cropId,
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    final cultivarRepository = CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      expect(cropId, '33333333-3333-4333-8333-333333333333');
      expect(activeOnly, isTrue);

      throw Exception('Errore caricamento cultivar');
    });

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        cropRepository: cropRepository,
        cultivarRepository: cultivarRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pomodoro'), findsOneWidget);

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    expect(
      find.text('Errore durante il caricamento delle cultivar.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('retries cultivar loading after an error', (tester) async {
    const cropId = '33333333-3333-4333-8333-333333333333';
    var cultivarLoads = 0;

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
      expect(activeOnly, isTrue);

      return [
        {
          'crop_id': cropId,
          'canonical_name': 'Pomodoro',
          'description': 'Coltura di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
          'taxon_id': '22222222-2222-4222-8222-222222222223',
          'taxon_rank': 'SPECIES',
          'taxon_scientific_name': 'Solanum lycopersicum',
          'family_taxon_id': '22222222-2222-4222-8222-222222222222',
          'family_scientific_name': 'Solanaceae',
        },
      ];
    });

    final cultivarRepository = CropCultivarRepository.withLoader(({
      String? cropId,
      bool activeOnly = true,
    }) async {
      cultivarLoads += 1;

      expect(cropId, '33333333-3333-4333-8333-333333333333');
      expect(activeOnly, isTrue);

      if (cultivarLoads == 1) {
        throw Exception('Errore caricamento cultivar');
      }

      return [
        {
          'cultivar_id': '44444444-4444-4444-8444-444444444444',
          'crop_id': cropId,
          'crop_canonical_name': 'Pomodoro',
          'canonical_name': 'San Marzano',
          'verification_status': 'VERIFIED',
          'description': 'Cultivar di prova',
          'is_active': true,
          'row_version': 1,
          'created_at': '2026-09-29T08:00:00+00:00',
          'updated_at': '2026-09-29T08:00:00+00:00',
        },
      ];
    });

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        cropRepository: cropRepository,
        cultivarRepository: cultivarRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pomodoro'));
    await tester.pumpAndSettle();

    expect(cultivarLoads, 1);
    expect(
      find.text('Errore durante il caricamento delle cultivar.'),
      findsOneWidget,
    );
    expect(find.text('Riprova'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();

    expect(cultivarLoads, 2);
    expect(
      find.text('Errore durante il caricamento delle cultivar.'),
      findsNothing,
    );
    expect(find.text('Cultivar di Pomodoro'), findsOneWidget);
    expect(find.text('San Marzano'), findsOneWidget);
    expect(find.text('Cultivar di prova'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
