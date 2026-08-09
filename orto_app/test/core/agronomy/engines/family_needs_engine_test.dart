import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/family_needs_engine.dart';
import 'package:orto_app/core/agronomy/models/family_crop_need.dart';

void main() {
  group('FamilyNeedsEngine', () {
    const engine = FamilyNeedsEngine();

    test('converte priorità alta in 1.0', () {
      const needs = [
        FamilyCropNeed(cropId: 'pomodoro', priority: FamilyNeedPriority.high),
      ];

      final recommendations = engine.analyze(needs: needs);

      expect(recommendations.length, 1);
      expect(recommendations.first.cropId, 'pomodoro');
      expect(recommendations.first.priority, 1.0);
      expect(recommendations.first.reason, 'Priorità familiare alta.');
    });

    test('converte tutti i livelli nelle priorità previste', () {
      const needs = [
        FamilyCropNeed(cropId: 'nessuna', priority: FamilyNeedPriority.none),
        FamilyCropNeed(cropId: 'bassa', priority: FamilyNeedPriority.low),
        FamilyCropNeed(cropId: 'media', priority: FamilyNeedPriority.medium),
        FamilyCropNeed(cropId: 'alta', priority: FamilyNeedPriority.high),
      ];

      final recommendations = engine.analyze(needs: needs);

      expect(recommendations.map((item) => item.priority).toList(), [
        0.0,
        0.3,
        0.6,
        1.0,
      ]);
    });

    test('restituisce una lista vuota quando non ci sono esigenze', () {
      final recommendations = engine.analyze(needs: const []);

      expect(recommendations, isEmpty);
    });
    test('mantiene l ordine delle esigenze ricevute', () {
      const needs = [
        FamilyCropNeed(cropId: 'lattuga', priority: FamilyNeedPriority.low),
        FamilyCropNeed(cropId: 'pomodoro', priority: FamilyNeedPriority.high),
      ];

      final recommendations = engine.analyze(needs: needs);

      expect(recommendations.map((item) => item.cropId).toList(), [
        'lattuga',
        'pomodoro',
      ]);
    });
  });
}
