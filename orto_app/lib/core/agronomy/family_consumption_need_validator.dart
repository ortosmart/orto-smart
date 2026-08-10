import 'models/family_consumption_need.dart';

class FamilyConsumptionNeedValidationResult {
  final bool isValid;
  final String? errorMessage;

  const FamilyConsumptionNeedValidationResult._({
    required this.isValid,
    this.errorMessage,
  });

  const FamilyConsumptionNeedValidationResult.valid() : this._(isValid: true);

  const FamilyConsumptionNeedValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

class FamilyConsumptionNeedValidator {
  const FamilyConsumptionNeedValidator._();

  static FamilyConsumptionNeedValidationResult validate(
    FamilyConsumptionNeed need,
  ) {
    if (need.cropId.trim().isEmpty) {
      return const FamilyConsumptionNeedValidationResult.invalid(
        'La coltura deve essere specificata.',
      );
    }

    if (need.quantity <= 0) {
      return const FamilyConsumptionNeedValidationResult.invalid(
        'La quantità consumata deve essere maggiore di zero.',
      );
    }

    if (need.intervalDays <= 0) {
      return const FamilyConsumptionNeedValidationResult.invalid(
        'L’intervallo di consumo deve essere maggiore di zero giorni.',
      );
    }

    return const FamilyConsumptionNeedValidationResult.valid();
  }
}
