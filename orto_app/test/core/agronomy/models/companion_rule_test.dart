import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/agronomy/models/companion_rule.dart';

void main() {
  group('CompanionRule', () {
    test('memorizza le informazioni della regola', () {
      const rule = CompanionRule(
        cropAId: '1',
        cropBId: '3',
        compatibility: CompanionCompatibility.excellent,
        reason: 'Il basilico può favorire la crescita del pomodoro.',
      );

      expect(rule.cropAId, '1');
      expect(rule.cropBId, '3');
      expect(
        rule.compatibility,
        CompanionCompatibility.excellent,
      );
      expect(
        rule.reason,
        'Il basilico può favorire la crescita del pomodoro.',
      );
    });

    test('considera equivalenti le coppie anche in ordine inverso', () {
      const rule = CompanionRule(
        cropAId: '1',
        cropBId: '3',
        compatibility: CompanionCompatibility.excellent,
        reason: 'Consociazione favorevole.',
      );

      expect(rule.matches('1', '3'), isTrue);
      expect(rule.matches('3', '1'), isTrue);
    });

    test('non corrisponde a colture diverse', () {
      const rule = CompanionRule(
        cropAId: '1',
        cropBId: '3',
        compatibility: CompanionCompatibility.excellent,
        reason: 'Consociazione favorevole.',
      );

      expect(rule.matches('1', '2'), isFalse);
    });
  });
}