import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/data/models/agronomic_parameter.dart';
import 'package:orto_app/data/models/catalog_capabilities.dart';
import 'package:orto_app/data/repositories/agronomic_parameter_repository.dart';
import 'package:orto_app/data/repositories/measurement_unit_repository.dart';
import 'package:orto_app/pages/agronomic_parameters_page.dart';
import 'package:orto_app/core/write_authority/agronomic_parameter_write_result.dart';
import 'package:orto_app/data/models/measurement_unit.dart';

final _fixedDate = DateTime.utc(2026, 9, 20);

CatalogCapabilities _capabilities({required bool canManage}) {
  return CatalogCapabilities(
    canManageIdentity: canManage,
    canIngest: false,
    canReview: false,
    canPublish: false,
    rowVersion: 1,
  );
}

AgronomicParameter _parameter({
  String id = 'parameter-1',
  String code = 'TEST_BOOLEAN',
  String name = 'Parametro booleano',
  bool active = true,
  int rowVersion = 1,
}) {
  return AgronomicParameter(
    id: id,
    code: code,
    name: name,
    description: null,
    valueSchema: 'BOOLEAN',
    knowledgeScope: 'INTRINSIC',
    quantityKind: null,
    canonicalUnitId: null,
    allowsCrop: true,
    allowsCultivar: false,
    allowsProductionContext: false,
    allowsProtectionContext: false,
    allowsTrainingContext: false,
    allowsHarvestPurpose: false,
    isActive: active,
    rowVersion: rowVersion,
    createdAt: _fixedDate,
    updatedAt: _fixedDate,
  );
}

Map<String, dynamic> _parameterToMap(AgronomicParameter parameter) => {
  'id': parameter.id,
  'code': parameter.code,
  'name': parameter.name,
  'description': parameter.description,
  'value_schema': parameter.valueSchema,
  'knowledge_scope': parameter.knowledgeScope,
  'quantity_kind': parameter.quantityKind,
  'canonical_unit_id': parameter.canonicalUnitId,
  'allows_crop': parameter.allowsCrop,
  'allows_cultivar': parameter.allowsCultivar,
  'allows_production_context': parameter.allowsProductionContext,
  'allows_protection_context': parameter.allowsProtectionContext,
  'allows_training_context': parameter.allowsTrainingContext,
  'allows_harvest_purpose': parameter.allowsHarvestPurpose,
  'is_active': parameter.isActive,
  'row_version': parameter.rowVersion,
  'created_at': parameter.createdAt.toIso8601String(),
  'updated_at': parameter.updatedAt.toIso8601String(),
};

class _FakeAgronomicParameterRepository extends AgronomicParameterRepository {
  _FakeAgronomicParameterRepository({
    List<AgronomicParameter> parameters = const [],
    this.loadError,
  }) : super.withLoader(({bool activeOnly = true}) async {
         if (loadError != null) throw loadError;

         return parameters
             .where((parameter) => !activeOnly || parameter.isActive)
             .map(_parameterToMap)
             .toList();
       });

  final Object? loadError;
  UpdateAgronomicParameterResult? updateResultOverride;
  CreateAgronomicParameterResult? createResultOverride;
  int createCallCount = 0;
  String? lastCreatedCode;
  String? lastCreatedName;
  String? lastCreatedDescription;
  String? lastCreatedValueSchema;
  String? lastCreatedKnowledgeScope;
  bool? lastCreatedAllowsCrop;
  bool? lastCreatedAllowsCultivar;

  @override
  Future<CreateAgronomicParameterResult> createAgronomicParameter({
    required String code,
    required String name,
    String? description,
    required String valueSchema,
    required String knowledgeScope,
    String? quantityKind,
    String? canonicalUnitId,
    required bool allowsCrop,
    required bool allowsCultivar,
    required bool allowsProductionContext,
    required bool allowsProtectionContext,
    required bool allowsTrainingContext,
    required bool allowsHarvestPurpose,
  }) async {
    createCallCount++;
    lastCreatedCode = code;
    lastCreatedName = name;
    lastCreatedDescription = description;
    lastCreatedValueSchema = valueSchema;
    lastCreatedKnowledgeScope = knowledgeScope;
    lastCreatedAllowsCrop = allowsCrop;
    lastCreatedAllowsCultivar = allowsCultivar;

    return createResultOverride ??
        AgronomicParameterCreated(
          agronomicParameterId: 'created-parameter-1',
          code: code,
          isActive: true,
          rowVersion: 1,
          createdAt: _fixedDate,
        );
  }

