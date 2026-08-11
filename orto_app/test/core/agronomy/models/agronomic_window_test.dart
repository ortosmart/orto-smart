import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('AgronomicWindow', () {
    test('mantiene i dati della finestra agronomica', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 3,
        startDay: 15,
        endMonth: 9,
        endDay: 30,
      );

      expect(window.startMethod, PlannedPlantingStartMethod.directRows);
      expect(window.startMonth, 3);
      expect(window.startDay, 15);
      expect(window.endMonth, 9);
      expect(window.endDay, 30);
    });

    test('può rappresentare una finestra che attraversa fine anno', () {
      const window = AgronomicWindow(
        startMethod: PlannedPlantingStartMethod.directRows,
        startMonth: 10,
        startDay: 1,
        endMonth: 2,
        endDay: 28,
      );

      expect(window.startMonth, 10);
      expect(window.endMonth, 2);
    });
  });
}
