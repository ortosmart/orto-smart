class CropCultivarWriteProtocolException implements Exception {
  final String message;

  const CropCultivarWriteProtocolException(this.message);

  @override
  String toString() => 'CropCultivarWriteProtocolException: $message';
}

// -----------------------------------------------------------------------------
// CREATE
// -----------------------------------------------------------------------------

sealed class CreateCropCultivarResult {
  const CreateCropCultivarResult();
}

class CropCultivarCreated extends CreateCropCultivarResult {
  final String cropCultivarId;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CropCultivarCreated({
    required this.cropCultivarId,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CreateCropCultivarForbidden extends CreateCropCultivarResult {
  const CreateCropCultivarForbidden();
}

class CreateCropCultivarInvalidInput extends CreateCropCultivarResult {
  const CreateCropCultivarInvalidInput();
}

class CreateCropCultivarCropNotFound extends CreateCropCultivarResult {
  const CreateCropCultivarCropNotFound();
}

class CreateCropCultivarDependencyInactive extends CreateCropCultivarResult {
  const CreateCropCultivarDependencyInactive();
}

class CreateCropCultivarDuplicateCanonicalName
    extends CreateCropCultivarResult {
  const CreateCropCultivarDuplicateCanonicalName();
}

// -----------------------------------------------------------------------------
// UPDATE
// -----------------------------------------------------------------------------

sealed class UpdateCropCultivarResult {
  const UpdateCropCultivarResult();
}

class CropCultivarUpdated extends UpdateCropCultivarResult {
  final String cropCultivarId;
  final int rowVersion;
  final DateTime updatedAt;

  const CropCultivarUpdated({
    required this.cropCultivarId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateCropCultivarUnchanged extends UpdateCropCultivarResult {
  final String cropCultivarId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateCropCultivarUnchanged({
    required this.cropCultivarId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateCropCultivarVersionConflict extends UpdateCropCultivarResult {
  final String? cropCultivarId;
  final int? expectedRowVersion;
  final int? currentRowVersion;
  final DateTime? updatedAt;

  const UpdateCropCultivarVersionConflict({
    this.cropCultivarId,
    this.expectedRowVersion,
    this.currentRowVersion,
    this.updatedAt,
  });
}

class UpdateCropCultivarForbidden extends UpdateCropCultivarResult {
  const UpdateCropCultivarForbidden();
}

class UpdateCropCultivarInvalidInput extends UpdateCropCultivarResult {
  const UpdateCropCultivarInvalidInput();
}

class UpdateCropCultivarNotFound extends UpdateCropCultivarResult {
  const UpdateCropCultivarNotFound();
}

class UpdateCropCultivarCropNotFound extends UpdateCropCultivarResult {
  const UpdateCropCultivarCropNotFound();
}

class UpdateCropCultivarDependencyInactive extends UpdateCropCultivarResult {
  const UpdateCropCultivarDependencyInactive();
}

class UpdateCropCultivarDuplicateCanonicalName
    extends UpdateCropCultivarResult {
  const UpdateCropCultivarDuplicateCanonicalName();
}

class UpdateCropCultivarIdentityInUse extends UpdateCropCultivarResult {
  const UpdateCropCultivarIdentityInUse();
}

// -----------------------------------------------------------------------------
// SET ACTIVE
// -----------------------------------------------------------------------------

sealed class SetCropCultivarActiveResult {
  const SetCropCultivarActiveResult();
}

class CropCultivarActiveChanged extends SetCropCultivarActiveResult {
  final String cropCultivarId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const CropCultivarActiveChanged({
    required this.cropCultivarId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetCropCultivarActiveUnchanged extends SetCropCultivarActiveResult {
  final String cropCultivarId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetCropCultivarActiveUnchanged({
    required this.cropCultivarId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetCropCultivarActiveVersionConflict extends SetCropCultivarActiveResult {
  final String? cropCultivarId;
  final int? expectedRowVersion;
  final int? currentRowVersion;
  final DateTime? updatedAt;

  const SetCropCultivarActiveVersionConflict({
    this.cropCultivarId,
    this.expectedRowVersion,
    this.currentRowVersion,
    this.updatedAt,
  });
}

class SetCropCultivarActiveForbidden extends SetCropCultivarActiveResult {
  const SetCropCultivarActiveForbidden();
}

class SetCropCultivarActiveInvalidInput extends SetCropCultivarActiveResult {
  const SetCropCultivarActiveInvalidInput();
}

class SetCropCultivarActiveNotFound extends SetCropCultivarActiveResult {
  const SetCropCultivarActiveNotFound();
}

class SetCropCultivarActiveDependencyInactive
    extends SetCropCultivarActiveResult {
  const SetCropCultivarActiveDependencyInactive();
}
