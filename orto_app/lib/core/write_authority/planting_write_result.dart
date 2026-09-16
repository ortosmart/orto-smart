class PlantingWriteProtocolException implements Exception {
  const PlantingWriteProtocolException();

  @override
  String toString() {
    return 'PlantingWriteProtocolException';
  }
}

sealed class CreatePlantingResult {
  const CreatePlantingResult();
}

final class PlantingCreated extends CreatePlantingResult {
  final String plantingId;
  final String profileId;
  final String gardenId;
  final String seasonId;
  final String bedId;
  final String cropId;
  final String? varietyId;

  final String startMethod;
  final DateTime startDate;
  final DateTime? endDate;

  final int startPositionCm;
  final int lengthCm;
  final int occupiedWidthCm;

  final String status;
  final int rowVersion;
  final DateTime createdAt;

  const PlantingCreated({
    required this.plantingId,
    required this.profileId,
    required this.gardenId,
    required this.seasonId,
    required this.bedId,
    required this.cropId,
    required this.varietyId,
    required this.startMethod,
    required this.startDate,
    required this.endDate,
    required this.startPositionCm,
    required this.lengthCm,
    required this.occupiedWidthCm,
    required this.status,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreatePlantingForbidden extends CreatePlantingResult {
  const CreatePlantingForbidden();
}

final class CreatePlantingWriteForbidden extends CreatePlantingResult {
  const CreatePlantingWriteForbidden();
}

final class CreatePlantingNotFound extends CreatePlantingResult {
  const CreatePlantingNotFound();
}

final class CreatePlantingInvalidInput extends CreatePlantingResult {
  const CreatePlantingInvalidInput();
}

final class CreatePlantingBlockedByInactiveGarden extends CreatePlantingResult {
  const CreatePlantingBlockedByInactiveGarden();
}

final class CreatePlantingBlockedByInactiveBed extends CreatePlantingResult {
  const CreatePlantingBlockedByInactiveBed();
}

final class CreatePlantingBlockedByInactiveCrop extends CreatePlantingResult {
  const CreatePlantingBlockedByInactiveCrop();
}

final class CreatePlantingBlockedByInactiveVariety
    extends CreatePlantingResult {
  const CreatePlantingBlockedByInactiveVariety();
}

final class CreatePlantingOutsideBedGeometry extends CreatePlantingResult {
  const CreatePlantingOutsideBedGeometry();
}

final class CreatePlantingOverlap extends CreatePlantingResult {
  const CreatePlantingOverlap();
}

sealed class UpdatePlantingResult {
  const UpdatePlantingResult();
}

final class PlantingUpdated extends UpdatePlantingResult {
  final String plantingId;
  final String gardenId;
  final String bedId;
  final String seasonId;
  final String cropId;
  final String? varietyId;

  final String startMethod;
  final DateTime startDate;

  final int startPositionCm;
  final int lengthCm;
  final int occupiedWidthCm;

  final String status;
  final int rowVersion;
  final DateTime updatedAt;

  const PlantingUpdated({
    required this.plantingId,
    required this.gardenId,
    required this.bedId,
    required this.seasonId,
    required this.cropId,
    required this.varietyId,
    required this.startMethod,
    required this.startDate,
    required this.startPositionCm,
    required this.lengthCm,
    required this.occupiedWidthCm,
    required this.status,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdatePlantingUnchanged extends UpdatePlantingResult {
  final String plantingId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdatePlantingUnchanged({
    required this.plantingId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdatePlantingVersionConflict extends UpdatePlantingResult {
  final String plantingId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdatePlantingVersionConflict({
    required this.plantingId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdatePlantingForbidden extends UpdatePlantingResult {
  const UpdatePlantingForbidden();
}

final class UpdatePlantingWriteForbidden extends UpdatePlantingResult {
  const UpdatePlantingWriteForbidden();
}

final class UpdatePlantingNotFound extends UpdatePlantingResult {
  const UpdatePlantingNotFound();
}

final class UpdatePlantingInvalidInput extends UpdatePlantingResult {
  const UpdatePlantingInvalidInput();
}

final class UpdatePlantingBlockedByInactiveCrop extends UpdatePlantingResult {
  const UpdatePlantingBlockedByInactiveCrop();
}

final class UpdatePlantingBlockedByInactiveVariety
    extends UpdatePlantingResult {
  const UpdatePlantingBlockedByInactiveVariety();
}

final class UpdatePlantingStartMethodLocked extends UpdatePlantingResult {
  const UpdatePlantingStartMethodLocked();
}

final class UpdatePlantingStartDateLocked extends UpdatePlantingResult {
  const UpdatePlantingStartDateLocked();
}

final class UpdatePlantingOutsideBedGeometry extends UpdatePlantingResult {
  const UpdatePlantingOutsideBedGeometry();
}

final class UpdatePlantingOverlap extends UpdatePlantingResult {
  const UpdatePlantingOverlap();
}

sealed class SetPlantingStatusResult {
  const SetPlantingStatusResult();
}

final class PlantingStatusUpdated extends SetPlantingStatusResult {
  final String plantingId;
  final String gardenId;
  final String previousStatus;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final int rowVersion;
  final DateTime updatedAt;

  const PlantingStatusUpdated({
    required this.plantingId,
    required this.gardenId,
    required this.previousStatus,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetPlantingStatusUnchanged extends SetPlantingStatusResult {
  final String plantingId;
  final int rowVersion;
  final DateTime updatedAt;

  const SetPlantingStatusUnchanged({
    required this.plantingId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetPlantingStatusVersionConflict extends SetPlantingStatusResult {
  final String plantingId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const SetPlantingStatusVersionConflict({
    required this.plantingId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class SetPlantingStatusForbidden extends SetPlantingStatusResult {
  const SetPlantingStatusForbidden();
}

final class SetPlantingStatusWriteForbidden extends SetPlantingStatusResult {
  const SetPlantingStatusWriteForbidden();
}

final class SetPlantingStatusNotFound extends SetPlantingStatusResult {
  const SetPlantingStatusNotFound();
}

final class SetPlantingStatusInvalidInput extends SetPlantingStatusResult {
  const SetPlantingStatusInvalidInput();
}

final class SetPlantingStatusInvalidTransition extends SetPlantingStatusResult {
  final String plantingId;
  final String currentStatus;
  final String targetStatus;

  const SetPlantingStatusInvalidTransition({
    required this.plantingId,
    required this.currentStatus,
    required this.targetStatus,
  });
}
