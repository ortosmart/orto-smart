import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/agronomic_window_evaluation.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindowEvaluation', () {
    const window = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 15,
      endMonth: 9,
      endDay: 30,
    );

    test('rappresenta una valutazione compatibile', () {
      final evaluation = AgronomicWindowEvaluation.compatible(window: window);

      expect(evaluation.status, AgronomicWindowEvaluationStatus.compatible);
      expect(evaluation.isCompatible, isTrue);
      expect(evaluation.isIncompatible, isFalse);
      expect(evaluation.isUnknown, isFalse);
      expect(evaluation.window, same(window));
      expect(evaluation.reasons, isNotEmpty);
    });

    test('rappresenta una valutazione incompatibile', () {
      final evaluation = AgronomicWindowEvaluation.incompatible(window: window);

      expect(evaluation.status, AgronomicWindowEvaluationStatus.incompatible);
      expect(evaluation.isCompatible, isFalse);
      expect(evaluation.isIncompatible, isTrue);
      expect(evaluation.isUnknown, isFalse);
      expect(evaluation.window, same(window));
      expect(evaluation.reasons, isNotEmpty);
    });

    test('rappresenta una valutazione sconosciuta senza finestra', () {
      final evaluation = AgronomicWindowEvaluation.unknown();

      expect(evaluation.status, AgronomicWindowEvaluationStatus.unknown);
      expect(evaluation.isCompatible, isFalse);
      expect(evaluation.isIncompatible, isFalse);
      expect(evaluation.isUnknown, isTrue);
      expect(evaluation.window, isNull);
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
