import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/data/companion_rules.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/services/bed_analysis_service.dart';

Planting _planting(String cropId) {
  return Planting(
    id: 'planting-$cropId',
    profileId: 'profile-1',
    gardenId: 'garden-1',
    seasonId: 'season-1',
    bedId: 'bed-1',
    cropId: cropId,
    varietyId: null,
    startMethod: 'purchased_seedlings',
    startDate: DateTime(2026, 1, 1),
    endDate: null,
    startPositionCm: 0,
    lengthCm: 100,
    plantSpacingCm: 40,
    rowSpacingCm: null,
    rowsCount: null,
    occupiedWidthCm: 90,
    plantsCount: 2,
    seedQuantityG: null,
    status: 'growing',
    notes: null,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    rowVersion: 1,
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
