import '../models/companion_rule.dart';

class CropIds {
  static const String pomodoro = '1';
  static const String lattuga = '2';
  static const String basilico = '3';
  static const String zucchina = '4';
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
    cropBId: CropIds.zucchina,
    compatibility: CompanionCompatibility.good,
    reason:
        'La lattuga può convivere con le zucchine se viene raccolta prima che queste occupino completamente lo spazio.',
  ),
  CompanionRule(
    cropAId: CropIds.pomodoro,
    cropBId: CropIds.zucchina,
    compatibility: CompanionCompatibility.neutral,
    reason:
        'Non esiste una particolare sinergia o incompatibilità diretta.',
  ),
];