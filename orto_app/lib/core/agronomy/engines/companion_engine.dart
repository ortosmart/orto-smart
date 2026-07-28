import '../data/companion_rules.dart';
import '../models/companion_result.dart';
import '../models/companion_rule.dart';

class CompanionEngine {
  static CompanionRule? findRule(
    String cropAId,
    String cropBId,
  ) {
    for (final rule in companionRules) {
      final sameOrder =
          rule.cropAId == cropAId && rule.cropBId == cropBId;

      final reverseOrder =
          rule.cropAId == cropBId && rule.cropBId == cropAId;

      if (sameOrder || reverseOrder) {
        return rule;
      }
    }

    return null;
  }

  static CompanionResult analyze(
    String cropAId,
    String cropBId,
  ) {
    final rule = findRule(cropAId, cropBId);

    if (rule == null) {
      return const CompanionResult(
        compatible: true,
        compatibility: CompanionCompatibility.neutral,
        message:
            'Non esistono informazioni specifiche su questa consociazione.',
      );
    }

    return CompanionResult(
      compatible:
          rule.compatibility != CompanionCompatibility.incompatible,
      compatibility: rule.compatibility,
      message: rule.reason,
    );
  }
}