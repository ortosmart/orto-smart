import '../models/companion_rule.dart';

class CropIds {
  static const int pomodoro = 1;
  static const int lattuga = 2;
  static const int basilico = 3;
  static const int zucchine = 4;
}

const companionRules = <CompanionRule>[
  CompanionRule(
    cropAId: CropIds.pomodoro,
    cropBId: CropIds.basilico,
    compatibility: CompanionCompatibility.excellent,
    reason:
        'Il basilico è una delle consociazioni più favorevoli per il pomodoro.',
  ),
  CompanionRule(
    cropAId: CropIds.lattuga,
    cropBId: CropIds.zucchine,
    compatibility: CompanionCompatibility.good,
    reason:
        'La lattuga può convivere con le zucchine se viene raccolta prima che queste occupino completamente lo spazio.',
  ),
  CompanionRule(
    cropAId: CropIds.pomodoro,
    cropBId: CropIds.zucchine,
    compatibility: CompanionCompatibility.neutral,
    reason:
        'Non esiste una particolare sinergia o incompatibilità diretta.',
  ),
];