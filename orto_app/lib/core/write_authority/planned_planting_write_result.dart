sealed class CreatePlannedPlantingResult {
  const CreatePlannedPlantingResult();
}

final class CreatePlannedPlantingCreated extends CreatePlannedPlantingResult {
  final String seasonPlanId;
  final String plannedPlantingId;
  final int rowVersion;

  const CreatePlannedPlantingCreated({
    required this.seasonPlanId,
    required this.plannedPlantingId,
    required this.rowVersion,
  });
}

final class CreatePlannedPlantingForbidden extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingForbidden();
}

final class CreatePlannedPlantingWriteForbidden
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingWriteForbidden();
}

final class CreatePlannedPlantingNotFound extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingNotFound();
}

final class CreatePlannedPlantingInvalidInput
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingInvalidInput();
}

final class CreatePlannedPlantingInactiveGarden
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingInactiveGarden();
}

final class CreatePlannedPlantingInactiveBed
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingInactiveBed();
}

final class CreatePlannedPlantingInactiveCrop
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingInactiveCrop();
}

final class CreatePlannedPlantingInactiveCultivar
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingInactiveCultivar();
}

final class CreatePlannedPlantingMissingBedGeometry
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingMissingBedGeometry();
}

final class CreatePlannedPlantingOutsideBedGeometry
    extends CreatePlannedPlantingResult {
  const CreatePlannedPlantingOutsideBedGeometry();
}

sealed class UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingResult();
}

final class UpdatePlannedPlantingUpdated extends UpdatePlannedPlantingResult {
  final String plannedPlantingId;
  final int rowVersion;

  const UpdatePlannedPlantingUpdated({
    required this.plannedPlantingId,
    required this.rowVersion,
  });
}

final class UpdatePlannedPlantingForbidden extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingForbidden();
}

final class UpdatePlannedPlantingWriteForbidden
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingWriteForbidden();
}

final class UpdatePlannedPlantingNotFound extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingNotFound();
}

final class UpdatePlannedPlantingInvalidInput
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingInvalidInput();
}

final class UpdatePlannedPlantingVersionConflict
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingVersionConflict();
}

final class UpdatePlannedPlantingBlockedByLifecycle
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingBlockedByLifecycle();
}

final class UpdatePlannedPlantingInactiveGarden
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingInactiveGarden();
}

final class UpdatePlannedPlantingInactiveBed
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingInactiveBed();
}

final class UpdatePlannedPlantingInactiveCrop
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingInactiveCrop();
}

final class UpdatePlannedPlantingInactiveCultivar
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingInactiveCultivar();
}

final class UpdatePlannedPlantingMissingBedGeometry
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingMissingBedGeometry();
}

final class UpdatePlannedPlantingOutsideBedGeometry
    extends UpdatePlannedPlantingResult {
  const UpdatePlannedPlantingOutsideBedGeometry();
}

final class UpdatePlannedPlantingOverlap extends UpdatePlannedPlantingResult {
  final String bedId;

  const UpdatePlannedPlantingOverlap({required this.bedId});
}
