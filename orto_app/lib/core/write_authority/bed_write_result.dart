class BedWriteProtocolException implements Exception {
  const BedWriteProtocolException();

  @override
  String toString() {
    return 'BedWriteProtocolException';
  }
}

sealed class CreateBedResult {
  const CreateBedResult();
}

final class BedCreated extends CreateBedResult {
  final String bedId;
  final String gardenId;
  final int number;
  final bool isActive;
  final int rowVersion;
  final DateTime createdAt;

  final String geometryId;
  final int widthCm;
  final int lengthCm;
  final DateTime validFrom;
  final DateTime? validTo;
  final int geometryRowVersion;
  final DateTime geometryCreatedAt;

  const BedCreated({
    required this.bedId,
    required this.gardenId,
    required this.number,
    required this.isActive,
    required this.rowVersion,
    required this.createdAt,
    required this.geometryId,
    required this.widthCm,
    required this.lengthCm,
    required this.validFrom,
    required this.validTo,
    required this.geometryRowVersion,
    required this.geometryCreatedAt,
  });
}

final class CreateBedForbidden extends CreateBedResult {
  const CreateBedForbidden();
}

final class CreateBedWriteForbidden extends CreateBedResult {
  const CreateBedWriteForbidden();
}

final class CreateBedNotFound extends CreateBedResult {
  const CreateBedNotFound();
}

final class CreateBedInvalidInput extends CreateBedResult {
  const CreateBedInvalidInput();
}

final class CreateBedDuplicateNumber extends CreateBedResult {
  const CreateBedDuplicateNumber();
}

sealed class UpdateBedResult {
  const UpdateBedResult();
}

final class BedUpdated extends UpdateBedResult {
  final String bedId;
  final String gardenId;
  final int number;
  final int rowVersion;
  final DateTime updatedAt;

