import 'package:flutter_test/flutter_test.dart';
import 'package:orto_app/services/agronomic_engine.dart';
import 'package:orto_app/services/occupied_space.dart';

void main() {
  group('AgronomicEngine.calculateOccupiedLength', () {
    test('10 piante a 50 cm occupano 450 cm', () {
      final length = AgronomicEngine.calculateOccupiedLength(
        plants: 10,
        spacingCm: 50,
      );

      expect(length, 450);
    });

    test('Una sola pianta occupa 0 cm', () {
      final length = AgronomicEngine.calculateOccupiedLength(
        plants: 1,
        spacingCm: 50,
      );

      expect(length, 0);
    });

    test('Numero di piante nullo restituisce 0 cm', () {
      final length = AgronomicEngine.calculateOccupiedLength(
        plants: 0,
        spacingCm: 50,
      );

      expect(length, 0);
    });

    test('Distanza negativa restituisce 0 cm', () {
      final length = AgronomicEngine.calculateOccupiedLength(
        plants: 10,
        spacingCm: -50,
      );

      expect(length, 0);
    });
  });

  group('AgronomicEngine.checkSpace', () {
    test('Le piante entrano nello spazio disponibile', () {
      final result = AgronomicEngine.checkSpace(
        availableCm: 500,
        plants: 10,
        spacingCm: 50,
      );

      expect(result.fits, isTrue);
      expect(result.occupiedLengthCm, 450);
      expect(result.availableLengthCm, 500);
      expect(result.freeLengthCm, 50);
    });

    test('Le piante non entrano nello spazio disponibile', () {
      final result = AgronomicEngine.checkSpace(
        availableCm: 400,
        plants: 10,
        spacingCm: 50,
      );

      expect(result.fits, isFalse);
      expect(result.occupiedLengthCm, 450);
      expect(result.availableLengthCm, 400);
      expect(result.freeLengthCm, -50);
      expect(result.message, contains('50.0 cm'));
    });
  });

  group('AgronomicEngine.suggestedSpacing', () {
    test('Calcola la distanza necessaria tra 10 piante in 400 cm', () {
      final spacing = AgronomicEngine.suggestedSpacing(
        availableCm: 400,
        plants: 10,
      );

      expect(spacing, closeTo(44.444, 0.001));
    });

    test('Una sola pianta restituisce distanza 0', () {
      final spacing = AgronomicEngine.suggestedSpacing(
        availableCm: 400,
        plants: 1,
      );

      expect(spacing, 0);
    });
  });

  group('AgronomicEngine.findFreeSpaces', () {
    test('Aiuola completamente libera', () {
      final spaces = AgronomicEngine.findFreeSpaces(
        bedLengthCm: 700,
        occupiedSpaces: [],
      );

      expect(spaces.length, 1);
      expect(spaces.first.startCm, 0);
      expect(spaces.first.endCm, 700);
      expect(spaces.first.lengthCm, 700);
    });

    test('Tre colture presenti', () {
      final spaces = AgronomicEngine.findFreeSpaces(
        bedLengthCm: 700,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 180),
          OccupiedSpace(startCm: 250, endCm: 350),
          OccupiedSpace(startCm: 450, endCm: 600),
        ],
      );

      expect(spaces.length, 3);

      expect(spaces[0].startCm, 180);
      expect(spaces[0].endCm, 250);

      expect(spaces[1].startCm, 350);
      expect(spaces[1].endCm, 450);

      expect(spaces[2].startCm, 600);
      expect(spaces[2].endCm, 700);
    });

    test('Gli intervalli sovrapposti vengono uniti', () {
      final spaces = AgronomicEngine.findFreeSpaces(
        bedLengthCm: 700,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 180),
          OccupiedSpace(startCm: 150, endCm: 250),
          OccupiedSpace(startCm: 400, endCm: 500),
        ],
      );

      expect(spaces.length, 2);

      expect(spaces[0].startCm, 250);
      expect(spaces[0].endCm, 400);

      expect(spaces[1].startCm, 500);
      expect(spaces[1].endCm, 700);
    });

    test('Gli intervalli fuori dai confini vengono limitati', () {
      final spaces = AgronomicEngine.findFreeSpaces(
        bedLengthCm: 700,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 100),
          OccupiedSpace(startCm: 650, endCm: 800),
        ],
      );

      expect(spaces.length, 1);
      expect(spaces.first.startCm, 100);
      expect(spaces.first.endCm, 650);
    });

    test('Aiuola completamente occupata', () {
      final spaces = AgronomicEngine.findFreeSpaces(
        bedLengthCm: 700,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 700),
        ],
      );

      expect(spaces, isEmpty);
    });
  });

  group('AgronomicEngine.firstSuitableSpace', () {
    test('Trova il primo spazio abbastanza grande', () {
      final space = AgronomicEngine.firstSuitableSpace(
        bedLengthCm: 700,
        requiredLengthCm: 80,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 180),
          OccupiedSpace(startCm: 250, endCm: 350),
          OccupiedSpace(startCm: 450, endCm: 600),
        ],
      );

      expect(space, isNotNull);
      expect(space!.startCm, 350);
      expect(space.endCm, 450);
      expect(space.lengthCm, 100);
    });

    test('Restituisce null se nessuno spazio è sufficiente', () {
      final space = AgronomicEngine.firstSuitableSpace(
        bedLengthCm: 700,
        requiredLengthCm: 150,
        occupiedSpaces: const [
          OccupiedSpace(startCm: 0, endCm: 180),
          OccupiedSpace(startCm: 250, endCm: 350),
          OccupiedSpace(startCm: 450, endCm: 600),
        ],
      );

      expect(space, isNull);
    });

    test('Aiuola libera restituisce tutto lo spazio', () {
      final space = AgronomicEngine.firstSuitableSpace(
        bedLengthCm: 700,
        requiredLengthCm: 300,
        occupiedSpaces: [],
      );

      expect(space, isNotNull);
      expect(space!.startCm, 0);
      expect(space.endCm, 700);
    });
  });
}