import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/engines/decision_engine.dart';
import 'package:orto_app/core/agronomy/models/candidate_agronomic_evaluation.dart';
import 'package:orto_app/core/agronomy/models/free_space.dart';
import 'package:orto_app/core/agronomy/models/suggestion_candidate.dart';
import 'package:orto_app/core/agronomy/scoring/decision_weights.dart';
import 'package:orto_app/data/models/association_result.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/rotation_result.dart';

SuggestionCandidate _candidate({
  required String cropId,
  required String cropName,
}) {
  return SuggestionCandidate(
    crop: Crop(id: cropId, name: cropName, plantSpacingCm: 40),
    freeSpace: const FreeSpace(startCm: 0, lengthCm: 200),
    maxPlants: 5,
    rows: 1,
    availableLengthCm: 200,
    requiredLengthCm: 200,
  );
}

CandidateAgronomicEvaluation _evaluation({
  required String cropId,
  required String cropName,
  required int spaceScore,
  required int rotationScore,
  required int associationScore,
  List<String> rotationReasons = const [],
  List<String> associationReasons = const [],
}) {
  return CandidateAgronomicEvaluation(
    candidate: _candidate(cropId: cropId, cropName: cropName),
    spaceScore: spaceScore,
    rotationResult: RotationResult.fromScore(
      score: rotationScore,
      reasons: rotationReasons,
    ),
    associationResult: AssociationResult(
      rating: AssociationRating.acceptable,
      score: associationScore,
      matches: const [],
      reasons: associationReasons,
    ),
  );
}

void main() {
  group('DecisionEngine - evaluateAgronomic', () {
    test('crea una raccomandazione per ogni valutazione agronomica', () {
      final engine = DecisionEngine();

      final evaluations = [
        _evaluation(
          cropId: '1',
          cropName: 'Pomodoro',
          spaceScore: 100,
          rotationScore: 80,
          associationScore: 60,
        ),
      ];

      final recommendations = engine.evaluateAgronomic(
        evaluations: evaluations,
      );

      expect(recommendations.length, 1);
      expect(recommendations.first.candidate.crop.name, 'Pomodoro');
    });

    test('calcola il punteggio ponderato 40 30 30', () {
      final engine = DecisionEngine();

      final evaluations = [
        _evaluation(
          cropId: '1',
          cropName: 'Pomodoro',
          spaceScore: 100,
          rotationScore: 80,
          associationScore: 60,
        ),
      ];

      final recommendations = engine.evaluateAgronomic(
        evaluations: evaluations,
      );

      expect(recommendations.first.score, 82);
    });

    test('ordina le raccomandazioni dal punteggio più alto al più basso', () {
      final engine = DecisionEngine();

      final evaluations = [
        _evaluation(
          cropId: '1',
          cropName: 'Pomodoro',
          spaceScore: 60,
          rotationScore: 50,
          associationScore: 40,
        ),
        _evaluation(
          cropId: '2',
          cropName: 'Lattuga',
          spaceScore: 100,
          rotationScore: 90,
          associationScore: 80,
        ),
      ];

      final recommendations = engine.evaluateAgronomic(
        evaluations: evaluations,
      );

      expect(recommendations.length, 2);
      expect(recommendations.first.candidate.crop.name, 'Lattuga');
      expect(recommendations.last.candidate.crop.name, 'Pomodoro');
      expect(
        recommendations.first.score,
        greaterThan(recommendations.last.score),
      );
    });

    test('riunisce le motivazioni di spazio rotazione e consociazione', () {
      final engine = DecisionEngine();

      final evaluations = [
        _evaluation(
          cropId: '1',
          cropName: 'Pomodoro',
          spaceScore: 100,
          rotationScore: 80,
          associationScore: 70,
          rotationReasons: const ['La rotazione è favorevole.'],
          associationReasons: const ['La consociazione è favorevole.'],
        ),
      ];

      final recommendations = engine.evaluateAgronomic(
        evaluations: evaluations,
      );

      final reasons = recommendations.first.reasons;

      expect(
        reasons,
        contains('La coltura è compatibile con lo spazio disponibile.'),
      );
      expect(reasons, contains('La rotazione è favorevole.'));
      expect(reasons, contains('La consociazione è favorevole.'));
    });
    test('usa una configurazione personalizzata dei pesi', () {
      final engine = DecisionEngine(
        weights: const DecisionWeights(
          space: 0.5,
          rotation: 0.3,
          association: 0.2,
        ),
      );

      final evaluations = [
        _evaluation(
          cropId: '1',
          cropName: 'Pomodoro',
          spaceScore: 100,
          rotationScore: 80,
          associationScore: 60,
        ),
      ];

      final recommendations = engine.evaluateAgronomic(
        evaluations: evaluations,
      );

      expect(recommendations.first.score, 86);
    });
    test('rifiuta una configurazione dei pesi non valida', () {
      expect(
        () => DecisionEngine(
          weights: const DecisionWeights(
            space: 0.5,
            rotation: 0.3,
            association: 0.3,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
