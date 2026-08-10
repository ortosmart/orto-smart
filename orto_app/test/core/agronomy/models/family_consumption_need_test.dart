import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/family_consumption_need.dart';

void main() {
  group('FamilyConsumptionNeed', () {
    test('mantiene i dati del fabbisogno familiare', () {
      const need = FamilyConsumptionNeed(
        cropId: 'lattuga',
        quantity: 4,
        unit: FamilyConsumptionUnit.pieces,
        intervalDays: 14,
      );

      expect(need.cropId, 'lattuga');
      expect(need.quantity, 4);
      expect(need.unit, FamilyConsumptionUnit.pieces);
      expect(need.intervalDays, 14);
    });

    test('supporta tutte le unità previste', () {
      expect(FamilyConsumptionUnit.values, [
        FamilyConsumptionUnit.pieces,
        FamilyConsumptionUnit.grams,
        FamilyConsumptionUnit.kilograms,
      ]);
    });
  });
}
