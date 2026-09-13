class BotanicalFamilyWriteProtocolException implements Exception {
  const BotanicalFamilyWriteProtocolException();

  @override
  String toString() {
    return 'BotanicalFamilyWriteProtocolException';
  }
}

sealed class CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyResult();
}

final class BotanicalFamilyCreated extends CreateBotanicalFamilyResult {
  final String botanicalFamilyId;
  final String profileId;
  final String name;
  final String? scientificName;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const BotanicalFamilyCreated({
    required this.botanicalFamilyId,
    required this.profileId,
    required this.name,
    required this.scientificName,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreateBotanicalFamilyForbidden extends CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyForbidden();
}

final class CreateBotanicalFamilyWriteForbidden
    extends CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyWriteForbidden();
}

final class CreateBotanicalFamilyInvalidInput
    extends CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyInvalidInput();
}

final class CreateBotanicalFamilyDuplicateName
    extends CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyDuplicateName();
}

final class CreateBotanicalFamilyDuplicateScientificName
    extends CreateBotanicalFamilyResult {
  const CreateBotanicalFamilyDuplicateScientificName();
}

sealed class UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyResult();
}

final class BotanicalFamilyUpdated extends UpdateBotanicalFamilyResult {
  final String botanicalFamilyId;
  final String profileId;
  final String name;
  final String? scientificName;
  final int rowVersion;
  final DateTime updatedAt;

  const BotanicalFamilyUpdated({
    required this.botanicalFamilyId,
    required this.profileId,
    required this.name,
    required this.scientificName,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalFamilyUnchanged extends UpdateBotanicalFamilyResult {
  final String botanicalFamilyId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateBotanicalFamilyUnchanged({
    required this.botanicalFamilyId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalFamilyVersionConflict
    extends UpdateBotanicalFamilyResult {
  final String botanicalFamilyId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateBotanicalFamilyVersionConflict({
    required this.botanicalFamilyId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateBotanicalFamilyForbidden extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyForbidden();
}

final class UpdateBotanicalFamilyWriteForbidden
    extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyWriteForbidden();
}

final class UpdateBotanicalFamilyNotFound extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyNotFound();
}

final class UpdateBotanicalFamilyInvalidInput
    extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyInvalidInput();
}

final class UpdateBotanicalFamilyDuplicateName
    extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyDuplicateName();
}

final class UpdateBotanicalFamilyDuplicateScientificName
    extends UpdateBotanicalFamilyResult {
  const UpdateBotanicalFamilyDuplicateScientificName();
}

class ActiveCropReference {
  final String cropId;
  final String name;

  const ActiveCropReference({required this.cropId, required this.name});
}

sealed class SetBotanicalFamilyActiveResult {
  const SetBotanicalFamilyActiveResult();
}

final class BotanicalFamilyActiveUpdated
    extends SetBotanicalFamilyActiveResult {
  final String botanicalFamilyId;
  final String profileId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const BotanicalFamilyActiveUpdated({
    required this.botanicalFamilyId,
    required this.profileId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBotanicalFamilyActiveUnchanged
    extends SetBotanicalFamilyActiveResult {
  final String botanicalFamilyId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetBotanicalFamilyActiveUnchanged({
    required this.botanicalFamilyId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBotanicalFamilyActiveVersionConflict
    extends SetBotanicalFamilyActiveResult {
  final String botanicalFamilyId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const SetBotanicalFamilyActiveVersionConflict({
    required this.botanicalFamilyId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class SetBotanicalFamilyActiveForbidden
    extends SetBotanicalFamilyActiveResult {
  const SetBotanicalFamilyActiveForbidden();
}

final class SetBotanicalFamilyActiveWriteForbidden
    extends SetBotanicalFamilyActiveResult {
  const SetBotanicalFamilyActiveWriteForbidden();
}

final class SetBotanicalFamilyActiveNotFound
    extends SetBotanicalFamilyActiveResult {
  const SetBotanicalFamilyActiveNotFound();
}

final class SetBotanicalFamilyActiveInvalidInput
    extends SetBotanicalFamilyActiveResult {
  const SetBotanicalFamilyActiveInvalidInput();
}

final class SetBotanicalFamilyActiveBlockedByActiveCrops
    extends SetBotanicalFamilyActiveResult {
  final String botanicalFamilyId;
  final List<ActiveCropReference> activeCrops;

  const SetBotanicalFamilyActiveBlockedByActiveCrops({
    required this.botanicalFamilyId,
    required this.activeCrops,
  });
}
