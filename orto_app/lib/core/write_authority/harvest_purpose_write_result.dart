class HarvestPurposeWriteProtocolException implements Exception {
  final String message;

  const HarvestPurposeWriteProtocolException(this.message);

  @override
  String toString() => 'HarvestPurposeWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateHarvestPurposeResult {
  const CreateHarvestPurposeResult();
}

class HarvestPurposeCreated extends CreateHarvestPurposeResult {
  final String harvestPurposeId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const HarvestPurposeCreated({
    required this.harvestPurposeId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateHarvestPurposeForbidden extends CreateHarvestPurposeResult {
  const CreateHarvestPurposeForbidden();
}

class CreateHarvestPurposeInvalidInput extends CreateHarvestPurposeResult {
  const CreateHarvestPurposeInvalidInput();
}

class CreateHarvestPurposeDuplicateCode extends CreateHarvestPurposeResult {
  const CreateHarvestPurposeDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateHarvestPurposeResult {
  const UpdateHarvestPurposeResult();
}

class HarvestPurposeUpdated extends UpdateHarvestPurposeResult {
  final String harvestPurposeId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const HarvestPurposeUpdated({
    required this.harvestPurposeId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateHarvestPurposeUnchanged extends UpdateHarvestPurposeResult {
  final String harvestPurposeId;
  final int rowVersion;

  const UpdateHarvestPurposeUnchanged({
    required this.harvestPurposeId,
    required this.rowVersion,
  });
}

class UpdateHarvestPurposeVersionConflict extends UpdateHarvestPurposeResult {
  final int rowVersion;

  const UpdateHarvestPurposeVersionConflict({required this.rowVersion});
}

class UpdateHarvestPurposeForbidden extends UpdateHarvestPurposeResult {
  const UpdateHarvestPurposeForbidden();
}

class UpdateHarvestPurposeInvalidInput extends UpdateHarvestPurposeResult {
  const UpdateHarvestPurposeInvalidInput();
}

class UpdateHarvestPurposeNotFound extends UpdateHarvestPurposeResult {
  const UpdateHarvestPurposeNotFound();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetHarvestPurposeActiveResult {
  const SetHarvestPurposeActiveResult();
}

class HarvestPurposeActiveChanged extends SetHarvestPurposeActiveResult {
  final String harvestPurposeId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const HarvestPurposeActiveChanged({
    required this.harvestPurposeId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetHarvestPurposeActiveUnchanged extends SetHarvestPurposeActiveResult {
  final String harvestPurposeId;
  final bool isActive;
  final int rowVersion;

  const SetHarvestPurposeActiveUnchanged({
    required this.harvestPurposeId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetHarvestPurposeActiveVersionConflict
    extends SetHarvestPurposeActiveResult {
  final int rowVersion;

  const SetHarvestPurposeActiveVersionConflict({required this.rowVersion});
}

class SetHarvestPurposeActiveForbidden extends SetHarvestPurposeActiveResult {
  const SetHarvestPurposeActiveForbidden();
}

class SetHarvestPurposeActiveInvalidInput
    extends SetHarvestPurposeActiveResult {
  const SetHarvestPurposeActiveInvalidInput();
}

class SetHarvestPurposeActiveNotFound extends SetHarvestPurposeActiveResult {
  const SetHarvestPurposeActiveNotFound();
}

class SetHarvestPurposeActiveDependents extends SetHarvestPurposeActiveResult {
  const SetHarvestPurposeActiveDependents();
}