  int setActiveCallCount = 0;
  String? lastSetActiveParameterId;
  int? lastSetActiveExpectedRowVersion;
  bool? lastSetActiveValue;

  SetAgronomicParameterActiveResult? setActiveResultOverride;

  @override
  Future<SetAgronomicParameterActiveResult> setAgronomicParameterActive({
    required String agronomicParameterId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    setActiveCallCount++;
    lastSetActiveParameterId = agronomicParameterId;
    lastSetActiveExpectedRowVersion = expectedRowVersion;
    lastSetActiveValue = isActive;

    return setActiveResultOverride ??
        AgronomicParameterActiveChanged(
          agronomicParameterId: agronomicParameterId,
          isActive: isActive,
          rowVersion: expectedRowVersion + 1,
          updatedAt: _fixedDate,
        );
  }

  int updateCallCount = 0;
  String? lastUpdatedParameterId;
  int? lastExpectedRowVersion;
  String? lastUpdatedCode;
  String? lastUpdatedName;

  @override
  Future<UpdateAgronomicParameterResult> updateAgronomicParameter({
    required String agronomicParameterId,
    required int expectedRowVersion,
    required String code,
    required String name,
    String? description,
    required String valueSchema,
    required String knowledgeScope,
    String? quantityKind,
    String? canonicalUnitId,
    required bool allowsCrop,
    required bool allowsCultivar,
    required bool allowsProductionContext,
    required bool allowsProtectionContext,
    required bool allowsTrainingContext,
    required bool allowsHarvestPurpose,
  }) async {
    updateCallCount++;
    lastUpdatedParameterId = agronomicParameterId;
    lastExpectedRowVersion = expectedRowVersion;
    lastUpdatedCode = code;
    lastUpdatedName = name;

    return updateResultOverride ??
        AgronomicParameterUpdated(
          agronomicParameterId: agronomicParameterId,
          code: code,
          isActive: true,
          rowVersion: expectedRowVersion + 1,
          updatedAt: _fixedDate,
        );
  }
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _FakeAgronomicParameterRepository repository,
  bool canManage = true,
  List<MeasurementUnit> measurementUnits = const [],
}) async {
  final unitRepository = MeasurementUnitRepository.withLoader(({
    bool activeOnly = true,
  }) async {
    return measurementUnits
        .where((unit) => !activeOnly || unit.isActive)
        .map(
          (unit) => <String, dynamic>{
            'id': unit.id,
            'code': unit.code,
            'name': unit.name,
            'symbol': unit.symbol,
            'quantity_kind': unit.quantityKind,
            'to_base_factor': unit.toBaseFactor,
            'to_base_offset': unit.toBaseOffset,
            'description': unit.description,
            'is_active': unit.isActive,
            'row_version': unit.rowVersion,
            'created_at': unit.createdAt.toIso8601String(),
            'updated_at': unit.updatedAt.toIso8601String(),
          },
        )
        .toList();
  });

  await tester.pumpWidget(
    MaterialApp(
      home: AgronomicParametersPage(
        capabilities: _capabilities(canManage: canManage),
        repository: repository,
        measurementUnitRepository: unitRepository,
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('AgronomicParametersPage', () {
    testWidgets('mostra i parametri agronomici caricati', (tester) async {
      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      await _pumpPage(tester, repository: repository);

      expect(find.text('Parametro booleano'), findsOneWidget);
      expect(find.textContaining('TEST_BOOLEAN'), findsOneWidget);
    });
    testWidgets('mostra un messaggio quando non ci sono parametri', (
      tester,
    ) async {
      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      expect(find.text('Nessun parametro agronomico trovato.'), findsOneWidget);
    });
    testWidgets('nasconde i comandi amministrativi in sola lettura', (
      tester,
    ) async {
      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      await _pumpPage(tester, repository: repository, canManage: false);

      expect(find.text('Parametro booleano'), findsOneWidget);
      expect(find.text('Nuovo parametro'), findsNothing);
      expect(find.byTooltip('Modifica parametro'), findsNothing);
      expect(find.byTooltip('Disattiva parametro'), findsNothing);
      expect(find.byTooltip('Attiva parametro'), findsNothing);
    });
    testWidgets('mostra i parametri disattivati quando richiesto', (
      tester,
    ) async {
      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(),
          _parameter(
            id: 'parameter-2',
            code: 'TEST_INACTIVE',
            name: 'Parametro disattivato',
            active: false,
          ),
        ],
      );

      await _pumpPage(tester, repository: repository);

      expect(find.text('Parametro booleano'), findsOneWidget);
      expect(find.text('Parametro disattivato'), findsNothing);

      await tester.tap(find.text('Mostra parametri disattivati'));
      await tester.pumpAndSettle();

      expect(find.text('Parametro disattivato'), findsOneWidget);
    });
    testWidgets('mostra un errore quando il caricamento fallisce', (
      tester,
    ) async {
      final repository = _FakeAgronomicParameterRepository(
        loadError: Exception('Errore simulato di caricamento'),
      );

      await _pumpPage(tester, repository: repository);

      expect(
        find.text('Errore durante il caricamento dei parametri agronomici.'),
        findsOneWidget,
      );

      expect(find.text('Riprova'), findsOneWidget);
    });
    testWidgets('apre il dialogo di creazione parametro', (tester) async {
      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      expect(find.text('Nuovo parametro'), findsOneWidget);
      expect(find.text('Nuovo parametro agronomico'), findsNothing);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('impedisce il salvataggio senza codice e nome', (tester) async {
      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Inserisci il codice'), findsOneWidget);
      expect(find.text('Inserisci il nome'), findsOneWidget);

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('richiede almeno un livello di applicazione', (tester) async {
      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_LEVEL',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro di prova',
      );

      final cropCheckbox = find.widgetWithText(
        CheckboxListTile,
        'Applicabile alle colture',
      );

      await tester.ensureVisible(cropCheckbox);
      await tester.tap(cropCheckbox);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(
        find.text('Seleziona almeno un livello: coltura o varietà.'),
        findsOneWidget,
      );

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('richiede la grandezza fisica per un parametro numerico', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository();
      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_NUMERIC',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro numerico di prova',
      );

      final valueSchemaDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Tipologia del valore',
      );

      await tester.ensureVisible(valueSchemaDropdown);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: valueSchemaDropdown,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Numerico singolo').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Seleziona la grandezza fisica.'), findsOneWidget);

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('richiede un contesto per un parametro contestuale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_CONTEXTUAL',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro contestuale di prova',
      );

      final knowledgeScopeDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Ambito della conoscenza',
      );

      await tester.ensureVisible(knowledgeScopeDropdown);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: knowledgeScopeDropdown,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Contestuale').last);
      await tester.pumpAndSettle();

      expect(find.text('Contesti agronomici applicabili'), findsOneWidget);

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(
        find.text('Seleziona almeno un contesto di applicazione.'),
        findsOneWidget,
      );

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('richiede una unità canonica per un parametro numerico', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository();

      final unit = MeasurementUnit(
        id: 'unit-test-length',
        code: 'TEST_CM',
        name: 'Centimetro',
        symbol: 'cm',
        quantityKind: 'LENGTH',
        toBaseFactor: 0.01,
        toBaseOffset: 0,
        description: null,
        isActive: true,
        rowVersion: 1,
        createdAt: _fixedDate,
        updatedAt: _fixedDate,
      );

      await _pumpPage(tester, repository: repository, measurementUnits: [unit]);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_NUMERIC_UNIT',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro numerico con unità obbligatoria',
      );

      final schemaDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Tipologia del valore',
      );

      await tester.ensureVisible(schemaDropdown);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: schemaDropdown,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Numerico singolo').last);
      await tester.pumpAndSettle();

      final quantityDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Grandezza fisica',
      );

      await tester.ensureVisible(quantityDropdown);
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: quantityDropdown,
          matching: find.byType(DropdownButton<String>),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('LENGTH').last);
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(DropdownButtonFormField<String>, 'Unità canonica'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('Salva'));
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(find.text('Seleziona l’unità canonica.'), findsOneWidget);
      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);
    });
    testWidgets('apre la modifica con i dati del parametro esistente', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(
            code: 'TEST_EXISTING',
            name: 'Parametro esistente',
            rowVersion: 3,
          ),
        ],
      );

      await _pumpPage(tester, repository: repository);

      expect(find.text('Parametro esistente'), findsOneWidget);

      await tester.tap(find.byTooltip('Modifica parametro'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica parametro agronomico'), findsOneWidget);

      final codeField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Codice parametro'),
      );

      final nameField = tester.widget<TextFormField>(
        find.widgetWithText(TextFormField, 'Nome parametro'),
      );

      expect(codeField.controller!.text, 'TEST_EXISTING');
      expect(nameField.controller!.text, 'Parametro esistente');

      expect(find.text('Salva'), findsOneWidget);
    });
    testWidgets('aggiorna il parametro usando la versione originale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(
            code: 'TEST_EXISTING',
            name: 'Parametro esistente',
            rowVersion: 3,
          ),
        ],
      );

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Modifica parametro'));
      await tester.pumpAndSettle();

      final nameField = find.widgetWithText(TextFormField, 'Nome parametro');

      await tester.enterText(nameField, 'Parametro aggiornato');

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.updateCallCount, 1);
      expect(repository.lastUpdatedParameterId, 'parameter-1');
      expect(repository.lastExpectedRowVersion, 3);
      expect(repository.lastUpdatedCode, 'TEST_EXISTING');
      expect(repository.lastUpdatedName, 'Parametro aggiornato');

      expect(find.text('Modifica parametro agronomico'), findsNothing);
    });
    testWidgets(
      'mantiene aperta la modifica in caso di conflitto di versione',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repository = _FakeAgronomicParameterRepository(
          parameters: [
            _parameter(
              code: 'TEST_EXISTING',
              name: 'Parametro esistente',
              rowVersion: 3,
            ),
          ],
        );

        repository.updateResultOverride =
            const UpdateAgronomicParameterVersionConflict(rowVersion: 4);

        await _pumpPage(tester, repository: repository);

        await tester.tap(find.byTooltip('Modifica parametro'));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome parametro'),
          'Parametro aggiornato',
        );

        await tester.tap(find.text('Salva'));
        await tester.pumpAndSettle();

        expect(repository.updateCallCount, 1);
        expect(repository.lastUpdatedParameterId, 'parameter-1');
        expect(repository.lastExpectedRowVersion, 3);
        expect(repository.lastUpdatedName, 'Parametro aggiornato');

        expect(find.text('Modifica parametro agronomico'), findsOneWidget);

        expect(
          find.text(
            'Il parametro è stato modificato altrove. '
            'Chiudi e ricarica i dati.',
          ),
          findsOneWidget,
        );
      },
    );
    testWidgets('mantiene aperta la modifica con semantica bloccata', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(
            code: 'TEST_EXISTING',
            name: 'Parametro esistente',
            rowVersion: 3,
          ),
        ],
      );

      repository.updateResultOverride =
          const UpdateAgronomicParameterSemanticsFrozen();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Modifica parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro aggiornato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.updateCallCount, 1);
      expect(repository.lastUpdatedParameterId, 'parameter-1');
      expect(repository.lastExpectedRowVersion, 3);
      expect(repository.lastUpdatedName, 'Parametro aggiornato');

      expect(find.text('Modifica parametro agronomico'), findsOneWidget);

      expect(
        find.text(
          'Le caratteristiche semantiche di questo parametro '
          'non possono più essere modificate.',
        ),
        findsOneWidget,
      );
    });
    testWidgets('chiude la modifica quando il parametro è invariato', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(
            code: 'TEST_EXISTING',
            name: 'Parametro esistente',
            rowVersion: 3,
          ),
        ],
      );

      repository.updateResultOverride = const UpdateAgronomicParameterUnchanged(
        agronomicParameterId: 'parameter-1',
        rowVersion: 3,
      );

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Modifica parametro'));
      await tester.pumpAndSettle();

      expect(find.text('Modifica parametro agronomico'), findsOneWidget);

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.updateCallCount, 1);
      expect(repository.lastUpdatedParameterId, 'parameter-1');
      expect(repository.lastExpectedRowVersion, 3);

      expect(find.text('Modifica parametro agronomico'), findsNothing);
    });
    testWidgets('crea un parametro agronomico e chiude il dialogo', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_CREATED',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro creato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCallCount, 1);
      expect(repository.lastCreatedCode, 'TEST_CREATED');
      expect(repository.lastCreatedName, 'Parametro creato');
      expect(repository.lastCreatedDescription, isNull);
      expect(repository.lastCreatedValueSchema, 'BOOLEAN');
      expect(repository.lastCreatedKnowledgeScope, 'INTRINSIC');
      expect(repository.lastCreatedAllowsCrop, isTrue);
      expect(repository.lastCreatedAllowsCultivar, isFalse);

      expect(find.text('Nuovo parametro agronomico'), findsNothing);
    });
    testWidgets('mantiene aperta la creazione con codice duplicato', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository();

      repository.createResultOverride =
          const CreateAgronomicParameterDuplicateCode();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuovo parametro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice parametro'),
        'TEST_DUPLICATE',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome parametro'),
        'Parametro duplicato',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCallCount, 1);
      expect(repository.lastCreatedCode, 'TEST_DUPLICATE');
      expect(repository.lastCreatedName, 'Parametro duplicato');

      expect(find.text('Nuovo parametro agronomico'), findsOneWidget);

      expect(
        find.text('Esiste già un parametro con questo codice.'),
        findsOneWidget,
      );
    });
    testWidgets('annulla la disattivazione senza chiamare il repository', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Disattiva parametro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vuoi disattivare il parametro "Parametro booleano"?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Annulla'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 0);
      expect(repository.lastSetActiveParameterId, isNull);
      expect(repository.lastSetActiveValue, isNull);

      expect(find.text('Parametro booleano'), findsOneWidget);
      expect(find.byTooltip('Disattiva parametro'), findsOneWidget);
    });
    testWidgets('conferma la disattivazione con versione corretta', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Disattiva parametro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vuoi disattivare il parametro "Parametro booleano"?'),
        findsOneWidget,
      );

      expect(repository.setActiveCallCount, 0);

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 1);
      expect(repository.lastSetActiveParameterId, 'parameter-1');
      expect(repository.lastSetActiveExpectedRowVersion, 1);
      expect(repository.lastSetActiveValue, isFalse);

      expect(find.text('Disattiva parametro'), findsNothing);
      expect(find.text('Parametro booleano'), findsOneWidget);
    });
    testWidgets('conferma la riattivazione di un parametro disattivato', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [
          _parameter(
            id: 'parameter-2',
            code: 'TEST_INACTIVE',
            name: 'Parametro disattivato',
            active: false,
            rowVersion: 3,
          ),
        ],
      );

      await _pumpPage(tester, repository: repository);

      expect(find.text('Parametro disattivato'), findsNothing);

      await tester.tap(find.text('Mostra parametri disattivati'));
      await tester.pumpAndSettle();

      expect(find.text('Parametro disattivato'), findsOneWidget);

      await tester.tap(find.byTooltip('Attiva parametro'));
      await tester.pumpAndSettle();

      expect(
        find.text('Vuoi attivare il parametro "Parametro disattivato"?'),
        findsOneWidget,
      );

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 1);
      expect(repository.lastSetActiveParameterId, 'parameter-2');
      expect(repository.lastSetActiveExpectedRowVersion, 3);
      expect(repository.lastSetActiveValue, isTrue);

      expect(find.text('Attiva parametro'), findsNothing);
    });
    testWidgets('mostra un conflitto di versione durante la disattivazione', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      repository.setActiveResultOverride =
          const SetAgronomicParameterActiveVersionConflict(rowVersion: 2);

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Disattiva parametro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 1);
      expect(repository.lastSetActiveParameterId, 'parameter-1');
      expect(repository.lastSetActiveExpectedRowVersion, 1);
      expect(repository.lastSetActiveValue, isFalse);

      expect(
        find.text('Il parametro è stato modificato altrove. Ricarica i dati.'),
        findsOneWidget,
      );

      expect(find.text('Parametro booleano'), findsOneWidget);
    });
    testWidgets('impedisce la disattivazione con dipendenze attive', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = _FakeAgronomicParameterRepository(
        parameters: [_parameter()],
      );

      repository.setActiveResultOverride =
          const SetAgronomicParameterActiveDependents();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byTooltip('Disattiva parametro'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Conferma'));
      await tester.pumpAndSettle();

      expect(repository.setActiveCallCount, 1);
      expect(repository.lastSetActiveParameterId, 'parameter-1');
      expect(repository.lastSetActiveExpectedRowVersion, 1);
      expect(repository.lastSetActiveValue, isFalse);

      expect(
        find.text(
          'Impossibile disattivare il parametro: esistono dipendenze attive.',
        ),
        findsOneWidget,
      );

      expect(find.text('Parametro booleano'), findsOneWidget);
      expect(find.byTooltip('Disattiva parametro'), findsOneWidget);
    });
  });
}
