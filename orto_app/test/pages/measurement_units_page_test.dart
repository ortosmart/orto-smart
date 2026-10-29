import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/write_authority/measurement_unit_write_result.dart';
import 'package:orto_app/data/models/catalog_capabilities.dart';
import 'package:orto_app/data/models/measurement_unit.dart';
import 'package:orto_app/data/repositories/measurement_unit_repository.dart';
import 'package:orto_app/pages/measurement_units_page.dart';

class _FakeMeasurementUnitRepository extends MeasurementUnitRepository {
  _FakeMeasurementUnitRepository({
    List<MeasurementUnit> units = const [],
    CreateMeasurementUnitResult? createResult,
    UpdateMeasurementUnitResult? updateResult,
    SetMeasurementUnitActiveResult? activeResult,
    this.loadError,
    this.createError,
  }) : createResult =
           createResult ??
           MeasurementUnitCreated(
             measurementUnitId: 'unit-new',
             code: 'TEST_UNIT',
             isActive: true,
             rowVersion: 1,
             createdAt: _fixedDate,
           ),
       updateResult =
           updateResult ??
           MeasurementUnitUpdated(
             measurementUnitId: 'unit-1',
             code: 'GRAM',
             isActive: true,
             rowVersion: 2,
             updatedAt: _fixedDate,
           ),
       activeResult =
           activeResult ??
           MeasurementUnitActiveChanged(
             measurementUnitId: 'unit-1',
             isActive: false,
             rowVersion: 2,
             updatedAt: _fixedDate,
           ),
       super.withProviders(
         ({bool activeOnly = true}) async {
           if (loadError != null) throw loadError;
           return units
               .where((unit) => !activeOnly || unit.isActive)
               .map(_toMap)
               .toList();
         },
         (functionName, parameters) async {
           if (functionName == 'create_measurement_unit') {
             if (createError != null) throw createError;
             return createResult ??
                 MeasurementUnitCreated(
                   measurementUnitId: 'unit-new',
                   code: 'TEST_UNIT',
                   isActive: true,
                   rowVersion: 1,
                   createdAt: _fixedDate,
                 );
           }
           if (functionName == 'update_measurement_unit') {
             return updateResult ??
                 MeasurementUnitUpdated(
                   measurementUnitId: 'unit-1',
                   code: 'GRAM',
                   isActive: true,
                   rowVersion: 2,
                   updatedAt: _fixedDate,
                 );
           }
           if (functionName == 'set_measurement_unit_active') {
             return activeResult ??
                 MeasurementUnitActiveChanged(
                   measurementUnitId: 'unit-1',
                   isActive: false,
                   rowVersion: 2,
                   updatedAt: _fixedDate,
                 );
           }
           throw StateError('Unexpected RPC: $functionName');
         },
       );

  static final _fixedDate = DateTime.utc(2026, 9, 20);

  final CreateMeasurementUnitResult createResult;
  final UpdateMeasurementUnitResult updateResult;
  final SetMeasurementUnitActiveResult activeResult;
  final Object? loadError;
  final Object? createError;

  int createCalls = 0;
  int updateCalls = 0;
  int activeCalls = 0;
  Map<String, dynamic>? lastParameters;
  String? lastFunction;

  static Map<String, dynamic> _toMap(MeasurementUnit unit) => {
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
  };

  @override
  Future<CreateMeasurementUnitResult> createMeasurementUnit({
    required String code,
    required String name,
    required String symbol,
    required String quantityKind,
    required num toBaseFactor,
    required num toBaseOffset,
    String? description,
  }) async {
    createCalls++;
    lastFunction = 'create_measurement_unit';
    lastParameters = {
      'code': code,
      'name': name,
      'symbol': symbol,
      'quantityKind': quantityKind,
      'toBaseFactor': toBaseFactor,
      'toBaseOffset': toBaseOffset,
      'description': description,
    };
    if (createError != null) throw createError!;
    return createResult;
  }

  @override
  Future<UpdateMeasurementUnitResult> updateMeasurementUnit({
    required String measurementUnitId,
    required int expectedRowVersion,
    required String code,
    required String name,
    required String symbol,
    required String quantityKind,
    required num toBaseFactor,
    required num toBaseOffset,
    String? description,
  }) async {
    updateCalls++;
    lastFunction = 'update_measurement_unit';
    lastParameters = {
      'measurementUnitId': measurementUnitId,
      'expectedRowVersion': expectedRowVersion,
      'code': code,
      'name': name,
      'symbol': symbol,
      'quantityKind': quantityKind,
      'toBaseFactor': toBaseFactor,
      'toBaseOffset': toBaseOffset,
      'description': description,
    };
    return updateResult;
  }

  @override
  Future<SetMeasurementUnitActiveResult> setMeasurementUnitActive({
    required String measurementUnitId,
    required int expectedRowVersion,
    required bool isActive,
  }) async {
    activeCalls++;
    lastFunction = 'set_measurement_unit_active';
    lastParameters = {
      'measurementUnitId': measurementUnitId,
      'expectedRowVersion': expectedRowVersion,
      'isActive': isActive,
    };
    return activeResult;
  }
}

CatalogCapabilities _capabilities({required bool canManage}) {
  return CatalogCapabilities(
    canManageIdentity: canManage,
    canIngest: false,
    canReview: false,
    canPublish: false,
    rowVersion: 1,
  );
}

