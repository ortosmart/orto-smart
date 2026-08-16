import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window_evaluation.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowEvaluation', () {
    const firstWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 2,
      startDay: 15,
      endMonth: 5,
      endDay: 31,
    );

    const secondWindow = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 8,
      startDay: 20,
      endMonth: 10,
      endDay: 15,
    );

    const evaluatedWindows = [firstWindow, secondWindow];

    test('rappresenta una valutazione compatibile', () {
      final evaluation = AgronomicWindowEvaluation.compatible(
        matchedWindow: firstWindow,
        evaluatedWindows: evaluatedWindows,
      );

      expect(evaluation.status, AgronomicWindowEvaluationStatus.compatible);
      expect(evaluation.isCompatible, isTrue);
      expect(evaluation.isIncompatible, isFalse);
      expect(evaluation.isUnknown, isFalse);
      expect(evaluation.matchedWindow, same(firstWindow));
      expect(evaluation.evaluatedWindows, evaluatedWindows);
      expect(evaluation.reasons, isNotEmpty);
    });

    test('rappresenta una valutazione incompatibile', () {
      final evaluation = AgronomicWindowEvaluation.incompatible(
        evaluatedWindows: evaluatedWindows,
      );

      expect(evaluation.status, AgronomicWindowEvaluationStatus.incompatible);
      expect(evaluation.isCompatible, isFalse);
      expect(evaluation.isIncompatible, isTrue);
      expect(evaluation.isUnknown, isFalse);
      expect(evaluation.matchedWindow, isNull);
      expect(evaluation.evaluatedWindows, evaluatedWindows);
      expect(evaluation.reasons, isNotEmpty);
    });

    test('rappresenta una valutazione sconosciuta senza finestre', () {
      final evaluation = AgronomicWindowEvaluation.unknown();

      expect(evaluation.status, AgronomicWindowEvaluationStatus.unknown);
      expect(evaluation.isCompatible, isFalse);
      expect(evaluation.isIncompatible, isFalse);
      expect(evaluation.isUnknown, isTrue);
      expect(evaluation.matchedWindow, isNull);
      expect(evaluation.evaluatedWindows, isEmpty);
      expect(evaluation.reasons, isNotEmpty);
    });

    test('mantiene una motivazione personalizzata', () {
      final evaluation = AgronomicWindowEvaluation.unknown(
        reason: 'Nessuna regola disponibile per la coltura.',
      );

      expect(evaluation.reasons, [
        'Nessuna regola disponibile per la coltura.',
      ]);
    });
  });
}
