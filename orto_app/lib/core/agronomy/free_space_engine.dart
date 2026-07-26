import '../../data/models/planting.dart';
import 'models/free_space.dart';

class FreeSpaceEngine {
  static List<FreeSpace> calculateFreeSpaces({
  required int bedLengthCm,
  required List<Planting> plantings,
}) {
  if (plantings.isEmpty) {
    return [
      FreeSpace(
        startCm: 0,
        lengthCm: bedLengthCm,
      ),
    ];
  }

  final sortedPlantings = [...plantings]
    ..sort((a, b) => a.startPositionCm.compareTo(b.startPositionCm));

  final spaces = <FreeSpace>[];
  var currentPosition = 0;

  for (final planting in sortedPlantings) {
    if (planting.startPositionCm > currentPosition) {
      spaces.add(
        FreeSpace(
          startCm: currentPosition,
          lengthCm: planting.startPositionCm - currentPosition,
        ),
      );
    }

    currentPosition =
        planting.startPositionCm + planting.lengthCm;
  }

  if (currentPosition < bedLengthCm) {
    spaces.add(
      FreeSpace(
        startCm: currentPosition,
        lengthCm: bedLengthCm - currentPosition,
      ),
    );
  }

  return spaces;
}
}