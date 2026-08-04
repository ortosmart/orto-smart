import '../../../services/free_space.dart' as legacy;
import '../models/free_space.dart' as core;

/// Converte gli spazi della precedente architettura
/// nel formato utilizzato dai nuovi motori agronomici.
class FreeSpaceAdapter {
  const FreeSpaceAdapter._();

  static core.FreeSpace fromLegacy(legacy.FreeSpace space) {
    final startCm = space.startCm.round();
    final endCm = space.endCm.round();

    final lengthCm = endCm > startCm ? endCm - startCm : 0;

    return core.FreeSpace(startCm: startCm, lengthCm: lengthCm);
  }

  static List<core.FreeSpace> fromLegacyList(
    Iterable<legacy.FreeSpace> spaces,
  ) {
    return spaces
        .map(fromLegacy)
        .where((space) => space.isValid)
        .toList(growable: false);
  }
}
