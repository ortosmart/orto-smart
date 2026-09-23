import '../models/crop_association.dart';

/// Backend delle consociazioni intenzionalmente non attivo nella Tranche 11.
///
/// Il database non espone ancora una relazione canonica `crop_associations`.
/// Le liste vuote mantengono operativi i motori senza eseguire query verso una
/// tabella inesistente. La funzione verra riattivata con una tranche dedicata.
class CropAssociationRepository {
  const CropAssociationRepository();

  Future<List<CropAssociation>> getAssociationsForCrop(String cropId) async {
    return const [];
  }

  Future<List<CropAssociation>> getAssociationsBetweenCrops(
    String cropId,
    Iterable<String> associatedCropIds,
  ) async {
    return const [];
  }

  Future<List<CropAssociation>> getAllAssociations() async {
    return const [];
  }
}
