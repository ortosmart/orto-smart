import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/free_space.dart';
import 'package:orto_app/core/agronomy/suggestion_engine.dart';
import 'package:orto_app/data/models/crop.dart';

void main() {
  group('SuggestionEngine', () {
    test('restituisce solo gli spazi sufficientemente lunghi', () {
      final freeSpaces = [
        const FreeSpace(startCm: 0, lengthCm: 100),
        const FreeSpace(startCm: 150, lengthCm: 150),
        const FreeSpace(startCm: 350, lengthCm: 250),
      ];

      final suggestions = SuggestionEngine.suggestSpaces(
        freeSpaces: freeSpaces,
        requiredLengthCm: 120,
      );

      expect(suggestions.length, 2);

      expect(suggestions[0].startCm, 150);
      expect(suggestions[0].lengthCm, 150);

      expect(suggestions[1].startCm, 350);
      expect(suggestions[1].lengthCm, 250);
    });
  });
  test('ordina i suggerimenti dal migliore al meno conveniente', () {
    final freeSpaces = [
      const FreeSpace(startCm: 0, lengthCm: 400),
      const FreeSpace(startCm: 450, lengthCm: 180),
      const FreeSpace(startCm: 650, lengthCm: 250),
    ];

    final suggestions = SuggestionEngine.suggestSpaces(
      freeSpaces: freeSpaces,
      requiredLengthCm: 170,
    );

    expect(suggestions.length, 3);

    expect(suggestions[0].lengthCm, 180);
    expect(suggestions[1].lengthCm, 250);
    expect(suggestions[2].lengthCm, 400);
  });
  group('generateCandidates', () {
    test('genera un candidato quando spazio e coltura sono compatibili', () {
      final freeSpaces = [const FreeSpace(startCm: 0, lengthCm: 240)];

      final crops = [const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40)];

      final candidates = SuggestionEngine.generateCandidates(
        freeSpaces: freeSpaces,
        crops: crops,
      );

      expect(candidates.length, 1);

      expect(candidates.first.crop.name, 'Pomodoro');
      expect(candidates.first.maxPlants, 6);
      expect(candidates.first.rows, 1);
      expect(candidates.first.availableLengthCm, 240);
      expect(candidates.first.requiredLengthCm, 240);
    });
    test('ignora le colture senza distanza tra le piante', () {
      final freeSpaces = [const FreeSpace(startCm: 0, lengthCm: 300)];

      final crops = [const Crop(id: '1', name: 'Basilico')];

      final candidates = SuggestionEngine.generateCandidates(
        freeSpaces: freeSpaces,
        crops: crops,
      );

      expect(candidates, isEmpty);
    });
    test('ignora gli spazi troppo piccoli', () {
      final freeSpaces = [const FreeSpace(startCm: 0, lengthCm: 30)];

      final crops = [const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40)];

      final candidates = SuggestionEngine.generateCandidates(
        freeSpaces: freeSpaces,
        crops: crops,
      );

      expect(candidates, isEmpty);
    });
    test('genera un candidato per ogni combinazione valida', () {
      final freeSpaces = [
        const FreeSpace(startCm: 0, lengthCm: 200),
        const FreeSpace(startCm: 300, lengthCm: 120),
      ];

      final crops = [
        const Crop(id: '1', name: 'Pomodoro', plantSpacingCm: 40),
        const Crop(id: '2', name: 'Lattuga', plantSpacingCm: 30),
      ];

      final candidates = SuggestionEngine.generateCandidates(
        freeSpaces: freeSpaces,
        crops: crops,
      );

      expect(candidates.length, 4);

      expect(candidates[0].crop.name, 'Pomodoro');
      expect(candidates[0].freeSpace.startCm, 0);
      expect(candidates[0].maxPlants, 5);

      expect(candidates[1].crop.name, 'Lattuga');
      expect(candidates[1].freeSpace.startCm, 0);
      expect(candidates[1].maxPlants, 6);

      expect(candidates[2].crop.name, 'Pomodoro');
      expect(candidates[2].freeSpace.startCm, 300);
      expect(candidates[2].maxPlants, 3);

      expect(candidates[3].crop.name, 'Lattuga');
      expect(candidates[3].freeSpace.startCm, 300);
      expect(candidates[3].maxPlants, 4);
    });
  });
}
