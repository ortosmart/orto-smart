import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';
import 'package:orto_app/core/agronomy/planned_planting_batch_validator.dart';

PlannedPlantingBatch _batch({
  String cropId = 'lattuga',
  PlannedPlantingStartMethod startMethod =
      PlannedPlantingStartMethod.purchasedSeedlings,
  double quantity = 6,
  PlannedPlantingQuantityType quantityType = PlannedPlantingQuantityType.plants,
}) {
  return PlannedPlantingBatch(
    cropId: cropId,
    startMethod: startMethod,
    plannedDate: DateTime(2026, 3, 15),
    quantity: quantity,
    quantityType: quantityType,
  );
}

void main() {
  group('PlannedPlantingBatchValidator', () {
    test('accetta piantine acquistate espresse come numero di piante', () {
      final result = PlannedPlantingBatchValidator.validate(_batch());

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('rifiuta una coltura senza identificativo', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(cropId: '   '),
      );

      expect(result.isValid, isFalse);
    });

    test('rifiuta una quantità non positiva', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(quantity: 0),
      );

      expect(result.isValid, isFalse);
    });

    test('semenzaio e trapianto richiedono il numero di piante', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(
          startMethod: PlannedPlantingStartMethod.nurseryThenTransplant,
          quantityType: PlannedPlantingQuantityType.seedGrams,
        ),
      );

      expect(result.isValid, isFalse);
    });

    test('semina diretta a file usa le piante finali previste', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(
          startMethod: PlannedPlantingStartMethod.directRows,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
      );

      expect(result.isValid, isTrue);
    });

    test('semina a spaglio richiede una quantità espressa come area', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(
          startMethod: PlannedPlantingStartMethod.directBroadcast,
          quantity: 5000,
          quantityType: PlannedPlantingQuantityType.areaSquareCm,
        ),
      );

      expect(result.isValid, isTrue);
    });

    test('semina a spaglio rifiuta il numero di piante', () {
      final result = PlannedPlantingBatchValidator.validate(
        _batch(
          startMethod: PlannedPlantingStartMethod.directBroadcast,
          quantityType: PlannedPlantingQuantityType.plants,
        ),
      );

      expect(result.isValid, isFalse);
    });
  });
}
