enum FamilyConsumptionUnit { pieces, grams, kilograms }

class FamilyConsumptionNeed {
  const FamilyConsumptionNeed({
    required this.cropId,
    required this.quantity,
    required this.unit,
    required this.intervalDays,
  });

  /// ID della coltura.
  final String cropId;

  /// Quantità consumata dalla famiglia nell'intervallo indicato.
  final double quantity;

  /// Unità di misura della quantità.
  final FamilyConsumptionUnit unit;

  /// Numero di giorni dell'intervallo di consumo.
  final int intervalDays;
}
