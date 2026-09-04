enum CompanionCompatibility { excellent, good, neutral, bad, incompatible }

class CompanionRule {
  final String cropAId;
  final String cropBId;
  final CompanionCompatibility compatibility;
  final String reason;

  const CompanionRule({
    required this.cropAId,
    required this.cropBId,
    required this.compatibility,
    required this.reason,
  });

  bool matches(String firstCropId, String secondCropId) {
    return (cropAId == firstCropId && cropBId == secondCropId) ||
        (cropAId == secondCropId && cropBId == firstCropId);
  }
}
