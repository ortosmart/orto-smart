import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/agronomic_window_resolver.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/crop_agronomic_window_rule.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowResolver', () {
    const resolver = AgronomicWindowResolver();

    const generalWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 1,
      endMonth: 9,
      endDay: 30,
    );

    const varietyWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 15,
      endMonth: 8,
      endDay: 31,
    );

    const rules = [
      CropAgronomicWindowRule(cropId: 'lattuga', window: generalWindow),
      CropAgronomicWindowRule(
        cropId: 'lattuga',
        varietyId: 'romana',
        window: varietyWindow,
      ),
    ];

    test('usa la regola specifica della varietà quando presente', () {
      final window = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(window, same(varietyWindow));
    });

    test('usa la regola generale se manca quella specifica', () {
      final window = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        varietyId: 'canasta',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(window, same(generalWindow));
    });

    test('usa la regola generale quando non è indicata una varietà', () {
      final window = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(window, same(generalWindow));
    });

    test('ignora le regole di una coltura diversa', () {
      final window = resolver.resolve(
        rules: rules,
        cropId: 'pomodoro',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(window, isNull);
    });

    test('ignora le regole con metodo di avvio diverso', () {
      final window = resolver.resolve(
        rules: rules,
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
      );

      expect(window, isNull);
    });

    test('restituisce null quando non esiste una regola applicabile', () {
      final window = resolver.resolve(
        rules: const [],
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
      );

      expect(window, isNull);
    });
    test('risolve la finestra direttamente da un lotto pianificato', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final window = resolver.resolveForBatch(rules: rules, batch: batch);

      expect(window, same(varietyWindow));
    });
    test('usa il fallback generale anche per un lotto pianificato', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'canasta',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final window = resolver.resolveForBatch(rules: rules, batch: batch);

      expect(window, same(generalWindow));
    });
  });
}
