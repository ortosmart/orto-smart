class PlantingValidationResult {
  final bool isValid;
  final String? errorMessage;

  const PlantingValidationResult._({required this.isValid, this.errorMessage});

  const PlantingValidationResult.valid() : this._(isValid: true);

  const PlantingValidationResult.invalid(String message)
    : this._(isValid: false, errorMessage: message);
}

class PlantingValidator {
  const PlantingValidator._();

  static PlantingValidationResult validate({
    required num startPositionCm,
    required num lengthCm,
    required num bedLengthCm,
    Iterable<String> overlappingCropNames = const [],
  }) {
    final start = startPositionCm.toDouble();
    final length = lengthCm.toDouble();
    final bedLength = bedLengthCm.toDouble();

    if (length <= 0) {
      return const PlantingValidationResult.invalid(
        'La lunghezza occupata deve essere maggiore di zero.',
      );
    }

    if (start < 0) {
      return const PlantingValidationResult.invalid(
        'La posizione iniziale non può essere negativa.',
      );
    }

    if (start + length > bedLength) {
      return const PlantingValidationResult.invalid(
        'La coltura supera i limiti dell’aiuola.',
      );
    }

    final overlappingNames = overlappingCropNames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    if (overlappingNames.isNotEmpty) {
      return PlantingValidationResult.invalid(
        'La posizione scelta si sovrappone a: '
        '${overlappingNames.join(', ')}. '
        'Sposta l’inizio dalla testata oppure usa la posizione consigliata.',
      );
    }

    return const PlantingValidationResult.valid();
  }
}
