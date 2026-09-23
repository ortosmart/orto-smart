import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window_evaluation.dart';
import 'package:orto_app/core/agronomy/models/crop_agronomic_window_rule.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';
import 'package:orto_app/services/agronomic_window_service.dart';

void main() {
  group('AgronomicWindowService', () {
    const generalSpringWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 2,
      startDay: 15,
      endMonth: 5,
      endDay: 31,
    );

    const generalAutumnWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 8,
      startDay: 20,
      endMonth: 10,
      endDay: 15,
    );

    const cultivarSpringWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 1,
      endMonth: 5,
      endDay: 15,
    );

    const cultivarAutumnWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 9,
      startDay: 1,
      endMonth: 10,
      endDay: 1,
    );

    const rules = [
      CropAgronomicWindowRule(cropId: 'lattuga', window: generalSpringWindow),
      CropAgronomicWindowRule(cropId: 'lattuga', window: generalAutumnWindow),
      CropAgronomicWindowRule(
        cropId: 'lattuga',
        cultivarId: 'romana',
        window: cultivarSpringWindow,
      ),
      CropAgronomicWindowRule(
        cropId: 'lattuga',
        cultivarId: 'romana',
        window: cultivarAutumnWindow,
      ),
    ];

    test(
      'restituisce compatible quando la data rientra nella prima finestra',
      () {
        final batch = PlannedPlantingBatch(
          cropId: 'lattuga',
          cultivarId: 'romana',
          startMethod: PlannedPlantingStartMethod.directRows,
          plannedDate: DateTime(2026, 4, 20),
          quantity: 4,
          quantityType: PlannedPlantingQuantityType.plants,
        );

        final evaluation = AgronomicWindowService.evaluateBatch(
          rules: rules,
          batch: batch,
        );

        expect(evaluation.status, AgronomicWindowEvaluationStatus.compatible);
        expect(evaluation.matchedWindow, same(cultivarSpringWindow));
        expect(evaluation.evaluatedWindows, [
          same(cultivarSpringWindow),
          same(cultivarAutumnWindow),
        ]);
      },
    );

    test(
      'restituisce compatible quando la data rientra nella seconda finestra',
      () {
        final batch = PlannedPlantingBatch(
          cropId: 'lattuga',
          cultivarId: 'romana',
          startMethod: PlannedPlantingStartMethod.directRows,
          plannedDate: DateTime(2026, 9, 15),
          quantity: 4,
          quantityType: PlannedPlantingQuantityType.plants,
        );

        final evaluation = AgronomicWindowService.evaluateBatch(
          rules: rules,
          batch: batch,
        );

        expect(evaluation.status, AgronomicWindowEvaluationStatus.compatible);
        expect(evaluation.matchedWindow, same(cultivarAutumnWindow));
        expect(evaluation.evaluatedWindows, hasLength(2));
      },
    );

    test(
      'restituisce incompatible quando la data è fuori da tutte le finestre',
      () {
        final batch = PlannedPlantingBatch(
          cropId: 'lattuga',
          cultivarId: 'romana',
          startMethod: PlannedPlantingStartMethod.directRows,
          plannedDate: DateTime(2026, 7, 10),
          quantity: 4,
          quantityType: PlannedPlantingQuantityType.plants,
        );

        final evaluation = AgronomicWindowService.evaluateBatch(
          rules: rules,
          batch: batch,
        );

        expect(evaluation.status, AgronomicWindowEvaluationStatus.incompatible);
        expect(evaluation.matchedWindow, isNull);
        expect(evaluation.evaluatedWindows, [
          same(cultivarSpringWindow),
          same(cultivarAutumnWindow),
        ]);
      },
    );

    test('restituisce unknown quando non esiste una regola applicabile', () {
      final batch = PlannedPlantingBatch(
        cropId: 'pomodoro',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 4, 20),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final evaluation = AgronomicWindowService.evaluateBatch(
        rules: rules,
        batch: batch,
      );

      expect(evaluation.status, AgronomicWindowEvaluationStatus.unknown);
      expect(evaluation.matchedWindow, isNull);
      expect(evaluation.evaluatedWindows, isEmpty);
    });

    test('usa tutte le finestre generali come fallback', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        cultivarId: 'canasta',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 9, 15),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final evaluation = AgronomicWindowService.evaluateBatch(
        rules: rules,
        batch: batch,
      );

      expect(evaluation.status, AgronomicWindowEvaluationStatus.compatible);
      expect(evaluation.matchedWindow, same(generalAutumnWindow));
      expect(evaluation.evaluatedWindows, [
        same(generalSpringWindow),
        same(generalAutumnWindow),
      ]);
    });
  });
}
