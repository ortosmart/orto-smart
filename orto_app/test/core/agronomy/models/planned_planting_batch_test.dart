import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('PlannedPlantingBatch', () {
    test('mantiene i dati assegnati al lotto pianificato', () {
      final plannedDate = DateTime(2026, 3, 15);

      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.nurseryThenTransplant,
        plannedDate: plannedDate,
        quantity: 6,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      expect(batch.cropId, 'lattuga');
      expect(batch.varietyId, 'romana');
      expect(
        batch.startMethod,
        PlannedPlantingStartMethod.nurseryThenTransplant,
      );
      expect(batch.plannedDate, plannedDate);
      expect(batch.quantity, 6);
      expect(batch.quantityType, PlannedPlantingQuantityType.plants);
    });

    test('supporta tutti i metodi di avvio previsti', () {
      expect(PlannedPlantingStartMethod.values, [
        PlannedPlantingStartMethod.purchasedSeedlings,
        PlannedPlantingStartMethod.nurseryThenTransplant,
        PlannedPlantingStartMethod.directRows,
        PlannedPlantingStartMethod.directBroadcast,
      ]);
    });

    test('supporta tutti i tipi di quantità previsti', () {
      expect(PlannedPlantingQuantityType.values, [
        PlannedPlantingQuantityType.plants,
        PlannedPlantingQuantityType.seedGrams,
        PlannedPlantingQuantityType.areaSquareCm,
      ]);
    });
  });
}
