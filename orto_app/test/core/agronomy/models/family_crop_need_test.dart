import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/family_crop_need.dart';

void main() {
  group('FamilyCropNeed', () {
    test('mantiene cropId e priorità assegnati', () {
      const need = FamilyCropNeed(
        cropId: 'pomodoro',
        priority: FamilyNeedPriority.high,
      );

      expect(need.cropId, 'pomodoro');
      expect(need.priority, FamilyNeedPriority.high);
    });

    test('supporta tutti i livelli di priorità previsti', () {
      expect(FamilyNeedPriority.values, [
        FamilyNeedPriority.none,
        FamilyNeedPriority.low,
        FamilyNeedPriority.medium,
        FamilyNeedPriority.high,
      ]);
    });
  });
}
