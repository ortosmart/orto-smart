import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/scoring/space_score_calculator.dart';

void main() {
  group('SpaceScoreCalculator', () {
    test('restituisce 0 con valori non validi', () {
      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 0,
          availableLengthCm: 100,
        ),
        0,
      );

      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 50,
          availableLengthCm: 0,
        ),
        0,
      );
    });

    test('restituisce 100 con occupazione almeno del 75 percento', () {
      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 75,
          availableLengthCm: 100,
        ),
        100,
      );
    });

    test('restituisce 80 con occupazione almeno del 50 percento', () {
      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 50,
          availableLengthCm: 100,
        ),
        80,
      );
    });

    test('restituisce 60 con occupazione almeno del 25 percento', () {
      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 25,
          availableLengthCm: 100,
        ),
        60,
      );
    });

    test('restituisce 40 con occupazione inferiore al 25 percento', () {
      expect(
        SpaceScoreCalculator.calculate(
          requiredLengthCm: 20,
          availableLengthCm: 100,
        ),
        40,
      );
    });
  });
}
