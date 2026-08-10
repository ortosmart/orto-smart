enum PlannedPlantingStartMethod {
  purchasedSeedlings,
  nurseryThenTransplant,
  directRows,
  directBroadcast,
}

enum PlannedPlantingQuantityType { plants, seedGrams, areaSquareCm }

class PlannedPlantingBatch {
  const PlannedPlantingBatch({
    required this.cropId,
    this.varietyId,
    required this.startMethod,
    required this.plannedDate,
    required this.quantity,
    required this.quantityType,
  });

  /// ID della coltura da pianificare.
  final String cropId;

  /// ID opzionale della varietà.
  final String? varietyId;

  /// Modalità prevista di avvio della coltura.
  final PlannedPlantingStartMethod startMethod;

  /// Data prevista per l'avvio del lotto.
  final DateTime plannedDate;

  /// Quantità prevista per il lotto.
  final double quantity;

  /// Tipo di quantità utilizzata.
  final PlannedPlantingQuantityType quantityType;
}
