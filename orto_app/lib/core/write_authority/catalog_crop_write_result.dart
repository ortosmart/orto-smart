class CatalogCropWriteProtocolException implements Exception {
  final String message;

  const CatalogCropWriteProtocolException(this.message);

  @override
  String toString() => 'CatalogCropWriteProtocolException: $message';
}

sealed class CreateCatalogCropResult {
  const CreateCatalogCropResult();
}

class CatalogCropCreated extends CreateCatalogCropResult {
  final String catalogCropId;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CatalogCropCreated({
    required this.catalogCropId,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CreateCatalogCropForbidden extends CreateCatalogCropResult {
  const CreateCatalogCropForbidden();
}

class CreateCatalogCropInvalidInput extends CreateCatalogCropResult {
  const CreateCatalogCropInvalidInput();
}

class CreateCatalogCropTaxonNotFound extends CreateCatalogCropResult {
  const CreateCatalogCropTaxonNotFound();
}

class CreateCatalogCropDependencyInactive extends CreateCatalogCropResult {
  const CreateCatalogCropDependencyInactive();
}

class CreateCatalogCropDuplicateCanonicalName extends CreateCatalogCropResult {
  const CreateCatalogCropDuplicateCanonicalName();
}

sealed class UpdateCatalogCropResult {
  const UpdateCatalogCropResult();
}

class CatalogCropUpdated extends UpdateCatalogCropResult {
  final String catalogCropId;
  final int rowVersion;
  final DateTime updatedAt;

  const CatalogCropUpdated({
    required this.catalogCropId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateCatalogCropUnchanged extends UpdateCatalogCropResult {
  final String catalogCropId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateCatalogCropUnchanged({
    required this.catalogCropId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateCatalogCropVersionConflict extends UpdateCatalogCropResult {
  final String? catalogCropId;
  final int? expectedRowVersion;
  final int? currentRowVersion;
  final DateTime? updatedAt;

  const UpdateCatalogCropVersionConflict({
    this.catalogCropId,
    this.expectedRowVersion,
    this.currentRowVersion,
    this.updatedAt,
  });
}

class UpdateCatalogCropForbidden extends UpdateCatalogCropResult {
  const UpdateCatalogCropForbidden();
}

class UpdateCatalogCropInvalidInput extends UpdateCatalogCropResult {
  const UpdateCatalogCropInvalidInput();
}

class UpdateCatalogCropNotFound extends UpdateCatalogCropResult {
  const UpdateCatalogCropNotFound();
}

class UpdateCatalogCropTaxonNotFound extends UpdateCatalogCropResult {
  const UpdateCatalogCropTaxonNotFound();
}

class UpdateCatalogCropDependencyInactive extends UpdateCatalogCropResult {
  const UpdateCatalogCropDependencyInactive();
}

class UpdateCatalogCropDuplicateCanonicalName extends UpdateCatalogCropResult {
  const UpdateCatalogCropDuplicateCanonicalName();
}

sealed class SetCatalogCropActiveResult {
  const SetCatalogCropActiveResult();
}

class CatalogCropActiveChanged extends SetCatalogCropActiveResult {
  final String catalogCropId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const CatalogCropActiveChanged({
    required this.catalogCropId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetCatalogCropActiveUnchanged extends SetCatalogCropActiveResult {
  final String catalogCropId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetCatalogCropActiveUnchanged({
    required this.catalogCropId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetCatalogCropActiveVersionConflict extends SetCatalogCropActiveResult {
  final String? catalogCropId;
  final int? expectedRowVersion;
  final int? currentRowVersion;
  final DateTime? updatedAt;

  const SetCatalogCropActiveVersionConflict({
    this.catalogCropId,
    this.expectedRowVersion,
    this.currentRowVersion,
    this.updatedAt,
  });
}

class SetCatalogCropActiveForbidden extends SetCatalogCropActiveResult {
  const SetCatalogCropActiveForbidden();
}

class SetCatalogCropActiveInvalidInput extends SetCatalogCropActiveResult {
  const SetCatalogCropActiveInvalidInput();
}

class SetCatalogCropActiveNotFound extends SetCatalogCropActiveResult {
  const SetCatalogCropActiveNotFound();
}

class SetCatalogCropActiveDependencyInactive
    extends SetCatalogCropActiveResult {
  const SetCatalogCropActiveDependencyInactive();
}

class SetCatalogCropActiveDependents extends SetCatalogCropActiveResult {
  final String dependentType;
  final int dependentCount;

  const SetCatalogCropActiveDependents({
    required this.dependentType,
    required this.dependentCount,
  });
}
