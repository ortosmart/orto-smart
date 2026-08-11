import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/agronomic_window_engine.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowEngine', () {
    const engine = AgronomicWindowEngine();

    const standardWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 15,
      endMonth: 9,
      endDay: 30,
    );

    const crossYearWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 10,
      startDay: 1,
      endMonth: 2,
      endDay: 28,
    );

    test('accetta una data interna a una finestra standard', () {
      expect(
        engine.contains(window: standardWindow, date: DateTime(2026, 4, 20)),
        isTrue,
      );
    });

    test('rifiuta una data esterna a una finestra standard', () {
      expect(
        engine.contains(window: standardWindow, date: DateTime(2026, 1, 10)),
        isFalse,
      );
    });

    test('accetta dicembre in una finestra che attraversa fine anno', () {
      expect(
        engine.contains(window: crossYearWindow, date: DateTime(2026, 12, 15)),
        isTrue,
      );
    });

    test('accetta gennaio in una finestra che attraversa fine anno', () {
      expect(
        engine.contains(window: crossYearWindow, date: DateTime(2026, 1, 15)),
        isTrue,
      );
    });

    test('rifiuta giugno in una finestra che attraversa fine anno', () {
      expect(
        engine.contains(window: crossYearWindow, date: DateTime(2026, 6, 15)),
        isFalse,
      );
    });

    test('include esattamente il giorno iniziale', () {
      expect(
        engine.contains(window: standardWindow, date: DateTime(2026, 3, 15)),
        isTrue,
      );
    });

    test('include esattamente il giorno finale', () {
      expect(
        engine.contains(window: standardWindow, date: DateTime(2026, 9, 30)),
        isTrue,
      );
    });

    test('rifiuta una finestra agronomica non valida', () {
      const invalidWindow = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 4,
        startDay: 31,
        endMonth: 9,
        endDay: 30,
      );

      expect(
        () =>
            engine.contains(window: invalidWindow, date: DateTime(2026, 5, 1)),
        throwsArgumentError,
      );
    });

    test('accetta un lotto con metodo e data compatibili', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(
        engine.isBatchCompatible(window: standardWindow, batch: batch),
        isTrue,
      );
    });

    test('rifiuta un lotto con metodo di avvio diverso dalla finestra', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(
        engine.isBatchCompatible(window: standardWindow, batch: batch),
        isFalse,
      );
    });

    test('rifiuta un lotto con metodo corretto ma data fuori finestra', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 1, 10),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(
        engine.isBatchCompatible(window: standardWindow, batch: batch),
        isFalse,
      );
    });
  });
}
