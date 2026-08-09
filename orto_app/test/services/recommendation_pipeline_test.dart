import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/data/models/bed_analysis_result.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/services/free_space.dart';
import 'package:orto_app/services/recommendation_pipeline.dart';
import 'package:orto_app/core/agronomy/models/family_crop_need.dart';

void main() {
  group('RecommendationPipeline', () {
    test('analizza i candidati prodotti dalla nuova pipeline', () {
      const bedAnalysis = BedAnalysisResult(
        freeSpaces: [FreeSpace(startCm: 0, endCm: 200)],
        suggestedSpace: null,
      );

      const crops = [
        Crop(
          id: '1',
          name: 'Pomodoro',
          plantSpacingCm: 40,
          botanicalFamily: 'Solanaceae',
          rotationSeasons: 3,
        ),
        Crop(
          id: '2',
          name: 'Lattuga',
          plantSpacingCm: 20,
          botanicalFamily: 'Asteraceae',
          rotationSeasons: 2,
        ),
      ];

      final result = RecommendationPipeline.generate(
        availableCrops: crops,
        existingPlantings: const [],
        cropsById: {'1': crops[0], '2': crops[1]},
        associations: const [],
        bedAnalysis: bedAnalysis,
      );

      expect(result.suggestions.length, 2);
      expect(result.analyzedCropsCount, 2);

      final suggestionsByCropName = {
        for (final suggestion in result.suggestions)
          suggestion.crop.name: suggestion,
      };

      expect(suggestionsByCropName['Pomodoro']?.plantsCount, 5);
      expect(suggestionsByCropName['Lattuga']?.plantsCount, 10);
    });
    test(
      'usa la priorità familiare per ordinare colture nella stessa fascia',
      () {
        const bedAnalysis = BedAnalysisResult(
          freeSpaces: [FreeSpace(startCm: 0, endCm: 200)],
          suggestedSpace: null,
        );

        const crops = [
          Crop(
            id: '1',
            name: 'Pomodoro',
            plantSpacingCm: 40,
            botanicalFamily: 'Solanaceae',
            rotationSeasons: 3,
          ),
          Crop(
            id: '2',
            name: 'Lattuga',
            plantSpacingCm: 20,
            botanicalFamily: 'Asteraceae',
            rotationSeasons: 2,
          ),
        ];

        final result = RecommendationPipeline.generate(
          availableCrops: crops,
          existingPlantings: const [],
          cropsById: {'1': crops[0], '2': crops[1]},
          associations: const [],
          bedAnalysis: bedAnalysis,
          familyNeeds: const [
            FamilyCropNeed(cropId: '1', priority: FamilyNeedPriority.medium),
            FamilyCropNeed(cropId: '2', priority: FamilyNeedPriority.high),
          ],
        );

        expect(result.suggestions.length, 2);

        expect(result.suggestions.first.crop.id, '2');
      },
    );
    test(
      'non permette alla priorità familiare di superare una fascia agronomica superiore',
      () {
        const bedAnalysis = BedAnalysisResult(
          freeSpaces: [FreeSpace(startCm: 0, endCm: 200)],
          suggestedSpace: null,
        );

        const crops = [
          Crop(
            id: '1',
            name: 'Coltura eccellente',
            plantSpacingCm: 40,
            botanicalFamily: 'FamigliaA',
            rotationSeasons: 3,
          ),
          Crop(
            id: '2',
            name: 'Coltura buona',
            plantSpacingCm: 110,
            botanicalFamily: 'FamigliaB',
            rotationSeasons: 3,
          ),
        ];

        final result = RecommendationPipeline.generate(
          availableCrops: crops,
          existingPlantings: const [],
          cropsById: {'1': crops[0], '2': crops[1]},
          associations: const [],
          bedAnalysis: bedAnalysis,
          familyNeeds: const [
            FamilyCropNeed(cropId: '1', priority: FamilyNeedPriority.none),
            FamilyCropNeed(cropId: '2', priority: FamilyNeedPriority.high),
          ],
        );

        expect(result.suggestions.length, 2);

        expect(result.suggestions[0].crop.id, '1');
        expect(result.suggestions[0].score, 85);

        expect(result.suggestions[1].crop.id, '2');
        expect(result.suggestions[1].score, 77);
      },
    );
  });
}
