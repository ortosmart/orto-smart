enum RotationRating {
  recommended,
  acceptable,
  discouraged,
  unknown,
}

class RotationResult {
  final int score;
  final RotationRating rating;
  final List<String> reasons;
  final int? seasonsSinceSameFamily;
  final int? requiredRotationSeasons;

  const RotationResult({
    required this.score,
    required this.rating,
    required this.reasons,
    this.seasonsSinceSameFamily,
    this.requiredRotationSeasons,
  });

  bool get isRecommended => rating == RotationRating.recommended;

  bool get isAcceptable => rating == RotationRating.acceptable;

  bool get isDiscouraged => rating == RotationRating.discouraged;

  bool get hasEnoughHistory =>
      rating != RotationRating.unknown;

  String get label {
    switch (rating) {
      case RotationRating.recommended:
        return 'Consigliata';
      case RotationRating.acceptable:
        return 'Accettabile';
      case RotationRating.discouraged:
        return 'Sconsigliata';
      case RotationRating.unknown:
        return 'Dati insufficienti';
    }
  }

  factory RotationResult.fromScore({
    required int score,
    required List<String> reasons,
    int? seasonsSinceSameFamily,
    int? requiredRotationSeasons,
  }) {
    final normalizedScore = score.clamp(0, 100);

    final RotationRating rating;

    if (normalizedScore >= 75) {
      rating = RotationRating.recommended;
    } else if (normalizedScore >= 45) {
      rating = RotationRating.acceptable;
    } else {
      rating = RotationRating.discouraged;
    }

    return RotationResult(
      score: normalizedScore,
      rating: rating,
      reasons: List.unmodifiable(reasons),
      seasonsSinceSameFamily: seasonsSinceSameFamily,
      requiredRotationSeasons: requiredRotationSeasons,
    );
  }

  factory RotationResult.unknown({
    String reason = 'Non ci sono dati sufficienti per valutare la rotazione.',
  }) {
    return RotationResult(
      score: 50,
      rating: RotationRating.unknown,
      reasons: List.unmodifiable([reason]),
    );
  }
}