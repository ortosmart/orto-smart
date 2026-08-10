import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/family_consumption_need_validator.dart';
import 'package:orto_app/core/agronomy/models/family_consumption_need.dart';

FamilyConsumptionNeed _need({
  String cropId = 'lattuga',
  double quantity = 4,
  FamilyConsumptionUnit unit = FamilyConsumptionUnit.pieces,
  int intervalDays = 14,
}) {
  return FamilyConsumptionNeed(
    cropId: cropId,
    quantity: quantity,
    unit: unit,
    intervalDays: intervalDays,
  );
}

void main() {
  group('FamilyConsumptionNeedValidator', () {
    test('accetta un fabbisogno valido', () {
      final result = FamilyConsumptionNeedValidator.validate(_need());

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('rifiuta una coltura senza identificativo', () {
      final result = FamilyConsumptionNeedValidator.validate(
        _need(cropId: '   '),
      );

      expect(result.isValid, isFalse);
    });

    test('rifiuta una quantità nulla', () {
      final result = FamilyConsumptionNeedValidator.validate(
        _need(quantity: 0),
      );

      expect(result.isValid, isFalse);
    });

    test('rifiuta una quantità negativa', () {
      final result = FamilyConsumptionNeedValidator.validate(
        _need(quantity: -1),
      );

      expect(result.isValid, isFalse);
    });

    test('rifiuta un intervallo nullo', () {
      final result = FamilyConsumptionNeedValidator.validate(
        _need(intervalDays: 0),
      );

      expect(result.isValid, isFalse);
    });

    test('rifiuta un intervallo negativo', () {
      final result = FamilyConsumptionNeedValidator.validate(
        _need(intervalDays: -7),
      );

      expect(result.isValid, isFalse);
    });
  });
}
