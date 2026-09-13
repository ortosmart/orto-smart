class CropVarietyWriteProtocolException implements Exception {
  const CropVarietyWriteProtocolException();

  @override
  String toString() {
    return 'CropVarietyWriteProtocolException';
  }
}

class InactiveCropReference {
  final String cropId;
  final String cropName;

  const InactiveCropReference({required this.cropId, required this.cropName});
}

sealed class CreateCropVarietyResult {
  const CreateCropVarietyResult();
}

final class CropVarietyCreated extends CreateCropVarietyResult {
  final String cropVarietyId;
  final String profileId;
  final String cropId;
  final String name;
  final String? scientificName;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const CropVarietyCreated({
    required this.cropVarietyId,
    required this.profileId,
    required this.cropId,
    required this.name,
    required this.scientificName,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreateCropVarietyForbidden extends CreateCropVarietyResult {
  const CreateCropVarietyForbidden();
}

final class CreateCropVarietyWriteForbidden extends CreateCropVarietyResult {
  const CreateCropVarietyWriteForbidden();
}

final class CreateCropVarietyNotFound extends CreateCropVarietyResult {
  const CreateCropVarietyNotFound();
}

final class CreateCropVarietyInvalidInput extends CreateCropVarietyResult {
  const CreateCropVarietyInvalidInput();
}

final class CreateCropVarietyDuplicateName extends CreateCropVarietyResult {
  const CreateCropVarietyDuplicateName();
}

final class CreateCropVarietyBlockedByInactiveCrop
    extends CreateCropVarietyResult {
  final InactiveCropReference crop;

  const CreateCropVarietyBlockedByInactiveCrop({required this.crop});
}

sealed class UpdateCropVarietyResult {
  const UpdateCropVarietyResult();
}

final class CropVarietyUpdated extends UpdateCropVarietyResult {
  final String cropVarietyId;
  final String profileId;
  final String cropId;
  final String name;
  final String? scientificName;
  final int rowVersion;
  final DateTime updatedAt;

  const CropVarietyUpdated({
    required this.cropVarietyId,
    required this.profileId,
    required this.cropId,
    required this.name,
    required this.scientificName,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropVarietyUnchanged extends UpdateCropVarietyResult {
  final String cropVarietyId;
  final String cropId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateCropVarietyUnchanged({
    required this.cropVarietyId,
    required this.cropId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropVarietyVersionConflict extends UpdateCropVarietyResult {
  final String cropVarietyId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateCropVarietyVersionConflict({
    required this.cropVarietyId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateCropVarietyForbidden extends UpdateCropVarietyResult {
  const UpdateCropVarietyForbidden();
}

final class UpdateCropVarietyWriteForbidden extends UpdateCropVarietyResult {
  const UpdateCropVarietyWriteForbidden();
}

final class UpdateCropVarietyNotFound extends UpdateCropVarietyResult {
  const UpdateCropVarietyNotFound();
}

final class UpdateCropVarietyInvalidInput extends UpdateCropVarietyResult {
  const UpdateCropVarietyInvalidInput();
}

final class UpdateCropVarietyDuplicateName extends UpdateCropVarietyResult {
  const UpdateCropVarietyDuplicateName();
}

sealed class SetCropVarietyActiveResult {
  const SetCropVarietyActiveResult();
}

final class CropVarietyActiveUpdated extends SetCropVarietyActiveResult {
  final String cropVarietyId;
  final String profileId;
  final String cropId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const CropVarietyActiveUpdated({
    required this.cropVarietyId,
    required this.profileId,
    required this.cropId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetCropVarietyActiveUnchanged extends SetCropVarietyActiveResult {
  final String cropVarietyId;
  final String cropId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetCropVarietyActiveUnchanged({
    required this.cropVarietyId,
    required this.cropId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetCropVarietyActiveVersionConflict
    extends SetCropVarietyActiveResult {
  final String cropVarietyId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const SetCropVarietyActiveVersionConflict({
    required this.cropVarietyId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class SetCropVarietyActiveForbidden extends SetCropVarietyActiveResult {
  const SetCropVarietyActiveForbidden();
}

final class SetCropVarietyActiveWriteForbidden
    extends SetCropVarietyActiveResult {
  const SetCropVarietyActiveWriteForbidden();
}

final class SetCropVarietyActiveNotFound extends SetCropVarietyActiveResult {
  const SetCropVarietyActiveNotFound();
}

final class SetCropVarietyActiveInvalidInput
    extends SetCropVarietyActiveResult {
  const SetCropVarietyActiveInvalidInput();
}

final class SetCropVarietyActiveBlockedByInactiveCrop
    extends SetCropVarietyActiveResult {
  final String cropVarietyId;
  final InactiveCropReference crop;

  const SetCropVarietyActiveBlockedByInactiveCrop({
    required this.cropVarietyId,
    required this.crop,
  });
}
