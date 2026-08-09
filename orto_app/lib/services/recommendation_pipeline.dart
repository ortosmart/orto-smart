import '../core/agronomy/adapters/free_space_adapter.dart';
import '../core/agronomy/engines/decision_engine.dart';
import '../core/agronomy/mappers/recommendation_mapper.dart';
import '../core/agronomy/models/candidate_agronomic_evaluation.dart';
import '../core/agronomy/models/suggestion_candidate.dart';
import '../core/agronomy/scoring/space_score_calculator.dart';
import '../core/agronomy/suggestion_engine.dart' as core;
import '../core/agronomy/scoring/decision_weights.dart';
import '../core/agronomy/engines/family_needs_engine.dart';
import '../core/agronomy/models/family_crop_need.dart';

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
    List<FamilyCropNeed> familyNeeds = const [],
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

    final decisionEngine = DecisionEngine(weights: DecisionWeights.standard);

    final recommendations = decisionEngine.evaluateAgronomic(
      evaluations: evaluations,
    );

    final familyRecommendations = const FamilyNeedsEngine().analyze(
      needs: familyNeeds,
    );

    final familyPriorityByCropId = {
      for (final recommendation in familyRecommendations)
        recommendation.cropId: recommendation.priority,
    };

    recommendations.sort((a, b) {
      final aBand = _ratingBand(a.score);
      final bBand = _ratingBand(b.score);

      final bandComparison = bBand.compareTo(aBand);

      if (bandComparison != 0) {
        return bandComparison;
      }

      final aFamilyPriority =
          familyPriorityByCropId[a.candidate.crop.id] ?? 0.0;
      final bFamilyPriority =
          familyPriorityByCropId[b.candidate.crop.id] ?? 0.0;

      final familyComparison = bFamilyPriority.compareTo(aFamilyPriority);

      if (familyComparison != 0) {
        return familyComparison;
      }

      return b.score.compareTo(a.score);
    });

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

  static int _ratingBand(double score) {
    if (score >= 85) {
      return 3;
    }

    if (score >= 70) {
      return 2;
    }

    if (score >= 50) {
      return 1;
    }

    return 0;
  }
}
