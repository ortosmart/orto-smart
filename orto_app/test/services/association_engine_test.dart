import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/association_result.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/crop_association.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/services/association_engine.dart';

void main() {
  const pomodoro = Crop(
    id: '1',
    name: 'Pomodoro',
  );

  const lattuga = Crop(
    id: '2',
    name: 'Lattuga',
  );

  const basilico = Crop(
    id: '3',
    name: 'Basilico',
  );

  const zucchina = Crop(
    id: '4',
    name: 'Zucchina',
  );

  final cropsById = <String, Crop>{
    pomodoro.id: pomodoro,
    lattuga.id: lattuga,
    basilico.id: basilico,
    zucchina.id: zucchina,
  };

  Planting buildPlanting({
    required String cropId,
  }) {
    return Planting(
      id: null,
      seasonId: 'season-2026',
      bedId: 'bed-1',
      cropId: cropId,
      varietyId: null,
      startPositionCm: 0,
      lengthCm: 100,
      plantingMethod: 'transplant',
      plantSpacingCm: 40,
      rowSpacingCm: 60,
      rowsCount: 1,
      occupiedWidthCm: 60,
      seedQuantityGrams: null,
      sowingDate: DateTime(2026, 4, 1),
      plantsCount: 2,
      status: 'growing',
      notes: null,
    );
  }

  group('AssociationEngine', () {
    test(
      'restituisce unknown quando non ci sono altre colture',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: pomodoro,
          existingPlantings: const [],
          associations: const [],
          cropsById: cropsById,
        );

        expect(result.rating, AssociationRating.unknown);
        expect(result.score, 50);
        expect(result.matches, isEmpty);
      },
    );

    test(
      'valuta come excellent una consociazione molto favorevole',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: pomodoro,
          existingPlantings: [
            buildPlanting(cropId: basilico.id),
          ],
          associations: const [
            CropAssociation(
              id: '1',
              cropId: '1',
              associatedCropId: '3',
              relationship: 'beneficial',
              score: 80,
              notes: 'Ottima consociazione.',
            ),
          ],
          cropsById: cropsById,
        );

        expect(result.rating, AssociationRating.excellent);
        expect(result.score, 90);
        expect(result.matches, hasLength(1));
        expect(result.matches.first.cropName, 'Basilico');
      },
    );

    test(
      'valuta come acceptable una consociazione neutra',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: zucchina,
          existingPlantings: [
            buildPlanting(cropId: lattuga.id),
          ],
          associations: const [
            CropAssociation(
              id: '2',
              cropId: '4',
              associatedCropId: '2',
              relationship: 'neutral',
              score: 0,
              notes: null,
            ),
          ],
          cropsById: cropsById,
        );

        expect(result.rating, AssociationRating.acceptable);
        expect(result.score, 50);
      },
    );

    test(
      'restituisce incompatible se esiste una consociazione incompatibile',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: pomodoro,
          existingPlantings: [
            buildPlanting(cropId: lattuga.id),
            buildPlanting(cropId: basilico.id),
          ],
          associations: const [
            CropAssociation(
              id: '3',
              cropId: '1',
              associatedCropId: '2',
              relationship: 'incompatible',
              score: -80,
              notes: 'Da evitare.',
            ),
            CropAssociation(
              id: '4',
              cropId: '1',
              associatedCropId: '3',
              relationship: 'beneficial',
              score: 80,
              notes: 'Favorevole.',
            ),
          ],
          cropsById: cropsById,
        );

        expect(result.rating, AssociationRating.incompatible);
        expect(result.matches, hasLength(2));
      },
    );

    test(
      'ignora le piantagioni duplicate della stessa coltura',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: pomodoro,
          existingPlantings: [
            buildPlanting(cropId: basilico.id),
            buildPlanting(cropId: basilico.id),
          ],
          associations: const [
            CropAssociation(
              id: '5',
              cropId: '1',
              associatedCropId: '3',
              relationship: 'beneficial',
              score: 80,
              notes: null,
            ),
          ],
          cropsById: cropsById,
        );

        expect(result.matches, hasLength(1));
      },
    );

    test(
      'restituisce unknown quando non esistono dati di consociazione',
      () {
        final result = AssociationEngine.evaluate(
          candidateCrop: pomodoro,
          existingPlantings: [
            buildPlanting(cropId: zucchina.id),
          ],
          associations: const [],
          cropsById: cropsById,
        );

        expect(result.rating, AssociationRating.unknown);
        expect(result.score, 50);
        expect(result.matches, hasLength(1));
        expect(result.matches.first.relationship, 'unknown');
      },
    );
  });
}