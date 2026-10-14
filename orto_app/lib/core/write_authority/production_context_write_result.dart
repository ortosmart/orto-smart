class ProductionContextWriteProtocolException implements Exception {
  final String message;

  const ProductionContextWriteProtocolException(this.message);

  @override
  String toString() => 'ProductionContextWriteProtocolException: $message';
}

// ------------------------------------------------------------
// CREATE
// ------------------------------------------------------------

sealed class CreateProductionContextResult {
  const CreateProductionContextResult();
}

class ProductionContextCreated extends CreateProductionContextResult {
  final String productionContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const ProductionContextCreated({
    required this.productionContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

class CreateProductionContextForbidden extends CreateProductionContextResult {
  const CreateProductionContextForbidden();
}

class CreateProductionContextInvalidInput
    extends CreateProductionContextResult {
  const CreateProductionContextInvalidInput();
}

class CreateProductionContextDuplicateCode
    extends CreateProductionContextResult {
  const CreateProductionContextDuplicateCode();
}

// ------------------------------------------------------------
// UPDATE
// ------------------------------------------------------------

sealed class UpdateProductionContextResult {
  const UpdateProductionContextResult();
}

class ProductionContextUpdated extends UpdateProductionContextResult {
  final String productionContextId;
  final String code;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const ProductionContextUpdated({
    required this.productionContextId,
    required this.code,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class UpdateProductionContextUnchanged extends UpdateProductionContextResult {
  final String productionContextId;
  final int rowVersion;

  const UpdateProductionContextUnchanged({
    required this.productionContextId,
    required this.rowVersion,
  });
}

class UpdateProductionContextVersionConflict
    extends UpdateProductionContextResult {
  final int rowVersion;

  const UpdateProductionContextVersionConflict({required this.rowVersion});
}

class UpdateProductionContextForbidden extends UpdateProductionContextResult {
  const UpdateProductionContextForbidden();
}

class UpdateProductionContextInvalidInput
    extends UpdateProductionContextResult {
  const UpdateProductionContextInvalidInput();
}

class UpdateProductionContextNotFound extends UpdateProductionContextResult {
  const UpdateProductionContextNotFound();
}

// ------------------------------------------------------------
// SET ACTIVE
// ------------------------------------------------------------

sealed class SetProductionContextActiveResult {
  const SetProductionContextActiveResult();
}

class ProductionContextActiveChanged extends SetProductionContextActiveResult {
  final String productionContextId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const ProductionContextActiveChanged({
    required this.productionContextId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

class SetProductionContextActiveUnchanged
    extends SetProductionContextActiveResult {
  final String productionContextId;
  final bool isActive;
  final int rowVersion;

  const SetProductionContextActiveUnchanged({
    required this.productionContextId,
    required this.isActive,
    required this.rowVersion,
  });
}

class SetProductionContextActiveVersionConflict
    extends SetProductionContextActiveResult {
  final int rowVersion;

  const SetProductionContextActiveVersionConflict({required this.rowVersion});
}

class SetProductionContextActiveForbidden
    extends SetProductionContextActiveResult {
  const SetProductionContextActiveForbidden();
}

class SetProductionContextActiveInvalidInput
    extends SetProductionContextActiveResult {
  const SetProductionContextActiveInvalidInput();
}

class SetProductionContextActiveNotFound
    extends SetProductionContextActiveResult {
  const SetProductionContextActiveNotFound();
}

class SetProductionContextActiveDependents
    extends SetProductionContextActiveResult {
  const SetProductionContextActiveDependents();
}
