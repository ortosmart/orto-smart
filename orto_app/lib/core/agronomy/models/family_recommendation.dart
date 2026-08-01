class FamilyRecommendation {
  const FamilyRecommendation({
    required this.cropId,
    required this.priority,
    required this.reason,
  });

  /// ID della coltura.
  final int cropId;

  /// Priorità assegnata dal FamilyNeedsEngine.
  /// Valore compreso tra 0.0 e 1.0.
  final double priority;

  /// Motivazione della priorità.
  final String reason;
}
