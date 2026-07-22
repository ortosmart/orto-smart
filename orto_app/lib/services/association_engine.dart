import '../data/models/association_result.dart';
import '../data/models/crop.dart';
import '../data/models/crop_association.dart';
import '../data/models/planting.dart';

class AssociationEngine {
  const AssociationEngine._();

  static AssociationResult evaluate({
    required Crop candidateCrop,
    required Iterable<Planting> existingPlantings,
    required Iterable<CropAssociation> associations,
    required Map<String, Crop> cropsById,
  }) {
    final existingCropIds = existingPlantings
        .map((planting) => planting.cropId)
        .where((cropId) => cropId != candidateCrop.id)
        .toSet();

    if (existingCropIds.isEmpty) {
      return const AssociationResult(
        rating: AssociationRating.unknown,
        score: 50,
        matches: [],
        reasons: [
          'Nell’aiuola non sono presenti altre colture da confrontare.',
        ],
      );
    }

    final associationsByCropId = <String, CropAssociation>{
      for (final association in associations)
        association.associatedCropId: association,
    };

    final matches = <AssociationMatch>[];
    final reasons = <String>[];

    for (final existingCropId in existingCropIds) {
      final existingCrop = cropsById[existingCropId];

      if (existingCrop == null) {
        continue;
      }

      final association = associationsByCropId[existingCropId];

      if (association == null) {
        matches.add(
          AssociationMatch(
            cropId: existingCrop.id,
            cropName: existingCrop.name,
            score: 0,
            relationship: 'unknown',
            notes: null,
          ),
        );

        reasons.add(
          'Non sono disponibili dati sulla consociazione con '
          '${existingCrop.name}.',
        );

        continue;
      }

      matches.add(
        AssociationMatch(
          cropId: existingCrop.id,
          cropName: existingCrop.name,
          score: association.score,
          relationship: association.relationship,
          notes: association.notes,
        ),
      );

      reasons.add(
        _buildReason(
          cropName: existingCrop.name,
          association: association,
        ),
      );
    }

    if (matches.isEmpty) {
      return const AssociationResult(
        rating: AssociationRating.unknown,
        score: 50,
        matches: [],
        reasons: [
          'Non è stato possibile valutare le colture presenti nell’aiuola.',
        ],
      );
    }

    final knownMatches = matches
        .where((match) => match.relationship != 'unknown')
        .toList();

    if (knownMatches.isEmpty) {
      return AssociationResult(
        rating: AssociationRating.unknown,
        score: 50,
        matches: matches,
        reasons: reasons,
      );
    }

    final hasIncompatible = knownMatches.any(
      (match) => match.relationship == 'incompatible',
    );

    final averageRelationshipScore = knownMatches
            .map((match) => match.score)
            .reduce((first, second) => first + second) /
        knownMatches.length;

    final normalizedScore =
        ((averageRelationshipScore + 100) / 2).round().clamp(0, 100);

    final rating = _calculateRating(
      score: normalizedScore,
      hasIncompatible: hasIncompatible,
    );

    return AssociationResult(
      rating: rating,
      score: normalizedScore,
      matches: matches,
      reasons: reasons,
    );
  }

  static AssociationRating _calculateRating({
    required int score,
    required bool hasIncompatible,
  }) {
    if (hasIncompatible) {
      return AssociationRating.incompatible;
    }

    if (score >= 85) {
      return AssociationRating.excellent;
    }

    if (score >= 70) {
      return AssociationRating.good;
    }

    if (score >= 50) {
      return AssociationRating.acceptable;
    }

    return AssociationRating.poor;
  }

  static String _buildReason({
    required String cropName,
    required CropAssociation association,
  }) {
    switch (association.relationship) {
      case 'beneficial':
        return 'Consociazione favorevole con $cropName '
            '(${association.score > 0 ? '+' : ''}${association.score}).';

      case 'neutral':
        return 'Consociazione neutra con $cropName.';

      case 'incompatible':
        return 'Consociazione da evitare con $cropName '
            '(${association.score}).';

      default:
        return 'Rapporto con $cropName non classificato.';
    }
  }
}