import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/models/free_space.dart';
import 'package:orto_app/core/agronomy/suggestion_engine.dart';

void main() {
  group('SuggestionEngine', () {
    test('restituisce solo gli spazi sufficientemente lunghi', () {
      final freeSpaces = [
        const FreeSpace(
          startCm: 0,
          lengthCm: 100,
        ),
        const FreeSpace(
          startCm: 150,
          lengthCm: 150,
        ),
        const FreeSpace(
          startCm: 350,
          lengthCm: 250,
        ),
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
    const FreeSpace(
      startCm: 0,
      lengthCm: 400,
    ),
    const FreeSpace(
      startCm: 450,
      lengthCm: 180,
    ),
    const FreeSpace(
      startCm: 650,
      lengthCm: 250,
    ),
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
}