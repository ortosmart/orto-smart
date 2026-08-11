import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/succession_planning_engine.dart';
import 'package:orto_app/core/agronomy/models/family_consumption_need.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('SuccessionPlanningEngine', () {
    const engine = SuccessionPlanningEngine();

    const need = FamilyConsumptionNeed(
      cropId: 'lattuga',
      quantity: 4,
      unit: FamilyConsumptionUnit.pieces,
      intervalDays: 14,
    );

    test('rifiuta un intervallo temporale non valido', () {
      expect(
        () => engine.generate(
          need: need,
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 4, 1),
          startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
        throwsArgumentError,
      );
    });

    test('genera il primo lotto alla data iniziale', () {
      final batches = engine.generate(
        need: need,
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 1),
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(batches.length, 1);
      expect(batches.first.cropId, 'lattuga');
      expect(batches.first.plannedDate, DateTime(2026, 4, 1));
      expect(batches.first.quantity, 4);
      expect(
        batches.first.startMethod,
        PlannedPlantingStartMethod.purchasedSeedlings,
      );
      expect(batches.first.quantityType, PlannedPlantingQuantityType.plants);
    });

    test('genera lotti successivi rispettando intervalDays', () {
      final batches = engine.generate(
        need: need,
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 5, 31),
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(batches.map((batch) => batch.plannedDate).toList(), [
        DateTime(2026, 4, 1),
        DateTime(2026, 4, 15),
        DateTime(2026, 4, 29),
        DateTime(2026, 5, 13),
        DateTime(2026, 5, 27),
      ]);
    });

    test('rifiuta un fabbisogno familiare non valido', () {
      const invalidNeed = FamilyConsumptionNeed(
        cropId: 'lattuga',
        quantity: 4,
        unit: FamilyConsumptionUnit.pieces,
        intervalDays: 0,
      );

      expect(
        () => engine.generate(
          need: invalidNeed,
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 5, 1),
          startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
        throwsArgumentError,
      );
    });
    test('propaga la varietà nei lotti pianificati', () {
      final batches = engine.generate(
        need: need,
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 15),
        startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
        quantityType: PlannedPlantingQuantityType.plants,
        varietyId: 'romana',
      );

      expect(batches.length, 2);
      expect(batches[0].varietyId, 'romana');
      expect(batches[1].varietyId, 'romana');
    });
    test('rifiuta una combinazione metodo quantità non valida', () {
      expect(
        () => engine.generate(
          need: need,
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 4, 15),
          startMethod: PlannedPlantingStartMethod.directBroadcast,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
        throwsArgumentError,
      );
    });
    test('rifiuta la conversione diretta da pezzi ad area coltivata', () {
      const broadcastNeed = FamilyConsumptionNeed(
        cropId: 'rucola',
        quantity: 4,
        unit: FamilyConsumptionUnit.pieces,
        intervalDays: 14,
      );

      expect(
        () => engine.generate(
          need: broadcastNeed,
          startDate: DateTime(2026, 4, 1),
          endDate: DateTime(2026, 4, 15),
          startMethod: PlannedPlantingStartMethod.directBroadcast,
          quantityType: PlannedPlantingQuantityType.areaSquareCm,
        ),
        throwsArgumentError,
      );
    });
    test('rifiuta la conversione diretta da chilogrammi a piante', () {
      const weightNeed = FamilyConsumptionNeed(
        cropId: 'pomodoro',
        quantity: 5,
        unit: FamilyConsumptionUnit.kilograms,
        intervalDays: 7,
      );

      expect(
        () => engine.generate(
          need: weightNeed,
          startDate: DateTime(2026, 5, 1),
          endDate: DateTime(2026, 5, 15),
          startMethod: PlannedPlantingStartMethod.purchasedSeedlings,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
        throwsArgumentError,
      );
    });
  });
}
