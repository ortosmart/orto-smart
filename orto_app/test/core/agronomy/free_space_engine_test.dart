import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/free_space_engine.dart';
import 'package:orto_app/data/models/planting.dart';

void main() {
  group('FreeSpaceEngine', () {
    test(
      'restituisce tutta l\'aiuola come spazio libero se non ci sono colture',
      () {
        final spaces = FreeSpaceEngine.calculateFreeSpaces(
          bedLengthCm: 700,
          plantings: <Planting>[],
        );

        expect(spaces.length, 1);
        expect(spaces.first.startCm, 0);
        expect(spaces.first.lengthCm, 700);
      },
    );

    test('calcola gli spazi liberi prima e dopo una coltura', () {
      final planting = Planting(
        seasonId: 'season-1',
        bedId: 'bed-1',
        cropId: 'crop-1',
        startPositionCm: 100,
        lengthCm: 200,
        sowingDate: DateTime(2026, 7, 26),
        status: 'growing',
      );

      final spaces = FreeSpaceEngine.calculateFreeSpaces(
        bedLengthCm: 700,
        plantings: [planting],
      );

      expect(spaces.length, 2);

      expect(spaces[0].startCm, 0);
      expect(spaces[0].lengthCm, 100);

      expect(spaces[1].startCm, 300);
      expect(spaces[1].lengthCm, 400);
    });

    test('calcola gli spazi liberi con due colture', () {
      final plantings = [
        Planting(
          seasonId: 'season-1',
          bedId: 'bed-1',
          cropId: 'crop-1',
          startPositionCm: 100,
          lengthCm: 100,
          sowingDate: DateTime(2026, 7, 26),
          status: 'growing',
        ),
        Planting(
          seasonId: 'season-1',
          bedId: 'bed-1',
          cropId: 'crop-2',
          startPositionCm: 350,
          lengthCm: 150,
          sowingDate: DateTime(2026, 7, 26),
          status: 'growing',
        ),
      ];

      final spaces = FreeSpaceEngine.calculateFreeSpaces(
        bedLengthCm: 700,
        plantings: plantings,
      );

      expect(spaces.length, 3);

      expect(spaces[0].startCm, 0);
      expect(spaces[0].lengthCm, 100);

      expect(spaces[1].startCm, 200);
      expect(spaces[1].lengthCm, 150);

      expect(spaces[2].startCm, 500);
      expect(spaces[2].lengthCm, 200);
    });
  });
  test('non crea spazi liberi tra colture adiacenti', () {
    final plantings = [
      Planting(
        seasonId: 'season-1',
        bedId: 'bed-1',
        cropId: 'crop-1',
        startPositionCm: 100,
        lengthCm: 100,
        sowingDate: DateTime(2026, 7, 26),
        status: 'growing',
      ),
      Planting(
        seasonId: 'season-1',
        bedId: 'bed-1',
        cropId: 'crop-2',
        startPositionCm: 200,
        lengthCm: 100,
        sowingDate: DateTime(2026, 7, 26),
        status: 'growing',
      ),
    ];

    final spaces = FreeSpaceEngine.calculateFreeSpaces(
      bedLengthCm: 700,
      plantings: plantings,
    );

    expect(spaces.length, 2);

    expect(spaces[0].startCm, 0);
    expect(spaces[0].lengthCm, 100);

    expect(spaces[1].startCm, 300);
    expect(spaces[1].lengthCm, 400);
  });
  test('non restituisce spazi se la coltura occupa tutta l\'aiuola', () {
    final planting = Planting(
      seasonId: 'season-1',
      bedId: 'bed-1',
      cropId: 'crop-1',
      startPositionCm: 0,
      lengthCm: 700,
      sowingDate: DateTime(2026, 7, 26),
      status: 'growing',
    );

    final spaces = FreeSpaceEngine.calculateFreeSpaces(
      bedLengthCm: 700,
      plantings: [planting],
    );

    expect(spaces, isEmpty);
  });
  test('ordina automaticamente le colture prima del calcolo', () {
    final plantings = [
      Planting(
        seasonId: 'season-1',
        bedId: 'bed-1',
        cropId: 'crop-2',
        startPositionCm: 350,
        lengthCm: 150,
        sowingDate: DateTime(2026, 7, 26),
        status: 'growing',
      ),
      Planting(
        seasonId: 'season-1',
        bedId: 'bed-1',
        cropId: 'crop-1',
        startPositionCm: 100,
        lengthCm: 100,
        sowingDate: DateTime(2026, 7, 26),
        status: 'growing',
      ),
    ];

    final spaces = FreeSpaceEngine.calculateFreeSpaces(
      bedLengthCm: 700,
      plantings: plantings,
    );

    expect(spaces.length, 3);

    expect(spaces[0].startCm, 0);
    expect(spaces[0].lengthCm, 100);

    expect(spaces[1].startCm, 200);
    expect(spaces[1].lengthCm, 150);

    expect(spaces[2].startCm, 500);
    expect(spaces[2].lengthCm, 200);
  });
}
