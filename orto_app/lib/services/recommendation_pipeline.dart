import '../core/agronomy/adapters/free_space_adapter.dart';
import '../core/agronomy/engines/decision_engine.dart';
import '../core/agronomy/mappers/recommendation_mapper.dart';
import '../core/agronomy/models/candidate_agronomic_evaluation.dart';
import '../core/agronomy/models/suggestion_candidate.dart';
import '../core/agronomy/scoring/space_score_calculator.dart';
import '../core/agronomy/suggestion_engine.dart' as core;

import 'association_engine.dart';
import 'rotation_engine.dart';

import '../data/models/bed_analysis_result.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';
import '../data/models/suggestion_result.dart';

/// Coordina l'intero processo di generazione delle raccomandazioni.
///
/// La pipeline non contiene regole agronomiche proprie:
/// delega le valutazioni ai motori specializzati e converte
/// il risultato finale nel formato utilizzato dall'interfaccia.
class RecommendationPipeline {
  const RecommendationPipeline._();

  static SuggestionResult generate({
    required List<Crop> availableCrops,
    required List<Planting> existingPlantings,
    required Map<String, Crop> cropsById,
    required List<CropAssociation> associations,
    required BedAnalysisResult bedAnalysis,
  }) {
    final freeSpaces = FreeSpaceAdapter.fromLegacyList(bedAnalysis.freeSpaces);

    final candidates = core.SuggestionEngine.generateCandidates(
      freeSpaces: freeSpaces,
      crops: availableCrops,
    );

    final evaluations = _buildEvaluations(
      candidates: candidates,
      existingPlantings: existingPlantings,
      cropsById: cropsById,
      associations: associations,
    );

    const decisionEngine = DecisionEngine();

    final recommendations = decisionEngine.evaluateAgronomic(
      evaluations: evaluations,
    );

    final evaluationsByCandidate = {
      for (final evaluation in evaluations) evaluation.candidate: evaluation,
    };

    final suggestions = recommendations
        .map((recommendation) {
          final evaluation = evaluationsByCandidate[recommendation.candidate];

          if (evaluation == null) {
            throw StateError(
              'Valutazione agronomica non trovata per la raccomandazione.',
            );
          }

          return RecommendationMapper.toCropSuggestion(
            evaluation: evaluation,
            recommendation: recommendation,
          );
        })
        .toList(growable: false);

    return SuggestionResult(
      suggestions: suggestions,
      analyzedCropsCount: availableCrops.length,
    );
  }

  static List<CandidateAgronomicEvaluation> _buildEvaluations({
    required List<SuggestionCandidate> candidates,
    required List<Planting> existingPlantings,
    required Map<String, Crop> cropsById,
    required List<CropAssociation> associations,
  }) {
    final evaluations = <CandidateAgronomicEvaluation>[];

    for (final candidate in candidates) {
      final rotationResult = RotationEngine.evaluate(
        candidateCrop: candidate.crop,
        history: existingPlantings,
        cropsById: cropsById,
      );

      final cropAssociations = associations
          .where((association) => association.cropId == candidate.crop.id)
          .toList();

      final associationResult = AssociationEngine.evaluate(
        candidateCrop: candidate.crop,
        existingPlantings: existingPlantings,
        associations: cropAssociations,
        cropsById: cropsById,
      );

      final spaceScore = SpaceScoreCalculator.calculate(
        requiredLengthCm: candidate.requiredLengthCm,
        availableLengthCm: candidate.availableLengthCm,
      );

      evaluations.add(
        CandidateAgronomicEvaluation(
          candidate: candidate,
          spaceScore: spaceScore,
          rotationResult: rotationResult,
          associationResult: associationResult,
        ),
      );
    }

    return evaluations;
  }
}
