import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/data/models/crop.dart';
import 'package:orto_app/data/models/planting.dart';
import 'package:orto_app/data/models/rotation_result.dart';
import 'package:orto_app/services/rotation_engine.dart';

void main() {
  const bedId = 'bed-1';

  const pomodoro = Crop(
    id: 'crop-pomodoro',
    name: 'Pomodoro',
    botanicalFamily: 'Solanaceae',
    rotationSeasons: 3,
    heavyFeeder: true,
  );

  const peperone = Crop(
    id: 'crop-peperone',
    name: 'Peperone',
    botanicalFamily: 'Solanaceae',
    rotationSeasons: 3,
    heavyFeeder: true,
  );

  const lattuga = Crop(
    id: 'crop-lattuga',
    name: 'Lattuga',
    botanicalFamily: 'Asteraceae',
    rotationSeasons: 2,
  );

  const basilico = Crop(
    id: 'crop-basilico',
    name: 'Basilico',
    botanicalFamily: 'Lamiaceae',
    rotationSeasons: 2,
  );

  const colturaSenzaFamiglia = Crop(
    id: 'crop-sconosciuta',
    name: 'Coltura sconosciuta',
  );

  final cropsById = <String, Crop>{
    pomodoro.id: pomodoro,
    peperone.id: peperone,
    lattuga.id: lattuga,
    basilico.id: basilico,
    colturaSenzaFamiglia.id: colturaSenzaFamiglia,
  };

  Planting createPlanting({
    required String id,
    required Crop crop,
    required int year,
    int month = 4,
    int day = 1,
  }) {
    return Planting(
      id: id,
      seasonId: 'season-$year',
      bedId: bedId,
      cropId: crop.id,
      startPositionCm: 0,
      lengthCm: 100,
      sowingDate: DateTime(year, month, day),
      status: 'completed',
    );
  }

  group('RotationEngine.evaluate', () {
    test(
      'consiglia la coltura quando la stessa famiglia non compare nella cronologia',
      () {
        final history = [
          createPlanting(
            id: 'lattuga-2025',
            crop: lattuga,
            year: 2025,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: pomodoro,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 100);
        expect(result.rating, RotationRating.recommended);
        expect(result.isRecommended, isTrue);
        expect(result.seasonsSinceSameFamily, isNull);
        expect(result.requiredRotationSeasons, 3);

        expect(
          result.reasons.any(
            (reason) =>
                reason.contains('Nessuna coltura della famiglia'),
          ),
          isTrue,
        );
      },
    );

    test(
      'sconsiglia la stessa famiglia nella stagione corrente',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2026',
            crop: pomodoro,
            year: 2026,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: peperone,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 6, 1),
        );

        expect(result.score, 15);
        expect(result.rating, RotationRating.discouraged);
        expect(result.isDiscouraged, isTrue);
        expect(result.seasonsSinceSameFamily, 0);
        expect(result.requiredRotationSeasons, 3);

        expect(
          result.reasons.any(
            (reason) => reason.contains('stagione corrente'),
          ),
          isTrue,
        );
      },
    );

    test(
      'considera rispettata una rotazione completa',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2023',
            crop: pomodoro,
            year: 2023,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: peperone,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 95);
        expect(result.rating, RotationRating.recommended);
        expect(result.isRecommended, isTrue);
        expect(result.seasonsSinceSameFamily, 3);
        expect(result.requiredRotationSeasons, 3);

        expect(
          result.reasons.any(
            (reason) =>
                reason.contains('rotazione della famiglia botanica'),
          ),
          isTrue,
        );
      },
    );

    test(
      'considera accettabile una rotazione parzialmente rispettata',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2024',
            crop: pomodoro,
            year: 2024,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: peperone,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 50);
        expect(result.rating, RotationRating.acceptable);
        expect(result.isAcceptable, isTrue);
        expect(result.seasonsSinceSameFamily, 2);
        expect(result.requiredRotationSeasons, 3);

        expect(
          result.reasons.any(
            (reason) =>
                reason.contains('attendere ancora 1 stagione'),
          ),
          isTrue,
        );
      },
    );

    test(
      'sconsiglia una rotazione ancora troppo breve',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2025',
            crop: pomodoro,
            year: 2025,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: peperone,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 35);
        expect(result.rating, RotationRating.discouraged);
        expect(result.seasonsSinceSameFamily, 1);
        expect(result.requiredRotationSeasons, 3);

        expect(
          result.reasons.any(
            (reason) =>
                reason.contains('attendere ancora 2 stagioni'),
          ),
          isTrue,
        );
      },
    );

    test(
      'restituisce dati insufficienti quando manca la famiglia botanica',
      () {
        final result = RotationEngine.evaluate(
          candidateCrop: colturaSenzaFamiglia,
          history: const [],
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 50);
        expect(result.rating, RotationRating.unknown);
        expect(result.hasEnoughHistory, isFalse);

        expect(
          result.reasons.single,
          contains('famiglia botanica'),
        );
      },
    );

    test(
      'applica una penalità per ripetizioni recenti della stessa famiglia',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2025',
            crop: pomodoro,
            year: 2025,
          ),
          createPlanting(
            id: 'peperone-2024',
            crop: peperone,
            year: 2024,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: pomodoro,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        // Punteggio base con una stagione trascorsa: 35.
        // Penalità per la seconda ripetizione recente: -5.
        expect(result.score, 30);
        expect(result.rating, RotationRating.discouraged);
        expect(result.seasonsSinceSameFamily, 1);

        expect(
          result.reasons.any(
            (reason) => reason.contains('compare 2 volte'),
          ),
          isTrue,
        );
      },
    );

    test(
      'ignora le piantagioni successive alla data di valutazione',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2027',
            crop: pomodoro,
            year: 2027,
          ),
        ];

        final result = RotationEngine.evaluate(
          candidateCrop: peperone,
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(result.score, 100);
        expect(result.rating, RotationRating.recommended);
        expect(result.seasonsSinceSameFamily, isNull);
      },
    );
  });

  group('RotationEngine.evaluateCandidates', () {
    test(
      'ordina le colture candidate dal punteggio più alto al più basso',
      () {
        final history = [
          createPlanting(
            id: 'pomodoro-2026',
            crop: pomodoro,
            year: 2026,
          ),
          createPlanting(
            id: 'lattuga-2025',
            crop: lattuga,
            year: 2025,
          ),
        ];

        final evaluations = RotationEngine.evaluateCandidates(
          candidateCrops: const [
            pomodoro,
            lattuga,
            basilico,
          ],
          history: history,
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(evaluations, hasLength(3));

        expect(evaluations[0].crop.id, basilico.id);
        expect(evaluations[0].result.score, 100);

        expect(evaluations[1].crop.id, lattuga.id);
        expect(evaluations[1].result.score, 50);

        expect(evaluations[2].crop.id, pomodoro.id);
        expect(evaluations[2].result.score, 15);

        for (
          var index = 0;
          index < evaluations.length - 1;
          index++
        ) {
          expect(
            evaluations[index].result.score,
            greaterThanOrEqualTo(
              evaluations[index + 1].result.score,
            ),
          );
        }
      },
    );

    test(
      'ordina alfabeticamente le colture con lo stesso punteggio',
      () {
        final evaluations = RotationEngine.evaluateCandidates(
          candidateCrops: const [
            lattuga,
            basilico,
          ],
          history: const [],
          cropsById: cropsById,
          referenceDate: DateTime(2026, 4, 1),
        );

        expect(evaluations, hasLength(2));
        expect(evaluations[0].result.score, 100);
        expect(evaluations[1].result.score, 100);

        expect(evaluations[0].crop.name, 'Basilico');
        expect(evaluations[1].crop.name, 'Lattuga');
      },
    );
  });
}