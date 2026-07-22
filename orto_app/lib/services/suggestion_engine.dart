import '../data/models/bed_analysis_result.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';
import '../data/models/suggestion_result.dart';
import 'association_engine.dart';
import 'rotation_engine.dart';

class SuggestionEngine {
  const SuggestionEngine();

  static SuggestionResult generateSuggestions({
    required List<Crop> availableCrops,
    required List<Planting> existingPlantings,
    required Map<String, Crop> cropsById,
    required List<CropAssociation> associations,
    required BedAnalysisResult bedAnalysis,
  }) {
    final suggestions = <CropSuggestion>[];

    for (final crop in availableCrops) {
      final requiredLength = _calculateRequiredLength(crop);
      final rows = _calculateRows(crop);
      final plants = _calculatePlants(crop);

      dynamic suitableSpace;

      for (final space in bedAnalysis.freeSpaces) {
        if (space.lengthCm >= requiredLength) {
          suitableSpace = space;
          break;
        }
      }

      if (suitableSpace == null) {
        continue;
      }

      final spaceScore = _calculateSpaceScore(
        requiredLength: requiredLength,
        availableLength: suitableSpace.lengthCm.round(),
      );

      final rotationResult = RotationEngine.evaluate(
        candidateCrop: crop,
        history: existingPlantings,
        cropsById: cropsById,
      );

      final cropAssociations = associations
    .where((association) => association.cropId == crop.id)
    .toList();

      final associationResult = AssociationEngine.evaluate(
        candidateCrop: crop,
        existingPlantings: existingPlantings,
        associations: cropAssociations,
        cropsById: cropsById,
      );

      final rotationScore = rotationResult.score;
      final associationScore = associationResult.score;

      final finalScore = _calculateFinalScore(
        spaceScore: spaceScore,
        rotationScore: rotationScore,
        associationScore: associationScore,
      );

      suggestions.add(
        CropSuggestion(
          crop: crop,
          score: finalScore,
          spaceScore: spaceScore,
          rotationScore: rotationScore,
          associationScore: associationScore,
          startPositionCm: suitableSpace.startCm.round(),
          lengthCm: requiredLength,
          plantsCount: plants,
          rowsCount: rows,
          reasons: [
            'La coltura entra nello spazio disponibile.',
            ...rotationResult.reasons,
            ...associationResult.reasons,
          ],
        ),
      );
    }

    return SuggestionResult(
      suggestions: suggestions,
      analyzedCropsCount: availableCrops.length,
    );
  }

  static int _calculateRequiredLength(Crop crop) {
    final plantSpacing = crop.plantSpacingCm;
    final rowSpacing = crop.rowSpacingCm;

    if (plantSpacing == null ||
        plantSpacing <= 0 ||
        rowSpacing == null ||
        rowSpacing <= 0) {
      return 100;
    }

    const bedWidthCm = 90;
    const desiredPlants = 12;

    final rows = ((bedWidthCm - 1) ~/ rowSpacing) + 1;
    final plantsPerRow = (desiredPlants / rows).ceil();

    if (plantsPerRow <= 1) {
      return plantSpacing;
    }

    return (plantsPerRow - 1) * plantSpacing;
  }

  static int _calculateRows(Crop crop) {
    final rowSpacing = crop.rowSpacingCm;

    if (rowSpacing == null || rowSpacing <= 0) {
      return 1;
    }

    const bedWidthCm = 90;
    final rows = ((bedWidthCm - 1) ~/ rowSpacing) + 1;

    return rows.clamp(1, 10);
  }

  static int _calculatePlants(Crop crop) {
    final plantSpacing = crop.plantSpacingCm;

    if (plantSpacing == null || plantSpacing <= 0) {
      return 0;
    }

    final requiredLength = _calculateRequiredLength(crop);
    final plantsPerRow = (requiredLength ~/ plantSpacing) + 1;
    final rows = _calculateRows(crop);

    return plantsPerRow * rows;
  }

  static int _calculateSpaceScore({
    required int requiredLength,
    required int availableLength,
  }) {
    if (requiredLength <= 0 || availableLength <= 0) {
      return 0;
    }

    final occupancyRatio = requiredLength / availableLength;

    if (occupancyRatio >= 0.75) {
      return 100;
    }

    if (occupancyRatio >= 0.50) {
      return 80;
    }

    if (occupancyRatio >= 0.25) {
      return 60;
    }

    return 40;
  }

static int _calculateFinalScore({
  required int spaceScore,
  required int rotationScore,
  required int associationScore,
}) {
  return ((spaceScore * 0.4) +
          (rotationScore * 0.3) +
          (associationScore * 0.3))
      .round();
}
}