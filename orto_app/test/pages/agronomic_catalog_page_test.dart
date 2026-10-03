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
      find.text('Nessuna voce presente nella tassonomia botanica.'),
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
      find.text('Nessuna voce presente nella tassonomia botanica.'),
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
  testWidgets(
    'hides create taxon action without identity management capability',
    (tester) async {
      final authorityRepository = CatalogAuthorityRepository.withInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'get_my_catalog_capabilities');
        expect(parameters, isEmpty);

        return {
          'status': 'ok',
          'can_manage_identity': false,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 1,
        };
      });

      await tester.pumpWidget(_testApp(repository: authorityRepository));
      await tester.pumpAndSettle();

      expect(find.text('Tassonomia botanica'), findsOneWidget);
      expect(find.text('Nuova voce botanica'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'shows create taxon action and opens dialog with identity capability',
    (tester) async {
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

      await tester.pumpWidget(_testApp(repository: authorityRepository));
      await tester.pumpAndSettle();

      expect(find.text('Nuova voce botanica'), findsOneWidget);

      await tester.tap(find.text('Nuova voce botanica'));
      await tester.pumpAndSettle();

      expect(find.text('Nuova voce botanica'), findsNWidgets(2));
      expect(find.text('Rango'), findsOneWidget);
      expect(find.text('Nome scientifico'), findsOneWidget);
      expect(find.text('Autore'), findsOneWidget);
      expect(find.text('Classificazione superiore'), findsOneWidget);
      expect(find.text('Ibrido'), findsOneWidget);
      expect(find.text('Descrizione'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(find.text('Crea'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('requires scientific name before creating a taxon', (
    tester,
  ) async {
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

    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        return [];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(writeCalls, 0);
    expect(find.text('Il nome scientifico è obbligatorio.'), findsOneWidget);
    expect(find.text('Crea'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('creates a taxon with expected parameters and reloads taxonomy', (
    tester,
  ) async {
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

    var taxonLoads = 0;
    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isTrue);

        if (taxonLoads == 1) {
          return [];
        }

        return [
          {
            'id': '22222222-2222-4222-8222-222222222222',
            'parent_taxon_id': null,
            'rank': 'FAMILY',
            'scientific_name': 'Solanaceae',
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
          'target_parent_taxon_id': null,
          'taxon_rank': 'FAMILY',
          'taxon_scientific_name': 'Solanaceae',
          'taxon_authorship': null,
          'taxon_is_hybrid': false,
          'taxon_description': null,
        });

        return {
          'status': 'created',
          'botanical_taxon_id': '22222222-2222-4222-8222-222222222222',
          'row_version': 1,
          'created_at': '2026-10-03T07:00:00+00:00',
          'updated_at': '2026-10-03T07:00:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(taxonLoads, 1);
    expect(
      find.text('Nessuna voce presente nella tassonomia botanica.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Nuova voce botanica'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SPECIES'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('FAMILY').last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Nome scientifico'),
      'Solanaceae',
    );

    await tester.tap(find.text('Crea'));
    await tester.pumpAndSettle();

    expect(writeCalls, 1);
    expect(taxonLoads, 2);

    expect(find.text('Nuova voce botanica'), findsOneWidget);
    expect(find.text('Solanaceae'), findsOneWidget);
    expect(find.text('FAMILY'), findsOneWidget);
    expect(
      find.text('Nessuna voce presente nella tassonomia botanica.'),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps create taxon dialog open on duplicate identity', (
    tester,
  ) async {
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

    var taxonLoads = 0;
    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads += 1;
        expect(activeOnly, isTrue);
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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
  });
  testWidgets(
    'shows dependency inactive when selected parent taxon is inactive',
    (tester) async {
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

      var taxonLoads = 0;
      var writeCalls = 0;

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          taxonLoads += 1;
          expect(activeOnly, isTrue);

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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
  testWidgets('cancels create taxon without calling write path', (
    tester,
  ) async {
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

    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        return [];
      },
      (functionName, parameters) async {
        writeCalls += 1;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
  });
  testWidgets(
    'prevents duplicate create taxon submission while rpc is pending',
    (tester) async {
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

      var taxonLoads = 0;
      var writeCalls = 0;

      final rpcCompleter = Completer<Map<String, dynamic>>();

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          taxonLoads += 1;
          expect(activeOnly, isTrue);

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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
    'hides edit taxon action without identity management capability',
    (tester) async {
      final authorityRepository = CatalogAuthorityRepository.withInvoker((
        functionName,
        parameters,
      ) async {
        expect(functionName, 'get_my_catalog_capabilities');
        expect(parameters, isEmpty);

        return {
          'status': 'ok',
          'can_manage_identity': false,
          'can_ingest': true,
          'can_review': true,
          'can_publish': true,
          'row_version': 1,
        };
      });

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Solanum'), findsOneWidget);
      expect(find.text('Modifica'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('shows edit taxon action with identity management capability', (
    tester,
  ) async {
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
        expect(activeOnly, isTrue);

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Solanum'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('opens edit taxon dialog with existing values', (tester) async {
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
        expect(activeOnly, isTrue);

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': 'Solanum',
            'authorship': 'L.',
            'is_hybrid': true,
            'description': 'Genere botanico di prova',
            'is_active': true,
            'row_version': 7,
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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    final scientificNameField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Nome scientifico'),
    );
    expect(scientificNameField.initialValue, 'Solanum');

    final authorshipField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Autore'),
    );
    expect(authorshipField.initialValue, 'L.');

    final descriptionField = tester.widget<TextFormField>(
      find.widgetWithText(TextFormField, 'Descrizione'),
    );
    expect(descriptionField.initialValue, 'Genere botanico di prova');

    final rankField = tester.widget<DropdownButtonFormField<String>>(
      find.widgetWithText(DropdownButtonFormField<String>, 'Rango'),
    );
    expect(rankField.initialValue, 'GENUS');

    final hybridCheckbox = tester.widget<CheckboxListTile>(
      find.widgetWithText(CheckboxListTile, 'Ibrido'),
    );
    expect(hybridCheckbox.value, isTrue);

    expect(find.text('Salva'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('edit taxon excludes itself from parent choices', (tester) async {
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
        expect(activeOnly, isTrue);

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    final solanumTile = find.ancestor(
      of: find.text('Solanum'),
      matching: find.byType(ListTile),
    );

    await tester.tap(
      find.descendant(of: solanumTile, matching: find.text('Modifica')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    await tester.tap(find.text('Nessuno'));
    await tester.pumpAndSettle();

    expect(find.text('GENUS · Capsicum'), findsOneWidget);
    expect(find.text('GENUS · Solanum'), findsNothing);

    expect(tester.takeException(), isNull);
  });
  testWidgets('updates taxon with original row version and reloads taxonomy', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

        return [
          {
            'id': '11111111-1111-4111-8111-111111111111',
            'parent_taxon_id': null,
            'rank': 'GENUS',
            'scientific_name': loadCalls == 1
                ? 'Solanum'
                : 'Solanum aggiornato',
            'authorship': 'L.',
            'is_hybrid': false,
            'description': 'Descrizione originale',
            'is_active': true,
            'row_version': loadCalls == 1 ? 7 : 8,
            'created_at': '2026-10-03T07:00:00+00:00',
            'updated_at': '2026-10-03T07:00:00+00:00',
          },
        ];
      },
      (functionName, parameters) async {
        updateCalls++;

        expect(functionName, 'update_botanical_taxon');
        expect(parameters, {
          'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
          'expected_row_version': 7,
          'target_parent_taxon_id': null,
          'taxon_rank': 'GENUS',
          'taxon_scientific_name': 'Solanum aggiornato',
          'taxon_authorship': 'L.',
          'taxon_is_hybrid': false,
          'taxon_description': 'Descrizione originale',
        });

        return {
          'status': 'updated',
          'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
          'row_version': 8,
          'updated_at': '2026-10-03T08:00:00+00:00',
        };
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(loadCalls, 1);

    await tester.tap(find.text('Modifica'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome scientifico'),
      'Solanum aggiornato',
    );

    await tester.ensureVisible(find.text('Salva'));
    await tester.tap(find.text('Salva'));
    await tester.pumpAndSettle();

    expect(updateCalls, 1);

    // Dopo il successo il dialog deve essere chiuso.
    expect(find.text('Modifica classificazione botanica'), findsNothing);

    // La tassonomia deve essere riletta dal repository.
    expect(loadCalls, 2);

    // La UI deve mostrare il valore restituito dalla nuova lettura.
    expect(find.text('Solanum aggiornato'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'closes edit dialog and reloads taxonomy when update is unchanged',
    (tester) async {
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

      var loadCalls = 0;
      var updateCalls = 0;

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);
          loadCalls++;

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
          updateCalls++;

          expect(functionName, 'update_botanical_taxon');
          expect(parameters, {
            'target_botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
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
            'botanical_taxon_id': '11111111-1111-4111-8111-111111111111',
            'row_version': 7,
            'updated_at': '2026-10-03T07:00:00+00:00',
          };
        },
      );

      await tester.pumpWidget(
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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
      expect(find.text('Modifica classificazione botanica'), findsNothing);

      // Dopo il successo rileggiamo sempre lo stato autorevole dal DB.
      expect(loadCalls, 2);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('keeps edit dialog open and preserves data on version conflict', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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

    // Il conflitto non deve chiudere il dialog.
    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico: non vogliamo perdere i dati locali.
    expect(loadCalls, 1);

    // Il valore digitato dall'utente deve rimanere nel campo.
    expect(find.text('Solanum modificato localmente'), findsOneWidget);

    expect(
      find.text(
        'La classificazione botanica è stata modificata nel frattempo. '
        'Ricarica i dati prima di effettuare una nuova modifica.',
      ),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps edit dialog open when update taxon is forbidden', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text(
        'Non sei autorizzato a modificare la classificazione botanica.',
      ),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps edit dialog open when update taxon has invalid input', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text('I dati inseriti non sono validi. Controlla i campi.'),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps edit dialog open when update taxon is not found', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text('La voce botanica da modificare non è più disponibile.'),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  });
  testWidgets('keeps edit dialog open when update taxon parent is not found', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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

    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico.
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
  });
  testWidgets('keeps edit dialog open when update taxon parent is inactive', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var updateCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        updateCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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

    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    // Nessun reload automatico.
    expect(loadCalls, 1);

    expect(
      find.text('La classificazione superiore selezionata non è attiva.'),
      findsOneWidget,
    );

    // Nessun retry automatico.
    expect(updateCalls, 1);

    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'keeps edit dialog open when update taxon has duplicate identity',
    (tester) async {
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

      var loadCalls = 0;
      var updateCalls = 0;

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);
          loadCalls++;

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
          updateCalls++;

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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

      expect(find.text('Modifica classificazione botanica'), findsOneWidget);

      // Nessun reload automatico.
      expect(loadCalls, 1);

      expect(
        find.text('Esiste già una voce con questa classificazione botanica.'),
        findsOneWidget,
      );

      // Nessun retry automatico.
      expect(updateCalls, 1);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('cancels edit taxon without calling write path', (tester) async {
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

    var loadCalls = 0;
    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        writeCalls++;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsNothing);

    // La pagina principale rimane disponibile.
    expect(find.text('Modifica'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
  testWidgets('requires scientific name when editing taxon', (tester) async {
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

    var loadCalls = 0;
    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        writeCalls++;
        throw StateError('RPC non prevista');
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsOneWidget);

    expect(find.text('Il nome scientifico è obbligatorio.'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
  testWidgets('prevents duplicate edit taxon submission while rpc is pending', (
    tester,
  ) async {
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

    var taxonLoads = 0;
    var writeCalls = 0;

    final rpcCompleter = Completer<Map<String, dynamic>>();

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        taxonLoads++;
        expect(activeOnly, isTrue);

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
        writeCalls++;

        expect(functionName, 'update_botanical_taxon');
        expect(
          parameters['target_botanical_taxon_id'],
          '11111111-1111-4111-8111-111111111111',
        );
        expect(parameters['expected_row_version'], 7);
        expect(parameters['taxon_scientific_name'], 'Solanum aggiornato');

        return rpcCompleter.future;
      },
    );

    await tester.pumpWidget(
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
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
    expect(find.text('Modifica classificazione botanica'), findsNothing);

    // Il valore riletto dal DB deve essere visualizzato.
    expect(find.text('Solanum aggiornato'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
  testWidgets('blocks retry when edit taxon write outcome is uncertain', (
    tester,
  ) async {
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

    var loadCalls = 0;
    var writeCalls = 0;

    final taxonRepository = BotanicalTaxonRepository.withProviders(
      ({bool activeOnly = true}) async {
        expect(activeOnly, isTrue);
        loadCalls++;

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
        writeCalls++;

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
      _testApp(
        repository: authorityRepository,
        taxonRepository: taxonRepository,
      ),
    );
    await tester.pumpAndSettle();

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
      find.byType(FilledButton).last,
    );
    expect(saveButton.onPressed, isNull);

    // Annulla deve invece tornare disponibile per uscire dal dialog.
    final cancelButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Annulla'),
    );
    expect(cancelButton.onPressed, isNotNull);

    expect(writeCalls, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'reloads taxonomy after closing edit dialog with uncertain write outcome',
    (tester) async {
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

      var loadCalls = 0;
      var writeCalls = 0;

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);
          loadCalls++;

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
          writeCalls++;

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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

      // L'errore incerto non deve provocare un reload mentre
      // il dialog conserva ancora i dati locali.
      expect(writeCalls, 1);
      expect(loadCalls, 1);
      expect(find.text('Solanum modificato localmente'), findsOneWidget);

      // L'utente chiude il dialog.
      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      // Nessuna seconda scrittura.
      expect(writeCalls, 1);

      // Solo dopo la chiusura rileggiamo lo stato autoritativo dal DB.
      expect(loadCalls, 2);

      expect(find.text('Modifica classificazione botanica'), findsNothing);

      expect(find.text('Solanum salvato dal server'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'blocks retry and reloads taxonomy after closing edit dialog on version conflict',
    (tester) async {
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

      var loadCalls = 0;
      var updateCalls = 0;

      final taxonRepository = BotanicalTaxonRepository.withProviders(
        ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);
          loadCalls++;

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
          updateCalls++;

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
        _testApp(
          repository: authorityRepository,
          taxonRepository: taxonRepository,
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

      // Dopo un version conflict non deve essere possibile inviare
      // una seconda scrittura con il row_version ormai obsoleto.
      final saveButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Salva'),
      );
      expect(saveButton.onPressed, isNull);

      // La chiusura del dialog deve invece restare disponibile.
      final cancelButton = tester.widget<TextButton>(
        find.widgetWithText(TextButton, 'Annulla'),
      );
      expect(cancelButton.onPressed, isNotNull);

      // Nessun retry automatico.
      expect(updateCalls, 1);

      await tester.tap(find.widgetWithText(TextButton, 'Annulla'));
      await tester.pumpAndSettle();

      // Solo dopo la chiusura rileggiamo lo stato autoritativo dal DB.
      expect(updateCalls, 1);
      expect(loadCalls, 2);

      expect(find.text('Modifica classificazione botanica'), findsNothing);
      expect(find.text('Solanum aggiornato da altro utente'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );
}
