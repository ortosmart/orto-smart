class CropWriteProtocolException implements Exception {
  const CropWriteProtocolException();

  @override
  String toString() {
    return 'CropWriteProtocolException';
  }
}

class InactiveBotanicalFamilyReference {
  final String botanicalFamilyId;
  final String botanicalFamilyName;

  const InactiveBotanicalFamilyReference({
    required this.botanicalFamilyId,
    required this.botanicalFamilyName,
  });
}

class ActiveCropVarietyReference {
  final String cropVarietyId;
  final String name;

  const ActiveCropVarietyReference({
    required this.cropVarietyId,
    required this.name,
  });
}

sealed class CreateCropResult {
  const CreateCropResult();
}

final class CropCreated extends CreateCropResult {
  final String cropId;
  final String profileId;
  final String botanicalFamilyId;
  final String name;
  final String? scientificName;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const CropCreated({
    required this.cropId,
    required this.profileId,
    required this.botanicalFamilyId,
    required this.name,
    required this.scientificName,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreateCropForbidden extends CreateCropResult {
  const CreateCropForbidden();
}

final class CreateCropWriteForbidden extends CreateCropResult {
  const CreateCropWriteForbidden();
}

final class CreateCropNotFound extends CreateCropResult {
  const CreateCropNotFound();
}

final class CreateCropInvalidInput extends CreateCropResult {
  const CreateCropInvalidInput();
}

final class CreateCropDuplicateName extends CreateCropResult {
  const CreateCropDuplicateName();
}

final class CreateCropDuplicateScientificName extends CreateCropResult {
  const CreateCropDuplicateScientificName();
}

final class CreateCropBlockedByInactiveBotanicalFamily
    extends CreateCropResult {
  final InactiveBotanicalFamilyReference botanicalFamily;

  const CreateCropBlockedByInactiveBotanicalFamily({
    required this.botanicalFamily,
  });
}

sealed class UpdateCropResult {
  const UpdateCropResult();
}

final class CropUpdated extends UpdateCropResult {
  final String cropId;
  final String profileId;
  final String botanicalFamilyId;
  final String name;
  final String? scientificName;
  final int rowVersion;
  final DateTime updatedAt;

  const CropUpdated({
    required this.cropId,
    required this.profileId,
    required this.botanicalFamilyId,
    required this.name,
    required this.scientificName,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropUnchanged extends UpdateCropResult {
  final String cropId;
  final String botanicalFamilyId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateCropUnchanged({
    required this.cropId,
    required this.botanicalFamilyId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropVersionConflict extends UpdateCropResult {
  final String cropId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateCropVersionConflict({
    required this.cropId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropForbidden extends UpdateCropResult {
  const UpdateCropForbidden();
}

final class UpdateCropWriteForbidden extends UpdateCropResult {
  const UpdateCropWriteForbidden();
}

final class UpdateCropNotFound extends UpdateCropResult {
  const UpdateCropNotFound();
}

final class UpdateCropInvalidInput extends UpdateCropResult {
  const UpdateCropInvalidInput();
}

final class UpdateCropDuplicateName extends UpdateCropResult {
  const UpdateCropDuplicateName();
}

final class UpdateCropDuplicateScientificName extends UpdateCropResult {
  const UpdateCropDuplicateScientificName();
}

final class UpdateCropBlockedByInactiveBotanicalFamily
    extends UpdateCropResult {
  final InactiveBotanicalFamilyReference botanicalFamily;

  const UpdateCropBlockedByInactiveBotanicalFamily({
    required this.botanicalFamily,
  });
}

sealed class SetCropActiveResult {
  const SetCropActiveResult();
}

final class CropActiveUpdated extends SetCropActiveResult {
  final String cropId;
  final String profileId;
  final String botanicalFamilyId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const CropActiveUpdated({
    required this.cropId,
    required this.profileId,
    required this.botanicalFamilyId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetCropActiveUnchanged extends SetCropActiveResult {
  final String cropId;
  final String botanicalFamilyId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetCropActiveUnchanged({
    required this.cropId,
    required this.botanicalFamilyId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetCropActiveVersionConflict extends SetCropActiveResult {
  final String cropId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const SetCropActiveVersionConflict({
    required this.cropId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class SetCropActiveForbidden extends SetCropActiveResult {
  const SetCropActiveForbidden();
}

final class SetCropActiveWriteForbidden extends SetCropActiveResult {
  const SetCropActiveWriteForbidden();
}

final class SetCropActiveNotFound extends SetCropActiveResult {
  const SetCropActiveNotFound();
}

final class SetCropActiveInvalidInput extends SetCropActiveResult {
  const SetCropActiveInvalidInput();
}

final class SetCropActiveBlockedByInactiveBotanicalFamily
    extends SetCropActiveResult {
  final String cropId;
  final InactiveBotanicalFamilyReference botanicalFamily;

  const SetCropActiveBlockedByInactiveBotanicalFamily({
    required this.cropId,
    required this.botanicalFamily,
  });
}

final class SetCropActiveBlockedByActiveCropVarieties
    extends SetCropActiveResult {
  final String cropId;
  final List<ActiveCropVarietyReference> activeCropVarieties;

  const SetCropActiveBlockedByActiveCropVarieties({
    required this.cropId,
    required this.activeCropVarieties,
  });
}