  const BedUpdated({
    required this.bedId,
    required this.gardenId,
    required this.number,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBedUnchanged extends UpdateBedResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;

  const UpdateBedUnchanged({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class UpdateBedVersionConflict extends UpdateBedResult {
  final String bedId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const UpdateBedVersionConflict({
    required this.bedId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class UpdateBedForbidden extends UpdateBedResult {
  const UpdateBedForbidden();
}

final class UpdateBedWriteForbidden extends UpdateBedResult {
  const UpdateBedWriteForbidden();
}

final class UpdateBedNotFound extends UpdateBedResult {
  const UpdateBedNotFound();
}

final class UpdateBedInvalidInput extends UpdateBedResult {
  const UpdateBedInvalidInput();
}

final class UpdateBedDuplicateNumber extends UpdateBedResult {
  const UpdateBedDuplicateNumber();
}

sealed class SetBedActiveResult {
  const SetBedActiveResult();
}

final class BedActiveUpdated extends SetBedActiveResult {
  final String bedId;
  final String gardenId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const BedActiveUpdated({
    required this.bedId,
    required this.gardenId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBedActiveUnchanged extends SetBedActiveResult {
  final String bedId;
  final String gardenId;
  final bool isActive;
  final int rowVersion;
  final DateTime updatedAt;

  const SetBedActiveUnchanged({
    required this.bedId,
    required this.gardenId,
    required this.isActive,
    required this.rowVersion,
    required this.updatedAt,
  });
}

final class SetBedActiveVersionConflict extends SetBedActiveResult {
  final String bedId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const SetBedActiveVersionConflict({
    required this.bedId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class SetBedActiveForbidden extends SetBedActiveResult {
  const SetBedActiveForbidden();
}

final class SetBedActiveWriteForbidden extends SetBedActiveResult {
  const SetBedActiveWriteForbidden();
}

final class SetBedActiveNotFound extends SetBedActiveResult {
  const SetBedActiveNotFound();
}

final class SetBedActiveInvalidInput extends SetBedActiveResult {
  const SetBedActiveInvalidInput();
}

class PreviousBedGeometry {
  final String geometryId;
  final DateTime validTo;
  final int rowVersion;
  final DateTime updatedAt;

  const PreviousBedGeometry({
    required this.geometryId,
    required this.validTo,
    required this.rowVersion,
    required this.updatedAt,
  });
}

sealed class ChangeBedGeometryResult {
  const ChangeBedGeometryResult();
}

final class BedGeometryChanged extends ChangeBedGeometryResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;

  final String geometryId;
  final int widthCm;
  final int lengthCm;
  final DateTime validFrom;
  final DateTime? validTo;
  final int geometryRowVersion;
  final DateTime geometryCreatedAt;

  final PreviousBedGeometry previousGeometry;

  const BedGeometryChanged({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.geometryId,
    required this.widthCm,
    required this.lengthCm,
    required this.validFrom,
    required this.validTo,
    required this.geometryRowVersion,
    required this.geometryCreatedAt,
    required this.previousGeometry,
  });
}

final class ChangeBedGeometryUnchanged extends ChangeBedGeometryResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;
  final String geometryId;
  final int geometryRowVersion;
  final DateTime geometryUpdatedAt;

  const ChangeBedGeometryUnchanged({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.geometryId,
    required this.geometryRowVersion,
    required this.geometryUpdatedAt,
  });
}

final class BedGeometryCorrectionRequired extends ChangeBedGeometryResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;
  final String geometryId;
  final int geometryRowVersion;
  final DateTime geometryUpdatedAt;

  const BedGeometryCorrectionRequired({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.geometryId,
    required this.geometryRowVersion,
    required this.geometryUpdatedAt,
  });
}

final class ChangeBedGeometryVersionConflict extends ChangeBedGeometryResult {
  final String bedId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const ChangeBedGeometryVersionConflict({
    required this.bedId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class ChangeBedGeometryForbidden extends ChangeBedGeometryResult {
  const ChangeBedGeometryForbidden();
}

final class ChangeBedGeometryWriteForbidden extends ChangeBedGeometryResult {
  const ChangeBedGeometryWriteForbidden();
}

final class ChangeBedGeometryNotFound extends ChangeBedGeometryResult {
  const ChangeBedGeometryNotFound();
}

final class ChangeBedGeometryInvalidInput extends ChangeBedGeometryResult {
  const ChangeBedGeometryInvalidInput();
}

sealed class CorrectBedGeometryResult {
  const CorrectBedGeometryResult();
}

final class BedGeometryCorrected extends CorrectBedGeometryResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;

  final String geometryId;
  final int widthCm;
  final int lengthCm;
  final DateTime validFrom;
  final DateTime? validTo;
  final int geometryRowVersion;
  final DateTime geometryUpdatedAt;

  final String correctionId;
  final DateTime correctionCreatedAt;
  final PreviousBedGeometry? previousGeometry;

  const BedGeometryCorrected({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.geometryId,
    required this.widthCm,
    required this.lengthCm,
    required this.validFrom,
    required this.validTo,
    required this.geometryRowVersion,
    required this.geometryUpdatedAt,
    required this.correctionId,
    required this.correctionCreatedAt,
    required this.previousGeometry,
  });
}

final class CorrectBedGeometryUnchanged extends CorrectBedGeometryResult {
  final String bedId;
  final String gardenId;
  final int rowVersion;
  final DateTime updatedAt;
  final String geometryId;
  final int geometryRowVersion;
  final DateTime geometryUpdatedAt;

  const CorrectBedGeometryUnchanged({
    required this.bedId,
    required this.gardenId,
    required this.rowVersion,
    required this.updatedAt,
    required this.geometryId,
    required this.geometryRowVersion,
    required this.geometryUpdatedAt,
  });
}

final class CorrectBedGeometryVersionConflict extends CorrectBedGeometryResult {
  final String bedId;
  final int expectedRowVersion;
  final int currentRowVersion;
  final DateTime updatedAt;

  const CorrectBedGeometryVersionConflict({
    required this.bedId,
    required this.expectedRowVersion,
    required this.currentRowVersion,
    required this.updatedAt,
  });
}

final class CorrectBedGeometryForbidden extends CorrectBedGeometryResult {
  const CorrectBedGeometryForbidden();
}

final class CorrectBedGeometryWriteForbidden extends CorrectBedGeometryResult {
  const CorrectBedGeometryWriteForbidden();
}

final class CorrectBedGeometryNotFound extends CorrectBedGeometryResult {
  const CorrectBedGeometryNotFound();
}

final class CorrectBedGeometryInvalidInput extends CorrectBedGeometryResult {
  const CorrectBedGeometryInvalidInput();
}
