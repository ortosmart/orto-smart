import '../models/candidate_agronomic_evaluation.dart';
import '../models/family_recommendation.dart';
import '../models/planting_recommendation.dart';
import '../models/suggestion_candidate.dart';

class DecisionEngine {
  const DecisionEngine();

  /// Valuta le possibilità tecniche e produce raccomandazioni agronomiche.
  ///
  /// Prima versione:
  /// restituisce una raccomandazione neutrale per ogni candidato ricevuto.
  List<PlantingRecommendation> evaluate({
    required List<SuggestionCandidate> candidates,
    List<FamilyRecommendation> familyRecommendations = const [],
  }) {
    final recommendations = candidates
        .map(
          (candidate) => PlantingRecommendation(
            candidate: candidate,
            score: candidate.maxPlants.toDouble(),
            reasons: ['Lo spazio consente ${candidate.maxPlants} piante.'],
          ),
        )
        .toList();

    recommendations.sort((a, b) => b.score.compareTo(a.score));

    return recommendations;
  }

  /// Valuta candidati già arricchiti con i risultati agronomici.
  ///
  /// Questa è la nuova API destinata alla RecommendationPipeline.
  List<PlantingRecommendation> evaluateAgronomic({
    required List<CandidateAgronomicEvaluation> evaluations,
    List<FamilyRecommendation> familyRecommendations = const [],
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

  static double _calculateFinalScore({
    required int spaceScore,
    required int rotationScore,
    required int associationScore,
  }) {
    return (spaceScore * 0.4) +
        (rotationScore * 0.3) +
        (associationScore * 0.3);
  }
}
