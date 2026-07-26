import 'models/free_space.dart';

class SuggestionEngine {
  static List<FreeSpace> suggestSpaces({
    required List<FreeSpace> freeSpaces,
    required int requiredLengthCm,
  }) {
    final compatibleSpaces = freeSpaces
        .where((space) => space.lengthCm >= requiredLengthCm)
        .toList();

    compatibleSpaces.sort(
      (a, b) => a.lengthCm.compareTo(b.lengthCm),
    );

    return compatibleSpaces;
  }
}