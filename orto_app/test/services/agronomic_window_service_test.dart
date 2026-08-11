import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window_evaluation.dart';
import 'package:orto_app/core/agronomy/models/crop_agronomic_window_rule.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';
import 'package:orto_app/services/agronomic_window_service.dart';

void main() {
  group('AgronomicWindowService', () {
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

    test('restituisce compatible quando il lotto rientra nella finestra', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'romana',
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
      expect(evaluation.window, same(varietyWindow));
    });

    test('restituisce incompatible quando la data è fuori finestra', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'romana',
        startMethod: PlannedPlantingStartMethod.directRows,
        plannedDate: DateTime(2026, 1, 10),
        quantity: 4,
        quantityType: PlannedPlantingQuantityType.plants,
      );

      final evaluation = AgronomicWindowService.evaluateBatch(
        rules: rules,
        batch: batch,
      );

      expect(evaluation.status, AgronomicWindowEvaluationStatus.incompatible);
      expect(evaluation.window, same(varietyWindow));
    });

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
      expect(evaluation.window, isNull);
    });

    test('usa il fallback generale della coltura', () {
      final batch = PlannedPlantingBatch(
        cropId: 'lattuga',
        varietyId: 'canasta',
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
      expect(evaluation.window, same(generalWindow));
    });
  });
}
