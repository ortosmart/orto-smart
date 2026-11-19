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

sealed class ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingResult();
}

final class ConfirmPlannedPlantingConfirmed
    extends ConfirmPlannedPlantingResult {
  final String plannedPlantingId;
  final int rowVersion;

  const ConfirmPlannedPlantingConfirmed({
    required this.plannedPlantingId,
    required this.rowVersion,
  });
}

final class ConfirmPlannedPlantingForbidden
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingForbidden();
}

final class ConfirmPlannedPlantingWriteForbidden
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingWriteForbidden();
}

final class ConfirmPlannedPlantingNotFound
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingNotFound();
}

final class ConfirmPlannedPlantingVersionConflict
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingVersionConflict();
}

final class ConfirmPlannedPlantingInactiveGarden
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingInactiveGarden();
}

final class ConfirmPlannedPlantingInactiveBed
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingInactiveBed();
}

final class ConfirmPlannedPlantingBlockedByLifecycle
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingBlockedByLifecycle();
}

final class ConfirmPlannedPlantingMissingBedGeometry
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingMissingBedGeometry();
}

final class ConfirmPlannedPlantingOutsideBedGeometry
    extends ConfirmPlannedPlantingResult {
  const ConfirmPlannedPlantingOutsideBedGeometry();
}

final class ConfirmPlannedPlantingOverlap extends ConfirmPlannedPlantingResult {
  final String bedId;

  const ConfirmPlannedPlantingOverlap({required this.bedId});
}

sealed class CancelPlannedPlantingResult {
  const CancelPlannedPlantingResult();
}

final class CancelPlannedPlantingCancelled extends CancelPlannedPlantingResult {
  final String plannedPlantingId;
  final int rowVersion;

  const CancelPlannedPlantingCancelled({
    required this.plannedPlantingId,
    required this.rowVersion,
  });
}

final class CancelPlannedPlantingForbidden extends CancelPlannedPlantingResult {
  const CancelPlannedPlantingForbidden();
}

final class CancelPlannedPlantingWriteForbidden
    extends CancelPlannedPlantingResult {
  const CancelPlannedPlantingWriteForbidden();
}

final class CancelPlannedPlantingNotFound extends CancelPlannedPlantingResult {
  const CancelPlannedPlantingNotFound();
}

final class CancelPlannedPlantingVersionConflict
    extends CancelPlannedPlantingResult {
  const CancelPlannedPlantingVersionConflict();
}

final class CancelPlannedPlantingBlockedByLifecycle
    extends CancelPlannedPlantingResult {
  const CancelPlannedPlantingBlockedByLifecycle();
}
