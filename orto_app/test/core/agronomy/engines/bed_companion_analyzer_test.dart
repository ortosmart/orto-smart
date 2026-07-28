import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/data/companion_rules.dart';
import 'package:orto_app/core/agronomy/engines/bed_companion_analyzer.dart';

void main() {
  group('BedCompanionAnalyzer', () {
    test('returns no pairs for empty list', () {
      final analysis = BedCompanionAnalyzer.analyze([]);

      expect(analysis.totalPairs, 0);
      expect(analysis.compatiblePairs, 0);
      expect(analysis.incompatiblePairs, 0);
      expect(analysis.hasIncompatibilities, isFalse);
    });

    test('returns no pairs for a single crop', () {
      final analysis = BedCompanionAnalyzer.analyze([
        CropIds.pomodoro,
      ]);

      expect(analysis.totalPairs, 0);
    });

    test('analyzes all pairs', () {
      final analysis = BedCompanionAnalyzer.analyze([
        CropIds.pomodoro,
        CropIds.basilico,
        CropIds.zucchina,
      ]);

      expect(analysis.totalPairs, 3);
    });

    test('contains at least one compatible pair', () {
      final analysis = BedCompanionAnalyzer.analyze([
        CropIds.pomodoro,
        CropIds.basilico,
      ]);

      expect(analysis.compatiblePairs, 1);
      expect(analysis.incompatiblePairs, 0);
      expect(analysis.hasIncompatibilities, isFalse);
    });
  });
}