MeasurementUnit _unit({
  String id = 'unit-1',
  String code = 'GRAM',
  String name = 'Grammo',
  String symbol = 'g',
  String quantityKind = 'MASS',
  num factor = 1,
  num offset = 0,
  bool active = true,
  int rowVersion = 1,
}) {
  return MeasurementUnit(
    id: id,
    code: code,
    name: name,
    symbol: symbol,
    quantityKind: quantityKind,
    toBaseFactor: factor,
    toBaseOffset: offset,
    description: null,
    isActive: active,
    rowVersion: rowVersion,
    createdAt: DateTime.utc(2026, 9, 20),
    updatedAt: DateTime.utc(2026, 9, 20),
  );
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required _FakeMeasurementUnitRepository repository,
  bool canManage = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MeasurementUnitsPage(
        capabilities: _capabilities(canManage: canManage),
        repository: repository,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('MeasurementUnitsPage', () {
    testWidgets('mostra le unità caricate', (tester) async {
      final repository = _FakeMeasurementUnitRepository(units: [_unit()]);

      await _pumpPage(tester, repository: repository);

      expect(find.text('Unità di misura'), findsOneWidget);
      expect(find.text('Grammo (g)'), findsOneWidget);
      expect(find.textContaining('GRAM'), findsOneWidget);
    });

    testWidgets('mostra il messaggio quando non ci sono unità', (tester) async {
      final repository = _FakeMeasurementUnitRepository();

      await _pumpPage(tester, repository: repository);

      expect(find.text('Nessuna unità di misura trovata.'), findsOneWidget);
    });

    testWidgets('nasconde i comandi di gestione in sola lettura', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository(units: [_unit()]);

      await _pumpPage(tester, repository: repository, canManage: false);

      expect(find.text('Nuova unità'), findsNothing);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(
        tester
            .widget<PopupMenuButton<String>>(
              find.byType(PopupMenuButton<String>),
            )
            .enabled,
        isFalse,
      );
    });

    testWidgets('mostra le unità disattivate quando richiesto', (tester) async {
      final repository = _FakeMeasurementUnitRepository(
        units: [
          _unit(),
          _unit(
            id: 'unit-2',
            code: 'OLD_UNIT',
            name: 'Unità disattivata',
            active: false,
          ),
        ],
      );

      await _pumpPage(tester, repository: repository);

      expect(find.text('Unità disattivata (g)'), findsNothing);

      await tester.tap(find.text('Mostra unità disattivate'));
      await tester.pumpAndSettle();

      expect(find.text('Unità disattivata (g)'), findsOneWidget);
    });

    testWidgets('mostra un errore di caricamento e consente di riprovare', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository(
        loadError: Exception('load failed'),
      );

      await _pumpPage(tester, repository: repository);

      expect(
        find.text('Errore durante il caricamento delle unità di misura.'),
        findsOneWidget,
      );
      expect(find.text('Riprova'), findsOneWidget);
    });

    testWidgets('apre il modulo di creazione', (tester) async {
      final repository = _FakeMeasurementUnitRepository();

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.text('Nuova unità'));
      await tester.pumpAndSettle();

      expect(find.text('Nuova unità di misura'), findsOneWidget);
      expect(find.text('Dimensione fisica'), findsOneWidget);
      expect(find.text('Fattore di conversione verso la base'), findsOneWidget);
    });

    testWidgets('non invia il form se il codice è invalido', (tester) async {
      final repository = _FakeMeasurementUnitRepository();

      await _pumpPage(tester, repository: repository);
      await tester.tap(find.text('Nuova unità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice'),
        'codice errato',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Unità di prova',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Simbolo'),
        'u',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dimensione fisica'),
        'MASS',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 0);
      expect(find.text('Nuova unità di misura'), findsOneWidget);
    });

    testWidgets('crea una unità e chiude il dialogo in caso di successo', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository();

      await _pumpPage(tester, repository: repository);
      await tester.tap(find.text('Nuova unità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice'),
        'TEST_UNIT',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Unità test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Simbolo'),
        'tu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dimensione fisica'),
        'MASS',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(repository.lastFunction, 'create_measurement_unit');
      expect(find.text('Nuova unità di misura'), findsNothing);
      expect(find.text('Unità di misura creata.'), findsOneWidget);
    });

    testWidgets('mantiene aperto il dialogo se il codice è duplicato', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository(
        createResult: const CreateMeasurementUnitDuplicateCode(),
      );

      await _pumpPage(tester, repository: repository);
      await tester.tap(find.text('Nuova unità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice'),
        'TEST_UNIT',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Unità test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Simbolo'),
        'tu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dimensione fisica'),
        'MASS',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(find.text('Nuova unità di misura'), findsOneWidget);
      expect(find.text('Il codice è già utilizzato.'), findsOneWidget);
    });

    testWidgets('gestisce il conflitto di versione in modifica', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository(
        units: [_unit(rowVersion: 4)],
        updateResult: const UpdateMeasurementUnitVersionConflict(rowVersion: 5),
      );

      await _pumpPage(tester, repository: repository);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Grammo aggiornato',
      );
      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      expect(repository.lastParameters?['expectedRowVersion'], 4);
      expect(find.text('Modifica unità di misura'), findsOneWidget);
      expect(
        find.text(
          'L’unità è stata modificata. Ricarica i dati prima di riprovare.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('gestisce una risposta tecnica di errore nel salvataggio', (
      tester,
    ) async {
      final repository = _FakeMeasurementUnitRepository(
        createError: Exception('network error'),
      );

      await _pumpPage(tester, repository: repository);
      await tester.tap(find.text('Nuova unità'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Codice'),
        'TEST_UNIT',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Unità test',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Simbolo'),
        'tu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Dimensione fisica'),
        'MASS',
      );

      await tester.tap(find.text('Salva'));
      await tester.pumpAndSettle();

      expect(repository.createCalls, 1);
      expect(find.text('Nuova unità di misura'), findsOneWidget);
      expect(
        find.text('Errore durante il salvataggio dell’unità.'),
        findsOneWidget,
      );
    });
  });
}
