import '../data/models/bed_analysis_result.dart';
import '../data/models/planting.dart';
import 'agronomic_engine.dart';
import 'occupied_space.dart';

/// Analizza gli spazi occupati e liberi di un'aiuola.
///
/// Questa classe coordina i dati delle colture presenti con i calcoli
/// eseguiti da [AgronomicEngine].
class BedAnalyzer {
  const BedAnalyzer._();

  /// Analizza un'aiuola e individua il primo spazio libero abbastanza grande
  /// per contenere la lunghezza richiesta.
  static BedAnalysisResult analyze({
    required double bedLengthCm,
    required double requiredLengthCm,
    required List<Planting> plantings,
  }) {
    if (bedLengthCm <= 0) {
      return const BedAnalysisResult(
        freeSpaces: [],
        suggestedSpace: null,
        message: 'La lunghezza dell’aiuola deve essere maggiore di zero.',
      );
    }

    if (requiredLengthCm < 0) {
      return const BedAnalysisResult(
        freeSpaces: [],
        suggestedSpace: null,
        message: 'La lunghezza richiesta non può essere negativa.',
      );
    }

    final occupiedSpaces = plantings
        .map(
          (planting) => OccupiedSpace(
            startCm: planting.startPositionCm.toDouble(),
            endCm:
                (planting.startPositionCm + planting.lengthCm).toDouble(),
          ),
        )
        .toList();

    final freeSpaces = AgronomicEngine.findFreeSpaces(
      bedLengthCm: bedLengthCm,
      occupiedSpaces: occupiedSpaces,
    );

    final suggestedSpace = AgronomicEngine.firstSuitableSpace(
      bedLengthCm: bedLengthCm,
      requiredLengthCm: requiredLengthCm,
      occupiedSpaces: occupiedSpaces,
    );

    if (suggestedSpace == null) {
      return BedAnalysisResult(
        freeSpaces: freeSpaces,
        suggestedSpace: null,
        message:
            'Non è disponibile uno spazio abbastanza grande per questa coltura.',
      );
    }

    return BedAnalysisResult(
      freeSpaces: freeSpaces,
      suggestedSpace: suggestedSpace,
      message:
          'Spazio consigliato da ${suggestedSpace.startCm.toStringAsFixed(0)} '
          'a ${suggestedSpace.endCm.toStringAsFixed(0)} cm.',
    );
  }
}