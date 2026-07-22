import 'crop.dart';

enum SuggestionRating {
  excellent,
  good,
  acceptable,
  notRecommended,
}

class CropSuggestion {
  final Crop crop;

  /// Punteggio complessivo da 0 a 100.
  final int score;

  /// Valutazioni parziali usate dal motore.
  final int spaceScore;
  final int rotationScore;
  final int associationScore;

  /// Posizione suggerita nell’aiuola.
  final int startPositionCm;
  final int lengthCm;

  /// Numero indicativo di piante che possono essere collocate.
  final int plantsCount;
  final int rowsCount;

  /// Motivazioni mostrate all’utente.
  final List<String> reasons;

  const CropSuggestion({
    required this.crop,
    required this.score,
    required this.spaceScore,
    required this.rotationScore,
    required this.associationScore,
    required this.startPositionCm,
    required this.lengthCm,
    required this.plantsCount,
    required this.rowsCount,
    required this.reasons,
  });

  int get endPositionCm => startPositionCm + lengthCm;

  SuggestionRating get rating {
    if (score >= 85) {
      return SuggestionRating.excellent;
    }

    if (score >= 70) {
      return SuggestionRating.good;
    }

    if (score >= 50) {
      return SuggestionRating.acceptable;
    }

    return SuggestionRating.notRecommended;
  }

  String get ratingLabel {
    switch (rating) {
      case SuggestionRating.excellent:
        return 'Eccellente';
      case SuggestionRating.good:
        return 'Buona';
      case SuggestionRating.acceptable:
        return 'Accettabile';
      case SuggestionRating.notRecommended:
        return 'Non consigliata';
    }
  }
}

class SuggestionResult {
  final List<CropSuggestion> suggestions;
  final int analyzedCropsCount;

  const SuggestionResult({
    required this.suggestions,
    required this.analyzedCropsCount,
  });

  bool get hasSuggestions => suggestions.isNotEmpty;

  CropSuggestion? get bestSuggestion {
    if (suggestions.isEmpty) {
      return null;
    }

    return suggestions.first;
  }
}