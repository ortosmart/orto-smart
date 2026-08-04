import '../../../data/models/suggestion_result.dart';
import '../models/candidate_agronomic_evaluation.dart';
import '../models/planting_recommendation.dart';

/// Converte le valutazioni e le raccomandazioni del motore agronomico
/// nei modelli utilizzati dall'interfaccia utente.
///
/// Non contiene logica agronomica:
/// esegue esclusivamente la trasformazione dei dati.
class RecommendationMapper {
  const RecommendationMapper._();

  static CropSuggestion toCropSuggestion({
    required CandidateAgronomicEvaluation evaluation,
    required PlantingRecommendation recommendation,
  }) {
    final candidate = evaluation.candidate;

    return CropSuggestion(
      crop: candidate.crop,
      score: recommendation.score.round(),
      spaceScore: evaluation.spaceScore,
      rotationScore: evaluation.rotationResult.score,
      associationScore: evaluation.associationResult.score,
      startPositionCm: candidate.freeSpace.startCm,
      lengthCm: candidate.requiredLengthCm,
      plantsCount: candidate.maxPlants,
      rowsCount: candidate.rows,
      reasons: recommendation.reasons,
    );
  }
}
