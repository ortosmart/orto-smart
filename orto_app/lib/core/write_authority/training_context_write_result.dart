class TrainingContextWriteProtocolException implements Exception {
  final String message;

  const TrainingContextWriteProtocolException(this.message);

  @override
  String toString() => 'TrainingContextWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateTrainingContextResult {
  const CreateTrainingContextResult();
}

class TrainingContextCreated extends CreateTrainingContextResult {
  final String trainingContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const TrainingContextCreated({
    required this.trainingContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateTrainingContextForbidden extends CreateTrainingContextResult {
  const CreateTrainingContextForbidden();
}

class CreateTrainingContextInvalidInput extends CreateTrainingContextResult {
  const CreateTrainingContextInvalidInput();
}

class CreateTrainingContextDuplicateCode extends CreateTrainingContextResult {
  const CreateTrainingContextDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateTrainingContextResult {
  const UpdateTrainingContextResult();
}

class TrainingContextUpdated extends UpdateTrainingContextResult {
  final String trainingContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const TrainingContextUpdated({
    required this.trainingContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateTrainingContextUnchanged extends UpdateTrainingContextResult {
  final String trainingContextId;
  final int rowVersion;

  const UpdateTrainingContextUnchanged({
    required this.trainingContextId,
    required this.rowVersion,
  });
}

class UpdateTrainingContextVersionConflict extends UpdateTrainingContextResult {
  final int rowVersion;

  const UpdateTrainingContextVersionConflict({required this.rowVersion});
}

class UpdateTrainingContextForbidden extends UpdateTrainingContextResult {
  const UpdateTrainingContextForbidden();
}

class UpdateTrainingContextInvalidInput extends UpdateTrainingContextResult {
  const UpdateTrainingContextInvalidInput();
}

class UpdateTrainingContextNotFound extends UpdateTrainingContextResult {
  const UpdateTrainingContextNotFound();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetTrainingContextActiveResult {
  const SetTrainingContextActiveResult();
}

class TrainingContextActiveChanged extends SetTrainingContextActiveResult {
  final String trainingContextId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const TrainingContextActiveChanged({
    required this.trainingContextId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetTrainingContextActiveUnchanged extends SetTrainingContextActiveResult {
  final String trainingContextId;
  final bool isActive;
  final int rowVersion;

  const SetTrainingContextActiveUnchanged({
    required this.trainingContextId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetTrainingContextActiveVersionConflict
    extends SetTrainingContextActiveResult {
  final int rowVersion;

  const SetTrainingContextActiveVersionConflict({required this.rowVersion});
}

class SetTrainingContextActiveForbidden extends SetTrainingContextActiveResult {
  const SetTrainingContextActiveForbidden();
}

class SetTrainingContextActiveInvalidInput
    extends SetTrainingContextActiveResult {
  const SetTrainingContextActiveInvalidInput();
}

class SetTrainingContextActiveNotFound extends SetTrainingContextActiveResult {
  const SetTrainingContextActiveNotFound();
}

class SetTrainingContextActiveDependents
    extends SetTrainingContextActiveResult {
  const SetTrainingContextActiveDependents();
}
