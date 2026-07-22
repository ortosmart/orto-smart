import 'free_space.dart';
import 'occupied_space.dart';
import 'space_check_result.dart';

class AgronomicEngine {
  /// Calcola la lunghezza occupata da un gruppo di piante.
  ///
  /// Esempio:
  /// 10 piante distanti 50 cm occupano 450 cm:
  /// (10 - 1) × 50
  static double calculateOccupiedLength({
    required int plants,
    required double spacingCm,
  }) {
    if (plants <= 1) {
      return 0;
    }

    if (spacingCm < 0) {
      return 0;
    }

    return (plants - 1) * spacingCm;
  }

  /// Verifica se il numero di piante entra nello spazio disponibile.
  static SpaceCheckResult checkSpace({
    required double availableCm,
    required int plants,
    required double spacingCm,
  }) {
    if (availableCm < 0) {
      return const SpaceCheckResult(
        fits: false,
        occupiedLengthCm: 0,
        availableLengthCm: 0,
        freeLengthCm: 0,
        message: 'Lo spazio disponibile non può essere negativo.',
      );
    }

    if (plants <= 0) {
      return SpaceCheckResult(
        fits: false,
        occupiedLengthCm: 0,
        availableLengthCm: availableCm,
        freeLengthCm: availableCm,
        message: 'Il numero di piante deve essere maggiore di zero.',
      );
    }

    if (spacingCm < 0) {
      return SpaceCheckResult(
        fits: false,
        occupiedLengthCm: 0,
        availableLengthCm: availableCm,
        freeLengthCm: availableCm,
        message: 'La distanza tra le piante non può essere negativa.',
      );
    }

    final occupiedLengthCm = calculateOccupiedLength(
      plants: plants,
      spacingCm: spacingCm,
    );

    final freeLengthCm = availableCm - occupiedLengthCm;
    final fits = freeLengthCm >= 0;

    if (fits) {
      return SpaceCheckResult(
        fits: true,
        occupiedLengthCm: occupiedLengthCm,
        availableLengthCm: availableCm,
        freeLengthCm: freeLengthCm,
        message: 'Le piante entrano nello spazio disponibile.',
      );
    }

    return SpaceCheckResult(
      fits: false,
      occupiedLengthCm: occupiedLengthCm,
      availableLengthCm: availableCm,
      freeLengthCm: freeLengthCm,
      message:
          'Le piante non entrano. Servono ${freeLengthCm.abs().toStringAsFixed(1)} cm aggiuntivi.',
    );
  }

  /// Suggerisce la distanza necessaria tra le piante per occupare
  /// esattamente lo spazio disponibile.
  static double suggestedSpacing({
    required double availableCm,
    required int plants,
  }) {
    if (availableCm <= 0 || plants <= 1) {
      return 0;
    }

    return availableCm / (plants - 1);
  }

  /// Restituisce tutti gli spazi liberi presenti nell'aiuola.
  ///
  /// Gli intervalli occupati:
  /// - vengono ordinati;
  /// - vengono limitati entro i confini dell'aiuola;
  /// - vengono uniti quando si sovrappongono.
  static List<FreeSpace> findFreeSpaces({
    required double bedLengthCm,
    required List<OccupiedSpace> occupiedSpaces,
  }) {
    if (bedLengthCm <= 0) {
      return const [];
    }

    final validSpaces = occupiedSpaces
        .where((space) => space.isValid)
        .map(
          (space) => OccupiedSpace(
            startCm: space.startCm.clamp(0, bedLengthCm).toDouble(),
            endCm: space.endCm.clamp(0, bedLengthCm).toDouble(),
          ),
        )
        .where((space) => space.endCm > space.startCm)
        .toList()
      ..sort((a, b) => a.startCm.compareTo(b.startCm));

    if (validSpaces.isEmpty) {
      return [
        FreeSpace(
          startCm: 0,
          endCm: bedLengthCm,
        ),
      ];
    }

    final mergedSpaces = <OccupiedSpace>[];

    for (final currentSpace in validSpaces) {
      if (mergedSpaces.isEmpty) {
        mergedSpaces.add(currentSpace);
        continue;
      }

      final lastSpace = mergedSpaces.last;

      if (currentSpace.startCm <= lastSpace.endCm) {
        mergedSpaces[mergedSpaces.length - 1] = OccupiedSpace(
          startCm: lastSpace.startCm,
          endCm: currentSpace.endCm > lastSpace.endCm
              ? currentSpace.endCm
              : lastSpace.endCm,
        );
      } else {
        mergedSpaces.add(currentSpace);
      }
    }

    final freeSpaces = <FreeSpace>[];
    var cursorCm = 0.0;

    for (final occupiedSpace in mergedSpaces) {
      if (occupiedSpace.startCm > cursorCm) {
        freeSpaces.add(
          FreeSpace(
            startCm: cursorCm,
            endCm: occupiedSpace.startCm,
          ),
        );
      }

      cursorCm = occupiedSpace.endCm;
    }

    if (cursorCm < bedLengthCm) {
      freeSpaces.add(
        FreeSpace(
          startCm: cursorCm,
          endCm: bedLengthCm,
        ),
      );
    }

    return freeSpaces;
  }

  /// Restituisce il primo spazio libero abbastanza grande
  /// per contenere la lunghezza richiesta.
  static FreeSpace? firstSuitableSpace({
    required double bedLengthCm,
    required double requiredLengthCm,
    required List<OccupiedSpace> occupiedSpaces,
  }) {
    if (requiredLengthCm < 0) {
      return null;
    }

    final freeSpaces = findFreeSpaces(
      bedLengthCm: bedLengthCm,
      occupiedSpaces: occupiedSpaces,
    );

    for (final freeSpace in freeSpaces) {
      if (freeSpace.lengthCm >= requiredLengthCm) {
        return freeSpace;
      }
    }

    return null;
  }
}