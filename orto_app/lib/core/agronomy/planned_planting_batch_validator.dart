import 'models/planned_planting_batch.dart';

class PlannedPlantingBatchValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PlannedPlantingBatchValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  const PlannedPlantingBatchValidationResult.valid() : this._(isValid: true);

  const PlannedPlantingBatchValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

class PlannedPlantingBatchValidator {
  const PlannedPlantingBatchValidator._();

  static PlannedPlantingBatchValidationResult validate(
    PlannedPlantingBatch batch,
  ) {
    if (batch.cropId.trim().isEmpty) {
      return const PlannedPlantingBatchValidationResult.invalid(
        'La coltura deve essere specificata.',
      );
    }

    if (batch.quantity <= 0) {
      return const PlannedPlantingBatchValidationResult.invalid(
        'La quantità prevista deve essere maggiore di zero.',
      );
    }

    switch (batch.startMethod) {
      case PlannedPlantingStartMethod.purchasedSeedlings:
      case PlannedPlantingStartMethod.nurseryThenTransplant:
      case PlannedPlantingStartMethod.directRows:
        if (batch.quantityType != PlannedPlantingQuantityType.plants) {
          return const PlannedPlantingBatchValidationResult.invalid(
            'Per questo metodo la quantità deve essere espressa '
            'come numero di piante previste.',
          );
        }

      case PlannedPlantingStartMethod.directBroadcast:
        if (batch.quantityType != PlannedPlantingQuantityType.areaSquareCm) {
          return const PlannedPlantingBatchValidationResult.invalid(
            'Per la semina a spaglio la quantità deve essere '
            'espressa come area prevista.',
          );
        }
    }

    return const PlannedPlantingBatchValidationResult.valid();
  }
}
