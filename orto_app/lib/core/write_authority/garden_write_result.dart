class GardenWriteProtocolException implements Exception {
  const GardenWriteProtocolException();

  @override
  String toString() => 'GardenWriteProtocolException';
}

sealed class CreateGardenResult {
  const CreateGardenResult();
}

final class GardenCreated extends CreateGardenResult {
  final String gardenId;
  final int rowVersion;
  final DateTime createdAt;

  const GardenCreated({
    required this.gardenId,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreateGardenForbidden extends CreateGardenResult {
  const CreateGardenForbidden();
}

final class CreateGardenWriteForbidden extends CreateGardenResult {
  const CreateGardenWriteForbidden();
}

final class CreateGardenInvalidInput extends CreateGardenResult {
  const CreateGardenInvalidInput();
}

final class CreateGardenDuplicateName extends CreateGardenResult {
  const CreateGardenDuplicateName();
}
