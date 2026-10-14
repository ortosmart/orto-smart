class ProtectionContextWriteProtocolException implements Exception {
  final String message;

  const ProtectionContextWriteProtocolException(this.message);

  @override
  String toString() => 'ProtectionContextWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateProtectionContextResult {
  const CreateProtectionContextResult();
}

class ProtectionContextCreated extends CreateProtectionContextResult {
  final String protectionContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const ProtectionContextCreated({
    required this.protectionContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateProtectionContextForbidden extends CreateProtectionContextResult {
  const CreateProtectionContextForbidden();
}

class CreateProtectionContextInvalidInput
    extends CreateProtectionContextResult {
  const CreateProtectionContextInvalidInput();
}

class CreateProtectionContextDuplicateCode
    extends CreateProtectionContextResult {
  const CreateProtectionContextDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateProtectionContextResult {
  const UpdateProtectionContextResult();
}

class ProtectionContextUpdated extends UpdateProtectionContextResult {
  final String protectionContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const ProtectionContextUpdated({
    required this.protectionContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateProtectionContextUnchanged extends UpdateProtectionContextResult {
  final String protectionContextId;
  final int rowVersion;

  const UpdateProtectionContextUnchanged({
    required this.protectionContextId,
    required this.rowVersion,
  });
}

class UpdateProtectionContextVersionConflict
    extends UpdateProtectionContextResult {
  final int rowVersion;

  const UpdateProtectionContextVersionConflict({required this.rowVersion});
}

class UpdateProtectionContextForbidden extends UpdateProtectionContextResult {
  const UpdateProtectionContextForbidden();
}

class UpdateProtectionContextInvalidInput
    extends UpdateProtectionContextResult {
  const UpdateProtectionContextInvalidInput();
}

class UpdateProtectionContextNotFound extends UpdateProtectionContextResult {
  const UpdateProtectionContextNotFound();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetProtectionContextActiveResult {
  const SetProtectionContextActiveResult();
}

class ProtectionContextActiveChanged extends SetProtectionContextActiveResult {
  final String protectionContextId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const ProtectionContextActiveChanged({
    required this.protectionContextId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetProtectionContextActiveUnchanged
    extends SetProtectionContextActiveResult {
  final String protectionContextId;
  final bool isActive;
  final int rowVersion;

  const SetProtectionContextActiveUnchanged({
    required this.protectionContextId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetProtectionContextActiveVersionConflict
    extends SetProtectionContextActiveResult {
  final int rowVersion;

  const SetProtectionContextActiveVersionConflict({required this.rowVersion});
}

class SetProtectionContextActiveForbidden
    extends SetProtectionContextActiveResult {
  const SetProtectionContextActiveForbidden();
}

class SetProtectionContextActiveInvalidInput
    extends SetProtectionContextActiveResult {
  const SetProtectionContextActiveInvalidInput();
}

class SetProtectionContextActiveNotFound
    extends SetProtectionContextActiveResult {
  const SetProtectionContextActiveNotFound();
}

class SetProtectionContextActiveDependents
    extends SetProtectionContextActiveResult {
  const SetProtectionContextActiveDependents();
}
