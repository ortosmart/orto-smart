import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/agronomic_window.dart';
import 'package:orto_app/core/agronomy/models/crop_agronomic_window_rule.dart';
import 'package:orto_app/core/agronomy/models/planned_planting_batch.dart';

void main() {
  group('CropAgronomicWindowRule', () {
    const window = AgronomicWindow(
      startMethod: PlannedPlantingStartMethod.directRows,
      startMonth: 3,
      startDay: 15,
      endMonth: 9,
      endDay: 30,
    );

    test('rappresenta una regola generale della coltura', () {
      const rule = CropAgronomicWindowRule(cropId: 'lattuga', window: window);

      expect(rule.cropId, 'lattuga');
      expect(rule.varietyId, isNull);
      expect(rule.window, same(window));
    });

    test('rappresenta una regola specifica della varietà', () {
      const rule = CropAgronomicWindowRule(
        cropId: 'lattuga',
        varietyId: 'romana',
        window: window,
      );

      expect(rule.cropId, 'lattuga');
      expect(rule.varietyId, 'romana');
      expect(rule.window, same(window));
    });
  });
}
