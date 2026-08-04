/// Calcola il punteggio di adeguatezza dello spazio disponibile.
///
/// Il punteggio è espresso in una scala da 0 a 100
/// ed è basato sul rapporto tra lunghezza richiesta
/// e lunghezza disponibile.
class SpaceScoreCalculator {
  const SpaceScoreCalculator._();

  static int calculate({
    required int requiredLengthCm,
    required int availableLengthCm,
  }) {
    if (requiredLengthCm <= 0 || availableLengthCm <= 0) {
      return 0;
    }

    final occupancyRatio = requiredLengthCm / availableLengthCm;

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
}
