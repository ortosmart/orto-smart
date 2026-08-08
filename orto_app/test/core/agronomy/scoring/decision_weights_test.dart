import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/scoring/decision_weights.dart';

void main() {
  group('DecisionWeights', () {
    test('la configurazione standard usa i pesi 40 30 30', () {
      const weights = DecisionWeights.standard;

      expect(weights.space, 0.4);
      expect(weights.rotation, 0.3);
      expect(weights.association, 0.3);
      expect(weights.total, 1.0);
      expect(weights.isValid, isTrue);
    });

    test('considera valida una configurazione con somma pari a 1', () {
      const weights = DecisionWeights(
        space: 0.5,
        rotation: 0.25,
        association: 0.25,
      );

      expect(weights.isValid, isTrue);
    });

    test('considera non valida una configurazione con somma diversa da 1', () {
      const weights = DecisionWeights(
        space: 0.5,
        rotation: 0.3,
        association: 0.3,
      );

      expect(weights.isValid, isFalse);
    });

    test('considera non valida una configurazione con peso negativo', () {
      const weights = DecisionWeights(
        space: -0.1,
        rotation: 0.6,
        association: 0.5,
      );

      expect(weights.isValid, isFalse);
    });
  });
}
