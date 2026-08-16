import '../core/agronomy/engines/agronomic_window_engine.dart';
import '../core/agronomy/engines/agronomic_window_resolver.dart';
import '../core/agronomy/models/agronomic_window_evaluation.dart';
import '../core/agronomy/models/crop_agronomic_window_rule.dart';
import '../core/agronomy/models/planned_planting_batch.dart';

/// Coordina la risoluzione e la valutazione delle finestre agronomiche.
///
/// Questa classe non contiene logica agronomica propria:
/// delega la selezione delle finestre al resolver
/// e la verifica temporale all'engine.
class AgronomicWindowService {
  const AgronomicWindowService._();

  static AgronomicWindowEvaluation evaluateBatch({
    required List<CropAgronomicWindowRule> rules,
    required PlannedPlantingBatch batch,
  }) {
    const resolver = AgronomicWindowResolver();
    const engine = AgronomicWindowEngine();

    final windows = resolver.resolveForBatch(rules: rules, batch: batch);

    if (windows.isEmpty) {
      return AgronomicWindowEvaluation.unknown(
        reason: 'Non esistono finestre agronomiche applicabili al lotto.',
      );
    }

    for (final window in windows) {
      if (engine.isBatchCompatible(window: window, batch: batch)) {
        return AgronomicWindowEvaluation.compatible(
          matchedWindow: window,
          evaluatedWindows: windows,
        );
      }
    }

    return AgronomicWindowEvaluation.incompatible(evaluatedWindows: windows);
  }
}
