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
