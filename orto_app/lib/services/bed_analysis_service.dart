import '../core/agronomy/engines/bed_companion_analyzer.dart';
import '../core/agronomy/models/bed_companion_analysis.dart';
import '../data/models/bed_analysis_result.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';
import '../data/models/suggestion_result.dart';
import 'bed_analyzer.dart';
import 'suggestion_engine.dart';

/// Coordina le analisi agronomiche relative a un'aiuola.
///
/// Questa classe non contiene logica agronomica propria:
/// delega i calcoli ai motori specializzati.
class BedAnalysisService {
  const BedAnalysisService._();

  /// Analizza gli spazi occupati e liberi dell'aiuola.
  static BedAnalysisResult analyzeSpace({
    required double bedLengthCm,
    required double requiredLengthCm,
    required List<Planting> plantings,
  }) {
    return BedAnalyzer.analyze(
      bedLengthCm: bedLengthCm,
      requiredLengthCm: requiredLengthCm,
      plantings: plantings,
    );
  }

  /// Analizza tutte le coppie di colture presenti nell'aiuola.
  static BedCompanionAnalysis analyzeCompanions({
    required List<Planting> plantings,
  }) {
    final cropIds = plantings.map((planting) => planting.cropId).toList();

    return BedCompanionAnalyzer.analyze(cropIds);
  }

  /// Genera i suggerimenti delle colture adatte agli spazi disponibili.
  static SuggestionResult generateSuggestions({
    required List<Crop> availableCrops,
    required List<Planting> existingPlantings,
    required Map<String, Crop> cropsById,
    required List<CropAssociation> associations,
    required BedAnalysisResult bedAnalysis,
  }) {
    return SuggestionEngine.generateSuggestions(
      availableCrops: availableCrops,
      existingPlantings: existingPlantings,
      cropsById: cropsById,
      associations: associations,
      bedAnalysis: bedAnalysis,
    );
  }
}
