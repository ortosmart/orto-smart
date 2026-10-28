
class MeasurementUnitWriteProtocolException implements Exception {
  final String message;

  const MeasurementUnitWriteProtocolException(this.message);

  @override
  String toString() => 'MeasurementUnitWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateMeasurementUnitResult {
  const CreateMeasurementUnitResult();
}

class MeasurementUnitCreated extends CreateMeasurementUnitResult {
  final String measurementUnitId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const MeasurementUnitCreated({
    required this.measurementUnitId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateMeasurementUnitForbidden extends CreateMeasurementUnitResult {
  const CreateMeasurementUnitForbidden();
}

class CreateMeasurementUnitInvalidInput extends CreateMeasurementUnitResult {
  const CreateMeasurementUnitInvalidInput();
}

class CreateMeasurementUnitDuplicateCode extends CreateMeasurementUnitResult {
  const CreateMeasurementUnitDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitResult();
}

class MeasurementUnitUpdated extends UpdateMeasurementUnitResult {
  final String measurementUnitId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const MeasurementUnitUpdated({
    required this.measurementUnitId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateMeasurementUnitUnchanged extends UpdateMeasurementUnitResult {
  final String measurementUnitId;
  final int rowVersion;

  const UpdateMeasurementUnitUnchanged({
    required this.measurementUnitId,
    required this.rowVersion,
  });
}

class UpdateMeasurementUnitVersionConflict
    extends UpdateMeasurementUnitResult {
  final int rowVersion;

  const UpdateMeasurementUnitVersionConflict({
    required this.rowVersion,
  });
}

class UpdateMeasurementUnitForbidden extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitForbidden();
}

class UpdateMeasurementUnitInvalidInput extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitInvalidInput();
}

class UpdateMeasurementUnitNotFound extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitNotFound();
}

class UpdateMeasurementUnitSemanticsFrozen
    extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitSemanticsFrozen();
}

class UpdateMeasurementUnitInUse extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitInUse();
}

class UpdateMeasurementUnitDuplicateCode
    extends UpdateMeasurementUnitResult {
  const UpdateMeasurementUnitDuplicateCode();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetMeasurementUnitActiveResult {
  const SetMeasurementUnitActiveResult();
}

class MeasurementUnitActiveChanged extends SetMeasurementUnitActiveResult {
  final String measurementUnitId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const MeasurementUnitActiveChanged({
    required this.measurementUnitId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetMeasurementUnitActiveUnchanged
    extends SetMeasurementUnitActiveResult {
  final String measurementUnitId;
  final bool isActive;
  final int rowVersion;

  const SetMeasurementUnitActiveUnchanged({
    required this.measurementUnitId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetMeasurementUnitActiveVersionConflict
    extends SetMeasurementUnitActiveResult {
  final int rowVersion;

  const SetMeasurementUnitActiveVersionConflict({
    required this.rowVersion,
  });
}

class SetMeasurementUnitActiveForbidden
    extends SetMeasurementUnitActiveResult {
  const SetMeasurementUnitActiveForbidden();
}

class SetMeasurementUnitActiveInvalidInput
    extends SetMeasurementUnitActiveResult {
  const SetMeasurementUnitActiveInvalidInput();
}

class SetMeasurementUnitActiveNotFound
    extends SetMeasurementUnitActiveResult {
  const SetMeasurementUnitActiveNotFound();
}

class SetMeasurementUnitActiveDependents
    extends SetMeasurementUnitActiveResult {
  const SetMeasurementUnitActiveDependents();
}
