import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/mappers/recommendation_mapper.dart';
import 'package:orto_app/core/agronomy/models/candidate_agronomic_evaluation.dart';
import 'package:orto_app/core/agronomy/models/free_space.dart';
import 'package:orto_app/core/agronomy/models/planting_recommendation.dart';
import 'package:orto_app/core/agronomy/models/suggestion_candidate.dart';
import 'package:orto_app/data/models/association_result.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/rotation_result.dart';

void main() {
  group('RecommendationMapper', () {
    test('converte valutazione e raccomandazione in CropSuggestion', () {
      const candidate = SuggestionCandidate(
        crop: Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
        freeSpace: FreeSpace(startCm: 100, lengthCm: 240),
        maxPlants: 6,
        rows: 1,
        availableLengthCm: 240,
        requiredLengthCm: 240,
      );

      const evaluation = CandidateAgronomicEvaluation(
        candidate: candidate,
        spaceScore: 90,
        rotationResult: RotationResult(
          score: 80,
          rating: RotationRating.recommended,
          reasons: ['Rotazione favorevole.'],
        ),
        associationResult: AssociationResult(
          rating: AssociationRating.good,
          score: 70,
          matches: [],
          reasons: ['Consociazione favorevole.'],
        ),
      );

      const recommendation = PlantingRecommendation(
        candidate: candidate,
        score: 84.6,
        reasons: ['Rotazione favorevole.', 'Consociazione favorevole.'],
      );

      final result = RecommendationMapper.toCropSuggestion(
        evaluation: evaluation,
        recommendation: recommendation,
      );

      expect(result.crop.name, 'Pomodoro');
      expect(result.score, 85);
      expect(result.spaceScore, 90);
      expect(result.rotationScore, 80);
      expect(result.associationScore, 70);
      expect(result.startPositionCm, 100);
      expect(result.lengthCm, 240);
      expect(result.plantsCount, 6);
      expect(result.rowsCount, 1);
      expect(result.reasons.length, 2);
    });
  });
}
