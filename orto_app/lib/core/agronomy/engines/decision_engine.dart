import '../models/candidate_agronomic_evaluation.dart';
import '../models/planting_recommendation.dart';
import '../scoring/decision_weights.dart';

class DecisionEngine {
  DecisionEngine({this.weights = DecisionWeights.standard}) {
    if (!weights.isValid) {
      throw ArgumentError('La configurazione dei pesi deve essere valida.');
    }
  }

  /// Pesi applicati ai diversi criteri agronomici.
  final DecisionWeights weights;

  /// Valuta candidati già arricchiti con i risultati agronomici.
  ///
  /// Questa è l'API utilizzata dalla RecommendationPipeline.
  List<PlantingRecommendation> evaluateAgronomic({
    required List<CandidateAgronomicEvaluation> evaluations,
  }) {
    final recommendations = evaluations.map((evaluation) {
      final score = _calculateFinalScore(
        spaceScore: evaluation.spaceScore,
        rotationScore: evaluation.rotationResult.score,
        associationScore: evaluation.associationResult.score,
      );

      return PlantingRecommendation(
        candidate: evaluation.candidate,
        score: score,
        reasons: [
          'La coltura è compatibile con lo spazio disponibile.',
          ...evaluation.rotationResult.reasons,
          ...evaluation.associationResult.reasons,
        ],
      );
    }).toList();

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    return recommendations;
  }

  double _calculateFinalScore({
    required int spaceScore,
    required int rotationScore,
    required int associationScore,
  }) {
    return (spaceScore * weights.space) +
        (rotationScore * weights.rotation) +
        (associationScore * weights.association);
  }
}
