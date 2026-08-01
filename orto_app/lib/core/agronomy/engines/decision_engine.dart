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
}
