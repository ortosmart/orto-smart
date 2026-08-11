import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/agronomic_window_validator.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowValidator', () {
    test('accetta una finestra agronomica valida', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 3,
        startDay: 15,
        endMonth: 9,
        endDay: 30,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });

    test('accetta una finestra che attraversa la fine dell’anno', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 10,
        startDay: 1,
        endMonth: 2,
        endDay: 28,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isTrue);
    });

    test('rifiuta un mese iniziale fuori intervallo', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 13,
        startDay: 1,
        endMonth: 9,
        endDay: 30,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isFalse);
    });

    test('rifiuta un giorno impossibile per il mese', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 4,
        startDay: 31,
        endMonth: 9,
        endDay: 30,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isFalse);
    });

    test('accetta il 29 febbraio', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 2,
        startDay: 29,
        endMonth: 3,
        endDay: 31,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isTrue);
    });

    test('rifiuta un giorno finale non valido', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 3,
        startDay: 1,
        endMonth: 11,
        endDay: 31,
      );

      final result = AgronomicWindowValidator.validate(window);

      expect(result.isValid, isFalse);
    });
  });
}
