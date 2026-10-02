class BotanicalTaxonWriteProtocolException implements Exception {
  const BotanicalTaxonWriteProtocolException();

  @override
  String toString() {
    return 'BotanicalTaxonWriteProtocolException';
  }
}

sealed class CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonResult();
}

final class BotanicalTaxonCreated extends CreateBotanicalTaxonResult {
  final String botanicalTaxonId;
  final int rowVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BotanicalTaxonCreated({
    required this.botanicalTaxonId,
    required this.rowVersion,
    required this.createdAt,
    required this.updatedAt,
  });
}

final class CreateBotanicalTaxonForbidden extends CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonForbidden();
}

final class CreateBotanicalTaxonInvalidInput
    extends CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonInvalidInput();
}

final class CreateBotanicalTaxonParentNotFound
    extends CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonParentNotFound();
}

final class CreateBotanicalTaxonDependencyInactive
    extends CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonDependencyInactive();
}

final class CreateBotanicalTaxonDuplicateIdentity
    extends CreateBotanicalTaxonResult {
  const CreateBotanicalTaxonDuplicateIdentity();
}

sealed class UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonResult();
}

final class BotanicalTaxonUpdated extends UpdateBotanicalTaxonResult {
  final String botanicalTaxonId;
  final int rowVersion;
  final DateTime updatedAt;

  const BotanicalTaxonUpdated({
    required this.botanicalTaxonId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalTaxonUnchanged extends UpdateBotanicalTaxonResult {
  final String botanicalTaxonId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateBotanicalTaxonUnchanged({
    required this.botanicalTaxonId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalTaxonVersionConflict
    extends UpdateBotanicalTaxonResult {
  final String botanicalTaxonId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateBotanicalTaxonVersionConflict({
    required this.botanicalTaxonId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalTaxonForbidden extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonForbidden();
}

final class UpdateBotanicalTaxonInvalidInput
    extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonInvalidInput();
}

final class UpdateBotanicalTaxonNotFound extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonNotFound();
}

final class UpdateBotanicalTaxonParentNotFound
    extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonParentNotFound();
}

final class UpdateBotanicalTaxonDependencyInactive
    extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonDependencyInactive();
}

final class UpdateBotanicalTaxonDuplicateIdentity
    extends UpdateBotanicalTaxonResult {
  const UpdateBotanicalTaxonDuplicateIdentity();
}

sealed class SetBotanicalTaxonActiveResult {
  const SetBotanicalTaxonActiveResult();
}

final class BotanicalTaxonActiveChanged extends SetBotanicalTaxonActiveResult {
  final String botanicalTaxonId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const BotanicalTaxonActiveChanged({
    required this.botanicalTaxonId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBotanicalTaxonActiveUnchanged
    extends SetBotanicalTaxonActiveResult {
  final String botanicalTaxonId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetBotanicalTaxonActiveUnchanged({
    required this.botanicalTaxonId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBotanicalTaxonActiveVersionConflict
    extends SetBotanicalTaxonActiveResult {
  final String? botanicalTaxonId;
  final int? expectedRowVersion;
  final int? currentRowVersion;
  final DateTime? updatedAt;

  const SetBotanicalTaxonActiveVersionConflict({
    this.botanicalTaxonId,
    this.expectedRowVersion,
    this.currentRowVersion,
    this.updatedAt,
  });
}

final class SetBotanicalTaxonActiveForbidden
    extends SetBotanicalTaxonActiveResult {
  const SetBotanicalTaxonActiveForbidden();
}

final class SetBotanicalTaxonActiveInvalidInput
    extends SetBotanicalTaxonActiveResult {
  const SetBotanicalTaxonActiveInvalidInput();
}

final class SetBotanicalTaxonActiveNotFound
    extends SetBotanicalTaxonActiveResult {
  const SetBotanicalTaxonActiveNotFound();
}

final class SetBotanicalTaxonActiveDependencyInactive
    extends SetBotanicalTaxonActiveResult {
  const SetBotanicalTaxonActiveDependencyInactive();
}

final class SetBotanicalTaxonActiveDependents
    extends SetBotanicalTaxonActiveResult {
  final int activeChildTaxaCount;
  final int activeCropsCount;

  const SetBotanicalTaxonActiveDependents({
    required this.activeChildTaxaCount,
    required this.activeCropsCount,
  });
}
