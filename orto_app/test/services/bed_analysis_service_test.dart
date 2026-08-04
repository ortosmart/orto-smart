import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/data/companion_rules.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/services/bed_analysis_service.dart';

Planting _planting(String cropId) {
  return Planting(
    seasonId: 'season-1',
    bedId: 'bed-1',
    cropId: cropId,
    startPositionCm: 0,
    lengthCm: 100,
    sowingDate: DateTime(2026, 1, 1),
    status: 'growing',
  );
}

void main() {
  group('BedAnalysisService - analyzeCompanions', () {
    test('returns no pairs for empty bed', () {
      final analysis = BedAnalysisService.analyzeCompanions(plantings: []);

      expect(analysis.totalPairs, 0);
      expect(analysis.hasIncompatibilities, isFalse);
    });

    test('analyzes compatible crops', () {
      final analysis = BedAnalysisService.analyzeCompanions(
        plantings: [_planting(CropIds.pomodoro), _planting(CropIds.basilico)],
      );

      expect(analysis.totalPairs, 1);
      expect(analysis.compatiblePairs, 1);
      expect(analysis.incompatiblePairs, 0);
    });
  });
}
