import '../family_consumption_need_validator.dart';
import '../models/family_consumption_need.dart';
import '../models/planned_planting_batch.dart';
import '../planned_planting_batch_validator.dart';

class SuccessionPlanningEngine {
  const SuccessionPlanningEngine();

  List<PlannedPlantingBatch> generate({
    required FamilyConsumptionNeed need,
    required DateTime startDate,
    required DateTime endDate,
    required PlannedPlantingStartMethod startMethod,
    required PlannedPlantingQuantityType quantityType,
    String? varietyId,
  }) {
    final needValidation = FamilyConsumptionNeedValidator.validate(need);

    if (!needValidation.isValid) {
      throw ArgumentError(
        needValidation.errorMessage ?? 'Il fabbisogno familiare non è valido.',
      );
    }

    if (!_isQuantityMappingSupported(
      consumptionUnit: need.unit,
      quantityType: quantityType,
    )) {
      throw ArgumentError(
        'L’unità del fabbisogno familiare non può essere convertita '
        'direttamente nel tipo di quantità richiesto per il lotto.',
      );
    }

    if (startDate.isAfter(endDate)) {
      throw ArgumentError(
        'La data iniziale non può essere successiva alla data finale.',
      );
    }

    final batches = <PlannedPlantingBatch>[];

    var plannedDate = startDate;

    while (!plannedDate.isAfter(endDate)) {
      final batch = PlannedPlantingBatch(
        cropId: need.cropId,
        varietyId: varietyId,
        startMethod: startMethod,
        plannedDate: plannedDate,
        quantity: need.quantity,
        quantityType: quantityType,
      );

      final batchValidation = PlannedPlantingBatchValidator.validate(batch);

      if (!batchValidation.isValid) {
        throw ArgumentError(
          batchValidation.errorMessage ?? 'Il lotto pianificato non è valido.',
        );
      }

      batches.add(batch);

      plannedDate = plannedDate.add(Duration(days: need.intervalDays));
    }

    return batches;
  }

  bool _isQuantityMappingSupported({
    required FamilyConsumptionUnit consumptionUnit,
    required PlannedPlantingQuantityType quantityType,
  }) {
    return consumptionUnit == FamilyConsumptionUnit.pieces &&
        quantityType == PlannedPlantingQuantityType.plants;
  }
}
