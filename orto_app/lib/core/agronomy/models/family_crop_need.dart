enum FamilyNeedPriority { none, low, medium, high }

class FamilyCropNeed {
  const FamilyCropNeed({required this.cropId, required this.priority});

  /// ID della coltura.
  final String cropId;

  /// Priorità familiare assegnata alla coltura.
  final FamilyNeedPriority priority;
}
