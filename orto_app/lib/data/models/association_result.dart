enum AssociationRating {
  excellent,
  good,
  acceptable,
  poor,
  incompatible,
  unknown,
}

class AssociationMatch {
  final String cropId;
  final String cropName;
  final int score;
  final String relationship;
  final String? notes;

  const AssociationMatch({
    required this.cropId,
    required this.cropName,
    required this.score,
    required this.relationship,
    this.notes,
  });
}

class AssociationResult {
  final AssociationRating rating;
  final int score;
  final List<AssociationMatch> matches;
  final List<String> reasons;

  const AssociationResult({
    required this.rating,
    required this.score,
    required this.matches,
    required this.reasons,
  });

  bool get isExcellent => rating == AssociationRating.excellent;

  bool get isGood => rating == AssociationRating.good;

  bool get isAcceptable => rating == AssociationRating.acceptable;

  bool get isPoor => rating == AssociationRating.poor;

  bool get isIncompatible => rating == AssociationRating.incompatible;
}