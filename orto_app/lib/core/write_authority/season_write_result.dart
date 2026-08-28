class SeasonWriteProtocolException implements Exception {
  const SeasonWriteProtocolException();

  @override
  String toString() {
    return 'SeasonWriteProtocolException';
  }
}

sealed class CreateSeasonResult {
  const CreateSeasonResult();
}

final class SeasonCreated extends CreateSeasonResult {
  final String seasonId;
  final String gardenId;
  final int year;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  const SeasonCreated({
    required this.seasonId,
    required this.gardenId,
    required this.year,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
  });
}

final class CreateSeasonForbidden extends CreateSeasonResult {
  const CreateSeasonForbidden();
}

final class CreateSeasonWriteForbidden extends CreateSeasonResult {
  const CreateSeasonWriteForbidden();
}

final class CreateSeasonNotFound extends CreateSeasonResult {
  const CreateSeasonNotFound();
}

final class CreateSeasonInvalidInput extends CreateSeasonResult {
  const CreateSeasonInvalidInput();
}

final class CreateSeasonDuplicateYear extends CreateSeasonResult {
  const CreateSeasonDuplicateYear();
}

sealed class UpdateSeasonResult {
  const UpdateSeasonResult();
}

final class SeasonUpdated extends UpdateSeasonResult {
  final String seasonId;
  final String gardenId;
  final int year;
  final int rowVersion;
  final DateTime updatedAt;

  const SeasonUpdated({
    required this.seasonId,
    required this.gardenId,
    required this.year,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateSeasonUnchanged extends UpdateSeasonResult {
  final String seasonId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateSeasonUnchanged({
    required this.seasonId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateSeasonVersionConflict extends UpdateSeasonResult {
  final String seasonId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateSeasonVersionConflict({
    required this.seasonId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateSeasonForbidden extends UpdateSeasonResult {
  const UpdateSeasonForbidden();
}

final class UpdateSeasonWriteForbidden extends UpdateSeasonResult {
  const UpdateSeasonWriteForbidden();
}

final class UpdateSeasonNotFound extends UpdateSeasonResult {
  const UpdateSeasonNotFound();
}

final class UpdateSeasonInvalidInput extends UpdateSeasonResult {
  const UpdateSeasonInvalidInput();
}

final class UpdateSeasonDuplicateYear extends UpdateSeasonResult {
  const UpdateSeasonDuplicateYear();
}

class DeactivatedSeason {
  final String seasonId;
  final int rowVersion;
  final DateTime updatedAt;

  const DeactivatedSeason({
    required this.seasonId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

sealed class ActivateSeasonResult {
  const ActivateSeasonResult();
}

final class SeasonActivated extends ActivateSeasonResult {
  final String seasonId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;
  final DeactivatedSeason? deactivatedSeason;

  const SeasonActivated({
    required this.seasonId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.deactivatedSeason,
  });
}

final class ActivateSeasonUnchanged extends ActivateSeasonResult {
  final String seasonId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;

  const ActivateSeasonUnchanged({
    required this.seasonId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class ActivateSeasonVersionConflict extends ActivateSeasonResult {
  final String seasonId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const ActivateSeasonVersionConflict({
    required this.seasonId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class ActivateSeasonForbidden extends ActivateSeasonResult {
  const ActivateSeasonForbidden();
}

final class ActivateSeasonWriteForbidden extends ActivateSeasonResult {
  const ActivateSeasonWriteForbidden();
}

final class ActivateSeasonNotFound extends ActivateSeasonResult {
  const ActivateSeasonNotFound();
}

final class ActivateSeasonInvalidInput extends ActivateSeasonResult {
  const ActivateSeasonInvalidInput();
}
