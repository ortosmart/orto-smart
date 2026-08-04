import 'package:flutter_test/flutter_test.dart';

import 'package:orto_app/core/agronomy/adapters/free_space_adapter.dart';
import 'package:orto_app/services/free_space.dart' as legacy;

void main() {
  group('FreeSpaceAdapter', () {
    test('converte uno spazio legacy nel modello core', () {
      const legacySpace = legacy.FreeSpace(startCm: 10.4, endCm: 210.6);

      final result = FreeSpaceAdapter.fromLegacy(legacySpace);

      expect(result.startCm, 10);
      expect(result.lengthCm, 201);
      expect(result.endCm, 211);
      expect(result.isValid, isTrue);
    });

    test('esclude gli spazi non validi dalla conversione di una lista', () {
      const legacySpaces = [
        legacy.FreeSpace(startCm: 0, endCm: 100),
        legacy.FreeSpace(startCm: 200, endCm: 200),
        legacy.FreeSpace(startCm: 350, endCm: 300),
      ];

      final results = FreeSpaceAdapter.fromLegacyList(legacySpaces);

      expect(results.length, 1);
      expect(results.first.startCm, 0);
      expect(results.first.lengthCm, 100);
    });
  });
}
