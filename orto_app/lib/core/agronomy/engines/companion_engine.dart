import '../data/companion_rules.dart';
import '../models/companion_rule.dart';
import '../models/companion_result.dart';

class CompanionEngine {
  static CompanionRule? findRule(
    int cropAId,
    int cropBId,
  ) {
    for (final rule in companionRules) {
      if (rule.matches(cropAId, cropBId)) {
        return rule;
      }
    }

    return null;
  }

static CompanionResult analyze(
  int cropAId,
  int cropBId,
) {
  final rule = findRule(cropAId, cropBId);

  if (rule == null) {
    return const CompanionResult(
      compatible: true,
      compatibility: CompanionCompatibility.neutral,
      message: 'Non esistono informazioni specifiche su questa consociazione.',
    );
  }

  return CompanionResult(
    compatible: rule.compatibility != CompanionCompatibility.incompatible,
    compatibility: rule.compatibility,
    message: rule.reason,
  );
}

}