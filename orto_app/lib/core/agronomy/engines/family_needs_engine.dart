import '../models/family_crop_need.dart';
import '../models/family_recommendation.dart';

class FamilyNeedsEngine {
  const FamilyNeedsEngine();

  /// Analizza le esigenze familiari associate alle colture.
  ///
  /// Converte i livelli di priorità in un valore normalizzato
  /// compreso tra 0.0 e 1.0.
  List<FamilyRecommendation> analyze({required List<FamilyCropNeed> needs}) {
    return needs
        .map(
          (need) => FamilyRecommendation(
            cropId: need.cropId,
            priority: _priorityValue(need.priority),
            reason: _priorityReason(need.priority),
          ),
        )
        .toList(growable: false);
  }

  double _priorityValue(FamilyNeedPriority priority) {
    switch (priority) {
      case FamilyNeedPriority.none:
        return 0.0;
      case FamilyNeedPriority.low:
        return 0.3;
      case FamilyNeedPriority.medium:
        return 0.6;
      case FamilyNeedPriority.high:
        return 1.0;
    }
  }

  String _priorityReason(FamilyNeedPriority priority) {
    switch (priority) {
      case FamilyNeedPriority.none:
        return 'Nessuna priorità familiare.';
      case FamilyNeedPriority.low:
        return 'Priorità familiare bassa.';
      case FamilyNeedPriority.medium:
        return 'Priorità familiare media.';
      case FamilyNeedPriority.high:
        return 'Priorità familiare alta.';
    }
  }
}
