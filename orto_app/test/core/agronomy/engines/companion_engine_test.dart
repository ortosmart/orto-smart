import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/core/agronomy/data/companion_rules.dart';
import 'package:orto_app/core/agronomy/engines/companion_engine.dart';
import 'package:orto_app/core/agronomy/models/companion_rule.dart';

void main() {
  group('CompanionEngine', () {
    test('trova una regola esistente', () {
      final rule = CompanionEngine.findRule(
        CropIds.pomodoro,
        CropIds.basilico,
      );

      expect(rule, isNotNull);
      expect(
        rule!.compatibility,
        CompanionCompatibility.excellent,
      );
    });

    test('riconosce la regola anche invertendo le colture', () {
      final rule = CompanionEngine.findRule(
        CropIds.basilico,
        CropIds.pomodoro,
      );

      expect(rule, isNotNull);
      expect(
        rule!.compatibility,
        CompanionCompatibility.excellent,
      );
    });

    test('restituisce null se non esiste alcuna regola', () {
      final rule = CompanionEngine.findRule(
        CropIds.lattuga,
        99,
      );

      expect(rule, isNull);
    });

test('analyze restituisce un risultato eccellente per pomodoro e basilico', () {
  final result = CompanionEngine.analyze(
    CropIds.pomodoro,
    CropIds.basilico,
  );

  expect(result.compatible, isTrue);
  expect(
    result.compatibility,
    CompanionCompatibility.excellent,
  );
  expect(result.message, isNotEmpty);
});

test('analyze restituisce neutrale quando non esiste una regola', () {
  final result = CompanionEngine.analyze(
    CropIds.lattuga,
    99,
  );

  expect(result.compatible, isTrue);
  expect(
    result.compatibility,
    CompanionCompatibility.neutral,
  );
  expect(
    result.message,
    'Non esistono informazioni specifiche su questa consociazione.',
  );
});

test('analyze usa il motivo della regola come messaggio', () {
  final rule = CompanionEngine.findRule(
    CropIds.pomodoro,
    CropIds.basilico,
  );

  final result = CompanionEngine.analyze(
    CropIds.pomodoro,
    CropIds.basilico,
  );

  expect(rule, isNotNull);
  expect(result.message, rule!.reason);
});

  });
}