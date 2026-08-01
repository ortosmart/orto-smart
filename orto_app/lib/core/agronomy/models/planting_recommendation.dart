import 'suggestion_candidate.dart';

class PlantingRecommendation {
  const PlantingRecommendation({
    required this.candidate,
    required this.score,
    required this.reasons,
  });

  /// Possibilità tecnica valutata dal DecisionEngine.
  final SuggestionCandidate candidate;

  /// Punteggio complessivo assegnato alla raccomandazione.
  final double score;

  /// Motivazioni agronomiche che spiegano la raccomandazione.
  final List<String> reasons;
}
