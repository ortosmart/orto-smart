import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/decision_engine.dart';
import 'package:orto_app/core/agronomy/models/free_space.dart';
import 'package:orto_app/core/agronomy/models/suggestion_candidate.dart';
import 'package:orto_app/data/models/crop.dart';

void main() {
  group('DecisionEngine', () {
    test('crea una raccomandazione per ogni candidato', () {
      const engine = DecisionEngine();

      final candidates = [
        SuggestionCandidate(
          crop: const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
          freeSpace: const FreeSpace(startCm: 0, lengthCm: 200),
          maxPlants: 5,
          rows: 1,
          availableLengthCm: 200,
          requiredLengthCm: 200,
        ),
      ];

      final recommendations = engine.evaluate(candidates: candidates);

      expect(recommendations.length, 1);
      expect(recommendations.first.candidate.crop.name, 'Pomodoro');
    });
    test('assegna uno score pari al numero massimo di piante', () {
      const engine = DecisionEngine();

      final candidates = [
        SuggestionCandidate(
          crop: const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
          freeSpace: const FreeSpace(startCm: 0, lengthCm: 200),
          maxPlants: 5,
          rows: 1,
          availableLengthCm: 200,
          requiredLengthCm: 200,
        ),
      ];

      final recommendations = engine.evaluate(candidates: candidates);

      expect(recommendations.first.score, 5);
    });
    test('ordina le raccomandazioni dal punteggio più alto al più basso', () {
      const engine = DecisionEngine();

      final candidates = [
        SuggestionCandidate(
          crop: const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
          freeSpace: const FreeSpace(startCm: 0, lengthCm: 200),
          maxPlants: 5,
          rows: 1,
          availableLengthCm: 200,
          requiredLengthCm: 200,
        ),
        SuggestionCandidate(
          crop: const Crop(id: '2', name: 'Lattuga', plantSpacingCm: 30),
          freeSpace: const FreeSpace(startCm: 250, lengthCm: 300),
          maxPlants: 10,
          rows: 1,
          availableLengthCm: 300,
          requiredLengthCm: 300,
        ),
      ];

      final recommendations = engine.evaluate(candidates: candidates);

      expect(recommendations.length, 2);

      expect(recommendations.first.score, 10);
      expect(recommendations.first.candidate.crop.name, 'Lattuga');

      expect(recommendations.last.score, 5);
      expect(recommendations.last.candidate.crop.name, 'Pomodoro');
    });
    test('aggiunge una motivazione alla raccomandazione', () {
      const engine = DecisionEngine();

      final candidates = [
        SuggestionCandidate(
          crop: const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
          freeSpace: const FreeSpace(startCm: 0, lengthCm: 200),
          maxPlants: 5,
          rows: 1,
          availableLengthCm: 200,
          requiredLengthCm: 200,
        ),
      ];

      final recommendations = engine.evaluate(candidates: candidates);

      expect(recommendations.first.reasons, isNotEmpty);
      expect(recommendations.first.reasons.first, contains('5'));
    });
  });
}
