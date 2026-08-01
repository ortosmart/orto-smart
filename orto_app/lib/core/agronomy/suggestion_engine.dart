import '../../data/models/crop.dart';
import 'models/free_space.dart';
import 'models/suggestion_candidate.dart';

class SuggestionEngine {
  static List<FreeSpace> suggestSpaces({
    required List<FreeSpace> freeSpaces,
    required int requiredLengthCm,
  }) {
    final compatibleSpaces = freeSpaces
        .where((space) => space.lengthCm >= requiredLengthCm)
        .toList();

    compatibleSpaces.sort((a, b) => a.lengthCm.compareTo(b.lengthCm));

    return compatibleSpaces;
  }

  static List<SuggestionCandidate> generateCandidates({
    required List<FreeSpace> freeSpaces,
    required List<Crop> crops,
  }) {
    final candidates = <SuggestionCandidate>[];

    for (final space in freeSpaces) {
      for (final crop in crops) {
        final spacing = crop.plantSpacingCm;

        // La coltura non ha una distanza definita.
        if (spacing == null || spacing <= 0) {
          continue;
        }

        // Lo spazio è troppo piccolo.
        if (space.lengthCm < spacing) {
          continue;
        }

        final maxPlants = space.lengthCm ~/ spacing;

        candidates.add(
          SuggestionCandidate(
            crop: crop,
            freeSpace: space,
            maxPlants: maxPlants,
            rows: 1,
            availableLengthCm: space.lengthCm,
            requiredLengthCm: maxPlants * spacing,
          ),
        );
      }
    }

    return candidates;
  }
}
