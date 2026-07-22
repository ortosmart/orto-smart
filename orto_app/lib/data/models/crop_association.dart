class CropAssociation {
  final String id;
  final String cropId;
  final String associatedCropId;
  final String relationship;
  final int score;
  final String? notes;

  const CropAssociation({
    required this.id,
    required this.cropId,
    required this.associatedCropId,
    required this.relationship,
    required this.score,
    this.notes,
  });

  factory CropAssociation.fromMap(Map<String, dynamic> map) {
    return CropAssociation(
      id: map['id'].toString(),
      cropId: map['crop_id'].toString(),
      associatedCropId: map['associated_crop_id'].toString(),
      relationship: map['relationship'] as String,
      score: (map['score'] as num?)?.toInt() ?? 0,
      notes: map['notes'] as String?,
    );
  }

  bool get isBeneficial => relationship == 'beneficial';

  bool get isNeutral => relationship == 'neutral';

  bool get isIncompatible => relationship == 'incompatible';

  String get relationshipLabel {
    switch (relationship) {
      case 'beneficial':
        return 'Favorevole';
      case 'neutral':
        return 'Neutra';
      case 'incompatible':
        return 'Da evitare';
      default:
        return 'Sconosciuta';
    }
  }
}