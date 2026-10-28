
class AgronomicParameterWriteProtocolException implements Exception {
  final String message;

  const AgronomicParameterWriteProtocolException(this.message);

  @override
  String toString() =>
      'AgronomicParameterWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateAgronomicParameterResult {
  const CreateAgronomicParameterResult();
}

class AgronomicParameterCreated extends CreateAgronomicParameterResult {
  final String agronomicParameterId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const AgronomicParameterCreated({
    required this.agronomicParameterId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateAgronomicParameterForbidden
    extends CreateAgronomicParameterResult {
  const CreateAgronomicParameterForbidden();
}

class CreateAgronomicParameterInvalidInput
    extends CreateAgronomicParameterResult {
  const CreateAgronomicParameterInvalidInput();
}

class CreateAgronomicParameterUnitNotFound
    extends CreateAgronomicParameterResult {
  const CreateAgronomicParameterUnitNotFound();
}

class CreateAgronomicParameterDependencyInactive
    extends CreateAgronomicParameterResult {
  const CreateAgronomicParameterDependencyInactive();
}

class CreateAgronomicParameterDuplicateCode
    extends CreateAgronomicParameterResult {
  const CreateAgronomicParameterDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterResult();
}

class AgronomicParameterUpdated extends UpdateAgronomicParameterResult {
  final String agronomicParameterId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const AgronomicParameterUpdated({
    required this.agronomicParameterId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateAgronomicParameterUnchanged
    extends UpdateAgronomicParameterResult {
  final String agronomicParameterId;
  final int rowVersion;

  const UpdateAgronomicParameterUnchanged({
    required this.agronomicParameterId,
    required this.rowVersion,
  });
}

class UpdateAgronomicParameterVersionConflict
    extends UpdateAgronomicParameterResult {
  final int rowVersion;

  const UpdateAgronomicParameterVersionConflict({
    required this.rowVersion,
  });
}

class UpdateAgronomicParameterForbidden
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterForbidden();
}

class UpdateAgronomicParameterInvalidInput
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterInvalidInput();
}

class UpdateAgronomicParameterNotFound
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterNotFound();
}

class UpdateAgronomicParameterUnitNotFound
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterUnitNotFound();
}

class UpdateAgronomicParameterDependencyInactive
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterDependencyInactive();
}

class UpdateAgronomicParameterSemanticsFrozen
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterSemanticsFrozen();
}

class UpdateAgronomicParameterEnumValuesExist
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterEnumValuesExist();
}

class UpdateAgronomicParameterDuplicateCode
    extends UpdateAgronomicParameterResult {
  const UpdateAgronomicParameterDuplicateCode();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveResult();
}

class AgronomicParameterActiveChanged
    extends SetAgronomicParameterActiveResult {
  final String agronomicParameterId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const AgronomicParameterActiveChanged({
    required this.agronomicParameterId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetAgronomicParameterActiveUnchanged
    extends SetAgronomicParameterActiveResult {
  final String agronomicParameterId;
  final bool isActive;
  final int rowVersion;

  const SetAgronomicParameterActiveUnchanged({
    required this.agronomicParameterId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetAgronomicParameterActiveVersionConflict
    extends SetAgronomicParameterActiveResult {
  final int rowVersion;

  const SetAgronomicParameterActiveVersionConflict({
    required this.rowVersion,
  });
}

class SetAgronomicParameterActiveForbidden
    extends SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveForbidden();
}

class SetAgronomicParameterActiveInvalidInput
    extends SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveInvalidInput();
}

class SetAgronomicParameterActiveNotFound
    extends SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveNotFound();
}

class SetAgronomicParameterActiveDependencyInactive
    extends SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveDependencyInactive();
}

class SetAgronomicParameterActiveDependents
    extends SetAgronomicParameterActiveResult {
  const SetAgronomicParameterActiveDependents();
}
